//
//  TimeText.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import Foundation
import SwiftUI

struct MessageStatus: View {
    
    private let messageStatus: DisplayMessageStatus
    
    init(with displayStatus: DisplayMessageStatus) {
        self.messageStatus = displayStatus
    }

    var body: some View {
        Text(messageStatus.timeString)
    }
}
