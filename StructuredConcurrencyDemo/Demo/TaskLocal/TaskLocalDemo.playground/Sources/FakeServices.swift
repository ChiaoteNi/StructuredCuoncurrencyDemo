//
//  FakeServices.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/12/19.
//

import Foundation

public enum TaskContext {
    @TaskLocal
    public static var source: String? = nil
}

final class APIHandler {

    func initiateSubscription() async {
        // do something ...
        EventLogger.log(
            "APIHandler",
            from: TaskContext.source ?? "Unknown"
        )
        DebugLogger.log(
            "APIHandler - initiateSubscription",
            debugTag: TaskTag.tag
        )
    }
}

public final class SubscriptionManager {

    private let apiHandler = APIHandler()

    public init() {}

    public func buyVIP() async {
        EventLogger.log(
            "SubscriptionManager",
            from: TaskContext.source ?? "Unknown"
        )
        DebugLogger.log(
            "SubscriptionManager - purchaseVIPSubscription",
            debugTag: TaskTag.tag
        )

        await apiHandler.initiateSubscription()
    }
}

enum EventLogger {
    static func log(_ name: String, from: String) {
        print("Event: \(name) - Source: \(from)")
    }
}

enum DebugLogger {
    static func log(_ message: String, debugTag: String) {
        print("Debug: \(message) - tag: \(debugTag)")
    }
}
