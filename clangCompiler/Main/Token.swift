//
//  Token.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


enum IntegerType {
    case decimal
    case octal
}


enum Token: Equatable {

    typealias Generator = (String) throws -> Token?
            
    // Numbers
    case intNumber(Int, IntegerType)
    case floatNumber(Float)
    
    // Brace
    case parensOpen
    case parensClose
    
    // Curly
    case curlyOpen
    case curlyClose
        
    // Number Type
    case intType
    case floatType
    
    // Other
    case op(Operator)
    case identifier(String)
    case `return`
    case semicolon
    
    var lenght: Int {
        switch self {
        case let .intNumber(number, type):
            let customInt = CustomIntNode(integer: number, type: type)
            return String(customInt.name).count
        case let .floatNumber(float):
            return String(float).count
        case .parensOpen:
            return 1
        case .parensClose:
            return 1
        case .curlyOpen:
            return 1
        case .curlyClose:
            return 1
        case .semicolon:
            return 1
        case .intType:
            return 3
        case .floatType:
            return 5
        case .op:
            return 1
        case let .identifier(string):
            return string.count
        case .return:
            return 6
        }
    }
    
    static var currentTokenIndex: Int = 1
    
    static var generators: [String: Generator] {
        return [
            /// Non didgits or words
            "\\*|\\/|\\+|\\-": {
                if $0 == "/" || $0 == "-" {
                    return .op(Operator(rawValue: $0)!)
                } else {
                    // If we have "+" or "*", throw error because 7 variant cant compile this operators.
                    throw CompilerError.invalidOperator($0, Token.currentTokenIndex)
                }
            },
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            "\\;": { _ in .semicolon },

            /// For words and keywords
            "[a-zA-Z_$][a-zA-Z_$0-9]*": {
                if $0 == "return" {
                    return .return
                }
                if $0 == "int" {
                    return .intType
                }
                if $0 == "float" {
                    return .floatType
                }
                return .identifier($0)
            },
            
            /// For number Int (octal and decimal) and float numbers
            "^(^0[0-8]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    return .floatNumber(Float($0)!)
                } else if $0.first == "0" {
                    var number = $0
                    number.removeFirst()
                    if let int8 = UInt8(number, radix: 8) {
                        return .intNumber(Int(int8), .octal)
                    } else {
                        throw CompilerError.invalidNumber(Token.currentTokenIndex)
                    }
                } else if let intNumber = Int($0) {
                    return .intNumber(intNumber, .decimal)
                } else {
                    throw CompilerError.invalidNumber(Token.currentTokenIndex)
                }
            }
        ]
    }
}
