import Foundation

public func printWithThreadInfo(_ message: Any, threadInfo: String = Thread.current.description) {
    print(threadInfo, message)
}
