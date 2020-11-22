//
//  DoWhileNode.swift
//  clangCompiler
//
//  Created by Denys Danyliuk on 14.11.2020.
//

import Foundation


struct DoWhileNode: Node {
    
    static var doWhileNumber: Int = 1

    var conditionNode: Node

    var block: Node
    
    func interpret() throws -> String {
        
        var result = String()
        
        result += "_doWhile_\(DoWhileNode.doWhileNumber):\n"
        result += try block.interpret()
        
        result += try conditionNode.interpret()
        result.deleteSufix("push eax\n")
        result += "cmp eax, 0\n"
        
        result += "jne _doWhile_\(DoWhileNode.doWhileNumber)\n"
        result += "_afterDoWhile_\(DoWhileNode.doWhileNumber):\n"
        return result
    }
}


extension DoWhileNode: TreeRepresentable {
    
    var name: String {
        return "do while"
    }
    
    var subnodes: [Node] {
        return [block, conditionNode]
    }
}


struct BreakNode: Node {
    
    var name: String {
        return "break"
    }
    
    var subnodes: [Node] {
        return []
    }
    
    func interpret() throws -> String {
        return "jmp _afterDoWhile_\(DoWhileNode.doWhileNumber)\n"
    }
}


struct ContinueNode: Node {
    
    var name: String {
        return "continue"
    }
    
    var subnodes: [Node] {
        return []
    }
    
    func interpret() throws -> String {
        return "jmp _doWhile_\(DoWhileNode.doWhileNumber)\n"
    }
}
