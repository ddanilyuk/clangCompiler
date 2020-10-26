//
//  Token.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


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
    case questionMark
    case colon
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
        case .colon:
            return 1
        case .questionMark:
            return 1
        case let .identifier(string):
            return string.count
        case .return:
            return 6
        }
    }
    
    var description: String {
        switch self {
        case .parensOpen:
            return "("
        case .parensClose:
            return ")"
        case .curlyOpen:
            return "{"
        case .curlyClose:
            return "}"
        case .intType:
            return "int type"
        case .floatType:
            return "float type"
        case let .op(op):
            return op.rawValue
        case .questionMark:
            return "?"
        case .return:
            return "return"
        case .semicolon:
            return ";"
        case .colon:
            return ":"
        default:
            return "\(self)"
        }
    }
    
    static var currentTokenIndex: Int = 1
    
    static var generators: [String: Generator] {
        return [
            /// Possible operators
            "\\*|\\/|\\+|\\-|\\>|\\<|\\=": {
                if $0 == "/" || $0 == "-" || $0 == "*" || $0 == ">" || $0 == "=" {
                    return .op(Operator(rawValue: $0)!)
                } else {
                    // Throw error if operator is not available for variant
                    throw CompilerError.invalidOperator($0, Token.currentTokenIndex)
                }
            },
            
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            "\\;": { _ in .semicolon },
            "\\?": { _ in .questionMark },
            "\\:": { _ in .colon },


            /// For words and keywords
            "[a-zA-Z_$][a-zA-Z_$0-9]*": {
                if $0 == "return" {
                    return .return
                } else if $0 == "int" {
                    return .intType
                } else if $0 == "float" {
                    return .floatType
                } else {
                    return .identifier($0)
                }
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
