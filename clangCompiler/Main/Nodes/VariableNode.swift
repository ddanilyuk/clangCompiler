//
//  VariableNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 10.10.2020.
//

import Foundation


struct VariableNode: PositionNode {
    
    enum VariableType {
        case declarationAndAssignment
        case onlyDeclaration
        case changing
        case getting
    }
    
    var identifier: String
    
    var address: Int
    
    var value: Node?
        
    var valueType: Token
    
    var variableNodeType: VariableType
    
    var lrPosition: LRPosition = .lhs {
        didSet {
            switch lrPosition {
            case .lhs:
                register = "eax"
            case .rhs:
                register = "ebx"
            }
        }
    }
    
    var register: String = "eax"
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        
        switch variableNodeType {
        case .declarationAndAssignment, .changing:
            if let value = value {
                result += try value.interpret(isCPPCode: isCPPCode)
                result.deleteSufix("push eax\n")
                result += "mov [ebp - \(address)], eax\n"
            }
        case .onlyDeclaration:
             result += "mov [ebp - \(address)], 0\n"
        case .getting:
            result += "mov \(register), [ebp - \(address)]\n"
        }
        
        return result
    }
}


extension VariableNode: TreeRepresentable {
    
    var name: String {
        var result = "variable \"\(identifier)\" | \(valueType) | address \(address)"
        switch variableNodeType {
        case .declarationAndAssignment:
            result += " | declaration and assign"
        case .onlyDeclaration:
            result += " | declare only"
        case .changing:
            result += " | changing"
        case .getting:
            result += " | using | position \(lrPosition.rawValue)"
        }
        return result
    }
    
    var subnodes: [Node] {
        return value != nil ? [value!] : []
    }
}
