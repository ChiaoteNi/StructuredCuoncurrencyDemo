import UIKit

// MARK: Case 1 - Known task count

let task1 = Task {
    print("task1 start")
    try await Task.sleep(nanoseconds: 1_000_000_000)

    print("task1 end")
    return 1
}
let task2 = Task {
    print("task2 start")
    try await Task.sleep(nanoseconds: 3_000_000_000)

    print("task2 end")
    return 2
}

// Switch: mark/unmark the line 20, and check the timing when the line 24 get the result
// task1.cancel()

Task {
    do {
        let values = try await (task1.value, task2.value)
        // We will get the result values until both of task1 and task2 respond
        print(values)
    } catch {
        // As soon as task 1 is canceled, we get the error message
        print("error: \(error)")
    }
}

// MARK: Case 2 - Unknow task count

func download() -> [Task<Int, Error>] {
    let count = Int.random(in: 1 ... 5)
    let tasks = (0 ..< count).map { index -> Task<Int, Error> in
        Task {
            let sleepTime = Int.random(in: 1 ... 5)
            try await Task.sleep(nanoseconds: UInt64(sleepTime * 1_000_000_000))
            return index
        }
    }
    return tasks
}

let tasks = download()
Task {
    // Creating an unlimited tuple to wait for all results is not feasible.
    // Instead, we should use TaskGroup to achieve this.
    let results = try await withThrowingTaskGroup(of: Int.self, returning: [Int].self) { group in
        tasks.forEach { task in
            group.addTask { try await task }
        }
        // However, here exist a potential issue that we'll discuss in the later demonstration.
        return try await group.reduce(into: [Int]()) { partialResult, result in
            partialResult.append(result)
        }
    }
    print(results)
}
// Let's go to the `Demonstrations for Convenient functions` first
