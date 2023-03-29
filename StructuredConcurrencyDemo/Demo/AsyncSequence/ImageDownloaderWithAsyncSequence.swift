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

struct DownloadTask {
    let stream: AsyncThrowingStream<RemoteImageLoader.TaskStatus, Error>
    var task: URLSessionDataTask?
    let subscribers: Set<AnyCancellable>
}

// For testing purpose
protocol ImageDataDecoding {
    func decode(data: Data) -> UIImage?
}

final class RemoteImageLoader {

    enum TaskStatus {
        case downloading(_ progress: Float)
        case finished(UIImage)
    }

    class ImageDataDecoder: ImageDataDecoding {
        func decode(data: Data) -> UIImage? {
            guard !data.isEmpty else { return nil }
            return UIImage(data: data)
        }
    }

    private let session: URLSession
    private let decoder: ImageDataDecoding
    private var caches: [URL: DownloadTask] = [:]

    init(
        session: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil),
        dataDecoder: ImageDataDecoding = ImageDataDecoder()
    ) {
        self.session = session
        self.decoder = dataDecoder
    }

    func loadImage(with url: URL) -> DownloadTask {
        var task: URLSessionDataTask?
        var subscribers: Set<AnyCancellable> = Set()
        let stream = AsyncThrowingStream { continuation in
            let request: URLRequest = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalCacheData,
                timeoutInterval: 30
            )
            let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
                if let data = data,
                   let self = self,
                   let image = self.decoder.decode(data: data) {
                    continuation.yield(TaskStatus.finished(image))
                    continuation.finish()
                } else if let error = error {
                    continuation.finish(throwing: error)
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let error: NSError = .init(
                        domain: url.absoluteString,
                        code: code,
                        userInfo: [NSLocalizedDescriptionKey: "fetch data fail"]
                    )
                    continuation.finish(throwing: error)
                }
            }
            dataTask.progress.publisher(for: \.completedUnitCount).sink { value in
                let progress = Float(value) / Float(dataTask.progress.totalUnitCount)
                continuation.yield(TaskStatus.downloading(progress))
            }.store(in: &subscribers)
            task = dataTask
        }
        return DownloadTask(stream: stream, task: task, subscribers: subscribers)
    }
}


