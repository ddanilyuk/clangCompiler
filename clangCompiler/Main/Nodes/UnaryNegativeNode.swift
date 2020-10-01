//
//  UnaryNegativeNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.09.2020.
//

import Foundation


struct UnaryNegativeNode: Node {
    
    enum Postition {
        case lhs
        case rhs
    }
    
    var node: Node
    
    var postition: Postition = .rhs
    
    var name: String {
        return "unary negative \(postition)"
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
            numberNode.register = register
            result += try numberNode.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        } else if let operationNode = node as? InfixOperation {
            result += try operationNode.specialInterpretForInfixOperation(isCPPCode: isCPPCode, isNegative: true)
        } else {
            result += try node.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        }
        
        return result
    }
}
