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
    
    var isNegative: Bool
    
    var node: Node
    
    var numberType: NumberType
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try node.interpret(isCPPCode: isCPPCode)
    }

//    func getValue() -> Float {
//        return node.getValue()
//    }
}


extension NumberNode: TreeRepresentable {
    var name: String {
        let string = isNegative ? " negative" : " positive"
        return numberType.rawValue + string
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
