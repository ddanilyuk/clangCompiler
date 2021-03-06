//
//  ReturnNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct ReturnNode: Node {
    
    var node: Node
    
    var functionIdenitifer: String
    
    func interpret() throws -> String {
        var result = try node.interpret()
        result += "jmp _ret_\(functionIdenitifer)\n"
        return result
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
