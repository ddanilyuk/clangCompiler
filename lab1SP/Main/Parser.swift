//
//  Parser.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
    
    // Possible errors
    enum Error: Swift.Error, LocalizedError {
        case expectedNumber(Int)
        case expectedIdentifier(Int)
        case expectedOperator(Int)
        case expectedExpression(Int)
        case expected(String, Int)
        case notDefined(String, Int)
        case alreadyDefined(String, Int)
        
        var index: Int {
            switch self {
            case let .expectedNumber(index), let .expectedIdentifier(index), let .expectedOperator(index), let .expectedExpression(index):
                return index
            case let .expected(_, index), let .notDefined(_, index), let .alreadyDefined(_, index):
                return index
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .expectedNumber:
                return "Number expected"
            case .expectedIdentifier:
                return "Identifier expected"
            case .expectedOperator:
                return "Operator expected"
            case .expectedExpression:
                return "Expression expected"
            case let .expected(str, _):
                return "Extected \"\(str)\""
            case let .notDefined(str, _):
                return "\(str) not defined"
            case let .alreadyDefined(str, _):
                return "\(str) already defined"
            }
        }
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
    
    func parseFloat() throws -> Node {
        guard case let Token.floatNumber(float) = popToken() else {
            throw Error.expectedNumber(index)
        }
        return NumberNode(node: float, numberType: .float)
    }
    
    func parseInt() throws -> Node {
        guard case let Token.intNumber(int, integerType) = popToken() else {
            throw Error.expectedNumber(index)
        }
        let numberType = integerType == .decimal ? NumberNode.NumberType.decimal : NumberNode.NumberType.octal
        let customInt = CustomIntNode(integer: int, type: integerType)
        
        return NumberNode(node: customInt, numberType: numberType)
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
            throw Error.expected("<Expression>", 1)
        }
    }
    
    func parseParens() throws -> Node {
        guard case .parensOpen = popToken() else {
            throw Error.expected("(", index)
        }
        
        let expressionNode = try parseExpression() // ADDED - was "try parse()"
        
        guard case .parensClose = popToken() else {
            throw Error.expected("(", index)
        }
        
        return expressionNode
    }
    
    func parseReturn() throws -> Node {
        guard case .return = popToken() else {
            throw Error.expected("return", index)
        }

        let value = try parseValue()
        
        guard case .semicolon = popToken() else {
            throw Parser.Error.expected("semicolon", index)
        }
        return ReturnNode(node: value)
    }
    
    func parseFunctionDefinition() throws -> Node {
        var functionReturnType: Token = .floatType
        
        switch (checkToken()) {
        case .floatType, .intType:
            functionReturnType = popToken()
        default:
            throw Error.expected("Function type", index)
        }
        
        
        guard case let Token.identifier(identifier) = popToken() else {
            throw Error.expectedIdentifier(index)
        }
        
        guard case .parensOpen = popToken() else {
            throw Parser.Error.expected("(", index)
        }
        guard case .parensClose = popToken() else {
            throw Parser.Error.expected(")", index)
        }
                
        let codeBlock = try parseCurlyCodeBlock(blockType: .function)
        
        return FunctionDefinitionNode(identifier: identifier,
                                      block: codeBlock,
                                      returnType: functionReturnType)
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        guard canCheckToken, case Token.curlyOpen = popToken() else {
            throw Parser.Error.expected("{", index)
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
            throw Error.expected("}", index)
        }
        
        let tokens = Array(self.tokens[startIndex..<endIndex])
        return try Parser(tokens: tokens).parse(blockType: blockType)
    }
    
    func parseExpression() throws -> Node { // ADDED this is the old parse method
        guard canCheckToken else {
            throw Error.expectedExpression(index)
        }
        let node = try parseValue()
        return try parseInfixOperation(node: node)
    }
    
    func parseInfixOperation(node: Node, nodePriority: Int = 0) throws -> Node {
        var leftNode = node
        
        var priority = try getPriority()
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw Error.expectedOperator(index)
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
            case .intType, .floatType:
                let declaration = try parseFunctionDefinition()
                nodes.append(declaration)
            case .return:
                let declaration = try parseReturn()
                nodes.append(declaration)
            
            default:
                break
            }
        }
        return Block(nodes: nodes, blockType: blockType)
    }
}
