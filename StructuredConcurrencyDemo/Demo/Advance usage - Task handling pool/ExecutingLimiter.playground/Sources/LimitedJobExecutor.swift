//
//  LimitedJobExecutor.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/12/17.
//

import Foundation

/*
 The following code is just a potential implementation of a custom executor to manage executing jobs with a pool.
 However, it's event not the good practice for now since the proposal `Custom Actor Executors` didn't introducing
 the `Specifying Task executors` within it.

 Additionally, the function runSynchronously completes immediately after executing the job.
 Therefore, it's suitable for creating an Executor to make jobs execute serially or on the same thread.
 However, it does not work for managing execution resources

 For the context of `Specifying Task executors`, please refer to here:
 https://github.com/apple/swift-evolution/blob/main/proposals/0392-custom-actor-executors.md#specifying-task-executors
 */
final class LimitedJobExecutor: SerialExecutor {

    // Stored property 'pool' of 'Sendable'-conforming class 'LimitedJobExecutor' is mutable
    var pool: [UnownedJob] = []

    var queue = DispatchSerialQueue(label: "com.LimitedJobExecutor")

    let maxExecutingJobNumber: Int
    var currentExecutedJobCount: Int = 0

    init(maxExecutingJobNumber: Int = 5) {
        self.maxExecutingJobNumber = maxExecutingJobNumber
    }

    // For iOS 13.0 ~ 17
    // This interface has been marked deprecated since iOS 17
    nonisolated func enqueue(_ job: UnownedJob) {
        queue.async {
            self.currentExecutedJobCount += 1
            if self.currentExecutedJobCount >= self.maxExecutingJobNumber {
                self.addJobToPool(job)
            } else {
                self.executeJob(job)
                self.currentExecutedJobCount -= 1
                self.executesJobFromPool()
            }
        }
    }

    // iOS 17.0
    @available(iOS 17.0, *)
    nonisolated func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        queue.async {
            if self.currentExecutedJobCount >= self.maxExecutingJobNumber {
                self.addJobToPool(unownedJob)
            } else {
                self.executeJob(unownedJob)
            }
        }
    }

    // Convert this executor value to the optimized form of borrowed executor references.
    nonisolated func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    // MARK: - Private functions

    private func executesJobFromPool() {
        guard !pool.isEmpty else { return }

        let job = pool.removeFirst()
        executeJob(job)

        executesJobFromPool()
    }

    private func addJobToPool(_ job: UnownedJob) {
        pool.append(job)
    }

    private func executeJob(_ job: UnownedJob) {
        currentExecutedJobCount += 1
        // Note: The function job.runSynchronously completes immediately after it's called.
        // This implies that it does not wait for the full execution of the job to conclude.
        // For instance, if the job contains an `await` statement, runSynchronously
        // will not pause execution to wait for the `await` to resolve.
        job.runSynchronously(on: asUnownedSerialExecutor())
        print("🌲runSynchronously finish")
        // According to the above comment, the currentExecutedJobCount won't work as what we expected.
        currentExecutedJobCount -= 1
    }
}

@globalActor
public final actor LimitedExecutingActor: GlobalActor {
    public typealias ActorType = LimitedExecutingActor

    public static var shared = LimitedExecutingActor()

    let executor: LimitedJobExecutor
    public let unownedExecutor: UnownedSerialExecutor

    init() {
        let executor = LimitedJobExecutor()
        self.executor = executor
        self.unownedExecutor = executor.asUnownedSerialExecutor()
    }
}
