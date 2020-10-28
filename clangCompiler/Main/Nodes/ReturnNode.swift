//
//  ReturnNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct ReturnNode: Node {
    
    var node: Node
    
    func interpret() throws -> String {
        return try node.interpret()
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
