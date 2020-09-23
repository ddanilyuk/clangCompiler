//
//  Lexer.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


class Lexer {
    
    let tokens: [Token]
    
    public static func getCurrentLineAndPosition(from index: Int, code: String, tokens: [Token]) -> (line: Int, position: Int, show: String) {
        var counter = 0
        
        for token in tokens[0..<(index - 1)] {
            counter += token.lenght
        }
        
        let array = Array(repeating: "*", count: counter)
        
        var showPosition = array.reduce("") { (part1, part2) -> String in
            return "\(part1)\(part2)"
        }
        showPosition += "^"
    
        return (line: 1, position: Int(counter), show: String(showPosition))
    }
    
    private static func getNextPrefix(code: String) -> (regex: String, prefix: String)? {
        
        let keyValue = Token.generators.first(where: { regex, generator in
                                                code.getPrefix(regex: regex) != nil
                                              })

        guard let regex = keyValue?.key, keyValue?.value != nil else {
            return nil
        }
        
        return (regex, code.getPrefix(regex: regex)!)
    }
    
    init(code: String, isPrintLexicalTable: Bool) {
        var code = code
        code.trimLeadingWhitespace()
        var tokens: [Token] = []
        
        if isPrintLexicalTable {
            print("Tokens:")
        }
        
        while let next = Lexer.getNextPrefix(code: code) {
            let (regex, prefix) = next
            code = String(code[prefix.endIndex...])
            code.trimLeadingWhitespace()
            guard let generator = Token.generators[regex], let token = generator(prefix) else {
                fatalError()
            }
            
            if isPrintLexicalTable {
                print("\(prefix) - \(token)")
            }
            
            tokens.append(token)
        }
        
        self.tokens = tokens
    }
    
}
