//
//  BasicDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/31.
//

import Foundation

final class BasicDemo: ObservableDemo {

    @Published
    var message = AttributedString()

    /*
     - Task will inherit the current context automatically,
       which means although you use Task { //... } in the main thread, the system won't 100% switch to the background thread.
       Alternative, you can use Task.detached to avoid inheriting the current context.
     - In the following case, the code inside the Task of line 25 will probably execute before or after the code at line 39.
       It depends on the priority; It will have a chance to go first if the priority is much higher than the following ones
       (ex: userInitiated).
       Otherwise, it will execute after the Task declared at line 39.
     */
    @MainActor
    func run() async {
        await logMessageWithMainActor("Start")

        Task(priority: .userInitiated) {
            await logMessageWithMainActor("0 - Main Task, priority: \(Task.currentPriority)")
            Task {
                await logMessageWithMainActor("1 - Sub Task, priority: \(Task.currentPriority)")
            }
            Task.detached {
                await self.logMessageWithMainActor("2 - detached from main Task, priority: \(Task.currentPriority)")
            }
        }

        Task.detached {
            await self.logMessageWithMainActor("3 - detached from main thread")
        }

        await Task {
            await logMessageWithMainActor("4 - 2nd Main Task")
        }.value

        await logMessageWithMainActor("5 - End")
    }

    /*
     Using `async let` will allow you to don't block the current flow until you use await for the task value or result.
     However, it won't change the behavior of the Task, which means it will execute the closure in the Task automatically as well.
     */
    func asyncLet() async {
        await logMessageWithMainActor("Start")

        async let task1 = Task {
            await logMessageWithMainActor("Task1")
            await logMessageWithMainActor("Task1 after 2 sec", delay: 2)
        }
        async let task2 = Task {
            await logMessageWithMainActor("Task2")
        }

//        try? await Task.sleep(nanoseconds: 1_000_000)

        await logMessageWithMainActor("Before waiting")
        await task1.value
        await task2.value
        await logMessageWithMainActor("After waiting")

        let tasks = Array(3...6).map { index in
            Task {
                await logMessageWithMainActor("Task \(index)")
            }
        }
        for task in tasks {
            await task.value
        }
        await logMessageWithMainActor("End")
    }

    /*
     - GCD will try to control the amount thread if it's possible (max 512)
     - Structured Concurrency won't just try to control, but reuse the thread resource more efficient and limited them into a maximum amount of about 10. (sometime will more than 10, but not very often)
     */
    func limitedThreadPool() {
        let indices = Array(0...100000) // you can tweak this from 0...1000 to 0...100000, then see how the amount of threads will be.

        var threadSetForQueue = Set<Int>()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.threadNumberSet")
        for index in indices {
            DispatchQueue(label: "queue \(index)").async(group: group) {
                let hash = Thread.current.hash
                _ = queue.sync {
                    threadSetForQueue.insert(hash)
                }
            }
        }
        group.notify(queue: .main) {
            let message = "threadSetForQueue: \(threadSetForQueue.count)"
            Task {
                await self.logMessageWithMainActor(message)
            }
        }

        let tasks = indices.map { _ in
            Task.detached {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                return Thread.current.hash
            }
        }
        Task { @MainActor in
            var threadSetForTask = Set<Int>()
            for task in tasks {
                let hash = await task.value
                threadSetForTask.insert(hash)
            }
            let message = "threadSetForTask: \(threadSetForTask.count)"
            await self.logMessageWithMainActor(message)
        }
    }

    func resultType() async {
        let task1 = Task { // Result<(), Never>
            await logMessageWithMainActor("YA")
        }

        let task2 = Task { // Result<Int, Never>
            return 1
        }

        let task3 = Task { // Result<(), Error>
            if Bool.random() {
                await logMessageWithMainActor("YO")
            } else {
                throw DemoError(description: "Test")
            }
        }

        await self.logMessageWithMainActor("\(type(of: task1.result))")
        await self.logMessageWithMainActor("\(type(of: task2.result))")
        await self.logMessageWithMainActor("\(type(of: task3.result))")
    }

    @MainActor
    func yield(_ prefix: String) {
        Task {
            logMessage(prefix + " start")

            // Case 1: Block the thread until the job finished
//            for i in 0 ..< 4 {
//                logMessage(prefix + " \(i)")
//            }

            // Case 2: Release the thread resource for other tasks at the beginning of each loop.
            for i in 0 ..< 5 {
                await Task.yield()
                logMessage(prefix + " \(i)")
            }

            logMessage(prefix + " end")
        }
    }
}

// MARK: - Private functions
extension BasicDemo {

    @MainActor
    private func logMessageWithMainActor(
        _ text: String,
        threadInfo: String = Thread.current.description,
        delay: UInt64 = 1
    ) async {

        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
        logMessage(text, threadInfo: threadInfo)
    }
}
