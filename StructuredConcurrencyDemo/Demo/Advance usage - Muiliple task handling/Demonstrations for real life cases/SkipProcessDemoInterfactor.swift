//
//  SkipProcessDemoInterfactor.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/21.
//

import UIKit

enum SkipProcessDemoState {
    case idle
    case processing
    case finish
    case processCanceled
}

protocol SkipProcessDemoStateStoring: AnyObject {
    func updateState(_ state: SkipProcessDemoState) async
    func showLoading() async
    func hideLoading() async
}

final class SkipProcessDemoInterfactor {
    
    weak var stateStore: SkipProcessDemoStateStoring?

//    // Version 1:
//    private var currenTask: Task<UIImage, Error>? {
//        didSet { oldValue?.cancel() }
//    }
//
//    func startProcess() async {
//        await stateStore?.updateState(.processing)
//        await stateStore?.showLoading()
//
//        let task = Task {
//            let sourceImageURLs = Array(0...5).compactMap {
//                URL(string: "assets://localBundle/asset_\($0).png")
//            }
//            let tasks = sourceImageURLs.map { generateImage(with: $0) }
//            let images = try await tasks.waitForAllResultByGroupWithOder()
//            return try await composeImages(images)
//        }
//        currenTask = task
//
//        do {
//            let result = try await task.value
//            await stateStore?.updateState(.finish)
//            print("🎉 Process finish!", result)
//        } catch {
//            print("💥 Process is canceled, Error:", error)
//            await stateStore?.updateState(.processCanceled)
//        }
//
//        await stateStore?.hideLoading()
//    }
//
//    func cancelProcess() {
//        currenTask?.cancel()
//    }

    // Version 2:
    var skipContinuation: CheckedContinuation<UIImage, Error>?

    func startProcess() async {
            await stateStore?.updateState(.processing)
            await stateStore?.showLoading()

            let mainFlowTask = Task {
                let sourceImageURLs = Array(0...0).compactMap {
                    URL(string: "assets://localBundle/asset_\($0).png")
                }
                let tasks = sourceImageURLs.map {
                    generateImage(with: $0)
                }
                let images = try await tasks.waitForOrderedTaskGroupResults()
                return try await composeImages(images)
            }

            let skipTask = Task<UIImage, Error> {
                do {
                    _ = try await withCheckedThrowingContinuation { continuation in
                        skipContinuation = continuation
                    }
                } catch {
                    print("💥 cancel")
                    throw error
                }
                return UIImage()
            }

            do {
                let result = try await [mainFlowTask, skipTask].waitForFirstResult()
                await stateStore?.updateState(.finish)
                await stateStore?.hideLoading()
                print("🎉 Process finish!", result)
            } catch {
                print("💥 Process is canceled, Error:", error)
                await stateStore?.hideLoading()
                await stateStore?.updateState(.processCanceled)
            }
    }

    func cancelProcess() {
        skipContinuation?.resume(throwing: CancellationError())
        skipContinuation = nil
    }
}

// MARK: - Private functions
extension  SkipProcessDemoInterfactor {

    private func composeImages(_ images: [UIImage]) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 100_000_000)
        return UIImage()
    }

    private func generateImage(with url: URL) -> Task<UIImage, Error> {
        Task {
            try Task.checkCancellation()
            let image = try await fetchRawImage(with: url)
            print("fetchRawImage", url.lastPathComponent)

            try Task.checkCancellation()
            let filteredImage = try await applyFilter(to: image)
            print("applyFilter", url.lastPathComponent)

            try Task.checkCancellation()
            let effectedImage = try await applyEffects(to: filteredImage)
            print("applyEffects", url.lastPathComponent)

            try Task.checkCancellation()
            let borderedImage = try await applyTextureBorders(to: effectedImage)
            print("applyTextureBorders", url.lastPathComponent)

            try Task.checkCancellation()
            let processedImage = try await processWithAI(to: borderedImage)
            print("processWithAI", url.lastPathComponent)

            try Task.checkCancellation()
            return processedImage
        }
    }

    private func fetchRawImage(with url: URL) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return UIImage()
    }

    private func applyFilter(to image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 100_000_000)
        return image
    }

    private func applyEffects(to image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 500_000_000)
        return image
    }

    private func applyTextureBorders(to image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return image
    }

    private func processWithAI(to image: UIImage) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 5_000_000_000)
        return image
    }
}
