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




class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // octal = 0o12 = 10
        // decimal = 12 = 12
        let fileText = "int main() { return 12; }"
        print("File text:\n\(fileText)\n")
        
        let lexer = Lexer(code: fileText)
        
        print(lexer.tokensTable)
    
        let parser = Parser(tokens: lexer.tokens)
        do {
            let node = try parser.parse(blockType: .startPoint)
            print("\nTree:\n\(TreePrinter.printTree(root: node))")
            
            print("ASM code: ")
            let interpretedCode = try node.interpret()
            print(interpretedCode)
            
//            print(Lexer.getASMCodeVisualStudio(returnType: "int?", mainBlockOfCode: interpretedCode))
            
            
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: fileText, tokens: lexer.tokens)
            }
        }

        print("\nParse ended")
    }
}
