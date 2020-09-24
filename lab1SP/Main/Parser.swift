//
//  Parser.swift
//  lab1SP
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
    
    func getPriority() throws -> Int {
        guard canCheckToken, case let Token.op(op) = checkToken() else {
            return -1
        }
        
        return op.precedence
    }
    
    func popToken() -> Token {
        let token = tokensArray[tokenIndex]
        tokenIndex += 1
        return token
    }
    
    func parseFloat() throws -> Node {
        guard case let Token.floatNumber(float) = popToken() else {
            throw CompilerError.expectedFloat(tokenIndex)
        }
        return NumberNode(node: float, numberType: .float)
    }
    
    func parseInt() throws -> Node {
        guard case let Token.intNumber(int, integerType) = popToken() else {
            throw CompilerError.expectedInt(tokenIndex)
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
            throw CompilerError.invalidValue(tokenIndex)
        }
    }
    
    func parseParens() throws -> Node {
        guard case .parensOpen = popToken() else {
            throw CompilerError.expected("(", tokenIndex)
        }
        
        let expressionNode = try parseExpression() // ADDED - was "try parse()"
        
        guard case .parensClose = popToken() else {
            throw CompilerError.expected("(", tokenIndex)
        }
        
        return expressionNode
    }
    
    func parseReturn() throws -> Node {
        guard case .return = popToken() else {
            throw CompilerError.expected("return", tokenIndex)
        }

        let value = try parseValue()
        
        guard case .semicolon = popToken() else {
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
        
        guard case .parensOpen = popToken() else {
            throw CompilerError.expected("(", tokenIndex)
        }
        guard case .parensClose = popToken() else {
            throw CompilerError.expected(")", tokenIndex)
        }
        
        let functionNodes = try parseCurlyCodeBlock(blockType: .function)
        
//        print(codeBlock)
        
        if let functionBlock = functionNodes as? Block {
            if let returnNode = functionBlock.nodes.last as? ReturnNode {
                if let numberNode = returnNode.node as? NumberNode {
                    switch numberNode.numberType {
                    case .decimal, .octal:
                        if functionReturnType == .floatType {
                            
                            // -2 becauese current postion is after } but i need to know where number.
                            // TODO: - change when will be possible to return eexpression
                            throw CompilerError.invalidReturnType("Int", tokenIndex - 2)
                        }
                    case .float:
                        if functionReturnType == .intType {
                            throw CompilerError.invalidReturnType("Float", tokenIndex - 2)
                        }
                    }
                } else {
                    throw CompilerError.expected("Expected number in return", tokenIndex - 2)
                }
            }
        }
        
        return FunctionDefinitionNode(identifier: identifier,
                                      block: functionNodes,
                                      returnType: functionReturnType)
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        guard canCheckToken, case Token.curlyOpen = popToken() else {
            throw CompilerError.expected("{", tokenIndex)
        }
        
        var depth = 1
        let startIndex = tokenIndex
        
        while canCheckToken {
            guard case Token.curlyClose = checkToken() else {
                if case Token.curlyOpen = checkToken() {
                    depth += 1
                }
                
                tokenIndex += 1
                continue
            }
            
            depth -= 1
            guard depth == 0 else {
                tokenIndex += 1
                continue
            }
            break
        }
        
        let endIndex = tokenIndex
        
        guard canCheckToken, case Token.curlyClose = popToken() else {
            throw CompilerError.expected("}", tokenIndex)
        }
        
        let tokens = Array(self.tokensArray[startIndex..<endIndex])
        return try Parser(tokens: tokens).parse(blockType: blockType)
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
        
        var priority = try getPriority()
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw CompilerError.expectedOperator(tokenIndex)
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
    // This function parse blocks
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
