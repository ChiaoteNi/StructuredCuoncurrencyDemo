//
//  MainActorDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/31.
//

import Foundation

final class MainActorDemo: ObservableDemo {

    // MARK: - Order Of Execution

    @Published
    var message: AttributedString = ""

    /*
     Try to guess the result and see if it's correct : P
     Then try to guess the result of changing to use the default priority.
     */
    @MainActor
    func orderOfExecution() async {
        Task { @MainActor in
            logMessage("🍇 1")
        }
        logMessage("🍇 2")

        await MainActor.run(body: {
            logMessage("🍇 3")

            Task(priority: .low) { @MainActor in
//            Task {
                logMessage("🍇 4")
                await log("🍇 5")
            }
        })
        logMessage("🍇 6")
    }

    @MainActor
    private func log(_ text: String) async {
        Task {
            logMessage(text)
        }
    }

    // MARK: - Execute a long-time Job

    @MainActor
    func executeLongTimeJob() async {
        for i in 0 ..< 5 {
            // Case 1: block the current thread
//            usleep(1_000_000)
//            // await Task.yield()

            // Case 2: do with await
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            print(i)
        }
    }

    func executeLongTimeJobInTask() async {
        Task { @MainActor in
            for i in 0 ..< 5 {
                // Case 1: block the current thread
//                usleep(1_000_000)
//            // await Task.yield()

                // Case 2: do with await
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                print(i)
            }
        }
    }
}
