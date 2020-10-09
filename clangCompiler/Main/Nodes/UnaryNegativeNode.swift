//
//  UnaryNegativeNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.09.2020.
//

import Foundation


struct UnaryNegativeNode: Node {
    
    enum Postition: String {
        case lhs = "left"
        case rhs = "right"
    }
    
    var node: Node
    
    var postition: Postition = .lhs
    
    var name: String {
        return "unary negative | \(postition.rawValue) position"
    }
    
    var subnodes: [Node] {
        return [node]
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        var register = String()
        
        switch postition {
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
            result += try operationNode.specialInterpretForInfixOperation(isCPPCode: isCPPCode, isNegative: true)
        } else {
            // If node is expression
            result += try node.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        }
        
        return result
    }
}
