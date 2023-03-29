//
//  AsyncSequenceDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/2/7.
//

import SwiftUI

// MARK: - Demo 1: How to map a sequence with await the result from its element?

// Solution 1: For loop - await end then execute the transform at each loop
extension Sequence {

    func asyncMap<ElementOfResult>(
        _ transform: @escaping (Element) async throws -> ElementOfResult
    ) async rethrows -> [ElementOfResult] {

        var results = [ElementOfResult]()
        for element in self {
            let result = try await transform(element)
            results.append(result)
        }
        return results
    }
}

// Solution 2: Tasks - execute the transform faster than the solution 1
extension Sequence where Element: Sendable {

    // following naming is to make the demo clearer for separating out these 3 cases
    func sendableElementsAsyncMap<ElementOfResult>(
        _ transform: @escaping (Element) async throws -> ElementOfResult
    ) async throws -> [ElementOfResult] {

        var results = [ElementOfResult]()
        let tasks = compactMap { element in
            Task {
                try await transform(element)
            }
        }
        for task in tasks {
            let result = try await task.value
            results.append(result)
        }
        return results
    }
}

// Solution 3: TaskGroup - execute the transform faster than the solution 1, but promise the order
extension Sequence {

    // following naming is to make the demo clearer for separating out these 3 cases
    func sendableResultsAsyncMap<ElementOfResult: Sendable>(
        _ transform: @escaping (Element) async throws -> ElementOfResult
    ) async rethrows -> [ElementOfResult] {

        try await withThrowingTaskGroup(
            of: ElementOfResult.self,
            returning: [ElementOfResult].self,
            body: { group in
                forEach { element in
                    group.addTask {
                        try await transform(element)
                    }
                }
                return try await group
                    .reduce(into: [ElementOfResult](), { partialResult, result in
                        partialResult.append(result)
                    })
            })
    }
}

// MARK: - Demo 2: The protocol AsyncSequence & AsyncIteratorProtocol
// The example for usage is in AsyncSequenceDemo.swift

typealias TransformHandler<Base: Sequence, ElementOfResult> = (Base.Element) async throws -> ElementOfResult

struct MyAsyncSequence<Base: Sequence, ElementOfResult>: AsyncSequence {

    typealias AsyncIterator = MySequenceIterator
    typealias Element = ElementOfResult

    let base: Base
    var iterator: MySequenceIterator<Base, ElementOfResult>
    let transform: TransformHandler<Base, ElementOfResult>

    init(base: Base, transform: @escaping TransformHandler<Base, ElementOfResult>) {
        self.base = base
        self.iterator = MySequenceIterator(base: base, transform: transform)
        self.transform = transform
    }

    func makeAsyncIterator() -> MySequenceIterator<Base, ElementOfResult> {
        // I created a new iterator for this demo.
        // However, it's okay to modify it to conform to AsyncIteratorProtocol and return itself here.
        return iterator
    }
}

struct MySequenceIterator<Base: Sequence, ElementOfResult>: AsyncIteratorProtocol {

    typealias Element = ElementOfResult

    let base: Base
    var iterator: Base.Iterator
    let transform: TransformHandler<Base, ElementOfResult>

    init(base: Base, transform: @escaping TransformHandler<Base, ElementOfResult>) {
        self.base = base
        self.iterator = base.makeIterator()
        self.transform = transform
    }

    mutating func next() async throws -> ElementOfResult? {
        guard let element = iterator.next() else {
            return nil
        }
        let result = try await transform(element)
        return result
    }
}

// MARK: - Demo 3. AsyncStream, AsyncThrowingStream, and the behavior when cancellation occurs

final class AsyncSequenceDemo {

    func asyncStreamDemo() async {
        let services = makeDemoServices()

        let stream = AsyncStream(ResourceBundle.self, bufferingPolicy: .bufferingOldest(2)) { continuation in
            continuation.onTermination = { @Sendable termination in
                // Clear the resource or do something when the stream is stopped
                debugPrint(termination)
            }
            Task {
                for service in services {
                    let result = await service.fetchBundle()
                    continuation.yield(result) // next
                }
                continuation.finish()
            }
        }

        for await bundle in stream {
            print(bundle.name)
        }
    }

