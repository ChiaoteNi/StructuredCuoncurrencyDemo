//
//  GroupingTasksDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/29.
//

import SwiftUI

struct GroupingTasksDemoView: View {

    @StateObject var demo = GroupingTasksDemo()

    var body: some View {
        GeometryReader { geo in
            VStack {
                ProgressView(demo.title, value: demo.progress)
                    .frame(width: geo.size.width - 50)
                    .padding(.all, 25)
                Text(demo.message)
                    .frame(width: geo.size.width - 50)
                    .padding(.all, 25)
                    .animation(.linear, value: demo.message)
                    .task {
//                        await demo.downloadResourceWithTasks()
                        await demo.downloadResourceWithTaskGroup()
                    }
            }
        }
    }
}

struct GroupingTasksDemo_Previews: PreviewProvider {
    static var previews: some View {
        GroupingTasksDemoView()
    }
}
