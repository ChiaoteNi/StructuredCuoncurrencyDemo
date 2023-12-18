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

    public enum ReleaseStrategy {
        case LIFO
        case FIFO
    }

    private var waitingQueue: [CheckedContinuation<Void, Never>] = []
    private var availableResources: Int
    private let releaseStrategy: ReleaseStrategy

    /// Initializes the resource limiter with a specified number of resources.
    /// - Parameters:
    ///   - resourceCount: The total number of resources this limiter manages.
    ///   - releaseStrategy: The strategy to use when releasing resources to waiting tasks.
    public init(resourceCount: Int = 5, releaseStrategy: ReleaseStrategy = .FIFO) {
        self.availableResources = resourceCount
        self.releaseStrategy = releaseStrategy
    }

    /// Asynchronously waits to acquire a resource.
    /// If no resources are available, suspends the caller until a resource is released.
    public func wait() async {
        availableResources -= 1

        guard availableResources < 0 else { return }

        await withCheckedContinuation { continuation in
            switch releaseStrategy {
            case .LIFO:
                waitingQueue.append(continuation)
            case .FIFO:
                waitingQueue.insert(continuation, at: 0)
            }
            print("🌲 Waiting Queue Count: \(waitingQueue.count)")
        }
    }

    /// Signals the release of a resource.
    /// Resumes a waiting task based on the specified release strategy.
    public func signal() async {
        availableResources += 1

        guard let continuation = waitingQueue.popLast() else {
            return
        }
        print("✨ Resuming Task, Waiting Queue Count: \(waitingQueue.count)")
        continuation.resume()
    }
}
