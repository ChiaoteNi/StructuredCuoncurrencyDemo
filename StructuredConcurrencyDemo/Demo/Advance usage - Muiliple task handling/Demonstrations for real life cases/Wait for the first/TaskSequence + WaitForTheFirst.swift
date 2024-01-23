//
//  TaskSequence + WaitForTheFirst.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/23.
//

import Foundation

extension Sequence where Element: Taskable {

    func waitForFirstResult() async throws -> Element.Success {
        // Version 1:
        do {
            let result = try await withThrowingTaskGroup(of: Element.Success.self) { group in
                forEach { task in
                    group.addTask { try await task.value }
                }

                do {
                    guard let result = try await group.next() else {
                        throw DemoError(description: "Pending task not found")
                    }
                    print("💥Got first response")
                    group.cancelAll()
                    return result
                } catch {
                    print("💥Got first response in error")
                    group.cancelAll()
                    throw error
                }
            }
            return result
        } catch {
            print("💥Got error")
            throw error
        }

//        // Version 2:
//        try await withCheckedThrowingContinuation { continuation in
//            Task {
//                try await withThrowingTaskGroup(of: Element.Success.self) { group in
//                    forEach { task in
//                        group.addTask { try await task.value }
//                    }
//
//                    do {
//                        guard let result = try await group.next() else {
//                            throw DemoError(description: "Pending task not found")
//                        }
//                        print("💥Got first response")
//                        continuation.resume(returning: result)
//                    } catch {
//                        print("💥Got first response in error")
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//        }
    }
}
