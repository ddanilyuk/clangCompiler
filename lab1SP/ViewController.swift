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

        let fileText = "int main() { return 012; }"
        print("File text:\n\(fileText)\n")
        
        let lexer = Lexer(code: fileText, isPrintLexicalTable: true)
    
        let parser = Parser(tokens: lexer.tokens)
        do {
            let node = try parser.parse(blockType: .startPoint)
            print("\nTree:\n\(TreePrinter.printTree(root: node))")
            
            print("Swift code: ")
            print(try node.interpret())
        } catch let error {
            if let error = error as? Parser.Error {
                let indexOfError = error.index
                let lineAndPosition = Lexer.getCurrentLineAndPosition(from: indexOfError, code: fileText, tokens: lexer.tokens)
                
                print("\nERROR!!!")
                print(error.localizedDescription)
                print("line: \(lineAndPosition.line), position: \(lineAndPosition.position)\n")
                print(fileText)
                print(lineAndPosition.show)
                
            }
        }

        print("\nParse ended")
    }
}
