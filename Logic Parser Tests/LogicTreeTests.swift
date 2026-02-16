//
//  LogicTreeTests.swift
//  Logic Parser Tests
//
//  Created by Michael Aspinall on 2026-02-11.
//

import Testing
@testable import Logic_Parser

struct LogicTreeNodeTests {
    @Test
    func data() {
        let node = LogicTreeNode(LogicUnits.and)
        #expect(node.data == LogicUnits.and)
    }
    @Test func parent() {
        let node = LogicTreeNode(LogicUnits.and)
        #expect(node.parent == nil)
        
        let parent = LogicTreeNode(LogicUnits.and)
        parent.left = node
        
        let parentAddress = Unmanaged.passUnretained(parent).toOpaque()
        #expect(Unmanaged.passUnretained(node.parent!).toOpaque() == parentAddress)
        #expect(parent.parent == nil)
    }
    @Test func left() {
        let parent = LogicTreeNode(LogicUnits.and)
        let left = LogicTreeNode(LogicUnits.and)
        #expect(parent.left == nil)
        
        parent.left = left
        
        let leftAddress = Unmanaged.passUnretained(left).toOpaque()
        #expect(Unmanaged.passUnretained(parent.left!).toOpaque() == leftAddress)
        
        parent.left = nil
        #expect(parent.left == nil)
    }
    @Test func right() {
        let parent = LogicTreeNode(LogicUnits.and)
        let right = LogicTreeNode(LogicUnits.and)
        #expect(parent.right == nil)
        
        parent.right = right
        
        let rightAddress = Unmanaged.passUnretained(right).toOpaque()
        #expect(Unmanaged.passUnretained(parent.right!).toOpaque() == rightAddress)
        
        parent.right = nil
        #expect(parent.right == nil)
    }
    @Test func children() {
        let parent = LogicTreeNode(LogicUnits.and)
        #expect(parent.children == [])
        
        let left = LogicTreeNode(LogicUnits.and)
        let right = LogicTreeNode(LogicUnits.and)
        
        parent.left = left
        #expect(parent.children == [left])
        parent.right = right
        #expect(parent.children == [left, right])
        parent.left = nil
        #expect(parent.children == [right])
        parent.right = nil
        #expect(parent.children == [])
    }
    @Test func allNodes() {
        let a = LogicTreeNode(LogicUnits.constant(str: "a"))
        let b = LogicTreeNode(LogicUnits.constant(str: "b"))
        let c = LogicTreeNode(LogicUnits.constant(str: "c"))
        let or = LogicTreeNode(LogicUnits.or)
        let not = LogicTreeNode(LogicUnits.not)
        let and = LogicTreeNode(LogicUnits.and)

        or.left = a
        or.right = b
        not.left = c
        and.left = or
        and.right = not

        let all = and.allNodes
        
        #expect(all.count == 6)
        #expect(all.contains(and))
        #expect(all.contains(or))
        #expect(all.contains(not))
        #expect(all.contains(a))
        #expect(all.contains(b))
        #expect(all.contains(c))
    }
    @Test func allConsts() {
        let a = LogicTreeNode(LogicUnits.constant(str: "a"))
        let b = LogicTreeNode(LogicUnits.constant(str: "b"))
        let c = LogicTreeNode(LogicUnits.constant(str: "c"))
        let or = LogicTreeNode(LogicUnits.or)
        let not = LogicTreeNode(LogicUnits.not)
        let and = LogicTreeNode(LogicUnits.and)

        or.left = a
        or.right = b
        not.left = c
        and.left = or
        and.right = not

        let consts = and.allConsts
        #expect(consts.count == 3)
        #expect(consts.contains(a))
        #expect(consts.contains(b))
        #expect(consts.contains(c))
        #expect(consts.allSatisfy { node in if case .constant = node.data { return true } else { return false } })
    }
}

