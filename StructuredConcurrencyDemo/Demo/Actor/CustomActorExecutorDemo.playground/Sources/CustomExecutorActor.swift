import Foundation

@globalActor
public final actor SpecificQueueActor: GlobalActor {
    // The type of the shared actor instance that will be used to provide mutually-exclusive access to declarations annotated with the given global actor type.
    public typealias ActorType = SpecificQueueActor
    // The shared actor instance that will be used to provide mutually-exclusive access to declarations annotated with the given global actor type.
    public static var shared = SpecificQueueActor()

    let executor: SpecificQueueExecutor
    public let unownedExecutor: UnownedSerialExecutor

    init() {
        let executor = SpecificQueueExecutor()
        self.executor = executor
        self.unownedExecutor = executor.asUnownedSerialExecutor()
    }
}

/*
 Executor is the protocol to define a service that can execute jobs.
 SerialExecutor is the one that inherits from Executor and Sendable
 */
final class SpecificQueueExecutor: SerialExecutor { // A service that executes jobs.

    // Simplified handling jobs via GCD that to execute them on a specific thread, and of course it's not required when implementing the SerialExecutor
    // Therefore, you can also choose other ways like using RunLoop, Timer, Thread, and so on.
    static let queue = DispatchQueue(label: "com.executor.specificQueue")

    // For iOS 13.0 ~ 16
    // This interface has been marked deprecated since iOS 17
    func enqueue(_ job: UnownedJob) { // UnownedJob: a unit of scheduleable work.
        SpecificQueueExecutor.queue.sync {
            print(job.priority.rawValue)
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    // For iOS 17.0
    @available(iOS 17.0, *)
    nonisolated func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        enqueue(unownedJob)
    }

    // Convert this executor value to the optimized form of borrowed executor references.
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

