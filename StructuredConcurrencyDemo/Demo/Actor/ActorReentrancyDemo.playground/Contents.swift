
import Foundation

/*
 Actor-isolated functions are [reentrant](https://en.wikipedia.org/wiki/Reentrancy_(computing)).
 When an actor-isolated function suspends, reentrancy allows other work to execute on the actor before the original actor-isolated function resumes, which we refer to as *interleaving*.
 Interleaving executions still respect the actor's "single-threaded illusion", i.e., no two functions will ever execute concurrently on any given actor.

 This design is intended to avoid deadlocks and provide data-race safety.
 However, the execution of works may interleave at suspension points, which means that even though you don't need to worry about data races due to the serial executor
 , it is still possible to execute work with a race condition during interleaving.

 More details see here [Actor reentrancy](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md#:~:text=Closures-,Actor%20reentrancy,-%22Interleaving%22%20execution%20with)
 */

// MARK: The behavior for a class-type state store
class StateStore {
    var state = 0 // We won't protect it from the race condition issue

    func run() async {
        print(state)        // 0
        await doSomething() // suspend the executing job
        print(state)        // ?
    }

    func add(_ value: Int) {
        state += value      // 0 -> 3
    }

    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

// MARK: The behavior for a actor-type state store
actor ActorStateStore {
    var state = 0

    func run() async {
        print(state)        // 0
        await doSomething() // suspend the executing job
        print(state)        // ?
    }
    func add(_ value: Int) {
        state += value      // 0 -> 4
    }
    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

// MARK: The behavior for a state store with an Actor attribute

@globalActor
actor SomeActor {
    static let shared = SomeActor()
}

@SomeActor
class SomeActorStateStore {

    static var shared = SomeActorStateStore()

    var state = 0

    func run() async {
        print(state)        // 0
        await doSomething() // suspend the executing job
        print(state)        // ?
    }

    func add(_ value: Int) {
        state += value      // 0 -> 5
    }

    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

final class ActorReentrancyDemo{
    let store = StateStore()
    let actorStore = ActorStateStore()
    var actorAttributedStore: SomeActorStateStore {
        get async { await SomeActorStateStore.shared }
    }

    func run() {
        Task.detached {
            await self.store.run()
        }
        Task.detached {
            await self.actorStore.run()
        }
        Task.detached {
            await self.actorAttributedStore.run()
        }
        Task.detached {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.store.add(3)
        }
        Task.detached {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await self.actorStore.add(4)
        }
        Task.detached {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await self.actorAttributedStore.add(5)
        }
    }
}

ActorReentrancyDemo().run()
