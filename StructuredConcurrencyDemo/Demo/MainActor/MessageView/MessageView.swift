//
//  MessageView.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/10.
//

import SwiftUI
import Combine

@MainActor
protocol MessageProviderLogic: AnyObservableObject {
    var messagePresenters: [MessageProviderProxy] { get }
    var lastPresenter: MessageProviderProxy? { get }
    var currentMessageID: Int { get }
}

struct MessageView: View {
    
    @State private var isScrollToBottomEnable: Bool = true
    @State private var isNearBottom: Bool = true
    
    @Store var store: MessageProviderLogic
    var vm: MessageBusinessLogic
    
    @MainActor
    init(chatID: Int, senderID: Int) {
        let vm: MessageViewModel = .init(chatID: chatID, userID: senderID)
        let store: MessageProviderStore = .init()
        vm.messageProviderStore = store
        
        self.vm = vm
        _store = Store(wrappedValue: store)
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            TrackScrollingScrollView {
                LazyVStack {
                    ForEach(store.messagePresenters, id: \.id) { context in
                        context.messageCell
                    }
                }
            }
            .onScrolling({ isOnBottom in
                isNearBottom = isOnBottom
            })
            .gesture(makeDragGesture())
            .onChange(of: store.messagePresenters) { newValue in
                scrollToBottomIfNeeded(with: scrollView)
            }
            .onAppear {
                vm.fetchLocalMessages(with: .init())
                vm.listenMessages(with: .init())
            }
        }
    }
}

extension MessageView {
    
    @MainActor
    private func scrollToBottomIfNeeded(with scrollView: ScrollViewProxy) {
        guard isScrollToBottomEnable else { return }
        guard let lastID = store.lastPresenter?.id else { return }
        withAnimation {
            scrollView.scrollTo(lastID, anchor: .bottom)
        }
    }
    
    private func makeDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { gesture in
                if isNearBottom, gesture.translation.height < 0 {
                    isScrollToBottomEnable = true
                } else {
                    isScrollToBottomEnable = false
                }
            }
            .onEnded { _ in
                isScrollToBottomEnable = isNearBottom
            }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

//// MARK: - Previews
//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        let store: MessageProviderStore = .init()
//        let vm: MessageViewModel = .init(chatID: 12345, userID: 1005)
//        vm.messageProviderStore = store
//        return MessageView(vm: vm, store: store)
//    }
//}
//
