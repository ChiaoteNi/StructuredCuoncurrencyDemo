import UIKit

final class TaskLocalDemoViewController: UIViewController {

    private let pageID = "Store Page"
    private let subscriptionManager = SubscriptionManager()

    @objc
    func handleVIPButtonTapped() {
        Task {
            // Use case 1: Passing value through layers for event logging
            await TaskContext.$source.withValue(pageID) {
                await subscriptionManager.buyVIP()
            }

            // Use case 2: Tagging for debugging purposes
            await Task(tag: "handleVIPButtonTapped") {
                await self.subscriptionManager.buyVIP()
            }
        }
    }
}

// Example usage
let demoViewController = TaskLocalDemoViewController()
demoViewController.handleVIPButtonTapped()
