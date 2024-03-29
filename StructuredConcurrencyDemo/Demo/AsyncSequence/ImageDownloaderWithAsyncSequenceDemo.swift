//
//  ImageDownloaderWithAsyncSequenceDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/3/26.
//

import UIKit
import Combine

// MARK: - Demo 5. Implement a simple image downloader with the asyncStream
/*
 We will start with a simple image downloader that only includes features for callbacks to track progress and download the image.
 - 1st step: refactor the interface to use AsyncSequence as an alternative to using callback closures.
 - 2nd step: check what will happen when starting to handle duplicated downloading tasks.
 - 3rd step: enable the ability to handle duplicated downloading tasks for the same URL correctly, and use an actor to handle potential data racing issues.
 Then we can discuss potentially dangerous cases involving the actor and await.
 - 4th step: switch to using an AsyncChannel or another custom AsyncSequence that you have created.
 - 5th step: switch to using the newest API, which was released in Swift 5.9, `makeStream` to simplify the implementation.

 **You can go through these steps by checking out to each commit.**

 The following is designed to demonstrate the behavior of AsyncStream.
 Since potentially dangerous cases can arise due to await in this use case, please consider using a lock to access caches in a production app
*/

typealias TaskStatusStream = AsyncThrowingStream<RemoteImageLoader.TaskStatus, any Error>

final class DownloadTask {
    let stream: TaskStatusStream
    var task: URLSessionDataTask?
    let subscribers: Set<AnyCancellable>?

    init(
        stream: TaskStatusStream,
        task: URLSessionDataTask? = nil,
        subscribers: Set<AnyCancellable>? = nil
    ) {
        self.stream = stream
        self.task = task
        self.subscribers = subscribers
    }
}

// For testing purpose
protocol ImageDataDecoding: Sendable {
    func decode(data: Data) -> UIImage?
}

actor RemoteImageLoader {

    enum TaskStatus {
        case downloading(_ progress: Float)
        case finished(UIImage)
    }

    private class ImageDataDecoder: ImageDataDecoding {
        func decode(data: Data) -> UIImage? {
            guard !data.isEmpty else { return nil }
            return UIImage(data: data)
        }
    }

    private class Cache {
        let dataTask: URLSessionDataTask
        var continuations: [TaskStatusStream.Continuation]

        init(
            dataTask: URLSessionDataTask,
            continuation: TaskStatusStream.Continuation
        ) {
            self.dataTask = dataTask
            self.continuations = [continuation]
        }
    }

    private class CacheStore {
        private var caches: [URL: Cache] = [:]

        func add(_ newCache: Cache, with url: URL) {
            if let cache = caches[url] {
                cache.continuations.append(contentsOf: newCache.continuations)
            } else {
                caches[url] = newCache
            }
        }

        func getCache(with url: URL) -> Cache? {
            caches[url]
        }
    }

    private let session: URLSession
    private let decoder: ImageDataDecoding
    private var cacheStore: CacheStore = CacheStore()

    init(
        session: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil),
        dataDecoder: ImageDataDecoding = ImageDataDecoder()
    ) {
        self.session = session
        self.decoder = dataDecoder
    }

    func loadImage(with url: URL) async -> DownloadTask {
        let (stream, continuation) = TaskStatusStream.makeStream()

        if let cache = cacheStore.getCache(with: url) {
            let newCache = Cache(dataTask: cache.dataTask, continuation: continuation)
            cacheStore.add(newCache, with: url)

            let downloadTask = DownloadTask(stream: stream, task: cache.dataTask)
            return downloadTask
        }

        let request: URLRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        let dataTask = session.dataTask(with: request) { data, response, error in
            Task { [weak self] in
                guard
                    let self = self,
                    let cache = await self.cacheStore.getCache(with: url)
                else {
                    assertionFailure("No cache is found")
                    return
                }

                if let data = data,
                   let image = self.decoder.decode(data: data) {
                    await self.traverseStreams(from: cache) { continuation in
                        continuation.yield(.finished(image))
                        continuation.finish()
                    }
                } else if let error = error {
                    await self.traverseStreams(from: cache) { continuation in
                        continuation.finish(throwing: error)
                    }
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let error: NSError = .init(
                        domain: url.absoluteString,
                        code: code,
                        userInfo: [NSLocalizedDescriptionKey: "fetch data fail"]
                    )
                    await self.traverseStreams(from: cache) { continuation in
                        continuation.finish(throwing: error)
                    }
                }
            }
        }

        var subscribers: Set<AnyCancellable> = Set()
        dataTask.progress
            .publisher(for: \Progress.completedUnitCount)
            .sink { value in
                Task { [weak self] in
                    guard
                        let self = self,
                        let cache = await self.cacheStore.getCache(with: url)
                    else {
                        return
                    }
                    let progress = Float(value) / Float(dataTask.progress.totalUnitCount)
                    await self.traverseStreams(from: cache) { continuation in
                        continuation.yield(.downloading(progress))
                    }
                }
            }.store(in: &subscribers)

        let cache = Cache(dataTask: dataTask, continuation: continuation)
        cacheStore.add(cache, with: url)

        let downloadTask = DownloadTask(stream: stream, task: dataTask, subscribers: subscribers)
        return downloadTask
    }
}

extension RemoteImageLoader {

    private func traverseStreams(
        from cache: Cache,
        then handler: (TaskStatusStream.Continuation) async -> Void
    ) async {
        for continuation in cache.continuations {
            await handler(continuation)
        }
    }
}
