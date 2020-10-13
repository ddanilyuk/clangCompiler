//
//  Lexer.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    var tokensTable: String = "Tokens:\n"
    
    var lexerCode: String
    
    var lexerTokens: [Token] = []
    
    init(code: String, tokens: inout [Token]) throws {
        // Saving code to class.
        self.lexerCode = code
        
        // Deleting left-side whitespaces.
        lexerCode.deleteLeftWhitespaces()
        
        // Iterating to find tokens.
        while let next = try Lexer.getNextPart(with: lexerCode, tokens: tokens) {
            let (regular, part) = next
            lexerCode = String(lexerCode[part.endIndex...])
            lexerCode.deleteLeftWhitespaces()
            
            guard let generator = Token.generators[regular], let token = try generator(part) else {
                throw CompilerError.invalidGenerator(tokens.count)
            }
            
            // Adding tokens to array
            tokens.append(token)

            // Adding tokens to description table
            let currentPostiton = Lexer.getPositionFromIndex(tokens: tokens, code: code, index: tokens.count, isError: false)
            
            tokensTable.append("\(part) - \(token) | line: \(currentPostiton.line), position: [\(currentPostiton.position)-\(currentPostiton.position + tokens[tokens.count - 1].lenght)]\n")
            
            Token.currentTokenIndex += 1
        }
    }
    
    public static func getPositionFromIndex(tokens: [Token], code: String, index: Int, isError: Bool) -> (line: Int, position: Int) {
        var superPosition = 0
        var position = 1
        var line = 1
        
        // Index of error starts from 1
        guard index > 1 else { return (line: 1, position: 1) }
        
        for token in tokens[0..<(index - 1)] {
            position += token.lenght
            superPosition += token.lenght
            
            // TODO:- rewrite this piece of SHIT
            while code[superPosition] == Character(" ") {
                position += 1
                superPosition += 1
            }
            while code[superPosition] == Character("\n") {
                line += 1
                position = 1
                superPosition += 1
            }
            while code[superPosition] == Character(" ") {
                position += 1
                superPosition += 1
            }
        }

        if isError {
            if tokens.count < index - 1 {
                position += tokens[index - 1].lenght
            }
        }
        
        return (line: line, position: position)
    }

    private static func getNextPart(with code: String, tokens: [Token]) throws -> (regex: String, prefix: String)? {
        let key = Token.generators.first(where: { regular, generator in
                                                code.getStringPrefix(with: regular) != nil })
        guard let regularExpression = key?.key, key?.value != nil else {
            if !code.isEmpty {
                throw CompilerError.invalidGenerator(tokens.count)
            } else {
                return nil
            }
        }
        return (regularExpression, code.getStringPrefix(with: regularExpression)!)
    }
}
