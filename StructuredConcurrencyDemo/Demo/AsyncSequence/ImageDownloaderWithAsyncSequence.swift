//
//  ImageDownloaderWithAsyncSequence.swift
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

 **You can go through these steps by checking out to each commit.**

 The following is designed to demonstrate the behavior of AsyncStream.
 Since potentially dangerous cases can arise due to await in this use case, please consider using a lock to access caches in a production app
*/

final class DownloadTask {
    let stream: AsyncThrowingStream<RemoteImageLoader.TaskStatus, Error>
    var task: URLSessionDataTask?
    let subscribers: Set<AnyCancellable>?

    init(
        stream: AsyncThrowingStream<RemoteImageLoader.TaskStatus, Error>,
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

    typealias StreamContinuation = AsyncThrowingStream<TaskStatus, Error>.Continuation

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
        var continuations: [StreamContinuation]

        init(
            dataTask: URLSessionDataTask,
            continuation: StreamContinuation
        ) {
            self.dataTask = dataTask
            self.continuations = [continuation]
        }
    }

    private actor CacheStore {
        private var caches: [URL: Cache] = [:]

        func add(_ cache: Cache, with url: URL) {
            caches[url] = cache
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
        if let cache = await cacheStore.getCache(with: url) {
            var cacheContinuation: StreamContinuation?
            let stream = AsyncThrowingStream<TaskStatus, Error> { continuation in
                cacheContinuation = continuation
            }
            if let cacheContinuation = cacheContinuation {
                cache.continuations.append(cacheContinuation)
            } else {
                assertionFailure("🎆")
            }
            let downloadTask = DownloadTask(stream: stream, task: cache.dataTask)
            return downloadTask
        }

        var task: URLSessionDataTask?
        var cacheContinuation: StreamContinuation?
        var subscribers: Set<AnyCancellable> = Set()
        // You can see the document says that AsyncStream is well-suited to adapt callback- or delegation-based APIs to participate with async-await.
        // However, achieving the same outcome using AsyncStream may be more challenging than using delegates and callbacks,
        // unless you keep the continuations and update all of the AsyncThrowingStream with them.
        let stream = AsyncThrowingStream { continuation in
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
                        return
                    }

                    if let data = data,
                       let image = self.decoder.decode(data: data) {
                        cache.continuations.forEach { continuation in
                            continuation.yield(TaskStatus.finished(image))
                            continuation.finish()
                        }
                    } else if let error = error {
                        cache.continuations.forEach { continuation in
                            continuation.finish(throwing: error)
                        }
                    } else {
                        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                        let error: NSError = .init(
                            domain: url.absoluteString,
                            code: code,
                            userInfo: [NSLocalizedDescriptionKey: "fetch data fail"]
                        )
                        cache.continuations.forEach { continuation in
                            continuation.finish(throwing: error)
                        }
                    }
                }
            }
            dataTask.progress
                .publisher(for: \.completedUnitCount)
                .sink { value in
                    Task { [weak self] in
                        guard let cache = await self?.cacheStore.getCache(with: url) else {
                            return
                        }
                        let progress = Float(value) / Float(dataTask.progress.totalUnitCount)
                        cache.continuations.forEach {
                            $0.yield(TaskStatus.downloading(progress))
                        }
                    }
                }.store(in: &subscribers)

            task = dataTask
            cacheContinuation = continuation
        }
        let downloadTask = DownloadTask(stream: stream, task: task, subscribers: subscribers)

        if let task = task, let cacheContinuation = cacheContinuation {
            let cache = Cache(dataTask: task, continuation: cacheContinuation)
            await self.cacheStore.add(cache, with: url)
        } else {
            assertionFailure("🎆")
        }
        return downloadTask
    }
}
