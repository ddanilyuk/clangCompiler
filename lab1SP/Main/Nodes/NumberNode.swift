//
//  NumberNode.swift
//  lab1SP
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
    
    var numberType: NumberType
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try node.interpret(isCPPCode: isCPPCode)
    }
}


extension NumberNode: TreeRepresentable {
    var name: String {
        return numberType.rawValue
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
