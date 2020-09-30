//
//  Extensions.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public extension String {
    
    var oneLineCode: String {
        let miltiline = self
        let replacing1 = miltiline.replacingOccurrences(of: "\n    ", with: " ", options: .literal, range: nil)
        let replacing2 = replacing1.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
        return replacing2.replacingOccurrences(of: "\t", with: " ", options: .literal, range: nil)
    }
    
    func getStringPrefix(with regularExpressions: String) -> String? {
        let expression = try! NSRegularExpression(pattern: "^\(regularExpressions)", options: [])
        let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        if range.location == 0 {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
    
    func cppModifiedString(numberOfTabs: Int) -> String {
        var selfString = self
        
        let subStrings = selfString.split(separator: "\n")
        
        var result = String()
        
        for subString in subStrings {
            let arrayOfTabs = Array(repeating: "\t", count: numberOfTabs)
            let stringOfTabs = arrayOfTabs.reduce("", { "\($0)\($1)"})
            result += "\(stringOfTabs)\(subString)\n"
        }
        return result
    }
    
    mutating func deleteLeftWhitespaces() {
        let index = startIndex
        while index < endIndex {
            guard CharacterSet.whitespacesAndNewlines.contains(self[index].unicodeScalars.first!) else {
                return
            }
            self.remove(at: index)
        }
    }
}


extension StringProtocol {
    subscript(offset: Int) -> Character {
        return self[index(startIndex, offsetBy: offset)]
    }
}


extension Float: Node {
    public func getValue() -> Float {
        return self
    }
    
    public func interpret(isCPPCode: Bool) throws -> String {
        return "\(Int(self))"
    }
    
    public var name: String {
        return "\(self)"
    }
    
    public var subnodes: [Node] {
        return []
    }
}


extension Int: Node {

    public func getValue() -> Float {
        return Float(self)
    }
    
    public func interpret(isCPPCode: Bool) throws -> String {
        return "\(self)"
    }
    
    public var name: String {
        return "\(self)"
    }
    
    public var subnodes: [Node] {
        return []
    }
}
