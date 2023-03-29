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
//                Spacer()
//                NavigationLink("Sendable") {
//                    SendableDemoView()
//                }
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
