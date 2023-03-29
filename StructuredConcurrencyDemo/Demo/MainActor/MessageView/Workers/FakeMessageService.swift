//
//  FakeMessageWorker.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/5.
//

import Foundation
import Combine

private actor PublisherStore {
    
    final class MessagePublisherCache {
        let publisher: PassthroughSubject<[Message], Error>
        var currentMessageID: Int
        
        init(publisher: PassthroughSubject<[Message], Error>, startID: Int) {
            self.publisher = publisher
            self.currentMessageID = startID
        }
    }
    
    private var caches: [Int: MessagePublisherCache] = [:]

    func get(for chatID: Int) -> MessagePublisherCache? {
        return caches[chatID]
    }
    
    func set(_ publisher: MessagePublisherCache, for chatID: Int) {
        return caches[chatID] = publisher
    }
    
    func remove(for chatID: Int) {
        caches[chatID] = nil
    }
}

final class FakeMessageService {
    
    static let shared: FakeMessageService = .init()
    
    private let publisherStore: PublisherStore = .init()
    private let users: [Int: String]
    
    init() {
        let keyValues = ["大雄", "怡靜", "技安", "阿福", "小叮噹", "小明"]
            .enumerated()
            .map { ($0.offset + 1000, $0.element) }
        users = Dictionary(uniqueKeysWithValues: keyValues)
    }
}

//MARK: - RemoteMessageService func.
extension FakeMessageService: RemoteMessageService {
    
    func listenNewMessages(of chatID: Int, from startID: Int) -> AnyPublisher<[Message], Error> {
        let publisher = PassthroughSubject<[Message], Error>()
        Task(priority: .medium) {
            await publisherStore.set(
                .init(publisher: publisher,
                      startID: startID),
                for: chatID
            )
            
            while let cache = await publisherStore.get(for: chatID) {
                let limit: Int = .random(in: 0 ..< 3)
                let messages: [Message] = self.getFakeMessages(
                    from: cache.currentMessageID,
                    limit: limit,
                    userList: self.users
                )
                cache.currentMessageID += limit
                cache.publisher.send(messages)
                try await Task.sleep(
                    nanoseconds: .random(in: 50 ..< 100) * 1000 * 1000
                )
            }
        }
        return publisher
            .eraseToAnyPublisher()
    }
    
    func send(message: MessageRequest, to chatID: Int) -> AnyPublisher<Message, Error> {
        let publisher = Future<Message, Error> { promise in
            Task { [weak self] in
                guard let self = self,
                        let cache = await self.publisherStore.get(for: chatID) else {
                    promise(.failure(NSError()))
                    return
                }
                cache.currentMessageID += 1
                let message: Message = .init(
                    id: cache.currentMessageID,
                    sender: .init(
                        id: message.senderID,
                        nickname: self.users[message.senderID] ?? "未知的使用者"
                    ),
                    messageType: message.messageType,
                    dateInSec: Int(Date().timeIntervalSince1970)
                )
                cache.publisher.send([message])
                await self.publisherStore.remove(for: chatID)
                promise(.success(message))
            }
        }
        return publisher.eraseToAnyPublisher()
    }
}

//MARK: - LocalMessageService func.
extension FakeMessageService: LocalMessageService {
    
    func fetchLocalMessages(chatID: Int) -> [Message] {
        return getFakeMessages(from: 0, limit: 15, userList: users)
    }
}

//MARK: - Private func.
extension FakeMessageService {
    
    private func getFakeMessages(from initialID: Int, limit: Int, userList: [Int: String]) -> [Message] {
        return (initialID ..< initialID + limit).compactMap { index in
            let mimeType: Message.MimeType = getRandomMimeType(with: "\(index)")
            
            let sender: User
            if case .system = mimeType {
                sender = .init(id: 5, nickname: "系統")
            } else {
                sender = getRandomUser(from: userList)
            }
            
            return Message(
                id: index,
                sender: sender,
                messageType: mimeType,
                dateInSec: Int(Date().timeIntervalSince1970)
            )
        }
    }
    
    private func getRandomUser(from users: [Int: String]) -> User {
        let id: Int = Int.random(in: 0 ..< users.count) + 1000
        return .init(id: id, nickname: users[id] ?? "")
    }
    
    private func getRandomMimeType(with content: String) -> Message.MimeType {
        let randomNumber: Int = .random(in: 0 ..< 4)
        switch randomNumber {
        case 0, 2:
            return .text("你好\(content)")
        case 1:
            let url = Int.random(in: 0 ..< 2) == 0
            ? "https://miro.medium.com/max/600/1*wJYe1ykDuMRf2HtUxh6OgA.png"
            : "https://miro.medium.com/max/700/1*KPzhKyjVgwstT7II-cOB1Q.png"
            return .image(url)
        default:
            return .system("有人加入\(content)")
        }
    }
}
