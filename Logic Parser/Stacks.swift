//
//  stacks.swift
//  Logic Parser
//
//  Created by Michael Aspinall on 2026-02-10.
//

import Foundation

public protocol Stack<Element> : Collection {
    var top: Element? {get}
    var count: Int {get}
    
    mutating func push(_ item: Element)
    mutating func pushAll(_ items: any Collection<Element>)
    
    @discardableResult mutating func pop() -> Element?
    @discardableResult mutating func pop(until: (_ item: Element) -> Bool) -> any Stack<Element>
    @discardableResult mutating func popAll() -> any Stack<Element>
}

extension Array : Stack {
    public var top: Element? {last}
    
    @discardableResult
    public mutating func pop() -> Element? {
        return removeLast()
    }
    @discardableResult
    public mutating func pop(until: (_ item: Element) -> Bool) -> any Stack<Element> {
        var array: [Element] = []
        while !isEmpty {
            if until(top!) { return array }

            array.push(pop()!)
        }
        return array
    }
    @discardableResult
    public mutating func popAll() -> any Stack<Element> {
        var array: [Element] = []
        while !isEmpty {
            array.push(pop()!)
        }
        return array
    }
    public mutating func push(_ item: Element) {
        return append(item)
    }
    public mutating func pushAll(_ items: any Collection<Element>) {
        for item in items {
            push(item)
        }
    }
}
