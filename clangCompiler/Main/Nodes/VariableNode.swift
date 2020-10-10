//
//  VariableNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 10.10.2020.
//

import Foundation


struct VariableNode: Node {
    
    var value: Node?
    
    var identifier: String
    
    var returnType: Token
    
    func interpret(isCPPCode: Bool) throws -> String {
        return ""
    }
}


extension VariableNode: TreeRepresentable {
    var name: String {
        return "\(identifier) | \(returnType)"
    }
    
    var subnodes: [Node] {
        if let node = value {
            return [node]
        } else {
            return []
        }
    }
}
