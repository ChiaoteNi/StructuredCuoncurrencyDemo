//
//  GroupingTasksDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/31.
//

import Foundation

protocol ResourceService: Sendable {
    var description: String { get }
    func fetchResource() async
}

final class GroupingTasksDemo: ObservableDemo {

    @Published
    var progress: Double = 0

    @Published
    var title: String = ""

    @Published
    var message: AttributedString = ""

    private let resourceServices: [ResourceService] = [
        FontService(),
        IconService(),
        VideoService(),
        StickerService()
    ]

    func downloadResourceWithTasks() async {
        let tasks = resourceServices.map { service in
            Task {
                await service.fetchResource()
                await logMessage(service.description + " downloaded")
//                return service.description
            }
        }

        for task in tasks {
            await task.value
            await updateProgress()

//            let resourceType = await task.value
//            await updateProgress()
//            await logMessage(resourceType + " downloaded")
        }

        await logMessage("🎊Finished🎊")
    }

    func downloadResourceWithTaskGroup() async {
        // Case 1: Do without result
//        await withTaskGroup(of: String.self) { group in
//            resourceServices.forEach { service in
//                group.addTask {
//                    await service.fetchResource()
//                    await self.updateProgress()
//                    await self.logMessage(service.description + " downloaded")
//                    return service.description
//                }
//            }
//        }
//        await logMessage("🎊Finished🎊")

        // Case 2: Do with results
        let results = await withTaskGroup(of: String.self, returning: [String].self) { group in
            resourceServices.forEach { service in
                group.addTask {
                    await service.fetchResource()
                    await self.updateProgress()
                    await self.logMessage(service.description + " downloaded")
                    return service.description
                }
            }
            return await group.reduce(into: [String](), { partialResult, result in
                partialResult.append(result)
            })
        }
        await logMessage("🎊Finished🎊 \(results)")
    }
}

extension GroupingTasksDemo {

    @MainActor
    private func resetStatus() {
        progress = 0
        title.removeAll()
        message = ""
    }

    @MainActor
    private func updateProgress() {
        let additionalProgress = 1 / Double(resourceServices.count)
        progress += additionalProgress
        title = "\(Int(progress * 100)) %"
    }

    @MainActor
    func logMessage(
        _ text: String,
        threadInfo: String = Thread.current.description
    ) {
        let mainMessage: AttributedString = {
            var result = AttributedString(stringLiteral: text + "\n")
            result.font = .subheadline
            result.foregroundColor = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute.Value(red: 180/255, green: 29/255, blue: 25/255)
            return result
        }()
        let threadDescription: AttributedString = {
            var result = AttributedString(stringLiteral: threadInfo + "\n")
            result.font = .caption
            result.foregroundColor = .blue
            return result
        }()

        message += mainMessage
        message += threadDescription
    }
}
