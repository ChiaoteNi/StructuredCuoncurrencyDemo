//
//  DemoProtocol.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2023/2/7.
//

import Foundation

typealias ObservableDemo = Demo & ObservableObject

protocol Demo: AnyObject {
    var message: AttributedString { get set }
}

extension Demo {

    func logMessage(
        _ text: String,
        threadInfo: String = Thread.current.description
    ) {
        let mainMessage: AttributedString = {
            var result = AttributedString(stringLiteral: text + "\n")
            result.font = .title3
            result.foregroundColor = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute.Value(red: 180/255, green: 29/255, blue: 25/255)
            return result
        }()
        let threadDescription: AttributedString = {
            var result = AttributedString(stringLiteral: threadInfo + "\n")
            result.font = .subheadline
            result.foregroundColor = .blue
            return result
        }()

        message += mainMessage
        message += threadDescription
    }
}
