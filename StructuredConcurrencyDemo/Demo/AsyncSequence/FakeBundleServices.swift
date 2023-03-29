//
//  FakeBundleServices.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/3/26.
//

import Foundation

// This is a fake bundle model used to simulate the download result for demo purposes
struct ResourceBundle {
    let name: String
}

// These are fake services that simulate downloading resources.
// All of them are with two kinds of functions, with and without throwing error.
// Therefore, we can demo both the AsyncThrowingStream and AsyncStream, or use rethrow on some of our functions.

protocol BundleService: Sendable {
    var description: String { get }
   func fetchBundle() async -> ResourceBundle
   func fetchBundleWithThrowingError() async throws -> ResourceBundle
}

final class IconBundleService: BundleService, Sendable {
    var description: String { "icons" }

    func fetchBundle() async -> ResourceBundle {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        return ResourceBundle(name: "icons")
    }

    func fetchBundleWithThrowingError() async throws -> ResourceBundle {
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return ResourceBundle(name: "icons")
    }
}

final class VideoBundleService: BundleService, Sendable {
    var description: String { "videos" }

    func fetchBundle() async -> ResourceBundle {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return ResourceBundle(name: "videos")
    }

    func fetchBundleWithThrowingError() async throws -> ResourceBundle {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return ResourceBundle(name: "videos")
    }
}

final class FontBundleService: BundleService, Sendable {
    var description: String { "fonts" }

    func fetchBundle() async -> ResourceBundle {
        try? await Task.sleep(nanoseconds: 500_000_000)
        return ResourceBundle(name: "fonts")
    }

    func fetchBundleWithThrowingError() async throws -> ResourceBundle {
        try await Task.sleep(nanoseconds: 500_000_000)
        return ResourceBundle(name: "fonts")
    }
}

final class StickerBundleService: BundleService, Sendable {
    var description: String { "stickers" }

    func fetchBundle() async -> ResourceBundle {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return ResourceBundle(name: "stickers")
    }

    func fetchBundleWithThrowingError() async throws -> ResourceBundle {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return ResourceBundle(name: "stickers")
    }
}

