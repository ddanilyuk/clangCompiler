//
//  ViewController.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import UIKit

// Name of variables and function with its values
var identifiers: [String: Definition] = [
    "PI": .variable(value: Float.pi),
]


var tokens: [Token] = []


class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileText = "int main() { return 0x12; }"
        print("File text:\n\(fileText)\n")
        

        do {
            let lexer = try Lexer(code: fileText)
                        
            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
            
            let node = try parser.parseBlock(blockType: .startPoint)
            print("\nTree:\n\(TreePrinter.printTree(root: node))")
            
            print("ASM code: ")
            let interpretedCode = try node.interpret()
            print(interpretedCode)
                        
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: fileText, tokens: tokens)
            }
        }

        print("\nParse ended")
    }
}
