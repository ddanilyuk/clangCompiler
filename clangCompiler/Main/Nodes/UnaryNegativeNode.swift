//
//  UnaryNegativeNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.09.2020.
//

import Foundation


struct UnaryNegativeNode: Node {
    
    var node: Node
    
    var name: String {
        return "unary negative"
    }
    
    var subnodes: [Node] {
        return [node]
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        return ""
    }
}
