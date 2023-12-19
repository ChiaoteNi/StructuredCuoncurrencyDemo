//
//  CustomTask.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/12/19.
//

import Foundation

public enum TaskTag {
    @TaskLocal
    static var tag: String = ""
}

public extension Task where Failure == Never {

    init(
        tag: String,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) {
        self.init(priority: priority) {
            await TaskTag.$tag.withValue(tag) {
                await operation()
            }
        }
    }
}
