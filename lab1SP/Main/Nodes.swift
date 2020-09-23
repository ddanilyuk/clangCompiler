//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation

// Empty protocol node
// Next will be used for implement iterator
public protocol Node: TreeRepresentable { }

// Operators
struct InfixOperation: Node {
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


enum Definition {
    case variable(value: Float)
    case function(FunctionDefinition)
}


struct Block: Node {
    let blockName: String
    let nodes: [Node]
}

extension Block: TreeRepresentable {
    var name: String {
        return blockName
    }
    
    var subnodes: [Node] {
        return nodes
    }
}


struct FunctionDefinition: Node {
    let identifier: String
    let block: Node
}

extension FunctionDefinition: TreeRepresentable {
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [block]
    }
}
