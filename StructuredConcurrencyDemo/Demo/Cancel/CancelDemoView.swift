//
//  CancelDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/29.
//

import SwiftUI

struct CancelDemoView: View {

    @StateObject var demo = CancelDemo()

    var body: some View {
        GeometryReader { geo in
            Text(demo.message)
                .frame(width: geo.size.width - 10)
                .padding(.all, 5)
                .animation(.linear, value: demo.message)
                .task {
                    await demo.statusWhenParentTaskCanceled()
//                    await demo.statusWhenOtherTaskThrowsError()
                }
        }
    }
}

struct CancelDemo_Previews: PreviewProvider {
    static var previews: some View {
        CancelDemoView()
    }
}
