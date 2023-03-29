//
//  MessageLayoutContainer.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import Foundation
import SwiftUI

struct MessageLayoutContainer<Content: View, Sender: View, TimeText: View>: View {
    
    var body: some View {
        VStack {
            HStack {
                makeLeadingSpacerIfNeeded(for: alignRule)
                sender.padding(makePadding(for: alignRule))
                makeTrailingSpacerIfNeeded(for: alignRule)
            }
            HStack {
                makeLeadingSpacerIfNeeded(for: alignRule)
                HStack {
                    makeLeadingTimeTextIfNeeded(for: alignRule, timeText: timeText)
                    content.padding(makePadding(for: alignRule))
                    makeTrailingTimeTextIfNeeded(for: alignRule, timeText: timeText)
                }
                makeTrailingSpacerIfNeeded(for: alignRule)
            }
        }
    }
    
    private let alignRule: MessageLayoutRule
    private let sender: Sender
    private let content: Content
    private let timeText: TimeText
    
    init(
        with alignRule: MessageLayoutRule,
        @ViewBuilder content: () -> Content,
        @ViewBuilder sender: () -> Sender,
        @ViewBuilder timeText: () -> TimeText
    ) {
        self.alignRule = alignRule
        self.sender = sender()
        self.content = content()
        self.timeText = timeText()
    }
    
    private func makePadding(for alignRule: MessageLayoutRule) -> EdgeInsets {
        switch alignRule {
        case .alignRight:    return .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        case .alignLeft:     return .init(top: 0, leading: 15, bottom: 0, trailing: 0)
        case .center:   return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }
    
    @ViewBuilder
    private func makeLeadingSpacerIfNeeded(for alignRule: MessageLayoutRule) -> some View {
        switch alignRule {
        case .alignRight:            Spacer()
        case .alignLeft, .center:    EmptyView()
        }
    }
    
    @ViewBuilder
    private func makeTrailingSpacerIfNeeded(for alignRule: MessageLayoutRule) -> some View {
        switch alignRule {
        case .alignRight, .center:   EmptyView()
        case .alignLeft:             Spacer()
        }
    }
    
    @ViewBuilder
    private func makeLeadingTimeTextIfNeeded(
        for alignRule: MessageLayoutRule,
        timeText: TimeText
    ) -> some View {
        
        switch alignRule {
        case .alignRight:
            VStack{
                Spacer()
                timeText
            }
        case .alignLeft, .center:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func makeTrailingTimeTextIfNeeded(
        for alignRule: MessageLayoutRule,
        timeText: TimeText
    ) -> some View {
        
        switch alignRule {
        case .alignLeft:
            VStack{
                Spacer()
                timeText
            }
        case .alignRight, .center:
            EmptyView()
        }
    }
}

//// MARK: - Previews
//struct MessageSpacer_Previews: PreviewProvider {
//    static var previews: some View {
//        let store: MessageProviderStore = .init()
//        let vm: MessageViewModel = .init(chatID: 12345, userID: 1005)
//        return MessageView(vm: vm, store: store)
//    }
//}

