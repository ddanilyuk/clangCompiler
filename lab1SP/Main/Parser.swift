//
//  Parser.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
    
    enum Error: Swift.Error {
        case expectedNumber
        case expectedIdentifier
        case expectedOperator
        case expectedExpression
        case expected(String)
        case notDefined(String)
        case invalidParameters(toFunction: String)
        case alreadyDefined(String)
    }
    
    let tokens: [Token]
    var index = 0
    
    var canPop: Bool {
        return index < tokens.count
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peek() -> Token {
        return tokens[index]
    }
    
    func peekPrecedence() throws -> Int {
        return -1
    }
    
    func popToken() -> Token {
        let token = tokens[index]
        index += 1
        return token
    }
    
    func parseFloat() throws -> Float {
        guard case let Token.floatNumber(float) = popToken() else {
            throw Error.expectedNumber
        }
        return float
    }
    
    func parseInt() throws -> Int {
        guard case let Token.intNumber(int) = popToken() else {
            throw Error.expectedNumber
        }
        return int
    }
    
    func parseValue() throws -> Node {
        switch (peek()) {
        case .floatNumber:
            return try parseFloat()
        case .intNumber:
            return try parseInt()
        default:
            throw Error.expected("<Expression>")
        }
    }
    
    
    func parseReturn() throws -> Node {
        guard case .return = popToken() else {
            throw Error.expected("return")
        }
        
        guard case let Token.floatNumber(float) = popToken() else {
            throw Error.expectedNumber
        }
        
        
        
        guard case .semicolon = popToken() else {
            throw Error.expected("semicolon")
        }
        let returnBlock = ReturnBlock(nodes: [float])
        return returnBlock
    }
    
    
    func parseFunctionDefinition() throws -> Node {
        guard case .intType = popToken() else {
            throw Error.expected("function")
        }
        
        guard case let .identifier(identifier) = popToken() else {
            throw Error.expectedIdentifier
        }
        
        guard case .parensOpen = popToken() else {
            throw Parser.Error.expected("(")
        }
        guard case .parensClose = popToken() else {
            throw Parser.Error.expected(")")
        }
                
        // Convert the nodes to their String values
        let codeBlock = try parseCurlyCodeBlock()
        
        return FunctionDefinition(identifier: identifier,
                                  block: codeBlock)
    }
    
    func parseCurlyCodeBlock() throws -> Node {
        guard canPop, case .curlyOpen = popToken() else {
            throw Parser.Error.expected("{")
        }
        
        var depth = 1
        let startIndex = index
        
        while canPop {
            guard case .curlyClose = peek() else {
                if case .curlyOpen = peek() {
                    depth += 1
                }
                
                index += 1
                continue
            }
            
            depth -= 1
            
            guard depth == 0 else {
                index += 1
                continue
            }
            
            break
        }
        
        let endIndex = index
        
        guard canPop, case .curlyClose = popToken() else {
            throw Error.expected("}")
        }
        
        let tokens = Array(self.tokens[startIndex..<endIndex])
        return try Parser(tokens: tokens).parse(name: "function block")
    }
    

    
    // Main parse function
    func parse(name: String) throws -> Node {
        var nodes: [Node] = []
        while canPop {
            let token = peek()
            switch token {
            case .intType:
                let declaration = try parseFunctionDefinition()
                nodes.append(declaration)
            case .return:
                let declaration = try parseReturn()
                nodes.append(declaration)
            
            default:
                break
            }
        }
        return Block(blockName: name, nodes: nodes)
    }
}

//enum Token: String, CaseIterable {
//    case integerKeyword = "int"
//    case functionName
//    case openParentheses = "("
//    case closeParentheses = ")"
//    case openFigureBrace = "{"
//    case closeFigureBrace = "}"
//    case returnKeyword = "return"
//    case semicolon = ";"
//}



