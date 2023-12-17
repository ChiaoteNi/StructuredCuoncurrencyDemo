import Foundation

/*
 This demo will show how to implement a custom executor for actor.
 The original executor for actor executes with the priority of task
 , but what if we want to executes tasks just follow FIFO?
 */

//@CommonGlobalActor
//@MainActor
@SpecificQueueActor
class Printer {

    // The `async` here is not required,
    // I leaved it here was to modify the demonstration code for different cases easily during the live demo.
    func execute(priority: TaskPriority, delays: UInt64 = 1) async {
        print("\(Thread.current)")
        Task(priority: priority) {
            try? await Task.sleep(nanoseconds: delays)
            print("yo \(priority)")
        }
    }
}

print(TaskPriority.high, TaskPriority.medium, TaskPriority.low)

Task.detached() {
    await Printer().execute(priority: .low)
    await Printer().execute(priority: .low)
    await Printer().execute(priority: .medium)
    await Printer().execute(priority: .high)
    await Printer().execute(priority: .high)
}
