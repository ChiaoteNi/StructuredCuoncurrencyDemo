# StructuredCuoncurrencyDemo 
 This is a demo project to practice Swift Structured Concurrency with multiple parts.

### Part I: (Jan. 31)
- **BasicDemo**: This demo will show some basic things like:
  - The basic async await usage and how the executing thread will be. (although you shouldn't think of thread while using Structured Concurrency)
  - async let
  - The generic types of Task
  - yield
- **CancelDemo:** This demo will show the following things:
  - The isCancelled changes status when the parent task is canceled
  - The isCancelled changes status when other Task throws an error
- **GroupingTasksDemo:**
  - Just like the naming, this demo will show how to do grouping jobs.
- **MainActorDemo:**
  - The order of execution
  - @MainActor attribute for function and closure

### Part II: (Feb. 28)
- **AsyncSequence**
  - AsyncMap for Sequence
  - AsyncSequence & AsyncIteratorProtocol protocol
  - AsyncStream & AsyncThrowingStream
    	- `onTermination` triggered when canceling
  - The implementations of `AsyncMapSequence` & `AsyncThrowingCompactMapSequence.`
  - Implement a simple image downloader with the AsyncSequence

### Part III: (May 9)
- **Actor**
  - ActorDemo.playground:
  		- MainActor
  		- GlobalActor
  		- Basic behaviors
  - CustomActorExecutorDemo.playground:
  - ActorReentrancyDemo.playground

## How to use this demo project?
**Part I:**
All demos work with their demo view, which is compatible with SwiftUI Preview. Please use the demo project in the following way:

- Place the demo view on the left side with the canvas, and the demo itself on the right.
- For example: BasicDemoView (left) / BasicDemo (right).
![Screen Shot 2023-02-05 at 2 34 54 PM](https://user-images.githubusercontent.com/40178645/217272062-7f5e1f13-4fb4-44bf-852d-20e936bdd14f.png)

**Part II:**
Most of the demos are triggered by the test cases, so please use the demo project in the following way:

- Place the demonstrations on the left side, and the test cases on the right.
- For example: AsyncSequenceDemo.swift (left) / AsyncSequenceDemoTest.swift (right)."
![Screen Shot 2023-03-29 at 10 59 50 AM](https://user-images.githubusercontent.com/40178645/228415642-a9f970ff-ac08-4f3a-b321-c34b0bacbc91.png)

**Part III:**
All demonstrations can be found in the following playground files:

1. ActorDemo.playground
2. CustomActorExecutorDemo.playground
3. ActorReentrancyDemo.playground

Simply highlight sections of the code and interact directly within the playground.

