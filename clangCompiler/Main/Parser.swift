//
//  Parser.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
        
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
    
    func popToken() -> Token {
        let token = tokensArray[tokenIndex]
        tokenIndex += 1
        return token
    }
    
    func parseFloatNumber() throws -> Node {
        guard case let Token.floatNumber(float) = popToken() else {
            throw CompilerError.expectedFloat(tokenIndex)
        }
        return NumberNode(isNegative: false, node: float, numberType: .float)
    }
    
    func parseIntNumber() throws -> Node {
        guard case let Token.intNumber(int, integerType) = popToken() else {
            throw CompilerError.expectedInt(tokenIndex)
        }
        let numberType = integerType == .decimal ? NumberNode.NumberType.decimal : NumberNode.NumberType.octal
        let customInt = CustomIntNode(integer: int, type: integerType)
        
        return NumberNode(isNegative: false, node: customInt, numberType: numberType)
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
            throw CompilerError.invalidFunctionIdentifier(tokenIndex)
        
        default:
            throw CompilerError.invalidValue(tokenIndex)
        }
    }
    
    func parseUnaryMinus() throws -> Node {
        if popToken() != Token.op(.minus) {
            throw CompilerError.expected("-", tokenIndex)
        }
        
        let value = try parseValue()
        let unaryNegative = UnaryNegativeNode(node: value)
        
//        if var numberNode = value as? NumberNode {
//            numberNode.isNegative = true
//            return numberNode
//        }
        
        return unaryNegative
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
            throw CompilerError.expected(")", tokenIndex)
        }

        return expressionNode
    }
    
    func parseReturn() throws -> Node {
        if popToken() != Token.return {
            throw CompilerError.expected("return", tokenIndex)
        }
                
        let value = try parseValue()
        
        if popToken() != Token.semicolon {
            throw CompilerError.expected("semicolon", tokenIndex)
        }
        
        return ReturnNode(node: value)
    }
    
    func parseFunctionDefinition() throws -> Node {
        var functionReturnType: Token = .floatType
        
        switch (checkToken()) {
        case .floatType, .intType:
            functionReturnType = popToken()
        default:
            throw CompilerError.expected("Function type", tokenIndex)
        }
        
        guard case let Token.identifier(identifier) = popToken() else {
            throw CompilerError.invalidFunctionIdentifier(tokenIndex)
        }
        
        if popToken() != Token.parensOpen {
            throw CompilerError.expected("(", tokenIndex)
        }
        
        if popToken() != Token.parensClose {
            throw CompilerError.expected("(", tokenIndex)
        }
        
        let functionNodeBlock = try parseCurlyCodeBlock(blockType: .function)
        
        // Checking if return value is matches with actual
        if let functionBlock = functionNodeBlock as? Block {
            if let returnNode = functionBlock.nodes.last as? ReturnNode {
                if let numberNode = returnNode.node as? NumberNode {
                    switch numberNode.numberType {
                    case .decimal, .octal:
                        if functionReturnType == .floatType {
                            
                            // -2 becauese current postion is after } but i need to know where number.
                            // TODO: - change when will be possible to return expression
                            throw CompilerError.invalidReturnType("Int", tokenIndex - 2)
                        }
                    case .float:
                        if functionReturnType == .intType {
                            throw CompilerError.invalidReturnType("Float", tokenIndex - 2)
                        }
                    }
                } else {
//                    throw CompilerError.expected("Expected number in return", tokenIndex - 2)
                }
            }
        }
        
        return FunctionDefinitionNode(identifier: identifier,
                                      block: functionNodeBlock,
                                      returnType: functionReturnType)
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        if canCheckToken {
            if popToken() != Token.curlyOpen {
                throw CompilerError.expected("{", tokenIndex)
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
        
        if canCheckToken {
            if popToken() != Token.curlyClose {
                throw CompilerError.expected("}", tokenIndex)
            }
        }
        
        // Getting new elements inside curly block
        let tokensInsideCurlyBlock: [Token] = Array(self.tokensArray[startCurlyBlockIndex..<endCurlyBlockIndex])
        
        // Try to parse it
        return try Parser(tokens: tokensInsideCurlyBlock).parseBlock(blockType: blockType)
    }
    
    func parseExpression() throws -> Node {
        guard canCheckToken else {
            throw CompilerError.expectedExpression(tokenIndex)
        }
        let node = try parseValue()
        return try parseInfixOperation(node: node)
    }
    
    func parseInfixOperation(node: Node, nodePriority: Int = 0) throws -> Node {
        var leftNode = node
        
        var priority = try getTokenPriority()
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw CompilerError.expectedOperator(tokenIndex)
            }
            
            var rightNode = try parseValue()
            
            let nextPrecedence = try getTokenPriority()
            
            if priority < nextPrecedence {
                rightNode = try parseInfixOperation(node: rightNode, nodePriority: priority + 1)
            }
            leftNode = InfixOperation(op: op, lhs: leftNode, rhs: rightNode)
            
            priority = try getTokenPriority()
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
                throw CompilerError.expected("return", 1)
            }
        }
        return Block(nodes: nodes, blockType: blockType)
    }
}
