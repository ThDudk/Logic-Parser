//
//  LogicTree.swift
//  Logic Parser
//
//  Created by Michael Aspinall on 2026-02-10.
//

import Foundation

public enum LogicUnits : Equatable {
    case and
    case biconditional
    case implication
    case not
    case or
    case constant(_ str: String)
    
    public var symbol: String {
        switch (self) {
        case .and:
            return "&"
        case .or:
            return "v"
        case .biconditional:
            return "<->"
        case .implication:
            return "->"
        case .not:
            return "~"
        case .constant(let str):
            return str
        }
    }
    public var name: String {
        switch (self) {
        case .and:
            return "and"
        case .or:
            return "or"
        case .biconditional:
            return "iff"
        case .implication:
            return "implies"
        case .not:
            return "not"
        case .constant(let str):
            return str
        }
    }
}

public class LogicTreeNode: CustomStringConvertible, Equatable {
    public enum TreeBuildErrors : Error {
        case MultipleParentsError
        case AddedChildToConstant
    }
    
    public let data: LogicUnits
    public private(set) var parent: LogicTreeNode?
    private var _left: LogicTreeNode?
    private var _right: LogicTreeNode?
    public var left: LogicTreeNode? {
        get { return _left }
        set(newValue) {
            if newValue == nil {
                _left?.parent = nil
                _left = nil
                return
            }
            guard let child = newValue else { return }
            
            precondition({ if case .constant = data { return false } else { return true } }(), "Cannot add a child to a constant node")
            precondition(child.parent == nil, "Cannot have multiple parents")
            
            child.parent = self
            _left?.parent = nil
            _left = child

        }
    }
    public var right: LogicTreeNode? {
        get { return _right }
        set(newValue) {
            if newValue == nil {
                _right?.parent = nil
                _right = nil
                return
            }
            guard let child = newValue else { return }
            
            precondition({ if case .constant = data { return false } else { return true } }(), "Cannot add a child to a constant node")
            precondition(child.parent == nil, "Cannot have multiple parents")
            
            child.parent = self
            _right?.parent = nil
            _right = child
        }
    }
    public var children: [LogicTreeNode] {
        var array: [LogicTreeNode] = []
        if left != nil {array.append(left!)}
        if right != nil {array.append(right!)}
        return array
    }
    public var allNodes: [LogicTreeNode] {
        var unexplored: [LogicTreeNode] = []
        var nodes: [LogicTreeNode] = []
        unexplored.push(self)
        
        while !unexplored.isEmpty {
            let node = unexplored.pop()!
            unexplored.pushAll(node.children)
            nodes.push(node)
        }
        
        return nodes
    }
    public var allConsts: [LogicTreeNode] {
        var constants: [LogicTreeNode] = []
        
        for node in allNodes {
            if case .constant = node.data {
                if !constants.allSatisfy( {$0.data != node.data}) {continue}
                
                constants.append(node)
            }
        }
        return constants
    }
    
    public var isArgument: Bool {
        precondition(isValidLogicStatement)
        
        return data == .implication
    }
    public var premises: [LogicTreeNode]? {
        precondition(isValidLogicStatement)
        
        guard isArgument else {
            return nil
        }
        
        var premises: [LogicTreeNode] = []
        var rootsToCheck: any Stack<LogicTreeNode> = []
        rootsToCheck.push(left!)
        
        while !rootsToCheck.isEmpty {
            let curr = rootsToCheck.pop()!
            
            if curr.data != .and {
                premises.append(curr)
                continue
            }
            
            rootsToCheck.pushAll([curr.left!, curr.right!])
        }
        
        return premises
    }
    public var conclusion: LogicTreeNode? {
        precondition(isValidLogicStatement)
        
        guard isArgument else {
            return nil
        }
        
        return right
    }
    
    public var isLeaf: Bool { return left == nil && right == nil }
    public var isValidLogicStatement: Bool {
        for node in allNodes {
            switch node.data {
            case .constant:
                return node.isLeaf
            case .not:
                return children.count == 1
            default:
                return children.count == 2
            }
        }
        return false
    }
    public var truthTable: TruthTable {
        return ComprehensiveTruthTable(tree: self)
    }
    
    public var description: String {
        return "LogicTreeNode(data: \(data), children: \(children))"
    }
    
    public init(_ data: LogicUnits) {
        self.data = data
    }
    
    public func graphViz(spellOutLogicUnits: Bool = false) -> GraphViz {
        var graphViz = GraphViz()

        var nodes: [(treeNode: LogicTreeNode, vizNode: GraphViz.Node, parentVizNode: GraphViz.Node?)] = []
        nodes.push((self, graphViz.addNode(label: (spellOutLogicUnits) ? data.name : data.symbol), nil))
        
        
        while !nodes.isEmpty {
            let top = nodes.pop()!
            nodes.pushAll(top.treeNode.children.map({ (
                $0,
                graphViz.addNode(label: (spellOutLogicUnits) ? $0.data.name : $0.data.symbol),
                top.vizNode)
            }))
            
            guard let parentNode = top.parentVizNode else { continue }
            
            graphViz.addEdge(fromId: parentNode.id, toId: top.vizNode.id)
        }
        
        return graphViz
    }
    
    public static func == (lhs: LogicTreeNode, rhs: LogicTreeNode) -> Bool {
        return lhs.data == rhs.data && lhs.children == rhs.children
    }
}

