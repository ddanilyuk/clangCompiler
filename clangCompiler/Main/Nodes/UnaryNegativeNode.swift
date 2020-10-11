//
//  UnaryNegativeNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.09.2020.
//

import Foundation


struct UnaryNegativeNode: PositionNode {
    
    var node: Node
    
    var lrPosition: LRPosition = .lhs {
        didSet {
            switch lrPosition {
            case .lhs:
                register = "eax"
            case .rhs:
                register = "ebx"
            }
        }
    }
    
    var register: String = "eax"
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        
        if var positionNode = node as? PositionNode {
            positionNode.lrPosition = lrPosition
            result += try positionNode.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        } else if let operationNode = node as? BinaryOperationNode {
            result += try operationNode.specialInterpret(isCPPCode: isCPPCode, isNegative: true)
        } else {
            assertionFailure("Something unexpected in unary negative node")
            result += try node.interpret(isCPPCode: isCPPCode)
            result += "neg \(register)\n"
        }
    
        return result
    }
}


extension UnaryNegativeNode: TreeRepresentable {
    
    var name: String {
        return "unary negative | \(lrPosition.rawValue) position"
    }
    
    var subnodes: [Node] {
        return [node]
    }
}
