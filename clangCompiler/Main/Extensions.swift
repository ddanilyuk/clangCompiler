//
//  Extensions.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public extension String {
    
    func getStringPrefix(with regularExpressions: String) -> String? {
        let expression = try! NSRegularExpression(pattern: "^\(regularExpressions)", options: [])
        let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        if range.location == 0 {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
    
    func cppModifiedString(numberOfTabs: Int) -> String {
        let subStrings = self.split(separator: "\n")
        
        var result = String()
        
        for subString in subStrings {
            let arrayOfTabs = Array(repeating: "    ", count: numberOfTabs)
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
    
    mutating func deleteSufix(_ sufix: String) {
        guard self.hasSuffix(sufix) else { return }
        self = String(self.dropLast(sufix.count))
    }
}


extension StringProtocol {
    subscript(offset: Int) -> Character {
        return self[index(startIndex, offsetBy: offset)]
    }
}


extension Float: Node {
    
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
