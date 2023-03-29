//
//  SwiftUIView.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/8.
//
// Ref: https://medium.com/@maxnatchanon/swiftui-how-to-get-content-offset-from-scrollview-5ce1f84603ec

import SwiftUI

struct TrackScrollingScrollView<Content: View>: View {
    
    @State var onScrollingAction: ((_ isNearBottom: Bool) -> Void)?
    let content: Content
    
    var body: some View {
        GeometryReader { outsideGeometry in
            ScrollView {
                content
                GeometryReader { insideGeometry in
                    EmptyView().preference(
                        key: ViewOffsetKey.self,
                        value: insideGeometry.frame(in: .global).minY
                    )
                }
                .frame(height: 1, alignment: .center)
                .onPreferenceChange(ViewOffsetKey.self) { newValue in
                    let isNearBottom = Int(newValue) > Int(outsideGeometry.frame(in: .named("scrollView")).maxY)
                    onScrollingAction?(isNearBottom)
                }
            }
            .coordinateSpace(name: "scrollView")
        }
    }
    
    init(@ViewBuilder with content: () -> Content) {
        self.content = content()
    }
    
    func onScrolling(_ action: @escaping (_ isNearBottom: Bool) -> Void) -> Self {
        self.onScrollingAction = action
        return self
    }
}
