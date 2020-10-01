//
//  InfixOperation.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


// Operators
struct InfixOperation: Node {

    func specialInterpretForInfixOperation(isCPPCode: Bool, isNegative: Bool) throws -> String {
        
        var result = String()
        var leftPopping = String()
        var rightPopping = String()
        
        let leftPartInterpreting = try lhs.interpret(isCPPCode: isCPPCode)
        let rightPartInterpreting = try rhs.interpret(isCPPCode: isCPPCode)

        var buffer = String()
        
        // Left
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
            negativeNode.postition = .lhs

            if rightPartInterpreting.hasSuffix("push eax\n") {
                buffer += try negativeNode.interpret(isCPPCode: isCPPCode)
            } else {
                result += try negativeNode.interpret(isCPPCode: isCPPCode)
            }
        } else {
            result += try lhs.interpret(isCPPCode: isCPPCode)
        }
        
        // Right
        if var rightPart = rhs as? NumberNode {
            rightPart.register = "ebx"
            result += try rightPart.interpret(isCPPCode: isCPPCode)
        } else if rightPartInterpreting.hasSuffix("push eax\n") {
            result += try rhs.interpret(isCPPCode: isCPPCode)
            rightPopping += "pop ebx\n"
        } else if var negativeNode = rhs as? UnaryNegativeNode {
            negativeNode.postition = .rhs
            result += try negativeNode.interpret(isCPPCode: isCPPCode)
        } else {
            result += try rhs.interpret(isCPPCode: isCPPCode)
        }
        
        result += buffer
        result += "\(rightPopping)\(leftPopping)"

        result += "cdq\n"
        result += "idiv ebx\n"
        
        result += isNegative ? "neg eax\n" : ""
        result += "push eax\n"
        
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

/*
// MARK: - Infix Operation struct
struct InfixOperation: ASTnode {
    
    let operation: BinaryOperator
    let leftNode: ASTnode
    let rightNode: ASTnode
    
    var isNegative = false
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code = ""
        /// Write "pop eax\n" if needed and add to code in the end
        var popLeft = ""
        /// Write "pop ebx\n" if needed and add to code in the end
        var popRight = ""
        /// Editiion code bufer
        var codeBufer = ""
        
        let left = try leftNode.generatingAsmCode()
        let right = try rightNode.generatingAsmCode()
        
        // Left node code generation
        if leftNode is Int || leftNode is Float {
            if right.hasSuffix("push eax\n") {
                codeBufer += "mov eax, \(left)\n"
            } else {
                code += "mov eax, \(left)\n"
            }
        } else if left.hasSuffix("push eax\n") {
            code += left
            //            code += "mov eax, ss : [esp]\nadd esp, 4\n"
            popLeft += "pop eax\n"
        } else if var prefixL = leftNode as? PrefixOperation {
            prefixL.sideLeft = true
            if right.hasSuffix("push eax\n") {
                codeBufer += try prefixL.generatingAsmCode()
            } else {
                code += try prefixL.generatingAsmCode()
            }
            
        } else {
            code += left
        }
        
        // Right node code generation
        if rightNode is Int || rightNode is Float {
            code += "mov ebx, \(right)\n"
        } else if right.hasSuffix("push eax\n") {
            code += right
            //            code += "mov ebx, ss : [esp]\nadd esp, 4\n"
            popRight += "pop ebx\n"
        } else if var prefixR = rightNode as? PrefixOperation {
            prefixR.sideLeft = false
            code += try prefixR.generatingAsmCode()
        } else {
            code += right
        }
        
        code += codeBufer
        
        if .divideBy == operation {
            code += popRight
            code += popLeft
            
            // Dividing: eax / ebx
            code += "cdq\nidiv ebx\n"
            
            // If dividing is negative
            code += isNegative ? "neg eax\n" : ""
            
            // Writing dividion result to the stack
            //            code += "sub esp, 4\nmove ss : [esp], eax\n"
            code += "push eax\n"
            
            return code
        } else {
            throw Parser.Error.unexpectedError
        }
    }
}
 */
