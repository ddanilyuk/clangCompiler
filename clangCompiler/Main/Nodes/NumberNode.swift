//
//  NumberNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct NumberNode: Node {
        
    enum NumberType: String {
        case intDecimal = "int(decimal)"
        case intOctal = "int(octal)"
        case float = "float"
    }
        
    var value: Node
    
    var register: String = "eax"
    
    var numberType: NumberType
    
    func interpret(isCPPCode: Bool) throws -> String {
        return "mov \(register), \(try value.interpret(isCPPCode: isCPPCode))\n"
    }
}


extension NumberNode: TreeRepresentable {
    var name: String {
        return numberType.rawValue
    }
    
    var subnodes: [Node] {
        return [value]
    }
}
