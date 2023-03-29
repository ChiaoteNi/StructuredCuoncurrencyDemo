//
//  BasicDemo.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/1/29.
//

import SwiftUI

struct BasicDemoView: View {

    @StateObject var demo = BasicDemo()

    var body: some View {
        GeometryReader { geo in
            Text(demo.message)
                .frame(width: geo.size.width - 50)
                .padding(.all, 25)
                .animation(.linear, value: demo.message)
                .task {
                    await demo.run()
//                    await demo.asyncLet()
//                    demo.limitedThreadPool()
//                    await demo.resultType()

//                    demo.yield("a")
//                    demo.yield("b")
                }
        }
    }
}

struct BasicDemo_Previews: PreviewProvider {
    static var previews: some View {
        BasicDemoView()
    }
}
