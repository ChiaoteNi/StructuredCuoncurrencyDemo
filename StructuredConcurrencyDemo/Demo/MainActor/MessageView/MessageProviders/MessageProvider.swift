//
//  MessageContext.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/11.
//

import SwiftUI

protocol MessageProvider: IdentifiableObject {
    var messageCell: AnyView { get }
}

class IdentifiableObject: Identifiable, Equatable {
    
    typealias ID = Int
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    static func == (lhs: IdentifiableObject, rhs: IdentifiableObject) -> Bool {
        lhs.id == rhs.id
    }
}
