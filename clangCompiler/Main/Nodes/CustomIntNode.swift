//
//  CustomIntNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct CustomIntNode: Node {
    
    var integer: Int
    var type: IntegerType
    
    var name: String {
        if self.type == .decimal {
            return "\(integer)"
        } else {
            if let octal = Int(String(integer, radix: 8)) {
                return "0\(octal)"
            } else {
                fatalError("Not octal")
            }
        }
    }
    
    var subnodes: [Node] {
        return []
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        return name
    }
}
