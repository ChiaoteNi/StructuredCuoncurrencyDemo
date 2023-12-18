//
//  AsyncResourceLimiter.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/12/18.
//

import Foundation

/// An actor that manages concurrent access to a finite number of resources,
/// functioning similarly to a semaphore but with support for Swift's concurrency model.
public actor AsyncResourceLimiter {

    enum ReleaseStrategy {
        case LIFO
        case FIFO
    }

    // It's not required, you can use OrderedDictionary in this class as well.
    struct Resource {
        let id = UUID()
        let continuation: ResourceContinuation
    }

    struct LimiterError: Error {
        let message: String
    }

    typealias ResourceContinuation = CheckedContinuation<(), Error>

    private var waitingQueue: [Resource] = []
    private var availableResources: Int
    private let releaseStrategy: ReleaseStrategy

    /// Initializes the resource limiter with a specified number of resources.
    /// - Parameters:
    ///   - resourceCount: The total number of resources this limiter manages.
    ///   - releaseStrategy: The strategy to use when releasing resources to waiting tasks.
    init(resourceCount: Int = 5, releaseStrategy: ReleaseStrategy = .FIFO) {
        self.availableResources = resourceCount
        self.releaseStrategy = releaseStrategy
    }

    /// Asynchronously waits to acquire a resource.
    /// If no resources are available, suspends the caller until a resource is released.
    /// - Parameter timeout: The maximum amount of time in nanoseconds to wait for a resource to become available.
    /// - Throws: An error if the timeout is reached before a resource becomes available.
    func wait(timeout: UInt64? = nil) async throws {
        availableResources -= 1

        guard availableResources < 0 else { return }

        try await withCheckedThrowingContinuation { continuation in
            let resource = Resource(continuation: continuation)
            switch releaseStrategy {
            case .LIFO:
                waitingQueue.append(resource)
            case .FIFO:
                waitingQueue.insert(resource, at: 0)
            }
            print("🌲 Waiting Queue Count: \(waitingQueue.count)")

            guard let timeout = timeout else {
                return
            }

            Task {
                try await Task.sleep(nanoseconds: timeout)

                guard let index = waitingQueue.firstIndex(where: {
                    $0.id == resource.id
                }) else {
                    return
                }
                waitingQueue.remove(at: index)
                continuation.resume(throwing: LimiterError(message: "Timeout"))
            }
        }
    }

    /// Signals the release of a resource.
    /// Resumes a waiting task based on the specified release strategy.
    public func signal() async {
        availableResources += 1

        guard let continuation = waitingQueue.popLast()?.continuation else {
            return
        }
        print("✨ Resuming Task, Waiting Queue Count: \(waitingQueue.count)")
        continuation.resume()
    }
}
