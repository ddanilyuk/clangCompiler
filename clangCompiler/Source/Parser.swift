//
//  Parser.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 22.09.2020.
//

import Foundation


class Parser {
        
    // Identifiers
    public static var identifiersArray: [(id: String, position: Int, depth: Int, valueType: Token)] = [] {
        didSet {
            let count = identifiersArray.filter({ $0.1 < 0 }).count
            if count > maximumVariablesInFunction {
                maximumVariablesInFunction = count
            }
        }
    }
    public static var maximumVariablesInFunction: Int = 0

    // Functions
    public static var functionsArray: [FunctionNode] = []
    
    // Other
    public static var currentDepth: Int = 0
    public static var currentVariablePosition: Int = -4
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
    @discardableResult
    func popToken() -> Token {
        let token = tokensArray[tokenIndex]
        tokenIndex += 1
        Parser.globalTokenIndex += 1
        return token
    }
    
    // Given token must be next token. If not, throw error
    func popSyntaxToken(_ token: Token) throws {
        if !canCheckToken || checkToken() != token {
            throw CompilerError.expected(token.description, Parser.globalTokenIndex)
        } else {
            popToken()
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
            return try parseIndetifier()
        default:
            throw CompilerError.invalidValue(Parser.globalTokenIndex + 1)
        }
    }
    
    func parseIndetifier() throws -> Node {
        guard case let Token.identifier(identifier) = popToken() else {
            throw CompilerError.invalidIdentifier(Parser.globalTokenIndex)
        }
        
        if !canCheckToken || checkToken() == Token.op(.equal) {
            throw CompilerError.invalidOperator("=", Parser.globalTokenIndex)
        }
        
        if !canCheckToken || checkToken() == Token.parensOpen {
            // Function
            return try parseFunctionUsing(identifier: identifier)
        } else {
            // Variable
            return try parseVaribleUsing(identifier: identifier)
        }
    }
    
    func parseFunctionUsing(identifier: String) throws -> Node {
        guard var functionNode = Parser.functionsArray.last(where: { function -> Bool in
            return function.identifier == identifier
        }) else {
            throw CompilerError.functionNotDefined(identifier, Parser.globalTokenIndex)
        }
        
        // Change `isUsed` variable to true in function node
        if let index = Parser.functionsArray.lastIndex(where: { (function) -> Bool in
            return function.identifier == identifier
        }) {
            Parser.functionsArray.remove(at: index)
            var usedFunction = functionNode
            usedFunction.isUsed = true
            Parser.functionsArray.insert(usedFunction, at: index)
        }
        
        //
        try popSyntaxToken(.parensOpen)
        var parameterNodes = [Node]()
        
        if checkToken() != .parensClose {
            
            while canCheckToken {
                var valueInParameter: Node = try parseValue()

                if var variable = valueInParameter as? VariableNode {
                    // If parameter is value
                    variable.variableNodeType = .using
                    valueInParameter = variable
                } else if var function = valueInParameter as? FunctionNode {
                    // If parameter is function
                    function.functionType = .using
                    valueInParameter = function
                }
                
                parameterNodes.append(VariableNode(identifier: "", address: 0, depth: 0, value: valueInParameter, valueType: .questionMark, variableNodeType: .parameterPushing))
                
                if Token.parensClose == checkToken() {
                    try popSyntaxToken(.parensClose)
                    break
                } else {
                    try popSyntaxToken(.comma)
                }
            }
            
            if functionNode.parametersCount != parameterNodes.count {
                throw CompilerError.invalidNumberOfArguments((identifier: identifier, expected: functionNode.parametersCount, given: parameterNodes.count), Parser.globalTokenIndex)
            }
        } else {
            try popSyntaxToken(.parensClose)
        }
        
        functionNode.parametersBlock = Block(nodes: parameterNodes.reversed(), blockType: .parameters)
        functionNode.functionType = .using
        
        return functionNode
    }
    
