import UIKit

/*
 Each actor protects its own data through data isolation,
 ensuring that only a single thread will access that data at a given time,
 even when many clients are concurrently making requests of the actor.

 Therefore, it doesn't guarantee execution on the same thread.
 */

actor SomeActor {
    let message = "YO"

    func demonstrateExecutingThread() async {
        printWithThreadInfo(message)      // Thread number = 5
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)      // Thread number = 7
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)
    }
}
Task {
//    await SomeActor().demonstrateExecutingThread()
////    await SomeActor().demonstrateExecutingThread()
////    await SomeActor().demonstrateExecutingThread()
}

// Now, what happens when using the MainActor attribute?

@MainActor
struct MainActorAttributedMessageStore {
    let message = "YO"

    func demonstrateExecutingThread() async {
        printWithThreadInfo(message)      // Thread number = 0
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)      // Thread number = 0
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)      // Thread number = 0
    }
}

Task {
//    await MainActorAttributedMessageStore().demonstrateExecutingThread()
////    await MainActorAttributedMessageStore().demonstrateExecutingThread()
////    await MainActorAttributedMessageStore().demonstrateExecutingThread()
}

// Of course, this behavior is not because of using the attribute, but we can still experiment to verify it.

@SomeGlobalActor
struct SomeActorAttributedMessageStore {
    let message = "YO"

    func demonstrateExecutingThread() async {
        printWithThreadInfo(message)      // Thread number = 4
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)      // Thread number = 7
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Suspends the execution of the job
        printWithThreadInfo(message)      // Thread number = 4
    }
}

Task {
    await SomeActorAttributedMessageStore().demonstrateExecutingThread()
////    await SomeActorAttributedMessageStore().demonstrateExecutingThread()
////    await SomeActorAttributedMessageStore().demonstrateExecutingThread()
}

// Just as expected, the behavior is the same as when using an actor, with the @GlobalActor attribute (of course).
// Honestly, executing jobs in the same thread now is not that important when doing with Structured Concurrency, but it's still very interesting to know how it works :)
// Therefore, how can we make our actor executes job on the same thread?
// Let's switch to CustomActorExecutorDemo.playground and see the next demo.
