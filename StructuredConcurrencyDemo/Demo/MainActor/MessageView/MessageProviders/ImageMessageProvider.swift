//
//  ImageMessageContext.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import SwiftUI

final class ImageMessageProvider: IdentifiableObject, MessageProvider {
    
    var messageCell: AnyView {
        AnyView(Group(content: {
            MessageLayoutContainer(with: alignRule) {
                Image("ILOVEMYJOB.png", bundle: nil)
                    .frame(width: 150, height: 100)
                    .background(Color.gray)
                    .clipShape(makeChatBubbleShape())
            } sender: {
                SenderTitle(with: sender)
            } timeText: {
                MessageStatus(with: status)
            }
        }))
    }
    
    private let url: URL
    private let sender: DisplaySender
    private let status: DisplayMessageStatus
    private let alignRule: MessageLayoutRule
    
    init(id: Int,
         urlString: String,
         sender: DisplaySender,
         status: DisplayMessageStatus,
         alignRule: MessageLayoutRule) throws {
        
        guard let url = URL(string: urlString) else { throw NSError() }
        self.url = url
        self.sender = sender
        self.status = status
        self.alignRule = alignRule
        super.init(id: id)
    }
}

extension ImageMessageProvider {
    
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

//// MARK: - Previews
//struct ImageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let store: MessageProviderStore = .init()
//        let vm: MessageViewModel = .init(chatID: 12345, userID: 1005)
//        vm.messageProviderStore = store
//        return MessageView(vm: vm, store: store)
//    }
//}
