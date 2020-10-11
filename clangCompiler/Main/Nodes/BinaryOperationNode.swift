//
//  InfixOperation.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


// Operators
struct BinaryOperationNode: Node {

    let op: Operator
    let lhs: Node
    let rhs: Node
    
    var precedence: Int {
        return op.priority
    }

    func interpret(isCPPCode: Bool) throws -> String {
        return try specialInterpret(isCPPCode: isCPPCode, isNegative: false)
    }
    
    func specialInterpret(isCPPCode: Bool, isNegative: Bool) throws -> String {
        var result = String()
        
        var leftPopping = String()
        var rightPopping = String()
        
        let leftPartInterpreting = try lhs.interpret(isCPPCode: isCPPCode)
        let rightPartInterpreting = try rhs.interpret(isCPPCode: isCPPCode)
        
        var buffer = String()
        
        // Left
        if leftPartInterpreting.hasSuffix("push eax\n") {
            result += try lhs.interpret(isCPPCode: isCPPCode)
            leftPopping += "pop eax\n"
        } else {
            if rightPartInterpreting.hasSuffix("push eax\n") {
                buffer += try lhs.interpret(isCPPCode: isCPPCode)
            } else {
                result += try lhs.interpret(isCPPCode: isCPPCode)
            }
        }
        
        // Right
        if rightPartInterpreting.hasSuffix("push eax\n") {
            result += try rhs.interpret(isCPPCode: isCPPCode)
            rightPopping += "pop ebx\n"
        } else {
            result += try rhs.interpret(isCPPCode: isCPPCode)
        }
        
        result += buffer
        result += "\(rightPopping)\(leftPopping)"
        
        switch op {
        case .divide:
            result += "cdq\n"
            result += "idiv ebx\n"
        case .multiply:
            result += "imul eax, ebx\n"
        case .greater:
            result += "cmp eax, ebx\n"
            result += "setg al\n"
            result += "movzx eax, al\n"
        default:
            assertionFailure("Not / or * or >")
        }
        
        result += isNegative ? "neg eax\n" : ""
        result += "push eax\n"
        
        return result
    }
    
    /*
    func specialInterpretForInfixOperation(isCPPCode: Bool, isNegative: Bool) throws -> String {
        
        var result = String()
        
        var leftPopping = String()
        var rightPopping = String()
        
        let leftPartInterpreting = try lhs.interpret(isCPPCode: isCPPCode)
        let rightPartInterpreting = try rhs.interpret(isCPPCode: isCPPCode)
        
        var buffer = String()
        
        // Left part
        if var leftPart = lhs as? NumberNode {
            leftPart.register = "eax"
            if rightPartInterpreting.hasSuffix("push eax\n") {
                buffer += try leftPart.interpret(isCPPCode: isCPPCode)
            } else {
                result += try leftPart.interpret(isCPPCode: isCPPCode)
            }
        } else if leftPartInterpreting.hasSuffix("push eax\n") {
            result += try lhs.interpret(isCPPCode: isCPPCode)
            leftPopping += "pop eax\n"
        } else if var negativeNode = lhs as? UnaryNegativeNode {
            negativeNode.lrPostition = .lhs
            
            if rightPartInterpreting.hasSuffix("push eax\n") {
                buffer += try negativeNode.interpret(isCPPCode: isCPPCode)
            } else {
                result += try negativeNode.interpret(isCPPCode: isCPPCode)
            }
        } else {
            result += try lhs.interpret(isCPPCode: isCPPCode)
        }
        
        // Right part
        if var rightPart = rhs as? NumberNode {
            rightPart.register = "ebx"
            result += try rightPart.interpret(isCPPCode: isCPPCode)
        } else if rightPartInterpreting.hasSuffix("push eax\n") {
            result += try rhs.interpret(isCPPCode: isCPPCode)
            rightPopping += "pop ebx\n"
        } else if var negativeNode = rhs as? UnaryNegativeNode {
            negativeNode.lrPostition = .rhs
            result += try negativeNode.interpret(isCPPCode: isCPPCode)
        } else {
            result += try rhs.interpret(isCPPCode: isCPPCode)
        }
        
        // Adding results
        result += buffer
        result += "\(rightPopping)\(leftPopping)"
        
        switch op {
        case .divide:
            result += "cdq\n"
            result += "idiv ebx\n"
        case .multiply:
            result += "imul eax, ebx\n"
        case .greater:
            result += "cmp eax, ebx\n"
            result += "setg al\n"
            result += "movzx eax, al\n"
        default:
            assertionFailure("Not / or * or >")
        }
        
        result += isNegative ? "neg eax\n" : ""
        result += "push eax\n"
        
        return result
    }
     */
}


extension BinaryOperationNode: TreeRepresentable {
    var name: String {
        return op.rawValue + " operation"
    }
    
    var subnodes: [Node] {
        return [lhs, rhs]
    }
}
