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
        
        result += try node.interpret(isCPPCode: isCPPCode)
        
        result.deleteSufix("push eax\n")
        result += """
        \n; function footer
        mov esp, ebp
        pop ebp
        """
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
