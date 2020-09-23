//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation

// Empty protocol node
// Next will be used for implement iterator
public protocol Node: TreeRepresentable {
    func interpret() throws -> String
}


// Operators
struct InfixOperation: Node {
    
    func interpret() throws -> String {
        return "(\(try lhs.interpret()) \(op.rawValue) \(try rhs.interpret()))"
    }
    
    let op: Operator
    let lhs: Node
    let rhs: Node
    var precedence: Int {
        switch op {
        case .minus, .plus: return 10
        case .times, .divideBy: return 20
        }
    }
}

extension InfixOperation: TreeRepresentable {
    var name: String {
        return op.rawValue
    }
    
    var subnodes: [Node] {
        return [lhs, rhs]
    }
}


enum Definition {
    case variable(value: Float)
    case function(FunctionDefinition)
}


struct Block: Node {
    
    enum BlockType: String {
        case function = "function"
        case `return` = "return"
        case startPoint = "start point"
        
        //
        case decimal = "int(decimal)"
        case octal = "int(octal)"
        case float = "float"
    }
    
    var blockType: BlockType
    
    func interpret() throws -> String {
        var result = String()
        
        if blockType == .return {
            result += "return "
        }
        
        for line in nodes[0..<(nodes.endIndex - 1)] {
            result += try line.interpret()
        }
        
        guard let last = nodes.last else {
            throw Parser.Error.expectedExpression
        }
        result += try last.interpret()

        return result
    }
    
    let nodes: [Node]
}

extension Block: TreeRepresentable {
    var name: String {
        return blockType.rawValue
    }
    
    var subnodes: [Node] {
        return nodes
    }
}


struct FunctionDefinition: Node {
    
    var returnType: Token
    
    func interpret() throws -> String {
        var result = "func \(identifier)() -> \(returnType) {\n\t"
        
        result += try block.interpret()
        
        result += "\n}"
        
        return result
    }
    let identifier: String
    let block: Node
}

extension FunctionDefinition: TreeRepresentable {
    var name: String {
        return identifier
    }
    
    var subnodes: [Node] {
        return [block]
    }
}


struct CustomInt: Node {
    
    func interpret() throws -> String {
        return name
    }
    
    var name: String {
        if self.type == .decimal {
            return "\(number)"
        } else {
            if let octal = Int(String(number, radix: 8)) {
                return "0o\(octal)"
            } else {
                fatalError("Not octal")
            }
        }
    }
    
    var subnodes: [Node] {
        return []
    }
    
    var number: Int
    var type: IntegerType
}

