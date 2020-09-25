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
        while let next = Lexer.getNextPrefix(with: lexerCode) {
            let (regular, prefix) = next
            lexerCode = String(lexerCode[prefix.endIndex...])
            lexerCode.deleteLeftWhitespaces()
            
            guard let generator = Token.generators[regular], let token = try generator(prefix) else {
                throw CompilerError.invalidGenerator(tokens.count)
            }
            
            // Adding tokens to description table
            tokensTable.append("\(prefix) - \(token)\n")
            
            // Adding tokens to array
            tokens.append(token)
            
            Token.currentTokenIndex += 1
        }
    }

    private static func getNextPrefix(with code: String) -> (regex: String, prefix: String)? {
        let key = Token.generators.first(where: { regular, generator in
                                                code.getStringPrefix(with: regular) != nil })
        guard let regularExpression = key?.key, key?.value != nil else { return nil }
        return (regularExpression, code.getStringPrefix(with: regularExpression)!)
    }
}
