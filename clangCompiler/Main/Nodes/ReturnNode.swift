//
//  ReturnNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct ReturnNode: Node {
    
    var node: Node
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try node.interpret(isCPPCode: isCPPCode)
    }
}


extension ReturnNode: TreeRepresentable {
    var name: String {
        return "return"
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
