//
//  CompilerError.swift
//  lab1SP
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


// Possible errors
enum CompilerError: Swift.Error, LocalizedError {
    
    // Values error.
    case expectedFloat(Int)
    case expectedInt(Int)

    // Operator.
    case expectedOperator(Int)
    
    // Expression `()`.
    case expectedExpression(Int)
    
    // Invalid value
    case invalidValue(Int)
    
    // Inavlid fuction identifier
    case invalidFunctionIdentifier(Int)
    
    // Return value not match with expected.
    case invalidReturnType(String, Int)

    // Something expected
    case expected(String, Int)
    
    // For functions
    case notDefined(String, Int)
    case alreadyDefined(String, Int)
    
    var index: Int {
        switch self {
        case let .expectedFloat(index), let .expectedInt(index), let .expectedOperator(index), let .expectedExpression(index), let .invalidValue(index), let .invalidFunctionIdentifier(index):
            return index
        case let .invalidReturnType(_, index), let .expected(_, index), let .notDefined(_, index), let .alreadyDefined(_, index):
            return index
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .expectedFloat:
            return "Float expected."
        case .expectedInt:
            return "Int expected."
        case .expectedOperator:
            return "Operator expected."
        case .expectedExpression:
            return "Expression expected."
        case .invalidValue:
            return "Invalid value given."
        case .invalidFunctionIdentifier:
            return "Givaen invalid funciton identifier."
            
        case let .invalidReturnType(str, _):
            return "Inavlid return type. Expected: \(str)"
        case let .expected(str, _):
            return "Extected \"\(str)\"."
        case let .notDefined(str, _):
            return "\(str) not defined."
        case let .alreadyDefined(str, _):
            return "\(str) already defined."
        }
    }
    
    public func fullErrorDescription(code: String, tokens: [Token]) {
        var counter = 0
        // Index of error starts from 1
        for token in tokens[0..<(self.index - 1)] {
            counter += token.lenght
            while code[counter] == Character(" ") {
                counter += 1
            }
        }
        
        let arrayOfAsterisks = Array(repeating: "*", count: counter)
        var graphicalOutputErrorPosition = arrayOfAsterisks.reduce("") { "\($0)\($1)" }
        graphicalOutputErrorPosition += "^"
        
        print("\nError!")
        print(self.localizedDescription)
        print("Line: \(1), position: \(counter)\n")
        print(code)
        print(graphicalOutputErrorPosition)
    }
}
