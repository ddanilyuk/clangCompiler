//
//  Parser.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
    
    // Possible errors
    enum Error: Swift.Error {
        case expectedNumber
        case expectedIdentifier
        case expectedOperator
        case expectedExpression
        case expected(String)
        case notDefined(String)
        case alreadyDefined(String)
    }
    
    // All tokens
    let tokens: [Token]
    
    // Start index
    var index = 0
    
    var canCheckToken: Bool {
        return index < tokens.count
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func checkToken() -> Token {
        return tokens[index]
    }
    
    func getPriority() throws -> Int {
        guard canCheckToken, case let Token.op(op) = checkToken() else {
            return -1
        }
        
        return op.precedence
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
        switch (checkToken()) {
        case .floatNumber:
            return try parseFloat()
        case .intNumber:
            return try parseInt()
        case .parensOpen:
            return try parseParens()
        case .identifier:
            fatalError("function call is not implemented")

        default:
            throw Error.expected("<Expression>")
        }
    }
    
    func parseParens() throws -> Node {
        guard case .parensOpen = popToken() else {
            throw Error.expected("(")
        }
        
        let expressionNode = try parseExpression() // ADDED - was "try parse()"
        
        guard case .parensClose = popToken() else {
            throw Error.expected("(")
        }
        
        return expressionNode
    }
    
    func parseReturn() throws -> Node {
        guard case .return = popToken() else {
            throw Error.expected("return")
        }
        
        let value = try parseValue()
        
        guard case .semicolon = popToken() else {
            throw Parser.Error.expected("semicolon")
        }
        let returnBlock = Block(blockType: .return, nodes: [value])
        
        return returnBlock
    }
    
    func parseFunctionDefinition() throws -> Node {
        var functionReturnType: Token = .floatType
        
        switch (checkToken()) {
        case .floatType, .intType:
            functionReturnType = popToken()
        default:
            throw Error.expected("function type")
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
                
        let codeBlock = try parseCurlyCodeBlock(blockType: .function)
        
        return FunctionDefinition(returnType: functionReturnType,
                                  identifier: identifier,
                                  block: codeBlock)
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        guard canCheckToken, case Token.curlyOpen = popToken() else {
            throw Parser.Error.expected("{")
        }
        
        var depth = 1
        let startIndex = index
        
        while canCheckToken {
            guard case Token.curlyClose = checkToken() else {
                if case Token.curlyOpen = checkToken() {
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
        
        guard canCheckToken, case Token.curlyClose = popToken() else {
            throw Error.expected("}")
        }
        
        let tokens = Array(self.tokens[startIndex..<endIndex])
        return try Parser(tokens: tokens).parse(blockType: blockType)
    }
    
    func parseExpression() throws -> Node { // ADDED this is the old parse method
        guard canCheckToken else {
            throw Error.expectedExpression
        }
        let node = try parseValue()
        return try parseInfixOperation(node: node)
    }
    
    func parseInfixOperation(node: Node, nodePriority: Int = 0) throws -> Node {
        var leftNode = node
        
        var priority = try getPriority()
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw Error.expectedOperator
            }
            
            var rightNode = try parseValue()
            
            let nextPrecedence = try getPriority()
            
            if priority < nextPrecedence {
                rightNode = try parseInfixOperation(node: rightNode, nodePriority: priority + 1)
            }
            leftNode = InfixOperation(op: op, lhs: leftNode, rhs: rightNode)
            
            priority = try getPriority()
        }
        return leftNode
    }

    // Main parse function
    func parse(blockType: Block.BlockType) throws -> Node {
        var nodes: [Node] = []
        while canCheckToken {
            let token = checkToken()
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
        return Block(blockType: blockType, nodes: nodes)
    }
}
