import UIKit

enum TaskTag {

    @TaskLocal
    static var tag: String = ""
}

Task {
    // ⬇️ error: setter for '$tag' is unavailable: use '$myTaskLocal.withValue(_:do:)' instead
    // TaskTag.$tag = TaskLocal(wrappedValue: "YO")

    TaskTag.$tag.withValue("FROM START PAGE") {
        Task {
            print("🌲sub", TaskTag.tag)

            Task {
                print("🌲sub_sub", TaskTag.tag)
            }

            await withCheckedContinuation { continuation in
                print("🌲sub_withContinuation", TaskTag.tag)
                continuation.resume()
            }

            Task.detached {
                print("🌲sub_detached", TaskTag.tag)
            }

            TaskTag.$tag.withValue("FROM ANOTHER PAGE") {
                Task {
                    print("🌲nested tag", TaskTag.tag)
                }
            }

        }
        print("🌲", TaskTag.tag)
    }
    print("🌲root", TaskTag.tag)
}

/*
 🌲sub FROM START PAGE
 🌲sub_sub FROM START PAGE
 🌲 FROM START PAGE
 🌲sub_withContinuation FROM START PAGE
 🌲root
 🌲sub_detached
 🌲nested tag FROM ANOTHER PAGE
 */
