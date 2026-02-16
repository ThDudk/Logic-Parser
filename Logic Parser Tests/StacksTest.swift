//
//  StacksTest.swift
//  Logic Parser Tests
//
//  Created by Michael Aspinall on 2026-02-11.
//

import Testing
@testable import Logic_Parser

struct StackTest {
    @Test(arguments: [Array<Int>()])
    func push(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        stack.push(1)
        #expect(stack.count == 1)
        #expect(stack.top == 1)
        
        stack.push(2)
        #expect(stack.count == 2)
        #expect(stack.top == 2)
        #expect(stackEquals(stack, [1, 2]))
    }

    @Test(arguments: [Array<Int>([1, 2])])
    func pop(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        let popped = stack.pop()
        #expect(popped == 2)
        #expect(stack.count == 1)
        #expect(stack.top == 1)
        #expect(stackEquals(stack, [1]))
    }
    
    @Test(arguments: [Array<Int>()])
    func isEmpty(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        #expect(stack.isEmpty)
        stack.push(42)
        #expect(!stack.isEmpty)
        _ = stack.pop()
        #expect(stack.isEmpty)
        #expect(stackEquals(stack, []))
    }

    @Test(arguments: [Array<Int>([1, 2, 3])])
    func popAll(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        
        stack.popAll()
        #expect(stackEquals(stack, []))
        
        stack.push(2)
        #expect(stack.top == 2)
    }

    @Test(arguments: [Array<Int>([1, 2, 3, 4])])
    func popUntil_matchesTop(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        
        let popped = stack.pop(until: { $0 == 4 })
        #expect(stackEquals(popped, []))
        #expect(stack.count == 4)
        #expect(stack.top == 4)
        #expect(stackEquals(stack, [1, 2, 3, 4]))
    }

    @Test(arguments: [Array<Int>([1, 2, 3, 4])])
    func popUntil_neverMatches_popsAll(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        
        let popped = stack.pop(until: { _ in false })
        #expect(stackEquals(popped, [4, 3, 2, 1]))
        #expect(stackEquals(stack, []))
    }

    @Test(arguments: [Array<Int>([1, 2, 3, 4, 5])])
    func popUntil_stopsMidway_returnsPoppedInOrder(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        
        let popped = stack.pop(until: { $0 == 3 })
        #expect(stackEquals(popped, [5, 4]))
        #expect(stack.count == 3)
        #expect(stack.top == 3)
        #expect(stackEquals(stack, [1, 2, 3]))
    }
    
    @Test(arguments: [Array<Int>()])
    func pushAll_appendsInOrder(initialStack: any Stack<Int>) async throws {
        var stack = initialStack
        
        stack.pushAll([1, 2, 3])
        #expect(stack.count == 3)
        #expect(stackEquals(stack, [1, 2, 3]))
        
        stack.pushAll([4, 5])
        #expect(stack.count == 5)
        #expect(stackEquals(stack, [1, 2, 3, 4, 5]))
    }
    
    private func stackEquals<T: Equatable>(_ initialStack: any Stack<T>, _ array: [T]) -> Bool {
        var stack = Array(initialStack)
                
        return stack == array
    }
}

