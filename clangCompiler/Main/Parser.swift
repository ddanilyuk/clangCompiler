//
//  Parser.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
    
    typealias IdentifiersArray = [(id: String, position: Int, depth: Int, valueType: Token)]
    
    public static var maxIdentifires: Int = 0
    
    public static var identifiersArray: IdentifiersArray = [] {
        didSet {
            if identifiersArray.count > maxIdentifires {
                maxIdentifires = identifiersArray.count
            }
        }
    }
    
    public static var currentDepth: Int = 0
    public static var currentVariablePosition: Int = 4

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
    
    // Get next token (NOT increment token index)
    func checkToken() -> Token {
        return tokensArray[tokenIndex]
    }
    
    // Gets next token priority.
    // -1 for not operators
    func getTokenPriority() throws -> Int {
        if canCheckToken {
            if case let Token.op(op) = checkToken() {
                return op.priority
            } else {
                return -1
            }
        } else {
            throw CompilerError.unexpectedError(Parser.globalTokenIndex)
        }
    }
    
    // Get next token and increment token index
    @discardableResult func popToken() -> Token {
        let token = tokensArray[tokenIndex]
        tokenIndex += 1
        Parser.globalTokenIndex += 1
        return token
    }
    
    // Given token must be next token. If not, throw error
    func popSyntaxToken(_ token: Token) throws {
        if !canCheckToken || popToken() != token {
            throw CompilerError.expected(token.description, Parser.globalTokenIndex)
        }
    }
}


// MARK:- Parsing functions
extension Parser {
    
    // MARK:- Values and numbers
    
    func parseValue() throws -> Node {
        switch (checkToken()) {
        case .intNumber:
            return try parseIntNumber()
        case .floatNumber:
            return try parseFloatNumber()
        case .parensOpen:
            return try parseExpressionInParens()
        case .op(.minus):
            return try parseUnaryMinus()
        case .identifier:
            guard case let Token.identifier(identifier) = popToken() else {
                throw CompilerError.invalidIdentifier(Parser.globalTokenIndex)
            }
            
            if let (_, position, depth, valueType) = Parser.identifiersArray.last(where: { (id, position, depth, valueType) -> Bool in
                return id == identifier
            }) {
                if !canCheckToken || checkToken() == Token.op(.equal) {
                    throw CompilerError.invalidOperator("=", Parser.globalTokenIndex + 1)
                }
                return VariableNode(identifier: identifier, address: position, depth: depth, valueType: valueType, variableNodeType: .getting)
            } else {
                throw CompilerError.notDefined(identifier, Parser.globalTokenIndex)
            }
        default:
            throw CompilerError.invalidValue(Parser.globalTokenIndex + 1)
        }
    }
    
    func parseIntNumber() throws -> Node {
        guard case let Token.intNumber(int, integerType) = popToken() else {
            throw CompilerError.expectedInt(Parser.globalTokenIndex)
        }
        let numberType = integerType == .decimal ? NumberNode.NumberType.intDecimal : NumberNode.NumberType.intOctal
        let customInt = CustomIntNode(integer: int, type: integerType)
        
        return NumberNode(value: customInt, numberType: numberType)
    }
    
    func parseFloatNumber() throws -> Node {
        guard case let Token.floatNumber(float) = popToken() else {
            throw CompilerError.expectedFloat(Parser.globalTokenIndex)
        }
        return NumberNode(value: Int(float), numberType: .float)
    }
    
    // MARK:- Exressions and operations
    
    func parseExpressionInParens() throws -> Node {
        try popSyntaxToken(Token.parensOpen)
        
        // Parsing expression inside parens
        let expressionNode = try parseExpression()
        
        try popSyntaxToken(Token.parensClose)
        
        return expressionNode
    }
    
    func parseExpression() throws -> Node {
        guard canCheckToken else { throw CompilerError.expectedExpression(Parser.globalTokenIndex) }
        
        let node = try parseValue()
        
        if checkToken() == Token.questionMark {
            return try parseTernaryOperator(node: node)
        } else {
            return try parseInfixOperation(node: node)
        }
    }
    
    func parseTernaryOperator(node: Node) throws -> Node {
        
        try popSyntaxToken(Token.questionMark)
        
        let trueNode = try parseExpression()
        
        try popSyntaxToken(Token.colon)
        
        let falseNode = try parseExpression()
        
        return TernaryNode(conditionNode: node, trueNode: trueNode, falseNode: falseNode)
    }
    
    func parseInfixOperation(node: Node, nodePriority: Int = 0) throws -> Node {
        
        var leftNode = node
        var priority = try getTokenPriority()
        
        // If next token have priority less than 0 (when it is not operator), this while block skips.
        while priority >= nodePriority {
            guard case let Token.op(op) = popToken() else {
                throw CompilerError.expectedOperator(Parser.globalTokenIndex)
            }
            
            var rightNode = try parseValue()
            
            // If right node is unary negative, select its position
            if var positionNode = rightNode as? PositionNode {
                positionNode.lrPosition = .rhs
                rightNode = positionNode
            }
            
            let nextPriority = try getTokenPriority()
            
            if priority < nextPriority {
                rightNode = try parseInfixOperation(node: rightNode, nodePriority: priority + 1)
            }
            
            leftNode = BinaryOperationNode(op: op, lhs: leftNode, rhs: rightNode)
            
            // New priority
            priority = try getTokenPriority()
        }
        
        return leftNode
    }
    
