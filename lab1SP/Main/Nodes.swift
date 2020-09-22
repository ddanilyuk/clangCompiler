//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public protocol Node: TreeRepresentable {
}

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

struct ReturnBlock: Node {
    let nodes: [Node]
}

extension ReturnBlock: TreeRepresentable {
    var name: String {
        return "return"
    }
    
    var subnodes: [Node] {
        return nodes
    }
}


struct FunctionDefinition: Node {
//    func interpret<T>() throws -> T where T : Numeric {
//        identifiers[identifier] = .function(self)
//        return 1 as! T
//    }
    // ADDED
    let identifier: String
    let block: Node
    
//    func interpret() throws -> Float {
//        identifiers[identifier] = .function(self)
//        return 1
//    }
}

extension FunctionDefinition: TreeRepresentable {
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [block]
    }
}
