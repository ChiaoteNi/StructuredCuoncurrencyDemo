import Foundation

@globalActor
public actor SomeGlobalActor {
    public static let shared = SomeGlobalActor()
}
