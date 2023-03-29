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

## How to use this demo project?
**Part I:**
All demos work with its demo view, which is able to work with SwiftUI Preview, so please try to use the demo project in the following way:

- Put the demo view on the left side with canvas and the demo on the right.
- ex: BasicDemoView (left) / BasicDemo (right)
![Screen Shot 2023-02-05 at 2 34 54 PM](https://user-images.githubusercontent.com/40178645/217272062-7f5e1f13-4fb4-44bf-852d-20e936bdd14f.png)
