//
//  WaitForTheFirstBehaviorDemo.swift
//  StructuredConcurrencyDemoTests
//
//  Created by Chiaote Ni on 2024/1/23.
//

import XCTest
@testable import StructuredConcurrencyDemo

final class WaitForTheFirstBehaviorDemo: XCTestCase {

    func testWaitForFirst() async throws {
        let task1 = makeTask(value: 1, sleepInNanoseconds: 3_000_000_000)
        let task2 = makeTask(value: 2, sleepInNanoseconds: 1_000_000_000)

        let result = try await [task1, task2].waitForFirstResult()
        XCTAssertEqual(result, 2)
    }

    func testWaitForFirstCancel() async throws {
        let task1 = makeTask(value: 1, sleepInNanoseconds: 3_000_000_000)
        let task2 = makeTask(value: 2, sleepInNanoseconds: 1_000_000_000)

        task2.cancel()
        do {
            _ = try await [task1, task2].waitForFirstResult()
            throw DemoError(description: "The expected error did not occur")
        } catch {
            print("Expected error did catched")
        }
    }
}

// MARK: - Private functions
extension WaitForTheFirstBehaviorDemo {

    private func makeTask(
        value: Int,
        sleepInNanoseconds: UInt64
    ) -> Task<Int, Error> {
        Task {
            try await Task.sleep(nanoseconds: sleepInNanoseconds)
            return value
        }
    }
}
