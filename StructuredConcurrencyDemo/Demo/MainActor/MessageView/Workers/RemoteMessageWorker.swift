//
//  RemoteMessageWorker.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/5.
//

import Foundation
import Combine

protocol RemoteMessageService {
    func listenNewMessages(of chatID: Int, from startID: Int) -> AnyPublisher<[Message], Error>
    func send(message: MessageRequest, to chatID: Int) -> AnyPublisher<Message, Error>
}

final class ListenMessageWorker: RemoteMessageRepository {
    
    private let messageService: RemoteMessageService
    private let chatID: Int
    
    private let scheduler: DispatchQueue = .init(label: "com.listenNewMessages")
    private var currentPublisher: AnyPublisher<[Message], Error>?
    
    init(chatID: Int, messageService: RemoteMessageService) {
        self.chatID = chatID
        self.messageService = messageService
    }
    
    func listenNewMessages(from startID: Int) -> AnyPublisher<[Message], Error> {
        messageService
            .listenNewMessages(of: chatID, from: startID)
            .collect(.byTimeOrCount(scheduler, 0.25, 5))
            .map { $0.flatMap { $0 } }
            .eraseToAnyPublisher()
    }
}
