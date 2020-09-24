//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation

// Empty protocol node.
// Next will be used for implement iterator.
public protocol Node: TreeRepresentable {
    func interpret() throws -> String
}


// Not used. Will be used for storing variables or functions.
enum Definition {
    case variable(value: Float)
    case function(FunctionDefinitionNode)
}


// Operators
struct InfixOperation: Node {
    
    func interpret() throws -> String {
        return "(\(try lhs.interpret()) \(op.rawValue) \(try rhs.interpret()))"
    }
    
    let op: Operator
    let lhs: Node
    let rhs: Node
    var precedence: Int {
        switch op {
        case .minus, .plus: return 10
        case .times, .divideBy: return 20
        }
    }
}

extension InfixOperation: TreeRepresentable {
    var name: String {
        return op.rawValue
    }
    
    var subnodes: [Node] {
        return [lhs, rhs]
    }
}


// Block can have multiple nodes.
struct Block: Node {
    
    enum BlockType: String {
        case function = "function"
        case startPoint = "start point"
    }
    
    let nodes: [Node]

    var blockType: BlockType
    
    func interpret() throws -> String {
        var result = String()

        for line in nodes {
            result += try line.interpret()
        }

        return result
    }
}


extension Block: TreeRepresentable {
    var name: String {
        return blockType.rawValue
    }
    
    var subnodes: [Node] {
        return nodes
    }
}
