//
//  MainActorDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/29.
//

import SwiftUI

struct MainActorDemoView: View {

    @StateObject var demo = MainActorDemo()

    var body: some View {
        textView()
            .task {
                await demo.orderOfExecution()
                    }
//        messageView()
//            .task {
////                await demo.executeLongTimeJob()
//                await demo.executeLongTimeJobInTask()
//            }
    }

    @ViewBuilder
    private func messageView() -> some View {
        MessageView(chatID: 12345, senderID: 1005)
    }

    @ViewBuilder
    private func textView() -> some View {
        GeometryReader { geo in
            Text(demo.message)
                .frame(width: geo.size.width - 50)
                .padding(.all, 25)
                .animation(.linear, value: demo.message)
        }
    }
}

struct MainActorDemo_Previews: PreviewProvider {
    static var previews: some View {
        MainActorDemoView()
    }
}
