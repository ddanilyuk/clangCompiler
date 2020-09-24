//
//  Lexer.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    let tokens: [Token]
    
    var tokensTable: String = "Tokens:\n"
    
    init(code: String) {
        var gettedCode = code
        
        // Deleting left-side whitespaces.
        gettedCode.trimLeadingWhitespace()
        
        // Creating array with tokens
        var tokens: [Token] = []
        
        while let next = Lexer.getNextPrefix(code: gettedCode) {
            let (regex, prefix) = next
            gettedCode = String(gettedCode[prefix.endIndex...])
            gettedCode.trimLeadingWhitespace()
            guard let generator = Token.generators[regex], let token = generator(prefix) else {
                fatalError("Invalid generator!")
            }
            
            // Adding tokens to description table
            tokensTable.append("\(prefix) - \(token)\n")
            
            // Adding tokens to array
            tokens.append(token)
        }
        self.tokens = tokens
    }

    private static func getNextPrefix(code: String) -> (regex: String, prefix: String)? {
        
        let keyValue = Token.generators.first(where: { regex, generator in
                                                code.getPrefix(regex: regex) != nil })
        guard let regex = keyValue?.key, keyValue?.value != nil else { return nil }
        return (regex, code.getPrefix(regex: regex)!)
    }
}
