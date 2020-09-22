//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public protocol Node: TreeRepresentable {
    func interpret<T: Numeric>() throws -> T where T : Numeric
}

struct InfixOperation: Node {
    func interpret<T: Numeric>() throws -> T {
        return 0.0 as! T
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


enum Definition {
    case variable(value: Float)
    case function(FunctionDefinition)
}


struct Block: Node {
    func interpret<T: Numeric>() throws -> T where T : Numeric {
        for line in nodes[0..<(nodes.endIndex - 1)] {
            let some = try line.interpret()
        }
        
        guard let last = nodes.last else {
            throw Parser.Error.expectedExpression
        }
        return try last.interpret()
    }
    
    let nodes: [Node]
    
//    func interpret() throws -> Float {
//        for line in nodes[0..<(nodes.endIndex - 1)] {
//            try line.interpret()
//        }
//
//        guard let last = nodes.last else {
//            throw Parser.Error.expectedExpression
//        }
//        return try last.interpret()
//    }
}

extension Block: TreeRepresentable {
    var name: String {
        return "block"
    }
    
    var subnodes: [Node] {
        return nodes
    }
}

struct FunctionDefinition: Node {
    func interpret<T>() throws -> T where T : Numeric {
        identifiers[identifier] = .function(self)
        return 1 as! T
    }
    // ADDED
    let identifier: String
    let block: Node
    
    func interpret() throws -> Float {
        identifiers[identifier] = .function(self)
        return 1
    }
}

extension FunctionDefinition: TreeRepresentable {
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [block]
    }
}
