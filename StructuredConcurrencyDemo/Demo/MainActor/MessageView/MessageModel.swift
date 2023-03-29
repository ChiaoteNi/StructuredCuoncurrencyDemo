//
//  MessageModel.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/8.
//

import Foundation
import SwiftUI

enum MessageLayoutRule {
    case alignLeft, alignRight, center
}

struct DisplaySender {
    let name: String
    let color: Color
}

struct DisplayMessageStatus {
    let timeString: String
}


enum Messages {
    
    enum FetchLocalMessages {
        struct Request {
            
        }
        
        struct Response {
            
        }
    }
    
    enum ListenMessages {
        struct Request {
            
        }
        
        struct Response {
            
        }
    }
}