    func asyncStreamThrowingDemo() async {
        let services = makeDemoServices()

        let stream = AsyncThrowingStream<ResourceBundle, Error> { continuation in
            continuation.onTermination = { @Sendable termination in
                // Clear the resource or do something when the stream is stopped
                debugPrint("🎊", termination)
            }
            Task {
                do {
                    for service in services {
                        let result = try await service.fetchBundleWithThrowingError()
                        continuation.yield(result)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }

        do {
            for try await bundle in stream {
                print(bundle.name)
            }
        } catch {
            print(error)
        }
    }

    func cancelToTriggerOnTerminationDemo() async {
        let task = Task {
            await asyncStreamThrowingDemo()
        }
        task.cancel() // You can see that the onTermination is invoked after this, and the log shows that the task is canceled.
    }
}

extension AsyncSequenceDemo {

    private func makeDemoServices() -> [BundleService] {
        [
            StickerBundleService(),
            FontBundleService(),
            IconBundleService()
        ]
    }
}

// MARK: - Demo 4. Let's see the implementations of AsyncMapSequence and AsyncThrowingCompactMapSequence
// The following code isn't 100% the same as the one in the Swift Standard Library.
// This is because I only kept the most important parts to showcase how it works and removed everything else,
// such as attributes and access controls, to make it easier to focus on the behavior

// MARK: AsyncMapSequence
/// An asynchronous sequence that maps the given closure over the asynchronous
/// sequence’s elements.
///
struct AsyncMapSequence<Base: AsyncSequence, Transformed> {
  let base: Base
  let transform: (Base.Element) async -> Transformed

  init(
    _ base: Base,
    transform: @escaping (Base.Element) async -> Transformed
  ) {
    self.base = base
    self.transform = transform
  }
}

extension AsyncMapSequence: AsyncSequence {

  typealias Element = Transformed
  typealias AsyncIterator = Iterator

  struct Iterator: AsyncIteratorProtocol {
    var baseIterator: Base.AsyncIterator
    let transform: (Base.Element) async -> Transformed

    init(
      _ baseIterator: Base.AsyncIterator,
      transform: @escaping (Base.Element) async -> Transformed
    ) {
      self.baseIterator = baseIterator
      self.transform = transform
    }

    mutating func next() async rethrows -> Transformed? {
      guard let element = try await baseIterator.next() else {
        return nil
      }
      return await transform(element)
    }
  }

  func makeAsyncIterator() -> Iterator {
    return Iterator(base.makeAsyncIterator(), transform: transform)
  }
}

// MARK: AsyncThrowingCompactMapSequence
/// An asynchronous sequence that maps an error-throwing closure over the base
/// sequence’s elements, omitting results that don't return a value.
///
struct AsyncThrowingCompactMapSequence<Base: AsyncSequence, ElementOfResult> {
    let base: Base
    let transform: (Base.Element) async throws -> ElementOfResult?

    init(
        _ base: Base,
        transform: @escaping (Base.Element) async throws -> ElementOfResult?
    ) {
        self.base = base
        self.transform = transform
    }
}

extension AsyncThrowingCompactMapSequence: AsyncSequence {

    typealias Element = ElementOfResult
    typealias AsyncIterator = Iterator

    struct Iterator: AsyncIteratorProtocol {
        typealias Element = ElementOfResult

        var baseIterator: Base.AsyncIterator
        let transform: (Base.Element) async throws -> ElementOfResult?
        var finished = false

        init(
            _ baseIterator: Base.AsyncIterator,
            transform: @escaping (Base.Element) async throws -> ElementOfResult?
        ) {
            self.baseIterator = baseIterator
            self.transform = transform
        }

        mutating func next() async throws -> ElementOfResult? {
            while !finished {
                guard let element = try await baseIterator.next() else {
                    finished = true
                    return nil
                }
                do {
                    if let transformed = try await transform(element) {
                        return transformed
                    }
                } catch {
                    finished = true
                    throw error
                }
            }
            return nil // return nil == finished
        }
    }

    func makeAsyncIterator() -> Iterator {
        return Iterator(base.makeAsyncIterator(), transform: transform)
    }
}

// MARK: - Demo 5. Implement a simple image downloader with the asyncStream
// Check out to the file ImageDownloaderWithAsyncSequence.swift
