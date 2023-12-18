import UIKit

/*
 This is a similar case of our Part IV demonstration `ImageDownloaderWithAsyncSequenceDemo`, but focuses on different aspects.
 In this demonstration, we don't care about the progress anymore, instead, we focus on how to limit the number of executing jobs
*/
final class ImageDownloader {

    typealias DownloadTask = Task<UIImage, Error>

    private let semephore = AsyncSemaphore(resourceCount: 3)

    func downlaodImage(with url: URL) -> DownloadTask {
        return DownloadTask {
            await semephore.wait()
            try Task.checkCancellation()
            print("🎉 \(url) start")
            let result = try await download(with: url)
            print("🎉 \(url) success")
            await semephore.signal()
            return result
        }
    }

    private func download(with url: URL) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return UIImage()
    }
}

let imageDownload = ImageDownloader()
let tasks = Array(0...9)
    .compactMap { URL(string: "file:/www.iOSTaipei.demonstration_\($0)") }
    .map { imageDownload.downlaodImage(with: $0) }

for task in tasks {
    do {
        let result = try await task.value
    } catch {
        print(error.localizedDescription)
        throw error
    }
}
