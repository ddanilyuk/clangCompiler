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
        var result = String()
        
        for line in subnodes {
            result += try line.interpret(isCPPCode: isCPPCode)
        }
        result += "; getting result\n"
        result += "pop eax\n"
        result += "mov b, eax"
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
