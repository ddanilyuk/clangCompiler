//
//  FunctionNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct FunctionNode: PositionNode {
    
    enum FunctionType {
        case onlyDeclaration
        case declarationAndAssignment
        case using
    }
            
    // Funciton name
    let identifier: String
        
    var parametersBlock: Node
    
    // Block inside function
    let functionBlock: Node
    
    var returnType: Token
    
    var functionType: FunctionType
    
    var variablesCount: Int
    
    var lrPosition: LRPosition = .lhs
    
    var isUsed = false
    
    var parametersCount: Int {
        get {
            if let block = parametersBlock as? Block {
                return block.nodes.count
            } else {
                return 0
            }
        }
    }
    
    func interpret() throws -> String {
        var result = String()
        switch functionType {
        
        case .declarationAndAssignment:
            
            let esp = variablesCount != 0 ? "\nsub esp, \(variablesCount * 4)" : ""
            result += """
            \n; Start \(identifier) header
            _\(identifier):
            push ebp
            mov ebp, esp \(esp)
            ; End \(identifier) header\n
            """
            
            result += try functionBlock.interpret()
            result.deleteSufix("push eax\n")
            
            result += """
            ; Start \(identifier) footer
            _ret_\(identifier):
            mov esp, ebp
            pop ebp
            ret
            ; End \(identifier) footer
            """
        case .onlyDeclaration:
            
            result += ""
        case .using:
            
            if lrPosition == .rhs {
                result += "push eax\n"
            }
            result += try parametersBlock.interpret()
            
            result += "call _\(identifier)\n"
            result += "add esp, \(parametersCount * 4)\n"
            if lrPosition == .rhs {
                result += "mov ebx, eax\n"
                result += "pop eax\n"
            }
        }
        return result
    }
}


extension FunctionNode: TreeRepresentable {
    
    var name: String {
        return identifier + " | " + lrPosition.rawValue
    }
    
    var subnodes: [Node] {
        return [parametersBlock, functionBlock]
    }
}
