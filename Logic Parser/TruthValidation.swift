//
//  TruthValidation.swift
//  Logic Parser
//
//  Created by Michael Aspinall on 2026-02-10.
//

import Foundation

public struct TruthValue: Equatable {
    public let truth: Dictionary<String, Bool>
    
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
    func trueValues() -> [TruthValue]
    func falseValues() -> [TruthValue]
    
    func isTautology() -> Bool
}

public extension TruthTable {
    func isTautology() -> Bool {
        return falseValues().isEmpty
    }
    func isContradiction() -> Bool {
        return trueValues().isEmpty
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
        var variableToIndex: [String: Int] = [:]
        var truthArray: [Bool] = []
        
        for variable in variables {
            variableToIndex[variable] = truthArray.count
            truthArray.append(false)
        }
        
        var truthValues: [TruthValue] = []
        
        while true {
            truthValues.append(TruthValue(truth: variableToIndex.mapValues( {truthArray[$0]} )))
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
    
    public func trueValues() -> [TruthValue] {
        var trueValues: [TruthValue] = []
        
        for values in allValues() {
            if !values.isTrue(tree: tree) {continue}
            trueValues.append(values)
        }
        
        return trueValues
    }
    
    public func falseValues() -> [TruthValue] {
        var falseValues: [TruthValue] = []
        
        for values in allValues() {
            if values.isTrue(tree: tree) {continue}
            falseValues.append(values)
        }
        
        return falseValues
    }
}

