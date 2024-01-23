//
//  SkipProcessDemoStateStore.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/21.
//

import Foundation

@MainActor
final class SkipProcessDemoStateStore: SkipProcessDemoStateStoring, ObservableObject {

    @Published
    var processState: SkipProcessDemoState = .idle

    @Published
    var isLoadingViewDisplayed: Bool = false

    @Published
    var message: String?

    func updateState(_ state: SkipProcessDemoState) {
        processState = state

        message = switch state {
        case .idle:             ""
        case .processing:       "Processing"
        case .finish:           "Success"
        case .processCanceled:  "Failed"
        }
    }

    func showLoading() {
        isLoadingViewDisplayed = true
    }

    func hideLoading() {
        isLoadingViewDisplayed = false
    }
}
