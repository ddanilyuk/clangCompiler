//
//  Lexer.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    let tokens: [Token]
    
    private static func getNextPrefix(code: String) -> (regex: String, prefix: String)? {
        
        let keyValue = Token.generators
            .first(where: { regex, generator in
                code.getPrefix(regex: regex) != nil
            })
        
        guard let regex = keyValue?.key,
              keyValue?.value != nil else {
            return nil
        }
        
        return (regex, code.getPrefix(regex: regex)!)
    }
    
    init(code: String) {
        var code = code
        code.trimLeadingWhitespace()
        var tokens: [Token] = []
        
        while let next = Lexer.getNextPrefix(code: code) {
            let (regex, prefix) = next
            code = String(code[prefix.endIndex...])
            code.trimLeadingWhitespace()
            guard let generator = Token.generators[regex],
                  let token = generator(prefix) else {
                fatalError()
            }
            tokens.append(token)
        }
        
        self.tokens = tokens
    }
    
}
