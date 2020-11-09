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
        case using
        case parameterDeclare
        case parameterPushing
    }
    
    var identifier: String
    
    var address: Int
    
    var depth: Int
    
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
    
    func interpret() throws -> String {
        var result = String()
        
        let sign = address < 0 ? "-" : "+"
        
        switch variableNodeType {
        case .declarationAndAssignment, .changing:
            if let value = value {
                result += try value.interpret()
                result.deleteSufix("push eax\n")
                result += "mov [ebp \(sign) \(abs(address))], eax\n"
            }
        case .onlyDeclaration:
             result += "mov [ebp \(sign) \(abs(address))], 0\n"
        case .using:
            result += "mov \(register), [ebp \(sign) \(abs(address))]\n"
        case .parameterDeclare:
            result += ""
        case .parameterPushing:
            if let value = value {
                result += "\(try value.interpret())"
            }
            result += "push \(register)\n"
        }
        
        return result
    }
}


extension VariableNode: TreeRepresentable {
    
    var name: String {
        
        let sign = address < 0 ? "-" : "+"
        var result = "variable \"\(identifier)\" | \(valueType) | address \(sign)\(abs(address)) | depth \(depth)"
        switch variableNodeType {
        case .declarationAndAssignment:
            result += " | declaration and assign"
        case .onlyDeclaration:
            result += " | declare only"
        case .changing:
            result += " | changing"
        case .using:
            result += " | using | position \(lrPosition.rawValue)"
        case .parameterDeclare:
            result += " | parameter declare"
        case .parameterPushing:
            result = "parameter"
        }
        return result
    }
    
    var subnodes: [Node] {
        return value != nil ? [value!] : []
    }
}
