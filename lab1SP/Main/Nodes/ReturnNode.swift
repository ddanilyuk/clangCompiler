//
//  ReturnNode.swift
//  lab1SP
//
//  Created by Денис Данилюк on 24.09.2020.
//

import Foundation


struct ReturnNode: Node {
    
    var node: Node
    
    func interpret() throws -> String {
        var result = String()
        
        result += "mov eax "
        
        for line in subnodes {
            result += try line.interpret()
        }
        
        result += "\nmov b eax"
        
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
