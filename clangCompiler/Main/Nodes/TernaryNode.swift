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
    
    static var ternaryNumber: Int = 1
    
    init(conditionNode: Node, trueNode: Node, falseNode: Node) {
        self.conditionNode = TernaryInsideNode(node: conditionNode, positionName: "condition")
        self.trueNode = TernaryInsideNode(node: trueNode, positionName: "if true")
        self.falseNode = TernaryInsideNode(node: falseNode, positionName: "if false")
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        result += try conditionNode.interpret(isCPPCode: isCPPCode)
        result.deleteSufix("push eax\n")
        
        result += "cmp eax, 0\n"
        result += "je _if_false\(TernaryNode.ternaryNumber)\n"
        
        result += try trueNode.interpret(isCPPCode: isCPPCode)
        
        result += "jmp _post_conditional\(TernaryNode.ternaryNumber)\n"
        result += "_if_false\(TernaryNode.ternaryNumber):\n"
        
        result += try falseNode.interpret(isCPPCode: isCPPCode)
        result += "_post_conditional\(TernaryNode.ternaryNumber):\n"
        
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
