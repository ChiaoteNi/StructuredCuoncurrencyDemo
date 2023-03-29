//
//  FetchLocalMessageWorker.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/11.
//

import Combine
import Foundation

protocol LocalMessageService {
    func fetchLocalMessages(chatID: Int) -> [Message]
}

final class FetchMessageWorker: LocalMessageRepository {
    
    private let messageService: LocalMessageService
    private let chatID: Int
    
    init(chatID: Int, messageService: LocalMessageService) {
        self.messageService = messageService
        self.chatID = chatID
    }
    
    func fetchLocalMessages() -> AnyPublisher<[Message], Error> {
        let messages = messageService.fetchLocalMessages(chatID: chatID)
        return Future<[Message], Error> { promise in
            promise(.success(messages))
        }.eraseToAnyPublisher()
    }
}
