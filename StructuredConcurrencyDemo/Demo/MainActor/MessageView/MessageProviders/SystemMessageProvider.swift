//
//  SystemMessageContext.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import Foundation
import SwiftUI

final class SystemMessageProvider: IdentifiableObject, MessageProvider {
    
    var messageCell: AnyView {
        AnyView(Group {
            Spacer()
            Text(content)
                .foregroundColor(Color.gray)
                .font(Font.system(size: 15, weight: .medium, design: .default))
                .padding(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
            Spacer()
        })
    }
    
    private let content: String
    
    init(with message: String, id: Int) throws {
        content = message
        super.init(id: id)
    }
}

// MARK: - Previews
struct SystemMessage_Previews: PreviewProvider {
    static var previews: some View {
        try? SystemMessageProvider(with: "14號加入", id: 0) .messageCell
    }
}

