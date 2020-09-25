//
//  Lexer.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    var tokensTable: String = "Tokens:\n"
    
    var lexerCode: String
    
    init(code: String) throws {
        // Saving code to class.
        self.lexerCode = code
        
        // Deleting left-side whitespaces.
        lexerCode.deleteLeftWhitespaces()
        
        // Iterating to find tokens.
        while let next = try Lexer.getNextPrefix(with: lexerCode) {
            let (regular, prefix) = next
            lexerCode = String(lexerCode[prefix.endIndex...])
            lexerCode.deleteLeftWhitespaces()
            
            guard let generator = Token.generators[regular], let token = try generator(prefix) else {
                throw CompilerError.invalidGenerator(tokens.count)
            }
            
            // Adding tokens to array
            tokens.append(token)

            // Adding tokens to description table
            let currentPostiton = Lexer.getPositionFromIndex(tokens: tokens, code: code, index: tokens.count)
            tokensTable.append("\(prefix) - \(token) | startPosition \(currentPostiton) endPosition \(currentPostiton + tokens[tokens.count - 1].lenght)\n")
            
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

    private static func getNextPrefix(with code: String) throws -> (regex: String, prefix: String)? {
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
