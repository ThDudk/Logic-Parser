//
//  Logic_Parser_Tests.swift
//  Logic Parser Tests
//
//  Created by Michael Aspinall on 2026-02-11.
//

import Testing
@testable import Logic_Parser
import StringBuilder

struct GraphVizTests {
    @Test func addNode() async throws {
        var graphViz = GraphViz()
        let _ = graphViz.addNode(label: "hi")
        
        #expect(graphViz.nodes.count == 1)
        #expect(graphViz.nodes.map({$0.label}) == ["hi"])
    }
    @Test func addRepeatedNode() async throws {
        var graphViz = GraphViz()
        let _ = graphViz.addNode(label: "node")
        let _ = graphViz.addNode(label: "node")
        
        #expect(graphViz.nodes.count == 2)
        #expect(graphViz.nodes.map({$0.label}) == ["node", "node"])
    }
    
    @Test func addEdge() async throws {
        var graphViz = GraphViz()
        
        let root = graphViz.addNode(label: "root")
        let left = graphViz.addNode(label: "left child")
        let right = graphViz.addNode(label: "right child")
        
        graphViz.addEdge(fromId: root.id, toId: left.id)
        graphViz.addEdge(fromId: root.id, toId: right.id)
        
        #expect(graphViz.edges.count == 2)
        #expect(graphViz.edges == [
            GraphViz.Edge(fromId: root.id, toId: left.id),
            GraphViz.Edge(fromId: root.id, toId: right.id)]
        )
    }
    @Test func string() async throws {
        var graphViz = GraphViz()
        
        let root = graphViz.addNode(label: "root")
        let left = graphViz.addNode(label: "left child")
        let right = graphViz.addNode(label: "right child")
        
        graphViz.addEdge(fromId: root.id, toId: left.id)
        graphViz.addEdge(fromId: root.id, toId: right.id)
        
        let body = String {
            "\t1[label=\"root\"];"
            "\t2[label=\"left child\"];"
            "\t3[label=\"right child\"];"
            ""
            "\t1 -> 2;"
            "\t1 -> 3;"
            "}"
        }
        
        graphViz.strict = true
        graphViz.directed = true
        
        #expect(graphViz.DotString == String {
            "strict digraph {"
            body
        })
        
        graphViz.strict = false
        graphViz.directed = true
        
        #expect(graphViz.DotString == String {
            "digraph {"
            body
        })
        
        graphViz.strict = true
        graphViz.directed = false
        
        #expect(graphViz.DotString == String {
            "strict graph {"
            body
        })
        
        graphViz.strict = false
        graphViz.directed = false
        
        #expect(graphViz.DotString == String {
            "graph {"
            body
        })
    }

}
