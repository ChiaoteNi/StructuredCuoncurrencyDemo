//
//  SkipProcessDemoView.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/21.
//

import SwiftUI

struct SkipProcessDemoView: View {

    private let interactor: SkipProcessDemoInterfactor

    @StateObject
    private var stateStore: SkipProcessDemoStateStore

    init() {
        let store = SkipProcessDemoStateStore()
        let interactor = SkipProcessDemoInterfactor()

        self.interactor = interactor
        _stateStore = StateObject(wrappedValue: store)

        interactor.stateStore = store
    }

    var body: some View {
        VStack {
            if let message = stateStore.message {
                Text(message)
                    .font(.title)
                    .padding()
            }

            Button("Start process") {
                Task { await interactor.startProcess() }
            }
            .padding()

            Spacer()
        }
        .overlay(
            Group {
                if stateStore.isLoadingViewDisplayed {
                    LoadingView(
                        message: "Processing...",
                        onCancel: { interactor.cancelProcess() }
                    )
                }
            }
        )
    }
}

struct LoadingView : View {

    let message: String
    let onCancel: () -> Void

    var body: some View {
        VStack {
            // A loading indicator
            ProgressView().padding()
            Text(message)
                .font(.caption)
                .padding()

            Button("Skip") {
                onCancel()
            }
            .padding()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.white.opacity(0.8))
    }
}

#Preview {
    SkipProcessDemoView()
}
