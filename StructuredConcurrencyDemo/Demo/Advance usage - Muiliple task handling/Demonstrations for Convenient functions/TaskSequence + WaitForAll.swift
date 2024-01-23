//
//  Task+Convenience.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/20.
//

import Foundation
/*
 Demonstrations using `waitForAllResults` are quite common in our real-life development.
 However, it can be quite tedious to write them every time. 
 So, how can we create some utility functions for this purpose?

 First of all, we can extend the behavior for a `Sequence` where the `Element` is a `Task`. 
 Considering that it's challenging to extend a `Sequence` for an `Element` that includes its own generic type
 , we can create a protocol like the following.

 For more details, refer to this article: https://www.swiftbysundell.com/articles/specialized-extensions-using-generic-type-constraints/
 */

protocol Taskable {
    associatedtype Success: Sendable
    associatedtype Failure: Error

    var value: Success { get async throws }

    func cancel()
}

extension Task: Taskable {
    typealias Success = Success
    typealias Failure = Failure
}

// MARK: - Wait for all

extension Sequence where Element: Taskable {

    // Case 1: Simplest implementation
    func waitForAll() async throws -> [Element.Success] {
        var results = [Element.Success]()
        for task in self {
            // Disadvantage: We can't catch the exception immediately.
            // When the second task throws an error, we will only catch it after we get the result from the first task.
            let result = try await task.value
            results.append(result)
        }
        return results
    }

    // Case 2: Wait for all using a TaskGroup
    func waitForAllByGroup() async throws -> [Element.Success] {
        try await withThrowingTaskGroup(of: Element.Success.self) { group in
            for task in self {
                group.addTask { try await task.value }
            }
            /*
             let firstReponse = try await group.next()

             About the next of TaskGroup,
             the values returned by successive calls to this method appear in the order that the tasks completed,
             not in the order that those tasks were added to the task group.
             */

            // Therefore, the order of the results might not correspond to the order of the elements in the sequence.
            let result = try await group
                .reduce(into: [Element.Success]()) { partialResult, childResult in
                    partialResult.append(childResult)
                }
            return result
        }
    }

    // Case 3: Wait for all tasks using a TaskGroup and maintain the corresponding order.
    private typealias ResultInfo = (index: Int, value: Element.Success)

    func waitForOrderedTaskGroupResults() async throws -> [Element.Success] {
        try await withThrowingTaskGroup(
            of: ResultInfo.self,
            returning: [Element.Success].self
        ) { group in
            for (index, task) in enumerated() {
                group.addTask {
                    let value = try await task.value
                    return (index, value)
                }
            }

            let result = try await group
                .reduce(into: [ResultInfo]()) { partialResult, childResult in
                    partialResult.append(childResult)
                }
                .sorted(\.index, by: <)
                .map { $0.value }

            return result
        }
    }
}

// MARK: - Array -> Tuple
/*
 The following code demonstrates a potential implementation for returning results as a tuple.

 However, it's just for demonstration purposes, and I don't recommend using this approach in production code.
 Tuples are a compound type in Swift, and Swift doesn't support extending their behavior.

 Achieving our goal with this method would require tricky and potentially unsafe implementations,
 making code maintenance difficult.
 */
extension Array where Element: Taskable {

    func waitAndCopyAllResults<Tuple>(to tuple: inout Tuple) async throws {
        let results = try await waitForAll()
        results.unsafeCopyToTuple(to: &tuple)
    }
}

private extension Array {

    func unsafeCopyToTuple<Tuple>(to tuple: inout Tuple) {
        withUnsafeMutablePointer(to: &tuple) { pointer in
            let bound = pointer.withMemoryRebound(to: Element.self, capacity: count) { $0 }
            enumerated().forEach { (bound + $0.offset).pointee = $0.element }
        }
    }
}

/*
Are we able to extend a Tuple directly? No.

 Data types that are normally considered basic or primitive in other languages 
 such as types that represent numbers, characters, and strings are actually named types, defined and implemented in the Swift standard library using structures.
 Because they’re named types, you can extend their behavior to suit the needs of your program, using an extension declaration, discussed in Extensions and Extension Declaration.

 A compound type is a type without a name, defined in the Swift language itself. 
 There are two compound types: function types and tuple types.
 A compound type may contain named types and other compound types.
 For example, the tuple type (Int, (Int, Int)) contains two elements: The first is the named type Int, and the second is another compound type (Int, Int).

 Reference: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/types/
 */
