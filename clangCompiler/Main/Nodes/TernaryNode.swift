//
//  TernaryNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 26.10.2020.
//

import Foundation


struct TernaryNode: Node {
    
    var conditionNode: Node
    var trueNode: Node
    var falseNode: Node
    
    init(conditionNode: Node, trueNode: Node, falseNode: Node) {
        self.conditionNode = TernaryInsideNode(node: conditionNode, positionName: "condition")
        self.trueNode = TernaryInsideNode(node: trueNode, positionName: "if true")
        self.falseNode = TernaryInsideNode(node: falseNode, positionName: "if false")
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        // Implement THIS function
        return ""
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
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try node.interpret(isCPPCode: isCPPCode)
    }
    
    var name: String {
        return positionName
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
