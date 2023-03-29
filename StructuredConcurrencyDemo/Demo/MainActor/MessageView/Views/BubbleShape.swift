//
//  BubbleView.swift
//  IM in SwiftUI
//
//  Created by 倪僑德 on 2021/11/7.
//

import Foundation
import SwiftUI

struct ChatBubble: Shape {
    
    enum Direction {
        case left
        case right
    }

    private let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            addTopPath(
                on: &path,
                in: rect,
                radius: 15,
                direction: direction
            )
            addBottomPath(
                on: &path,
                in: rect,
                radius: 15
            )
        }
    }
    
    private func addTopPath(
        on path: inout Path,
        in rect: CGRect,
        radius: CGFloat,
        direction: Direction
    ) {
        let width = rect.width
        let height = rect.height / 2
        
        path.move(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: radius))
        
        // right-top corner
        switch direction {
        case .right:
            path.addLine(to: CGPoint(x: width, y: 0))
        case .left:
            path.addCurve(
                to: CGPoint(x: width - radius, y: 0),
                control1: CGPoint(x: width, y: radius/2),
                control2: CGPoint(x: width - radius/2, y: 0)
            )
        }
        
        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addLine(to: CGPoint(x: radius, y: 0))
        
        // right-top corner
        switch direction {
        case .right:
            path.addCurve(
                to: CGPoint(x: 0, y: radius),
                control1: CGPoint(x: radius/2, y: 0),
                control2: CGPoint(x: 0, y: radius/2)
            )
        case .left:
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: 0, y: height))
    }
    
    private func addBottomPath(
        on path: inout Path,
        in rect: CGRect,
        radius: CGFloat
    ) {
        let width: CGFloat = rect.width
        let height: CGFloat = rect.height
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: height - radius))
        path.addCurve(to: CGPoint(x: radius, y: height),
                   control1: CGPoint(x: 0, y: height - radius/2),
                   control2: CGPoint(x: radius/2, y: height))
        path.addLine(to: CGPoint(x: width - radius, y: height))
        path.addCurve(to: CGPoint(x: width, y: height - radius),
                   control1: CGPoint(x: width - radius/2, y: height),
                   control2: CGPoint(x: width, y: height - radius/2))
        path.addLine(to: CGPoint(x: width, y: height / 2))
    }
}

// MARK: - Previews
struct Bubble_Previews: PreviewProvider {
    static var previews: some View {
        Color.gray
            .clipShape(ChatBubble(direction: .left))
    }
}


