import Foundation

@globalActor
public actor CommonGlobalActor {
    public static let shared = CommonGlobalActor()
}