    func parseVaribleUsing(identifier: String) throws -> Node {
        if let (_, position, depth, valueType) = Parser.identifiersArray.last(where: { (id, _, _, _) -> Bool in
            return id == identifier
        }) {
            return VariableNode(identifier: identifier, address: position, depth: depth, valueType: valueType, variableNodeType: .using)
        } else {
            throw CompilerError.variableNotDefined(identifier, Parser.globalTokenIndex)
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
        
        if canCheckToken {
            if checkToken() == Token.questionMark {
                return try parseTernaryOperator(node: node)
            } else {
                return try parseBinaryOperation(leftNode: node)
            }
        } else {
            throw CompilerError.unexpectedError(Parser.globalTokenIndex - 1)
        }
        
    }
    
    func parseTernaryOperator(node: Node) throws -> Node {
        try popSyntaxToken(Token.questionMark)
        
        let trueNode = try parseExpression()
        
        try popSyntaxToken(Token.colon)
        
        let falseNode = try parseExpression()
        
        return TernaryNode(conditionNode: node, trueNode: trueNode, falseNode: falseNode)
    }
    
    func parseDoWhileBlock() throws -> Node {
        try popSyntaxToken(.do)
        
        let block = try parseCurlyCodeBlock(blockType: .doWhileBlock)
        
        try popSyntaxToken(.while)
        
        let conditionNode = try parseExpressionInParens()
        
        try popSyntaxToken(.semicolon)
        
        return DoWhileNode(conditionNode: conditionNode, block: block)
    }
    
    func parseBinaryOperation(leftNode: Node, nodePriority: Int = 0) throws -> Node {
        
        var leftNode = leftNode
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
                rightNode = try parseBinaryOperation(leftNode: rightNode, nodePriority: priority + 1)
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
    
    func parserVariableOrFunction() throws -> Node {
        
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
        
        if Parser.identifiersArray.last(where: { (id, _, depth, _) -> Bool in
            return id == identifier && depth == Parser.currentDepth
        }) != nil {
            throw CompilerError.variableAlreadyDefined(identifier, Parser.globalTokenIndex)
        }

        if checkToken() == .parensOpen {
            return try parseFunction(valueType: valueType, identifier: identifier)
        } else {
            return try parseVariable(valueType: valueType, identifier: identifier)
        }
    }
    
    func parseVariable(valueType: Token, identifier: String) throws -> Node {
        var variable = VariableNode(identifier: identifier, address: Parser.currentVariablePosition, depth: Parser.currentDepth, valueType: valueType, variableNodeType: .declarationAndAssignment)
        Parser.currentVariablePosition -= 4
                
        Parser.identifiersArray.append((id: identifier, position: variable.address, depth: Parser.currentDepth, valueType: variable.valueType))
        
        // If only declaration of variable
        if checkToken() != Token.op(.equal) {
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
    
    func parseFunction(valueType: Token, identifier: String) throws -> Node {
        // Get index to generate errors if needed
        let functionStartIndex = Parser.globalTokenIndex - 1
        
        let parametersBlock = try parseFunctionParameters()
        
        let functionNode = FunctionNode(identifier: identifier,
                                                  parametersBlock: parametersBlock,
                                                  functionBlock: Block(nodes: [], blockType: .function),
                                                  returnType: .floatType,
                                                  functionType: .onlyDeclaration,
                                                  variablesCount: 0)
        
        Parser.functionsArray.append(functionNode)
        
        if !canCheckToken || checkToken() == Token.semicolon {
            // If only declaration
            try popSyntaxToken(.semicolon)
            return functionNode
            
        } else {
            // If declaration and assign
            let functionNodeBlock = try parseCurlyCodeBlock(blockType: .function)
            
            // Check if last node in function block is ReturnNode
            if let block = functionNodeBlock as? Block {
                
                var isHaveReturn: Bool = false
                var currentBlock: Block = block
                
                repeat {
                    if currentBlock.nodes.contains(where: { $0 is ReturnNode ? true : false }) {
                        isHaveReturn = true
                        break
                    }
                } while currentBlock.nodes.contains(where: { node -> Bool in
                    if let block = node as? Block {
                        currentBlock = block
                        return true
                    } else {
                        return false
                    }
                })
                
                if !isHaveReturn {
                    throw CompilerError.noReturn(identifier, Parser.globalTokenIndex)
                }
            }
            
            let functionNode = FunctionNode(identifier: identifier,
                                                      parametersBlock: parametersBlock,
                                                      functionBlock: functionNodeBlock,
                                                      returnType: valueType,
                                                      functionType: .declarationAndAssignment,
                                                      variablesCount: Parser.maximumVariablesInFunction)
            
            try Parser.functionsArray.removeAll { functionDefinitionNode in
                if functionDefinitionNode.identifier == identifier {
                    if functionDefinitionNode.functionType == .declarationAndAssignment {
                        throw CompilerError.functionAlreadyDefined(identifier, functionStartIndex)
                    } else if functionDefinitionNode.parametersCount != functionNode.parametersCount {
                        throw CompilerError.invalidfunctionAssignment((identifier: identifier, expected: functionDefinitionNode.parametersCount, given: functionNode.parametersCount), functionStartIndex)
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            }

            Parser.functionsArray.append(functionNode)
            
            return functionNode
        }
    }
    
    func parseFunctionParameters() throws -> Node {
        try popSyntaxToken(.parensOpen)
        
        if checkToken() == Token.parensClose {
            try popSyntaxToken(.parensClose)
            return Block(nodes: [], blockType: .parameters)
        }
        
        var nodes = [Node]()
        var parameterPosition = 8
        
        while canCheckToken {
            nodes.append(try parseParameterDeclare(position: parameterPosition))
            parameterPosition += 4
            
            if Token.parensClose == checkToken() {
                try popSyntaxToken(.parensClose)
                break
            } else {
                try popSyntaxToken(.comma)
            }
        }
        
        return Block(nodes: nodes, blockType: .parameters)
    }
    
    func parseParameterDeclare(position: Int) throws -> Node {
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
        
        Parser.identifiersArray.append((id: identifier, position: position, depth: 0, valueType: valueType))
        return VariableNode(identifier: identifier, address: position, depth: 0, valueType: valueType, variableNodeType: .parameterDeclare)
    }
    
    /// Now, this function parse only variables changes.
    func parseVariableChange() throws -> Node {
        guard case let .identifier(identifier) = popToken() else {
            throw CompilerError.invalidIdentifier(Parser.globalTokenIndex)
        }
        
        guard let (_, position, depth, valueType) = Parser.identifiersArray.last(where: { (id, _, _, _) in
            return id == identifier
        }) else {
            throw CompilerError.variableNotDefined(identifier, Parser.globalTokenIndex)
        }
        
        if checkToken() == .op(.divideEqual) {
            let oldVariable = VariableNode(identifier: identifier, address: position, depth: depth, valueType: valueType, variableNodeType: .using)
            
            let newValue = try parseBinaryOperation(leftNode: oldVariable)

            try popSyntaxToken(Token.semicolon)
            
            return VariableNode(identifier: identifier, address: position, depth: depth, value: newValue, valueType: valueType, variableNodeType: .changing)
        } else {
            try popSyntaxToken(Token.op(.equal))
            let newValue = try parseExpression()
            try popSyntaxToken(Token.semicolon)
            return VariableNode(identifier: identifier, address: position, depth: depth, value: newValue, valueType: valueType, variableNodeType: .changing)
        }
    }
    
    func parseReturn() throws -> Node {
        try popSyntaxToken(Token.return)
        let value = try parseExpression()
        try popSyntaxToken(Token.semicolon)
        
        return ReturnNode(node: value, functionIdenitifer: Parser.functionsArray.last?.identifier ?? "")
    }
    
    func parseContinue(blockType: Block.BlockType) throws -> Node {
        if blockType != .doWhileBlock {
            throw CompilerError.continueOutsideLoop(Parser.globalTokenIndex - Parser.currentDepth)
        }
        try popSyntaxToken(Token.continue)
        try popSyntaxToken(Token.semicolon)
        return ContinueNode()
    }
    
    func parseBreak(blockType: Block.BlockType) throws -> Node {
        if blockType != .doWhileBlock {
            throw CompilerError.breakOutsideLoop(Parser.globalTokenIndex)
        }
        try popSyntaxToken(Token.break)
        try popSyntaxToken(Token.semicolon)
        return BreakNode()
    }
    
    // MARK: - Main parse function
    // This function parse blocks
    func parseBlock(blockType: Block.BlockType) throws -> Node {
        var blockNodes: [Node] = []
        while canCheckToken {
            let token = checkToken()
            switch token {
            case .intType, .floatType:
                
                let node = try parserVariableOrFunction()
                if let funcNode = node as? FunctionNode {
                    if funcNode.functionType == .declarationAndAssignment {
                        Parser.currentDepth = 1
                        Parser.currentVariablePosition = -4
                        Parser.identifiersArray = []
                        Parser.maximumVariablesInFunction = 0
                    }
                }
                blockNodes.append(node)
                
            case .return:
                blockNodes.append(try parseReturn())
            case .identifier:
                blockNodes.append(try parseVariableChange())
            case .curlyOpen:
                let beforeBlockIdentifiersCount = Parser.identifiersArray.filter { $0.1 < 0 }.count
                let beforeBlockFunctionsCount = Parser.functionsArray.filter{ $0.functionType == .onlyDeclaration }.count

                Parser.currentDepth += 1
                blockNodes.append(try parseCurlyCodeBlock(blockType: .codeBlock))
                
                while Parser.identifiersArray.filter({ $0.1 < 0 }).count != beforeBlockIdentifiersCount {
                    Parser.identifiersArray.removeLast()
                    Parser.currentVariablePosition += 4
                }
                
                while Parser.functionsArray.filter({ $0.functionType == .onlyDeclaration }).count != beforeBlockFunctionsCount {
                    Parser.functionsArray.removeLast()
                }
                
                Parser.currentDepth -= 1
                
            case .do:
                let node = try parseDoWhileBlock()
                blockNodes.append(node)
                
            case .continue:
                let node = try parseContinue(blockType: blockType)
                blockNodes.append(node)
                
            case .break:
                let node = try parseBreak(blockType: blockType)
                blockNodes.append(node)
            case .comment:
                popToken()
            default:
                throw CompilerError.unexpectedError(Parser.globalTokenIndex)
            }
        }
        
        // After parsing genetating errors
        if blockType == .startPoint {
            let usedFunctions = Parser.functionsArray.filter { $0.isUsed && $0.functionType == .onlyDeclaration }
            let haveDefinitionFunctions = Parser.functionsArray.filter { $0.functionType == .declarationAndAssignment }
            
            try usedFunctions.forEach { functionNode in
                if !haveDefinitionFunctions.contains(where: { $0.identifier == functionNode.identifier }) {
                    throw CompilerError.functionUsedButNotHaveDefinition(functionNode.identifier, 0)
                }
            }
        }
        return Block(nodes: blockNodes, blockType: blockType)
    }
}
