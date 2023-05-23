import Foundation

// When we want to limit a protocol that can only be confirmed from a reference type
// We can do like this:
protocol SomeProtocol: AnyObject {}

// Then, when we want to limit a protocol that can only be confirmed from a reference type
// We can do like this:
protocol SomeActorProtocol: AnyActor {}

// Also, since all actors conform to the protocol Actor, we can make an extension for this protocol,
// and implement the functions in the extension when we want to add some utility functions for all actors
extension Actor {
    func doSomethingSpecial() {}
}

protocol SomeAsyncProtocol {
    func doSomething() async
}

public actor SomeActor: SomeAsyncProtocol {
    func doSomething() {}
}

// More details see [here](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md#protocol-conformances:~:text=Reentrancy%20Summary-,Protocol%20conformances,-Detailed%20design)
