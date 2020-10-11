//
//  ProtocolsAndEnums.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public protocol Node: TreeRepresentable {
    func interpret(isCPPCode: Bool) throws -> String
}


public protocol PositionNode: Node {
    var lrPosition: LRPosition { get set }
}


enum Operator: String, CaseIterable {
    case multiply = "*"
    case divide = "/"
    case plus = "+"
    case minus = "-"
    case greater = ">"
    case equal = "="
    
    var priority: Int {
        switch self {
        case .minus, .plus:
            return 100
        case .multiply, .divide:
            return 200
        case .greater:
            return 50
        case .equal:
            return 25
        }
    }
}


enum IntegerType {
    case decimal
    case octal
}


public enum LRPosition: String {
    case lhs = "left"
    case rhs = "right"
}
