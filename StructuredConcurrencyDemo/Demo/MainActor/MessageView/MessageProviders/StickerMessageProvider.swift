//
//  StickerMessageContext.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
// c c

import SwiftUI

final class StickerMessageProvider: IdentifiableObject, MessageProvider {
    
    var messageCell: AnyView {
        AnyView(Group(content: {
            Text("貼圖訊息")
        }))
    }
    
    private let url: URL
    
    init(with message: Message) throws {
        switch message.messageType {
        case .sticker(let urlString):
            if let url = URL(string: urlString) {
                self.url = url
            } else {
                throw NSError()
            }
        default:
            throw NSError()
        }
        super.init(id: message.id)
    }
}
