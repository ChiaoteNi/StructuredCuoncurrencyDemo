//
//  AsyncSequenceDemoTest.swift
//  AsyncSequenceDemo
//
//  Created by Chiaote Ni on 2023/3/28.
//

import XCTest
@testable import StructuredConcurrencyDemo

final class AsyncSequenceDemoTest: XCTestCase {

    func testDemo1AsyncMapForSequence() async throws {
        let seeds: [BundleService] = [
            VideoBundleService(), // 2 sec.
            StickerBundleService(), // 1.5 sec.
            IconBundleService(), // 3 sec.
        ]
        let expectedResults = ["videos", "stickers", "icons"]

        // Solution 1
        var results = await seeds
            .asyncMap({ service in
                await service.fetchBundle()
            })
            .map { $0.name }

        XCTAssertEqual(results, expectedResults)

        // Solution 2
        results = try await seeds
            .sendableElementsAsyncMap({ service in
                await service.fetchBundle()
            })
            .map { $0.name }

        XCTAssertEqual(results, expectedResults)

        // Solution 3
        results = await seeds
            .sendableResultsAsyncMap({ service in
                await service.fetchBundle()
            })
            .map { $0.name }

        XCTAssertNotEqual(results, expectedResults)
    }

    func testDemo2CustomAsyncSequence() async throws {
        let seeds: [BundleService] = [
            FontBundleService(), // 0.5 sec.
            VideoBundleService(), // 2 sec.
            StickerBundleService(), // 1.5 sec.
            IconBundleService(), // 3 sec.
        ]
        let tasks = MyAsyncSequence(base: seeds) { service in
            await service.fetchBundle()
        }

        for try await bundle in tasks {
            // You can do something here such as updating the downloading progress
            print(bundle.name)
        }

        // Or get all the results with reduce
        let bundles = try await tasks
            .reduce(into: [ResourceBundle]()) { partialResult, bundle in
                partialResult.append(bundle)
            }

        let results = bundles.map { $0.name }
        XCTAssertEqual(results, ["fonts", "videos", "stickers", "icons"])
    }

    // This case is just to execute the demo function to see the logs
    func testExecutingDemo3() async throws {
        let demo = AsyncSequenceDemo()
        await demo.asyncStreamDemo()
        await demo.asyncStreamThrowingDemo()
        await demo.cancelToTriggerOnTerminationDemo()
    }

}
