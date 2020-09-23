//
//  Token.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


enum Token {
    typealias Generator = (String) -> Token?
    
    // Numbers
    case intNumber(Int)
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
            "\\*|\\/|\\+|\\-": { .op(Operator(rawValue: $0)!) },
            "^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    return .floatNumber(Float($0)!)
                } else {
                    return .intNumber(Int($0)!)
                }
            },
            
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            
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
            "\\;": { _ in .semicolon }            
        ]
    }
}
