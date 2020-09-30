//
//  NumberNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct NumberNode: Node {
        
    enum NumberType: String {
        case decimal = "int(decimal)"
        case octal = "int(octal)"
        case float = "float"
    }
        
    var node: Node
    
    var register: String = "xxx"
    
    var numberType: NumberType
    
    func interpret(isCPPCode: Bool) throws -> String {
        let result = "mov \(register), \(try node.interpret(isCPPCode: isCPPCode))\n"
        return result
        
    }

//    func getValue() -> Float {
//        return node.getValue()
//    }
}


extension NumberNode: TreeRepresentable {
    var name: String {
        return numberType.rawValue
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
