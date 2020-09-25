//
//  Extensions.swift
//  lab1SP
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
    
    mutating func deleteLeftWhitespaces() {
        let i = startIndex
        while i < endIndex {
            guard CharacterSet.whitespacesAndNewlines.contains(self[i].unicodeScalars.first!) else {
                return
            }
            self.remove(at: i)
        }
    }
}


extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
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
