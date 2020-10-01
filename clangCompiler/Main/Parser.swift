//
//  Parser.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
    
    public static var globalTokenIndex = -1
        
    // All tokensArray
    let tokensArray: [Token]
    
    // Start tokenIndex
    var tokenIndex = 0
    
    var canCheckToken: Bool {
        return tokenIndex < tokensArray.count
    }
    
    init(tokens: [Token]) {
        self.tokensArray = tokens
    }
    
    func checkToken() -> Token {
        return tokensArray[tokenIndex]
    }
    
    func getTokenPriority() throws -> Int {
        if canCheckToken {
            if case let Token.op(op) = checkToken() {
                return op.precedence
            } else {
                return -1
            }
        } else {
            return -2
        }
    }
    
    @discardableResult func popToken() -> Token {
        let token = tokensArray[tokenIndex]
        tokenIndex += 1
        Parser.globalTokenIndex += 1
        return token
    }
    
    func parseFloatNumber() throws -> Node {
        guard case let Token.floatNumber(float) = popToken() else {
            throw CompilerError.expectedFloat(Parser.globalTokenIndex)
        }
        return NumberNode(node: float, numberType: .float)
    }
    
    func parseIntNumber() throws -> Node {
        guard case let Token.intNumber(int, integerType) = popToken() else {
            throw CompilerError.expectedInt(Parser.globalTokenIndex)
        }
        let numberType = integerType == .decimal ? NumberNode.NumberType.decimal : NumberNode.NumberType.octal
        let customInt = CustomIntNode(integer: int, type: integerType)
        
        return NumberNode(node: customInt, numberType: numberType)
    }
    
    func parseValue() throws -> Node {
        switch (checkToken()) {
        case .floatNumber:
            return try parseFloatNumber()
        case .intNumber:
            return try parseIntNumber()
        case .parensOpen:
            return try parseExpressionInParens()
        case .op(.minus):
            return try parseUnaryMinus()
        case .identifier:
            throw CompilerError.invalidFunctionIdentifier(Parser.globalTokenIndex)
        default:
            throw CompilerError.invalidValue(Parser.globalTokenIndex)
        }
    }
    
    func parseUnaryMinus() throws -> Node {
        if popToken() != Token.op(.minus) {
            throw CompilerError.expected("-", tokenIndex)
        }
        
        
        if !canCheckToken || Token.op(.minus) == checkToken() {
            throw CompilerError.expected("number or expression", Parser.globalTokenIndex)
        }
                
        return UnaryNegativeNode(node: try parseValue())
    }
    
    func parseExpressionInParens() throws -> Node {
        // Check if next element is "("
        if popToken() != Token.parensOpen {
            throw CompilerError.expected("(", tokenIndex)
        }
        
        // Parsing expression inside parens
        let expressionNode = try parseExpression()
        
        // Check if next element is ")"
        if popToken() != Token.parensClose {
            throw CompilerError.expected(")", Parser.globalTokenIndex)
        }

        return expressionNode
    }
    
    func parseReturn() throws -> Node {
        if popToken() != Token.return {
            throw CompilerError.expected("return", Parser.globalTokenIndex)
        }
                
        let value = try parseExpression()
        
        if !canCheckToken || popToken() != Token.semicolon {
            throw CompilerError.expected("semicolon", Parser.globalTokenIndex)
        }
        
        return ReturnNode(node: value)
    }
    
    func parseFunctionDefinition() throws -> Node {
        var functionReturnType: Token = .floatType
        
        switch (checkToken()) {
        case .floatType, .intType:
            functionReturnType = popToken()
        default:
            throw CompilerError.expected("Function type", Parser.globalTokenIndex)
        }
        
        guard case let Token.identifier(identifier) = popToken() else {
            throw CompilerError.invalidFunctionIdentifier(Parser.globalTokenIndex)
        }
        
        
        if popToken() != Token.parensOpen {
            throw CompilerError.expected("(", Parser.globalTokenIndex)
        }
        
        if popToken() != Token.parensClose {
            throw CompilerError.expected(")", Parser.globalTokenIndex)
        }
        
        let functionNodeBlock = try parseCurlyCodeBlock(blockType: .function)
        
        return FunctionDefinitionNode(identifier: identifier,
                                      block: functionNodeBlock,
                                      returnType: functionReturnType)
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        if canCheckToken {
            if popToken() != Token.curlyOpen {
                throw CompilerError.expected("{", Parser.globalTokenIndex)
            }
        }

        let startCurlyBlockIndex = tokenIndex
        
        // Parsing deeper
        var blockDepth = 1
        while canCheckToken {
            if Token.curlyClose == checkToken() {
                blockDepth -= 1
                if blockDepth != 0 {
                    tokenIndex += 1
                    continue
                }
                break
            } else {
                if Token.curlyOpen == checkToken() {
                    blockDepth += 1
                }
                tokenIndex += 1
                continue
            }
        }
        
        let endCurlyBlockIndex = tokenIndex
        
        if !canCheckToken || popToken() != Token.curlyClose {
            throw CompilerError.expected("}", endCurlyBlockIndex)
        }
        
        // Getting new elements inside curly block
        let tokensInsideCurlyBlock: [Token] = Array(self.tokensArray[startCurlyBlockIndex..<endCurlyBlockIndex])
        
        // Try to parse it
        return try Parser(tokens: tokensInsideCurlyBlock).parseBlock(blockType: blockType)
    }
    
    func parseExpression() throws -> Node {
        guard canCheckToken else {
            throw CompilerError.expectedExpression(Parser.globalTokenIndex)
        }
        let node = try parseValue()
        
        if var unaryNegativeNode = node as? UnaryNegativeNode {
            unaryNegativeNode.postition = .lhs
            return try parseInfixOperation(node: unaryNegativeNode)
        } else {
            return try parseInfixOperation(node: node)
        }
        
    }
    
    func parseInfixOperation(node: Node, nodePriority: Int = 0) throws -> Node {
        
        var leftNode = node
        
        var priority = try getTokenPriority()
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw CompilerError.expectedOperator(Parser.globalTokenIndex)
            }
            
            var rightNode = try parseValue()
            

            if var unaryRight = rightNode as? UnaryNegativeNode {
                unaryRight.postition = .rhs
                let nextPriority = try getTokenPriority()
                if priority < nextPriority {
                    rightNode = try parseInfixOperation(node: unaryRight, nodePriority: priority + 1)
                    leftNode = OperationNode(op: op, lhs: leftNode, rhs: rightNode)
                } else {
                    leftNode = OperationNode(op: op, lhs: leftNode, rhs: unaryRight)
                }
                priority = try getTokenPriority()
                
            } else {
                let nextPriority = try getTokenPriority()
                if priority < nextPriority {
                    rightNode = try parseInfixOperation(node: rightNode, nodePriority: priority + 1)
                }
                leftNode = OperationNode(op: op, lhs: leftNode, rhs: rightNode)
                priority = try getTokenPriority()
            }
        }
        return leftNode
    }

    // Main parse function
    // This function parse blocks
    func parseBlock(blockType: Block.BlockType) throws -> Node {
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
                throw CompilerError.unexpectedError(Parser.globalTokenIndex)
            }
        }
        return Block(nodes: nodes, blockType: blockType)
    }
}
