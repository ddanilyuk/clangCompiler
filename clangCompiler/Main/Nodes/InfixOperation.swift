//
//  InfixOperation.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


// Operators
struct InfixOperation: Node {
    
//    func getValue() -> Float {
//        switch op {
//        case .plus:
//            return lhs.getValue() + rhs.getValue()
//        case .minus:
//            return lhs.getValue() - rhs.getValue()
//        case .divideBy:
//            return lhs.getValue() / rhs.getValue()
//        case .times:
//            return lhs.getValue() * rhs.getValue()
//        }
//    }
    
    func specialInterpretForInfixOperation(isCPPCode: Bool, isNegative: Bool) throws -> String {
        var result = String()
        
        if var leftPart = lhs as? NumberNode {
            leftPart.register = "eax"
            result += try leftPart.interpret(isCPPCode: isCPPCode)
        } else if let negativeNode = lhs as? UnaryNegativeNode {
            result += try negativeNode.interpret(isCPPCode: isCPPCode)
        } else {
            // Pop
            result += try lhs.interpret(isCPPCode: isCPPCode)
            result += "mov eax, ss:[esp]\n"
            result += "add esp, 4\n"
        }
        
        if var rightPart = rhs as? NumberNode {
            rightPart.register = "ebx"
            result += "\(try rightPart.interpret(isCPPCode: isCPPCode))"
        } else if let negativeNode = rhs as? UnaryNegativeNode {
            result += try negativeNode.interpret(isCPPCode: isCPPCode)
        } else {
            // Pop
            result += try rhs.interpret(isCPPCode: isCPPCode)
            result += "mov ebx, ss:[esp]\n"
            result += "add esp, 4\n"
        }
        
        result += "cdq\n"
        result += "idiv ebx\n"
        
        result += isNegative ? "neg eax\n" : ""
        
        result += "sub esp, 4\n"
        result += "mov ss:[esp], eax\n"
        
        return result
    }
    
    func interpret(isCPPCode: Bool) throws -> String {
        return try specialInterpretForInfixOperation(isCPPCode: isCPPCode, isNegative: false)
    }
    
    let op: Operator
    let lhs: Node
    let rhs: Node
    var precedence: Int {
        switch op {
        case .minus, .plus: return 10
        case .times, .divideBy: return 20
        }
    }
}


extension InfixOperation: TreeRepresentable {
    var name: String {
        return op.rawValue + " operation"
    }
    
    var subnodes: [Node] {
        return [lhs, rhs]
    }
}
