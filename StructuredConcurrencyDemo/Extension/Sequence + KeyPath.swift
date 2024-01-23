//
//  Sequence + KeyPath.swift
//  StructuredConcurrencyDemo
//
//  Created by Chiaote Ni on 2024/1/21.
//

import Foundation

extension Sequence {

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted(keyPath, by: >)
    }

    func sorted<T: Comparable>(
        _ keyPath: KeyPath<Element, T>,
        by comparation: (T, T) -> Bool
    ) -> [Element] {

        sorted(by: {
            comparation($0[keyPath: keyPath], $1[keyPath: keyPath])
        })
    }
}
