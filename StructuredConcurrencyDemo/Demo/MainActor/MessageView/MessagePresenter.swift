//
//  MessageAnalyzer.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/11.
//

import Foundation
import SwiftUI

struct MessagePresenter: Identifiable {
    var id: Int { result.id }
    var result: MessageProvider
    
    init(with message: Message, userID: Int) throws {

        switch message.messageType {
        case .text(let content):
            self.result = try TextMessageProvider(
                id: message.id,
                content: content,
                sender: makeDisplaySender(with: message.sender, userID: userID),
                status: makeDisplayStatus(with: message),
                alignRule: getLayoutRule(senderID: message.sender.id, userID: userID)
            )
        case .image(let url):
            self.result = try ImageMessageProvider(
                id: message.id,
                urlString: url,
                sender: makeDisplaySender(with: message.sender, userID: userID),
                status: makeDisplayStatus(with: message),
                alignRule: getLayoutRule(senderID: message.sender.id, userID: userID)
            )
        case .sticker:
            self.result = try StickerMessageProvider(with: message)
        case .system(let content):
            self.result = try SystemMessageProvider(with: content, id: message.id)
        case .unknown:
            throw NSError()
        }
    }
}

private func makeDisplaySender(with sender: User, userID: Int) -> DisplaySender {
    DisplaySender(
        name: sender.nickname,
        color: sender.id == userID ? Color.green : Color.gray
    )
}

private func makeDisplayStatus(with message: Message) -> DisplayMessageStatus {
    let messageTime: Date = Date(
        timeIntervalSince1970: .init(message.dateInSec)
    )
    
    let formatter: DateFormatter = .init()
    if Date().timeIntervalSince(messageTime) > 60 * 60 * 24 {
        formatter.dateFormat = "hh:mm"
    } else {
        formatter.dateFormat = "MM/dd"
    }
    return DisplayMessageStatus(timeString: formatter.string(from: messageTime))
}

private func getLayoutRule(senderID: Int, userID: Int) -> MessageLayoutRule {
    switch senderID {
    case userID:    return .alignRight
    case 0 ... 10:  return .center
    default:        return .alignLeft
    }
}

extension MessagePresenter: Equatable {
    
    static func == (lhs: MessagePresenter, rhs: MessagePresenter) -> Bool {
        lhs.id == rhs.id
    }
}