public struct LogicTreeParser {
    public enum Token : Equatable {
        case logicToken (LogicUnits)
        case openningBracket
        case closingBracket
    }
    private struct TokenMatcher{
        let regex: Regex<Substring>
        let tokenProvider: (_ matchString: Substring) -> Token
    }
    /// Array of valid parsing tokens. Tokens will be checked in the array's order.
    private let validTokens: [TokenMatcher] = [
        TokenMatcher(regex: /<->/, tokenProvider: { _ in return .logicToken(.biconditional) }),
        TokenMatcher(regex: /->/, tokenProvider: { _ in return .logicToken(.implication) }),
        TokenMatcher(regex: /\^|&/, tokenProvider: { _ in return .logicToken(.and) }),
        TokenMatcher(regex: /!|~|¬/, tokenProvider: { _ in return .logicToken(.not) }),
        TokenMatcher(regex: /[Vv]/, tokenProvider: { _ in return .logicToken(.or) }),
        TokenMatcher(regex: /[A-Za-z]/, tokenProvider: { match in return .logicToken(.constant(String(match))) }),
        TokenMatcher(regex: /\(|\[/, tokenProvider: { _ in return .openningBracket }),
        TokenMatcher(regex: /\)|\]/, tokenProvider: {_ in return .closingBracket })
    ]
    
    public enum ParseErrors : Swift.Error {
        case unknownToken(tokenStr: String)
        case unexpectedBracketInPostfix
        case IllegalInput(inputString: String)
    }
    
    public func parse(string: String) throws -> LogicTreeNode {
        let cleanedStr = string.replacingOccurrences(of: " ", with: "")
        
        let postfixArray = toPostfixNotation(tokens: try parseTokens(string: cleanedStr))
        
        var stack: [LogicTreeNode] = []
        
        for token in postfixArray {
            switch token {
            case .logicToken(let logicUnit):
                switch (logicUnit) {
                case .constant:
                    stack.push(LogicTreeNode(logicUnit))
                case .not:
                    let node = LogicTreeNode(logicUnit)
                    guard stack.count >= 1 else { throw ParseErrors.IllegalInput(inputString: string) }
                    node.left = stack.pop()!
                    stack.push(node)
                default:
                    let node = LogicTreeNode(logicUnit)
                    guard stack.count >= 2 else { throw ParseErrors.IllegalInput(inputString: string) }
                    node.right = stack.pop()!
                    node.left = stack.pop()!
                    stack.push(node)
                }
            default: throw ParseErrors.unexpectedBracketInPostfix
            }
        }

        guard stack.count == 1 else {
            throw ParseErrors.IllegalInput(inputString: string)
        }
        
        return stack.pop()!
    }
    
    private func toPostfixNotation(tokens: [Token]) -> [Token] {
        var outputStack: [Token] = []
        var operatorStack: [Token] = []
        
        for token in tokens {
            switch token {
            case .logicToken(let logicUnits):
                if case .constant = logicUnits {
                    outputStack.push(token)
                    continue
                }
                if case .not = logicUnits {
                    operatorStack.push(token)
                    continue
                }
                if !operatorStack.isEmpty {
                    outputStack.pushAll(operatorStack.pop(until: {$0 == .openningBracket}))
                }
                operatorStack.push(token)
                
            case .closingBracket:
                let popped = operatorStack.pop(until: { return $0 == Token.openningBracket })
                outputStack.pushAll(popped)
                operatorStack.pop() // get rid of the openning bracket
                
            case .openningBracket:
                operatorStack.push(token)
            }
        }
        
        outputStack.pushAll(operatorStack.popAll())
        
        return outputStack;
    }
    
    private func parseTokens(string: String) throws -> [Token] {
        var tokenArray: [Token] = []
        var currentSubstring: Substring = string[string.startIndex..<string.endIndex]
        
        tokenLoop: while currentSubstring.count > 0 {
            let match = try nextTokenMatch(substring: currentSubstring)
            
            tokenArray.append(match.token)
            currentSubstring = currentSubstring[match.substring.endIndex..<currentSubstring.base.endIndex]
        }
        
        return tokenArray
    }

    private func nextTokenMatch(substring: Substring) throws -> (token: Token, substring: Substring) {
        var earliestTokenMatchIndex: String.Index? = nil
        
        for matcher in validTokens {
            let matchOptional = substring.firstMatch(of: matcher.regex)
            
            guard let match = matchOptional else { continue }
            guard match.range.lowerBound == substring.startIndex else {
                if earliestTokenMatchIndex == nil || match.range.lowerBound < earliestTokenMatchIndex! {
                    earliestTokenMatchIndex = match.range.lowerBound
                }
                continue
            }
            
            let tokenString = substring.base[match.range]
            return (matcher.tokenProvider(tokenString), tokenString)
        }
        
        if earliestTokenMatchIndex == nil {
            throw ParseErrors.unknownToken(tokenStr: String(substring))
        }
        throw ParseErrors.unknownToken(tokenStr: String(substring[substring.startIndex..<earliestTokenMatchIndex!]))
    }
}

public extension LogicTreeNode {
    convenience init(_ rootNode: LogicUnits, @LogicTreeBuilder _ contents: () -> [LogicTreeNode]) {
        self.init(rootNode)
        let contents = contents()
        precondition(contents.count <= 2, "Cannot have Logic Tree Node with more than 2 children.")
        self.left = contents[0]
        self.right = contents[1]
    }
}

@resultBuilder
public struct LogicTreeBuilder {
    public static func buildBlock(_ left: LogicTreeNode, _ right: LogicTreeNode) -> [LogicTreeNode] {
        return [left, right]
    }
}
