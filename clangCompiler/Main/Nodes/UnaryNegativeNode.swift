//
//  UnaryNegativeNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.09.2020.
//

import Foundation


struct UnaryNegativeNode: PositionNode {
    
    var node: Node
    
    var lrPosition: LRPosition = .lhs
    
    var name: String {
        return "unary negative | \(lrPosition.rawValue) position"
    }
    
    var subnodes: [Node] {
        return [node]
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        var register = String()
        
        switch lrPosition {
        case .lhs:
            register = "eax"
        case .rhs:
            register = "ebx"
        }
    
        if var numberNode = node as? NumberNode {
            // If node is number
            numberNode.register = register
            result += try numberNode.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        } else if let operationNode = node as? BinaryOperationNode {
            // If node is Binary operation
            result += try operationNode.specialInterpret(isCPPCode: isCPPCode, isNegative: true)
        } else if var variable = node as? VariableNode {
            // If node is expression
            variable.lrPosition = lrPosition
            result += try variable.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        } else {
            assertionFailure("Something unexpected in unary negative node")
        }
        
        return result
    }
}
