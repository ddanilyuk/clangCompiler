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
    
    // TODO:- add variables count
    
    let parametersBlock: Node
    
    // Block inside function
    let functionBlock: Node
    
    var returnType: Token
    
    func interpret() throws -> String {
        // TODO:- move block interpreting to here
        return try functionBlock.interpret()
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
