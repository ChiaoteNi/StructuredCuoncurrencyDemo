import UIKit

/*
 This is a similar case of our Part IV demonstration `ImageDownloaderWithAsyncSequenceDemo`, but focuses on different aspects.
 In this demonstration, we don't care about the progress anymore, instead, we focus on how to limit the number of executing jobs
*/
final class ImageDownloader {

    typealias DownloadTask = Task<UIImage, Error>

    func downlaodImage(with url: URL) -> DownloadTask {
        return DownloadTask { @LimitedExecutingActor in
            print("🎉 \(url) start")
            try Task.checkCancellation()
            let result = try await download(with: url)
            print("🎉 \(url) success")
            return result
        }
    }

    private func download(with url: URL) async throws -> UIImage {
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
