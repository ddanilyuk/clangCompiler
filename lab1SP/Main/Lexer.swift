//
//  Lexer.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    // Generated tokens
    var tokens: [Token] = []
    
    var tokensTable: String = "Tokens:\n"
    
    var lexerCode: String
    
    init(code: String) {
        // Saving code to class.
        self.lexerCode = code
        
        // Deleting left-side whitespaces.
        lexerCode.deleteLeftWhitespaces()
        
        // Iterating to find tokens.
        while let next = Lexer.getNextPrefix(with: lexerCode) {
            let (regular, prefix) = next
            lexerCode = String(lexerCode[prefix.endIndex...])
            lexerCode.deleteLeftWhitespaces()
            
            guard let generator = Token.generators[regular], let token = generator(prefix) else {
                fatalError("Invalid generator!")
            }
            
            // Adding tokens to description table
            tokensTable.append("\(prefix) - \(token)\n")
            
            // Adding tokens to array
            tokens.append(token)
        }
    }

    private static func getNextPrefix(with code: String) -> (regex: String, prefix: String)? {
        let key = Token.generators.first(where: { regular, generator in
                                                code.getStringPrefix(with: regular) != nil })
        guard let regularExpression = key?.key, key?.value != nil else { return nil }
        return (regularExpression, code.getStringPrefix(with: regularExpression)!)
    }
}
