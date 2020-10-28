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
                __asm {\n
            """
            
            for node in nodes {
                result += try node.interpret().cppModifiedString(numberOfTabs: 2)
            }
            
            result += """
                }
                cout << "Result: " << b << endl;
            }
            """
        case .function:
            let esp = "\nsub esp, \(Parser.maxIdentifires * 4)\n"
            result += """
            ; Start function header
            push ebp
            mov ebp, esp \(esp)
            ; End function header\n\n
            """
            for node in nodes {
                result += try node.interpret()
            }
            result.deleteSufix("push eax\n")
            result += """
            \n; Start function footer
            _ret:
            mov esp, ebp
            pop ebp
            ; End function footer\n
            """
            
            result += """
            \n; Return value
            mov b, eax
            """
            
        case .codeBlock:
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
