//
//  ResourceDownloader.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/31.
//

import Foundation

final class IconService: ResourceService, Sendable {
    var description: String { "icons" }
    func fetchResource() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
final class VideoService: ResourceService, Sendable {
    var description: String { "videos" }
    func fetchResource() async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }
}
final class FontService: ResourceService, Sendable {
    var description: String { "fonts" }
    func fetchResource() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
final class StickerService: ResourceService, Sendable {
    var description: String { "stickers" }
    func fetchResource() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
    }
}

