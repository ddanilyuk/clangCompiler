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
    
    func interpret(isCPPCode: Bool) throws -> String {
        // return "(\(try lhs.interpret()) \(op.rawValue) \(try rhs.interpret()))"
        return ""
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
