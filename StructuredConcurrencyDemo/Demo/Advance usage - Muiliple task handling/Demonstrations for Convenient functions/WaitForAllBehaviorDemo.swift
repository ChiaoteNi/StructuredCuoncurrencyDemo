//
//  WaitForAllBehaviorDemo.swift
//  StructuredConcurrencyDemoTests
//
//  Created by Chiaote Ni on 2024/1/20.
//

import XCTest
@testable import StructuredConcurrencyDemo

final class WaitForAllBehaviorDemo: XCTestCase {

    func testWaitForAll() async throws {
        let makeTask1 = { Task {
            print("task1 start")
            try await Task.sleep(nanoseconds: 3_000_000_000)

            print("task1 end")
            return 1
        }}
        let makeTask2 = { Task {
            print("task2 start")
            try await Task.sleep(nanoseconds: 1_000_000_000)

            print("task2 end")
            return 2
        }}

        // Case 1: Simplest implementation
        do {
            let task1 = makeTask1()
            let task2 = makeTask2()
            let results = try await [task1, task2].waitForAll()
            XCTAssertEqual(results, [1, 2])
        }

        // Case 2: Wait for all using a TaskGroup
        do {
            let task1 = makeTask1()
            let task2 = makeTask2()
            let results = try await [task1, task2].waitForAllByGroup()
            XCTAssertEqual(results, [2, 1])
        }

        // Case 3: Wait for all tasks using a TaskGroup and maintain the corresponding order.
        do {
            let task1 = makeTask1()
            let task2 = makeTask2()
            let results = try await [task1, task2].waitForOrderedTaskGroupResults()
            XCTAssertEqual(results, [1, 2])
        }

        // Case 4: Do with Tuple type.
        do {
            let task1 = makeTask1()
            let task2 = makeTask2()

            var result = (0, 0)
            try await [task1, task2].waitAndCopyAllResults(to: &result)
            XCTAssertEqual(result.0, 1)
            XCTAssertEqual(result.1, 2)
        }
    }

    // MARK: - Performance
    /*
     From the tests `testPerformanceWaitForAllResults` and `testPerformanceWaitForAllResultByGroup`,
     we can see that they have very similar performances.
     As expected, the `waitForOrderedTaskGroupResults` takes slightly more time than the other two.
     */

    func testPerformanceWaitForAll() throws {
        measure {
            // compare the duration of waitForAllResultByGroupWithOder and waitForAllResultByGroup
            for _ in 0 ... 1000 {
                let task1 = makeTask(value: 1, sleepInNanoseconds: 5_000)
                let task2 = makeTask(value: 2, sleepInNanoseconds: 3_000)
                let exp = expectation(description: "Finished")

                Task {
                    _ = try? await [task1, task2].waitForAll()
                    exp.fulfill()
                }
                wait(for: [exp], timeout: 200.0)
            }
        }
    }

    func testPerformanceWaitForAllByGroup() throws {
        measure {
            // compare the duration of waitForAllResultByGroupWithOder and waitForAllResultByGroup
            for _ in 0 ... 1000 {
                let task1 = makeTask(value: 1, sleepInNanoseconds: 5_000)
                let task2 = makeTask(value: 2, sleepInNanoseconds: 3_000)
                let exp = expectation(description: "Finished")

                Task {
                    _ = try? await [task1, task2].waitForAllByGroup()
                    exp.fulfill()
                }
                wait(for: [exp], timeout: 200.0)
            }
        }
    }

    func testPerformanceWaitForOrderedTaskGroupResults() throws {
        measure {
            // compare the duration of waitForAllResultByGroupWithOder and waitForAllResultByGroup
            for _ in 0 ... 1000 {
                let task1 = makeTask(value: 1, sleepInNanoseconds: 5_000)
                let task2 = makeTask(value: 2, sleepInNanoseconds: 3_000)
                let exp = expectation(description: "Finished")

                Task {
                    _ = try? await [task1, task2].waitForOrderedTaskGroupResults()
                    exp.fulfill()
                }
                wait(for: [exp], timeout: 200.0)
            }
        }
    }
}

// MARK: - Private functions
extension WaitForAllBehaviorDemo {

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
