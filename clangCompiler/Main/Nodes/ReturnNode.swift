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
        
//        if isCPPCode {
//            result += "\n\t\tmov eax, "
//        } else {
//            result += "mov eax, "
//        }
        
        for line in subnodes {
            result += try line.interpret(isCPPCode: isCPPCode)
        }
        result += "mov eax, ss:[esp]\n"
        result += "add esp, 4\n"

        result += "mov b, eax"
//        if isCPPCode {
//            result += "\n\t\tmov b, eax\n"
//        } else {
//            result += "\nmov b, eax\n"
//        }
                
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
