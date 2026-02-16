//
//  TruthValidationTests.swift
//  Logic Parser Tests
//
//  Created by Michael Aspinall on 2026-02-16.
//

import Testing
@testable import Logic_Parser

struct TruthValidationTests {
    @Test
    func truthValue_known_and_isTrue() {
        let v = TruthValue(["a": true, "b": false])
        #expect(v.known(constant: "a"))
        #expect(v.known(constant: "b"))
        #expect(!v.known(constant: "c"))
        #expect(v.isTrue(constant: "a") == true)
        #expect(v.isTrue(constant: "b") == false)
        #expect(v.isTrue(constant: "c") == nil)
    }

    @Test
    func truthValue_isTrue_tree() {
        let v = TruthValue(["p": true, "q": false])
        let node = LogicTreeNode(.constant("p"))
        #expect(v.isTrue(tree: node))
        let notNode = LogicTreeNode(.not)
        notNode.left = LogicTreeNode(.constant("q"))
        #expect(v.isTrue(tree: notNode))
    }

    @Test
    func allValues_enumerates_all_assignments() {
        let node = LogicTreeNode(.and)
        node.left = LogicTreeNode(.constant("a"))
        node.right = LogicTreeNode(.constant("b"))
        let table = ComprehensiveTruthTable(tree: node)
        let values = table.allValues()
        #expect(values.count == 4)
        let allComb = Set(values.map { [$0.isTrue(constant: "a"), $0.isTrue(constant: "b")] })
        #expect(allComb == Set([[false, false], [true, false], [false, true], [true, true]]))
    }

    @Test
    func trueValues_and_falseValues_match_expected_results() {
        let node = LogicTreeNode(.or)
        node.left = LogicTreeNode(.constant("a"))
        node.right = LogicTreeNode(.constant("b"))
        let table = ComprehensiveTruthTable(tree: node)
        let trues = table.trueValues()
        let falses = table.falseValues()
        #expect(trues.count == 3)
        #expect(falses.count == 1)
        #expect(trues.contains { $0.isTrue(constant: "a") == true && $0.isTrue(constant: "b") == false })
        #expect(trues.contains { $0.isTrue(constant: "a") == false && $0.isTrue(constant: "b") == true })
        #expect(trues.contains { $0.isTrue(constant: "a") == true && $0.isTrue(constant: "b") == true })
        #expect(falses.contains { $0.isTrue(constant: "a") == false && $0.isTrue(constant: "b") == false })
    }

    @Test
    func tautology_and_contradiction_detection() {
        let taut = LogicTreeNode(.or)
        taut.left = LogicTreeNode(.constant("a"))
        taut.right = LogicTreeNode(.not)
        taut.right!.left = LogicTreeNode(.constant("a"))
        let tTable = ComprehensiveTruthTable(tree: taut)
        #expect(tTable.isTautology())
        let contr = LogicTreeNode(.and)
        contr.left = LogicTreeNode(.constant("a"))
        contr.right = LogicTreeNode(.not)
        contr.right!.left = LogicTreeNode(.constant("a"))
        let cTable = ComprehensiveTruthTable(tree: contr)
        #expect(cTable.isContradiction())
    }
    
    @Test
    func logical_equivalence() throws {
        let parser = LogicTreeParser()
        let table = try parser.parse(string: "p v q").truthTable
        let equal1 = try parser.parse(string: "q v p").truthTable
        let unequal1 = try parser.parse(string: "~p v q").truthTable
        let equal2 = try parser.parse(string: "~p -> q").truthTable
        let equal3 = try parser.parse(string: "~q -> p").truthTable
        
        #expect(table.isLogicallyEquivalent(to: equal1))
        #expect(table.isLogicallyEquivalent(to: equal2))
        #expect(table.isLogicallyEquivalent(to: equal3))
        #expect(!table.isLogicallyEquivalent(to: unequal1))
    }
    
    @Test
    func test_truthValue_equality() {
        let v1 = TruthValue(["a": true, "b": false])
        let v2 = TruthValue(["a": true, "b": false])
        let v3 = TruthValue(["b": false, "a": true])
        let v4 = TruthValue(["a": false, "b": false])
        let v5 = TruthValue(["a": true, "b": false, "c": true])
        let v6 = TruthValue(["a": true])

        #expect(v1 == v2)
        #expect(v1 == v3)
        #expect(v2 == v3)
        #expect(!(v1 == v4))
        #expect(!(v1 == v5))
        #expect(!(v1 == v6))
    }
}
