//
//  AsyncSemaphore.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/12/18.
//

import Foundation

/// An actor that functions like a semaphore, but for asynchronous Swift concurrency.
/// It manages a finite number of resources that tasks can acquire and release.
public actor AsyncSemaphore {

    private var waitingPool: [CheckedContinuation<Void, Never>] = []
    private var availableResources: Int

    /// Initializes the semaphore with a specified number of resources.
    /// - Parameter resourceCount: The total number of resources this semaphore manages.
    public init(resourceCount: Int = 5) {
        self.availableResources = resourceCount
    }

    /// Asynchronously waits to acquire a resource.
    /// If no resources are available, the caller will be suspended until a resource is released.
    public func wait() async {
        availableResources -= 1

        guard availableResources < 0 else {
            return
        }

        await withCheckedContinuation { continuation in
            waitingPool.insert(continuation, at: 0)
            print("🌲Waiting pool count", waitingPool.count)
        }
    }

    /// Signals that a resource has been released.
    /// If there are tasks waiting for a resource, one of them will be resumed.
    public func signal() async {
        availableResources += 1

        guard let continuation = waitingPool.popLast() else {
            return
        }
        print("✨Resuming Task", waitingPool.count)
        continuation.resume()
    }
}
