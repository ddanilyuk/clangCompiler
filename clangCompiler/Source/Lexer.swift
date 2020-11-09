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
        var parts = [String]()
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
            parts.append(part)
            Token.currentTokenIndex += 1
        }
        
        for i in 0..<tokens.count {
            let part = parts[i]
            let token = tokens[i]
            let currentPostiton = Lexer.getPositionOf(inputIndex: i, tokens: tokens, code: code, isError: false)
            tokensTable.append("\(part) - \(token) | line: \(currentPostiton.line), position: [\(currentPostiton.position)-\(currentPostiton.position + token.lenght))\n")
        }
        
        
    }
    
    public static func getPositionOf(inputIndex: Int, tokens: [Token], code: String, isError: Bool) -> (line: Int, position: Int) {
        var position = 0
        var line = 0
        var tokenCounter = 0

        var index = inputIndex
        guard index > 0 else { return (line: 1, position: 1) }
        
        if index > tokens.count {
            index = tokens.count
        }

        code.enumerateLines { (oneLine, stop) in
            position = 1
            line += 1
            
            if !oneLine.isEmpty {
                while oneLine[position - 1] == Character(" ") {
                    position += 1
                }
                
                if tokenCounter == index {
                    stop = true
                }
                
                for token in tokens[tokenCounter..<(index)] {
                    position += token.lenght
                    tokenCounter += 1

                    if position > oneLine.count {
                        break
                    }
                    
                    while oneLine[position - 1] == Character(" ") {
                        position += 1
                        
                        if position > oneLine.count {
                            break
                        }
                    }
                    
                    if position > oneLine.count {
                        break
                    }
                    if tokenCounter == index {
                        stop = true
                        return 
                    }
                }
            }
        }
                
        return (line: line, position: position)
    }
    
    private static func getNextPart(with code: String, tokens: [Token]) throws -> (regex: String, prefix: String)? {
        let key = Token.generators.first(where: { regular, generator in
            code.getStringPrefix(with: regular) != nil
        })
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
