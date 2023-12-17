//
//  ContentView.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: PART I
                NavigationLink("Basic demo") {
                    BasicDemoView()
                }
                Spacer()
                NavigationLink("Grouping Tasks") {
                    GroupingTasksDemoView()
                }
                Spacer()
                NavigationLink("Cancel Task") {
                    CancelDemoView()
                }
                Spacer()
                NavigationLink("MainActor") {
                    MainActorDemoView()
                }
                // MARK: PART II
                // The demostrations for AsyncSequence will be shown in AsyncSequenceDemoTest.swift and ImageDownloaderWithAsyncSequenceTest.swift
                // Please run the tests to see how they will perform.
                // You can find these tests in the following path:
                // ./Demo/AsyncSequence/AsyncSequenceDemoTests

                // MARK: PART III
                // For demostrations for Actor, you can find them in the following playground files
                // 1. ActorDemo.playground
                // 2. CustomActorExecutorDemo.playground
                // 3. ActorReentrancyDemo.playground
            }
            .padding(50)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
