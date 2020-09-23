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

        let fileText = "int main() { return ((2 + 1) + 15); }"
        print("File text:\n\n\(fileText)\n")
        
        let lexer = Lexer(code: fileText)
        print("Tokens: \(lexer.tokens.map({ "\($0)" }))")
        let parser = Parser(tokens: lexer.tokens)
        
        do {
            let node = try parser.parse(blockType: .startPoint)
            print("Tree:")
            print(TreePrinter.printTree(root: node))
            print("Swift code: ")
            print(try node.interpret())
        } catch let error {
            if let error = error as? Parser.Error {
                print(error)
            }
        }

        print("parse ended")
    }
}