    func parseCurlyCodeBlock(blockType: Block.BlockType) throws -> Node {
        
        try popSyntaxToken(.curlyOpen)
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
        
        try popSyntaxToken(.curlyClose)
        
        // Getting new elements inside curly block
        let tokensInsideCurlyBlock: [Token] = Array(self.tokensArray[startCurlyBlockIndex..<endCurlyBlockIndex])
        
        // Try to parse it
        return try Parser(tokens: tokensInsideCurlyBlock).parseBlock(blockType: blockType)
    }
    
    func parseUnaryMinus() throws -> Node {
        try popSyntaxToken(Token.op(.minus))
        
        if !canCheckToken || Token.op(.minus) == checkToken() {
            throw CompilerError.expected("number or expression", Parser.globalTokenIndex)
        }
        
        return UnaryNegativeNode(node: try parseValue())
    }
    
    // MARK:- Variables and functions
    
    func parserVariableOrFunctionDeclaration() throws -> Node {
        
        var valueType: Token = .floatType
        
        switch (checkToken()) {
        case .floatType, .intType:
            valueType = popToken()
        default:
            throw CompilerError.expected("value type", Parser.globalTokenIndex)
        }
        
        guard case let Token.identifier(identifier) = popToken() else {
            throw CompilerError.invalidIdentifier(Parser.globalTokenIndex)
        }
        
        
        if Parser.identifiersArray.last(where: { (id, position, depth, valueType) -> Bool in
            return id == identifier && depth == Parser.currentDepth
        }) != nil {
            throw CompilerError.alreadyDefined(identifier, Parser.globalTokenIndex)
        }

        if checkToken() == .parensOpen {
            return try parseFunctionDeclaration(valueType: valueType, identifier: identifier)
        } else {
            return try parseVariableDeclaration(valueType: valueType, identifier: identifier)
        }
    }
    
    func parseVariableDeclaration(valueType: Token, identifier: String) throws -> Node {
        var variable = VariableNode(identifier: identifier, address: Parser.currentVariablePosition, depth: Parser.currentDepth, valueType: valueType, variableNodeType: .declarationAndAssignment)
        Parser.currentVariablePosition += 4
                
        Parser.identifiersArray.append((id: identifier, position: variable.address, depth: Parser.currentDepth, valueType: variable.valueType))
        
        // If only declaration of variable
        if checkToken() == Token.semicolon {
            variable.variableNodeType = .onlyDeclaration
            popToken()
            return variable
        }
        
        try popSyntaxToken(Token.op(.equal))
        
        let value = try parseExpression()
        variable.value = value
        
        try popSyntaxToken(Token.semicolon)
        
        return variable
    }
    
    func parseFunctionDeclaration(valueType: Token, identifier: String) throws -> Node {
        
        try popSyntaxToken(.parensOpen)
        try popSyntaxToken(.parensClose)
        
        let functionNodeBlock = try parseCurlyCodeBlock(blockType: .function)
        
        // Check if last node in function block is ReturnNode
        if let block = functionNodeBlock as? Block {
            if !(block.nodes.last is ReturnNode) {
                throw CompilerError.expected("return", Parser.globalTokenIndex)
            }
        }
        
        return FunctionDefinitionNode(identifier: identifier,
                                      block: functionNodeBlock,
                                      returnType: valueType)
    }
    
    /// Now, this function parse only variables changes.
    func parseIdentifierChange() throws -> Node {
        guard case let .identifier(identifier) = popToken() else {
            throw CompilerError.invalidIdentifier(Parser.globalTokenIndex)
        }
        
        guard let (_, position, depth, valueType) = Parser.identifiersArray.last(where: { (id, position, depth, valueType) in
            return id == identifier
        }) else {
            throw CompilerError.notDefined(identifier, Parser.globalTokenIndex)
        }
        
        try popSyntaxToken(Token.op(.equal))
        let newValue = try parseExpression()
        try popSyntaxToken(Token.semicolon)
        
        return VariableNode(identifier: identifier, address: position, depth: depth, value: newValue, valueType: valueType, variableNodeType: .changing)
    }
    
    func parseReturn() throws -> Node {
        try popSyntaxToken(Token.return)
        let value = try parseExpression()
        try popSyntaxToken(Token.semicolon)
        
        return ReturnNode(node: value)
    }
    
    // MARK:- Main parse function
    // This function parse blocks
    func parseBlock(blockType: Block.BlockType) throws -> Node {
        var nodes: [Node] = []
        while canCheckToken {
            let token = checkToken()
            switch token {
            case .intType, .floatType:
                nodes.append(try parserVariableOrFunctionDeclaration())
            case .return:
                nodes.append(try parseReturn())
            case .identifier:
                nodes.append(try parseIdentifierChange())
            case .curlyOpen:
                let beforeBlockCount = Parser.identifiersArray.count
                Parser.currentDepth += 1
                nodes.append(try parseCurlyCodeBlock(blockType: .codeBlock))
                while Parser.identifiersArray.count != beforeBlockCount {
                    Parser.identifiersArray.removeLast()
                    Parser.currentVariablePosition -= 4
                }
                Parser.currentDepth -= 1
            default:
                throw CompilerError.unexpectedError(Parser.globalTokenIndex)
            }
        }
        return Block(nodes: nodes, blockType: blockType)
    }
}
