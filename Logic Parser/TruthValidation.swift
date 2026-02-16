//
//  TruthValidation.swift
//  Logic Parser
//
//  Created by Michael Aspinall on 2026-02-10.
//

import Foundation
import KindaSortaEqual

public struct TruthValue: Equatable, Hashable {
    public let truth: Dictionary<String, Bool>
    
    public static func == (lhs: TruthValue, rhs: TruthValue) -> Bool {
        return lhs.truth.values.hasSameElements(as: rhs.truth.values)
    }
    
    public init(_ truth: Dictionary<String, Bool> = [:]) {
        self.truth = truth
    }
    
    public func known(constant: String) -> Bool {
        return truth.keys.contains(constant)
    }
    public func isTrue(constant: String) -> Bool? {
        return truth[constant]
    }
    
    public func isTrue(tree: LogicTreeNode) -> Bool {
        precondition(tree.isValidLogicStatement)
        precondition(tree.allNodes.allSatisfy({ LogicTreeNode in
            guard case LogicUnits.constant(let const) = LogicTreeNode.data else {return true}
            
            return known(constant: const)
        }))
        
        return isTrueSafe(tree)
    }
    private func isTrueSafe(_ tree: LogicTreeNode) -> Bool {
        switch tree.data {
        case .constant(let string):
            return truth[string]!
        case .and:
            return isTrueSafe(tree.left!) && isTrueSafe(tree.right!)
        case .or:
            return isTrueSafe(tree.left!) || isTrueSafe(tree.right!)
        case .biconditional:
            let leftTrue = isTrueSafe(tree.left!)
            let rightTrue = isTrueSafe(tree.right!)
            return (leftTrue && rightTrue) || (!leftTrue && !rightTrue)
        case .implication:
            return isTrueSafe(tree.right!) || !isTrueSafe(tree.left!)
        case .not:
            return !isTrueSafe(tree.children[0])
        }
    }
}

public protocol TruthTable {
    func allValues() -> [TruthValue]
    func allValues(when: TruthValue) -> [TruthValue]
    func trueValues() -> [TruthValue]
    func trueValues(when: TruthValue) -> [TruthValue]
    func falseValues() -> [TruthValue]
    func falseValues(when: TruthValue) -> [TruthValue]
    
    func isTautology() -> Bool
    func isLogicallyEquivalent(to: TruthTable) -> Bool
}

public extension TruthTable {
    func isTautology() -> Bool {
        return falseValues().isEmpty
    }
    func isContradiction() -> Bool {
        return trueValues().isEmpty
    }
    func isLogicallyEquivalent(to: TruthTable) -> Bool {
        let trueValues = trueValues()
        let otherTrueValues = to.trueValues()
        
        return trueValues.hasSameElements(as: otherTrueValues)
    }
}

struct ComprehensiveTruthTable : TruthTable {
    public let tree: LogicTreeNode
    public var variables: [String] {
        tree.allConsts.map { node in
            guard case .constant(let string) = node.data else {
                preconditionFailure("Expected only .constant nodes in allConsts")
            }
            return string
        }
    }
    
    public func allValues() -> [TruthValue] {
        return allValues(when: TruthValue())
    }
    public func allValues(when: TruthValue) -> [TruthValue] {
        var variableToIndex: [String: Int] = [:]
        var truthArray: [Bool] = []
        
        for variable in variables {
            variableToIndex[variable] = truthArray.count
            truthArray.append(false)
        }
        
        var truthValues: [TruthValue] = []
        
        while true {
            let curr = TruthValue(variableToIndex.mapValues( {truthArray[$0]} ))
            
            var allMatch = true
            for variable in variables {
                if when.known(constant: variable) && when.isTrue(constant: variable) != curr.isTrue(constant: variable) {
                    allMatch = false
                    break;
                }
            }
            
            if allMatch {truthValues.append(curr)}
            
            if !truthArray.contains(false) {break}
            truthArray = iterate(array: truthArray)
        }
        
        return truthValues
    }
    private func iterate(array: [Bool]) -> [Bool] {
        var newArray = array
        
        for idx in newArray.indices {
            if newArray[idx] {
                newArray[idx] = false
                continue
            }
            
            newArray[idx] = true
            break
        }
        
        return newArray
    }
    
    func trueValues() -> [TruthValue] {
        return trueValues(when: TruthValue())
    }
    func falseValues() -> [TruthValue] {
        return falseValues(when: TruthValue())
    }
    public func trueValues(when: TruthValue) -> [TruthValue] {
        var trueValues: [TruthValue] = []
        
        for values in allValues(when: when) {
            if !values.isTrue(tree: tree) {continue}
            trueValues.append(values)
        }
        
        return trueValues
    }
    
    public func falseValues(when: TruthValue) -> [TruthValue] {
        var falseValues: [TruthValue] = []
        
        for values in allValues(when: when) {
            if values.isTrue(tree: tree) {continue}
            falseValues.append(values)
        }
        
        return falseValues
    }
}

