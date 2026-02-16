//
//  GraphViz.swift
//  Logic Parser
//
//  Created by Michael Aspinall on 2026-02-10.
//
import Foundation
import StringBuilder

public struct GraphViz : Equatable {
    public struct Node : Equatable {
        public let label: String
        public let id: String
        
        public init(label: String, id: String) {
            self.label = label
            self.id = id
        }
    }

    public struct Edge : Equatable {
        public let fromId: String
        public let toId: String
        
        public init(fromId: String, toId: String) {
            self.fromId = fromId
            self.toId = toId
        }
    }

    public var strict: Bool
    public var directed: Bool
    public private(set) var nodes: [Node] = []
    public private(set) var edges: [Edge] = []
    
    public init(strict: Bool = true, directed: Bool = true) {
        self.strict = strict
        self.directed = directed
    }
    
    /// Adds a node with the text `label` to the graph
    /// - Parameter label: node's label
    /// - Returns: The create `Node` object. This contains the Node's ID and should be stored.
    public mutating func addNode(label: String) -> Node {
        let node = Node(label: label, id: String(nodes.count + 1))
        nodes.append(node)
        return node
    }
    /// Adds an edge between the nodes with ids `fromId` and `toId`.
    ///
    /// Note: In an undirected graph, calling this in both ways will create multiple edges.
    ///
    /// - Parameter fromID: starting node's Id
    /// - Parameter fromID: starting node's Id
    /// - Returns: The created `Edge`.
    @discardableResult
    public mutating func addEdge(fromId: String, toId: String) -> Edge {
        let edge = Edge(fromId: fromId, toId: toId)
        edges.append(edge)
        return edge
    }
    
    /// The DOT language representation of `this`.
    ///
    /// Example:
    /// ```graphviz
    /// strict digraph G {
    ///     1[label="root"]
    ///     2[label="left child"]
    ///     3[label="right child"]
    ///     1 -> 2
    ///     1 -> 3
    /// }
    /// ```
    public var DotString: String {
        return String {
            String(separator: " ") {
                if strict { "strict" }
                (directed) ? "digraph" : "graph"
                "{"
            }
            
            for node in nodes {
                String(separator: "") {
                    "\t"
                    node.id
                    "[label=\""
                    node.label
                    "\"];"
                }
            }
            ""
            for edge in edges {
                String(separator: "") {
                    "\t"
                    edge.fromId
                    " -> "
                    edge.toId
                    ";"
                }
            }
            "}"
        }
    }
}
