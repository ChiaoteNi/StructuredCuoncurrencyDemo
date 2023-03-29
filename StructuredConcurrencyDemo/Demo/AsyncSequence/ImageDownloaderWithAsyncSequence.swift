//
//  ImageDownloaderWithAsyncSequence.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/3/26.
//

import UIKit

// MARK: - Demo 5. Implement a simple image downloader with the asyncStream
/*
 We will start with a simple image downloader that only includes features for callbacks to track progress and download the image.
 - 1st step: refactor the interface to use AsyncSequence as an alternative to using callback closures.
 - 2nd step: check what will happen when starting to handle duplicated downloading tasks.
 - 3rd step: enable the ability to handle duplicated downloading tasks for the same URL correctly, and use an actor to handle potential data racing issues.
 - 4th step: discuss potentially dangerous cases involving the actor and await.

 **You can go through these steps by checking out to each commit.**

 The following is designed to demonstrate the behavior of AsyncStream.
 Since potentially dangerous cases can arise due to await in this use case, please consider using a lock to access caches in a production app
*/

final class ImageDownloadTask {

    var dataTask: URLSessionDataTask
    fileprivate var observation: NSKeyValueObservation?

    deinit {
        observation?.invalidate()
        observation = nil
    }

    init(with dataTask: URLSessionDataTask, progressObservation: NSKeyValueObservation) {
        self.dataTask = dataTask
        self.observation = progressObservation
    }

    func execute() -> Void {
        dataTask.resume()
    }

    func cancel() {
        dataTask.cancel()
    }
}

// For testing purpose
protocol ImageDataDecoding {
    func decode(data: Data) -> UIImage?
}

final class RemoteImageLoader {

    class ImageDataDecoder: ImageDataDecoding {
        func decode(data: Data) -> UIImage? {
            guard !data.isEmpty else { return nil }
            return UIImage(data: data)
        }
    }

    private let session: URLSession
    private let decoder: ImageDataDecoding

    init(
        session: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil),
        dataDecoder: ImageDataDecoding = ImageDataDecoder()
    ) {
        self.session = session
        self.decoder = dataDecoder
    }

    func loadImage(
        with url: URL,
        progressHandler: @escaping (Double) -> Void,
        then handler: @escaping (Result<UIImage, Error>) -> Void
    ) -> ImageDownloadTask {

        let request: URLRequest = .init(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let data = data,
               let image = self?.decoder.decode(data: data) {
                handler(.success(image))
            } else if let error = error {
                handler(.failure(error))
            } else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                let error: NSError = .init(
                    domain: url.absoluteString,
                    code: code,
                    userInfo: [NSLocalizedDescriptionKey: "fetch data fail"]
                )
                handler(.failure(error))
            }
        }

        let observation = task.progress.observe(
            \.fractionCompleted,
             options: .new
        ) { progressObj, newValue in
            progressHandler(Double(progressObj.fractionCompleted))
        }

        return ImageDownloadTask(with: task, progressObservation: observation)
    }
}


