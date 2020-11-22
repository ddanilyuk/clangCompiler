//
//  BinaryOperationNode.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


struct BinaryOperationNode: Node {

    let op: Operator
    let lhs: Node
    let rhs: Node
    
    var precedence: Int {
        return op.priority
    }

    func interpret() throws -> String {
        return try specialInterpret(isNegative: false)
    }
    
    func specialInterpret(isNegative: Bool) throws -> String {
        var result = String()
        
        var leftPopping = String()
        var rightPopping = String()
        
        let leftPartInterpreting = try lhs.interpret()
        let rightPartInterpreting = try rhs.interpret()
        
        var buffer = String()
        
        // Left part
        if leftPartInterpreting.hasSuffix("push eax\n") {
            result += leftPartInterpreting
            leftPopping += "pop eax\n"
        } else {
            if rightPartInterpreting.hasSuffix("push eax\n") {
                buffer += leftPartInterpreting
            } else {
                result += leftPartInterpreting
            }
        }
        
        // Right part
        result += rightPartInterpreting
        if rightPartInterpreting.hasSuffix("push eax\n") {
            rightPopping += "pop ebx\n"
        }
        
        // After parts
        result += buffer
        result += "\(rightPopping)\(leftPopping)"
        
        switch op {
        case .divide, .divideEqual:
            result += "cdq\n"
            result += "idiv ebx\n"
        case .multiply:
            result += "imul eax, ebx\n"
        case .greater:
            result += "cmp eax, ebx\n"
            result += "setg al\n"
            result += "movzx eax, al\n"
            
        // Uncomment for course work
        // case .minus:
        // result += "sub eax, ebx\n"
            
        default:
            throw CompilerError.invalidOperator(op.rawValue, 0)
        }
        
        result += isNegative ? "neg eax\n" : ""
        result += "push eax\n"
        
        return result
    }
}


extension BinaryOperationNode: TreeRepresentable {
    
    var name: String {
        return op.rawValue + " operation"
    }
    
    var subnodes: [Node] {
        return [lhs, rhs]
    }
}
