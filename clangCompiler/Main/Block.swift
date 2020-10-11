//
//  Block.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 25.09.2020.
//

import Foundation


// Block can have multiple nodes.
struct Block: Node {
    
    enum BlockType: String {
        case function = "function block"
        case startPoint = "start point"
    }
    
    let nodes: [Node]
    
    var blockType: BlockType
    
    func interpret(isCPPCode: Bool) throws -> String {
        var result = String()
        
        switch blockType {
        case .startPoint:
            if isCPPCode {
                result += """
                #include <iostream>
                #include <string>
                #include <stdint.h>
                using namespace std;
                int main()
                {
                    int b;
                    __asm {\n
                """
            }
            
            for line in nodes {
                if isCPPCode {
                    result += try line.interpret(isCPPCode: isCPPCode).cppModifiedString(numberOfTabs: 2)
                } else {
                    result += try line.interpret(isCPPCode: isCPPCode)
                }
            }
            
            if isCPPCode {
                result += """
                    }
                    cout << b << endl;
                }
                """
            }
            
        case .function:
            result += """
            push ebp
            mov ebp, esp
            ; function header\n
            """
            for line in nodes {
                result += try line.interpret(isCPPCode: isCPPCode)
            }
            
        }
        
        return result
    }
}


extension Block: TreeRepresentable {
    var name: String {
        return blockType.rawValue
    }
    
    var subnodes: [Node] {
        return nodes
    }
}
