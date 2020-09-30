//
//  CompilerError.swift
//  clangCompiler
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
    
    // Generator Errors
    case invalidNumber(Int)
    case invalidGenerator(Int)
    
    
    // Return value not match with expected.
    case invalidReturnType(String, Int)

    // Something expected
    case expected(String, Int)
    

    // For functions (now not used)
    case notDefined(String, Int)
    case alreadyDefined(String, Int)
    
    var index: Int {
        switch self {
        case let .expectedFloat(index), let .expectedInt(index), let .expectedOperator(index), let .expectedExpression(index), let .invalidValue(index), let .invalidFunctionIdentifier(index), let .invalidNumber(index), let .invalidGenerator(index):
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
            return "Given invalid funciton identifier."
        case .invalidNumber:
            return "Given number is invalid"
        case .invalidGenerator:
            return "Something with token genator"
            
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
        
        let lineAndPosition = Lexer.getPositionFromIndex(tokens: tokens, code: code, index: self.index, isError: true)
        
        let arrayOfAsterisks = Array(repeating: "-", count: lineAndPosition.position - 1)
        var graphicalOutputErrorPosition = arrayOfAsterisks.reduce("") { "\($0)\($1)" }
        graphicalOutputErrorPosition += "^"
        
        print("\nError!")
        print(self.localizedDescription)
        print("Line: \(lineAndPosition.line), position: \(lineAndPosition.position)\n")
        
        let splittedLines = code.split(separator: "\n")
        for i in 0..<splittedLines.count {
            print(splittedLines[i])
            if i == lineAndPosition.line - 1 {
                print(graphicalOutputErrorPosition)
            }
        }
    }
}
