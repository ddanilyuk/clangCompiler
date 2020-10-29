//
//  TernaryNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 26.10.2020.
//

import Foundation


struct TernaryNode: Node {
    
    static var ternaryNumber: Int = 1

    var conditionNode: Node
    var trueNode: Node
    var falseNode: Node
    
    init(conditionNode: Node, trueNode: Node, falseNode: Node) {
        self.conditionNode = TernaryInsideNode(node: conditionNode, positionName: "condition")
        self.trueNode = TernaryInsideNode(node: trueNode, positionName: "if true")
        self.falseNode = TernaryInsideNode(node: falseNode, positionName: "if false")
    }
    
    func interpret() throws -> String {
        var result = String()
        result += try conditionNode.interpret()
        result.deleteSufix("push eax\n")
        
        result += "cmp eax, 0\n"
        result += "je _if_false_\(TernaryNode.ternaryNumber)\n"
        
        result += try trueNode.interpret()
        
        result += "jmp _post_conditional_\(TernaryNode.ternaryNumber)\n"
        result += "_if_false_\(TernaryNode.ternaryNumber):\n"
        
        result += try falseNode.interpret()
        result += "_post_conditional_\(TernaryNode.ternaryNumber):\n"
        
        TernaryNode.ternaryNumber += 1
        
        return result
    }
}


extension TernaryNode: TreeRepresentable {
    var name: String {
        return "ternary"
    }
    
    var subnodes: [Node] {
        return [conditionNode, trueNode, falseNode]
    }
}


struct TernaryInsideNode: Node {
    
    var node: Node
    
    var positionName: String
    
    func interpret() throws -> String {
        return try node.interpret()
    }
    
    var name: String {
        return positionName
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
