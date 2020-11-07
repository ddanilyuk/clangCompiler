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
        case codeBlock = "code block"
        case parameters = "parameters"
    }
    
    let nodes: [Node]
    
    var blockType: BlockType
    
    func interpret() throws -> String {
        var result = String()
        
        switch blockType {
        case .startPoint:
            result += """
            #include <iostream>
            #include <string>
            #include <stdint.h>
            using namespace std;
            int main()
            {
                int b;
                __asm {
                    call _main
                    jmp _mainReturn\n
            """
            
            for node in nodes {
                result += try node.interpret().cppModifiedString(numberOfTabs: 2)
            }
            
            result += """
                    
                    _mainReturn:
                    mov b, eax
                }
                cout << "Result: " << b << endl;
            }
            """
        case .function:
            for node in nodes {
                result += try node.interpret()
            }
        case .codeBlock, .parameters:
            for node in nodes {
                result += try node.interpret()
            }
            return result
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
