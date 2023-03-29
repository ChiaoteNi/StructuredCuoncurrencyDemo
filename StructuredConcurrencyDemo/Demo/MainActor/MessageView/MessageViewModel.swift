//
//  MessageViewModel.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/10.
//

import SwiftUI
import Combine

protocol MessageBusinessLogic {
    func fetchLocalMessages(with request: Messages.FetchLocalMessages.Request)
    func listenMessages(with request: Messages.ListenMessages.Request)
}

protocol RemoteMessageRepository {
    func listenNewMessages(from startID: Int) -> AnyPublisher<[Message], Error>
}

protocol LocalMessageRepository {
    func fetchLocalMessages() -> AnyPublisher<[Message], Error>
}

protocol MessageProviderStorageLogic {
    func add(_ providers: [MessageProviderProxy]) async
    func resetProviders(with newProviders: [MessageProviderProxy]) async
    func getCurrentMessageID() async -> Int
}

final class MessageViewModel: MessageBusinessLogic {
    
    private let remoteMessageRepo: RemoteMessageRepository
    private let localMessageRepo: LocalMessageRepository
    var messageProviderStore: MessageProviderStorageLogic?
    
    private var cancellables = Set<AnyCancellable>()
    private let userID: Int
    
    init(
        chatID: Int,
        userID: Int,
        remoteMessageProvider: RemoteMessageRepository? = nil,
        localMessageProvider: LocalMessageRepository? = nil
    ) {
        self.userID = userID
        self.remoteMessageRepo = remoteMessageProvider ?? ListenMessageWorker(
            chatID: chatID,
            messageService: FakeMessageService.shared
        )
        self.localMessageRepo = localMessageProvider ?? FetchMessageWorker(
            chatID: chatID,
            messageService: FakeMessageService.shared
        )
    }
    
    func fetchLocalMessages(with request: Messages.FetchLocalMessages.Request) {
        localMessageRepo
            .fetchLocalMessages()
            .tryMapToPresenter(with: userID)
            .sink(receiveCompletion: { _ in }) { providers in
                Task { [weak self] in
                    await self?.messageProviderStore?.resetProviders(with: providers)
                }
            }
            .store(in: &cancellables)
    }
    
    func listenMessages(with request: Messages.ListenMessages.Request) {
        Task {
            let currentMessageID = await messageProviderStore?.getCurrentMessageID() ?? 0
            remoteMessageRepo
                .listenNewMessages(from: currentMessageID)
                .tryMapToPresenter(with: userID)
                .sink(receiveCompletion: { _ in }) { [weak self] providers in
                    Task { [weak self] in
                        await self?.messageProviderStore?.add(providers)
                    }
                }
                .store(in: &cancellables)
        }
    }
}

fileprivate
extension AnyPublisher where Output == [Message] {
    
    func tryMapToPresenter(with userID: Int) -> Publishers.TryMap<Self, [MessageProviderProxy]> {
        tryMap({ messages -> [MessageProviderProxy] in
            try messages
                .compactMap {
                    let provider = try MessagePresenter(with: $0, userID: userID).result
                    let proxy: MessageProviderProxy = .init(with: provider)
                    return proxy
                }
        })
    }
}

final class MessageProviderProxy: IdentifiableObject {
    var messageCell: AnyView { provider.messageCell }
    
    let provider: MessageProvider
    init(with provider: MessageProvider) {
        self.provider = provider
        super.init(id: provider.id)
    }
}
