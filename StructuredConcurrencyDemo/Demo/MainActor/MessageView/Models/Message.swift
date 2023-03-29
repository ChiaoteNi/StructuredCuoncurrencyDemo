//
//  Message.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/10/10.
//

import Foundation

struct Message: Identifiable {
    
    enum MimeType {
        case text(_ content: String)
        case image(_ url: String)
        case sticker(_ url: String)
        case system(_ content: String)
        case unknown
    }
    
    var id: Int
    var sender: User
    var messageType: MimeType
    var dateInSec: Int
}

struct User {
    var id: Int
    var nickname: String
}
