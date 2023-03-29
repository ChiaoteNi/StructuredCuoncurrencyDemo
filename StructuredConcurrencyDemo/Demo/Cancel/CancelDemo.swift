//
//  CancelDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/31.
//

import Foundation

final class CancelDemo: ObservableDemo {

    @Published
    var message = AttributedString()

    private func doA() async {
        await self.logWithMainActor("throwErrorAction isCancelled: \(Task.isCancelled)")
    }

    private func doB() async {
        await self.logWithMainActor("0 checkIsCancelAction isCancelled: \(Task.isCancelled)")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await self.logWithMainActor("1 checkIsCancelAction isCancelled: \(Task.isCancelled)")
    }

    @MainActor
    func statusWhenParentTaskCanceled() async {
        logWithMainActor("Start")
        let task = Task {
//            async let throwErrorAction: Void = {
//                await self.logWithMainActor("throwErrorAction isCancelled: \(Task.isCancelled)")
//                throw CancellationError()
//            }()
            async let checkIsCancelAction: Void = {
                await self.logWithMainActor("0 checkIsCancelAction isCancelled: \(Task.isCancelled)")
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await self.logWithMainActor("1 checkIsCancelAction isCancelled: \(Task.isCancelled)")
            }()

//            try await throwErrorAction
            self.logWithMainActor("main task isCancelled: \(Task.isCancelled)")

            // The subTask will not inherit the cancel status, so the isCancelled will be false.
            let subTask = Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                logWithMainActor("0 subTask isCancelled: \(Task.isCancelled)")
                try await Task.sleep(nanoseconds: 1_000_000_000)
                logWithMainActor("1 subTask isCancelled \(Task.isCancelled)")
            }

            // The doSomething is executing under the current Task context, so the isCancelled will be true
            await doSomething()

            // The API of Structured Concurrency doesn't work under GCD context,
            // so the Task.isCancelled will be false.
            DispatchQueue.main.async {
                self.logWithMainActor("GCD isCancelled: \(Task.isCancelled)")
            }

//            do {
//                let errorResult: Void = try await throwErrorAction
//                let commonResult: Void = try await checkIsCancelAction
//                let taskResult = await subTask.result
//                logWithMainActor("Error: \(errorResult)")
//                logWithMainActor("Common: \(commonResult)")
//                logWithMainActor("Task: \(taskResult)")
//                logWithMainActor("is main Task canceled: \(Task.isCancelled)")
//            } catch {
//                logWithMainActor("Error: \(error)")
//            }
        }
        task.cancel()
    }

    // reference: https://fortee.jp/iosdc-japan-2022/proposal/1bbc3929-1302-4d62-9d0d-19de7083562d
    func statusWhenOtherTaskThrowsError() async {
        Task {
            async let error: Void = {
                throw CancellationError()
            }()

            async let checkIsCancel: Void = {
                print("🎁0", Task.isCancelled)
                try await Task.sleep(nanoseconds: 1_000)
                print("🎁1", Task.isCancelled)
            }()

            do {
                try await(error, checkIsCancel)
            } catch {
                print(error)
            }
            // if b throw error, a will be cancelled as well
        }
    }
}

// MARK: - Private functions
extension CancelDemo {

    @MainActor
    private func doSomething() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.logWithMainActor("doSomething: \(Task.isCancelled)")
    }

    @MainActor
    private func logWithMainActor(
        _ text: String,
        threadInfo: String = Thread.current.description
    ) {
        logMessage(text, threadInfo: threadInfo)
    }
}
