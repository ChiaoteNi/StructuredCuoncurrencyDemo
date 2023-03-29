//
//  TextMessageContext.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import SwiftUI

final class TextMessageProvider: IdentifiableObject, MessageProvider {
    
    let content: String
    let sender: DisplaySender
    let status: DisplayMessageStatus
    let alignRule: MessageLayoutRule
    
    var messageCell: AnyView {
        AnyView(Group {
            MessageLayoutContainer(with: alignRule) {
                Text(content)
                    .padding(.init(5))
                    .frame(minWidth: 50, minHeight: 50, alignment: .center)
                    .background(Color.green)
                    .clipShape(makeChatBubbleShape())
            } sender: {
                SenderTitle(with: sender)
            } timeText: {
                MessageStatus(with: status)
            }
        })
    }
    
    init(id: Int,
         content: String,
         sender: DisplaySender,
         status: DisplayMessageStatus,
         alignRule: MessageLayoutRule) throws {
        
        self.content = content
        self.sender = sender
        self.status = status
        self.alignRule = alignRule
        super.init(id: id)
    }
}

extension TextMessageProvider {
    private func makeChatBubbleShape() -> some Shape {
        let direction: ChatBubble.Direction = {
            switch alignRule {
            case .alignLeft:             return .left
            case .alignRight, .center:   return .right
            }
        }()
        
        return ChatBubble(direction: direction)
    }
}

// MARK: - Previews
struct TextMessage_Previews: PreviewProvider {
    static var previews: some View {
        try? TextMessageProvider(
            id: 0,
            content: "這是一則測試訊息",
            sender: DisplaySender(name: "小明", color: .green),
            status: .init(timeString: "昨天"),
            alignRule: .alignLeft
        ).messageCell
    }
}

