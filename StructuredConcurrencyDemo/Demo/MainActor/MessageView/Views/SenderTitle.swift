//
//  SenderTitle.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import Foundation
import SwiftUI

struct SenderTitle: View {
    
    private let displayModel: DisplaySender
    
    init(with sender: DisplaySender) {
        self.displayModel = sender
    }

    var body: some View {
        Text(displayModel.name)
            .foregroundColor(displayModel.color)
    }
}
