//
//  VariableNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 10.10.2020.
//

import Foundation


struct VariableNode: Node {
    
    enum VariableType {
        case declarationAndAssignment
        case onlyDeclaration
        case changing
        case getting
    }
    
    var identifier: String
    
    var position: Int
    
    var value: Node?
        
    var valueType: Token
    
    var variableNodeType: VariableType
    
    var lrPosition: LRPosition = .lhs
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        
        switch variableNodeType {
        case .declarationAndAssignment, .changing:
            if let value = value {
                result += try value.interpret(isCPPCode: isCPPCode)
                result.deleteSufix("push eax\n")
                result += "mov [\(position) + ebp], eax\n"
            }
        case .onlyDeclaration:
            result += "mov [\(position) + ebp], 0\n"
        case .getting:
            var register = String()
            
            switch lrPosition {
            case .lhs:
                register = "eax"
            case .rhs:
                register = "ebx"
            }
            
            result += "mov \(register), [\(position) + ebp]\n"
        }
        
        return result
    }
}


extension VariableNode: TreeRepresentable {
    
    var name: String {
        var result = "variable \"\(identifier)\" | \(valueType) | position \(position)"
        switch variableNodeType {
        case .declarationAndAssignment:
            result += " | declaration and assign"
        case .onlyDeclaration:
            result += " | declare only"
        case .changing:
            result += " | changing"
        case .getting:
            result += " | using | lrPosition \(lrPosition.rawValue)"
        }
        return result
    }
    
    var subnodes: [Node] {
        if let node = value {
            return [node]
        } else {
            return []
        }
    }
}
