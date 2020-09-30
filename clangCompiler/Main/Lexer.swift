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
            let currentPostiton = Lexer.getPositionFromIndex(tokens: tokens, code: code, index: tokens.count)
            tokensTable.append("\(part) - \(token) | startPosition \(currentPostiton) endPosition \(currentPostiton + tokens[tokens.count - 1].lenght)\n")
            
            Token.currentTokenIndex += 1
        }
    }
    
    public static func getPositionFromIndex(tokens: [Token], code: String, index: Int) -> Int {
        var counter = 0
        // Index of error starts from 1
        
        for token in tokens[0..<(index - 1)] {
            counter += token.lenght
            while code[counter] == Character(" ") {
                counter += 1
            }
        }
        return counter
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
