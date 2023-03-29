//
//  MessageProviderStore.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/28.
//

import Foundation

@globalActor
actor MessageStoreActor {
    static let shared = MessageStoreActor()
}

@MainActor
final class MessageProviderStore: ObservableObject, MessageProviderStorageLogic, MessageProviderLogic {
    
    @Published private(set) var messagePresenters: [MessageProviderProxy] = []
    
    var lastPresenter: MessageProviderProxy? { messagePresenters.last }
    
    private(set) var currentMessageID: Int = 0
        
    func add(_ providers: [MessageProviderProxy]) async {
        if let lastID = providers.last?.id {
            currentMessageID = lastID
        }
        messagePresenters.append(contentsOf: providers)
    }
    
    func resetProviders(with newProviders: [MessageProviderProxy]) async {
        currentMessageID = newProviders.last?.id ?? 0
        messagePresenters = newProviders
    }
    
    func getCurrentMessageID() async -> Int {
        currentMessageID
    }
}
