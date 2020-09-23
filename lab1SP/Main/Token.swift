//
//  Token.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


enum IntegerType {
    case decimal
    case octal
}


enum Token {
    typealias Generator = (String) -> Token?
    
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
    
    static var generators: [String: Generator] {
        return [
            
            /// Non didgit or word
            "\\*|\\/|\\+|\\-": { .op(Operator(rawValue: $0)!) },
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            "\\;": { _ in .semicolon },

            /// For words and keywords
            "[a-zA-Z_$][a-zA-Z_$0-9]*": {
                guard $0 != "return" else {
                    return .return
                }
                guard $0 != "int" else {
                    return .intType
                }
                guard $0 != "float" else {
                    return .floatType
                }
                return .identifier($0)
            },
            
            /// For number Int (octal and decimal) and float numbers
            "^(^0[0-8]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    return .floatNumber(Float($0)!)
                } else if $0.contains("0") || $0.contains("0") {
                    var number = $0
                    number.removeFirst()
                    if let int8 = UInt8(number, radix: 8) {
                        return .intNumber(Int(int8), .octal)
                    } else {
                        // TODO:- Replace for throwing error
                        fatalError("Not Hex")
                    }
                } else if let intNumber = Int($0) {
                    return .intNumber(intNumber, .decimal)
                } else {
                    // TODO:- Replace for throwing error
                    fatalError("Not number")
                }
            }
        ]
    }
}
