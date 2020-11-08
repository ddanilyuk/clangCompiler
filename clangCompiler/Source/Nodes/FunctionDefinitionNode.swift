//
//  FunctionDefinitionNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct FunctionDefinitionNode: Node {
    
    enum FunctionType {
        case onlyDeclaration
        case declarationAndAssignment
        case using
    }
    
    // Funciton name
    let identifier: String
    
    // TODO:- add variables count
    
    var parametersBlock: Node
    
    // Block inside function
    let functionBlock: Node
    
    var returnType: Token
    
    var functionType: FunctionType
    
    var variablesCount: Int
    
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
            result += try parametersBlock.interpret()
            result += "call _\(identifier)\n"
        }
        // TODO:- move block interpreting to here
        return result
    }
}


extension FunctionDefinitionNode: TreeRepresentable {
    
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [parametersBlock, functionBlock]
    }
}
