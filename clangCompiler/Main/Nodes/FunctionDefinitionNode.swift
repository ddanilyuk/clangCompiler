//
//  FunctionDefinitionNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct FunctionDefinitionNode: Node {
    // Funciton name
    let identifier: String
    
    // Block inside function
    let block: Node
    
    var returnType: Token
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try block.interpret(isCPPCode: isCPPCode)
    }
}


extension FunctionDefinitionNode: TreeRepresentable {
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [block]
    }
}
