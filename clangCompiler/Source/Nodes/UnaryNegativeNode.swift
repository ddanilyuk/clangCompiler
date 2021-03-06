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
    
    func interpret() throws -> String {
        var result = String()
        
        if var positionNode = node as? PositionNode {
            positionNode.lrPosition = lrPosition
            result += try positionNode.interpret()
            result += "neg \(register)\n"
        } else if let operationNode = node as? BinaryOperationNode {
            result += try operationNode.specialInterpret(isNegative: true)
        } else {
            #if DEBUG
                assertionFailure("Something unexpected in unary negative node")
            #endif
            result += try node.interpret()
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
