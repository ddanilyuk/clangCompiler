//
//  ViewController.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import UIKit


var identifiers: [String: Definition] = [ // CHANGED
    "PI": .variable(value: Float.pi),
]


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fileText =
        """
        int main() {
            return 2;
        }
        """
        
        fileText = "int main() { return 0; }"
        print("File text:\n\n\(fileText)\n")
        
        let lexer = Lexer(code: fileText)
        print("Tokens: \(lexer.tokens.map({ "\($0)" }))")
        let parser = Parser(tokens: lexer.tokens)
        
        do {
            let node = try parser.parse(name: "start point")
            print("Tree:")
            print(TreePrinter.printTree(root: node))
        } catch let error {
            if let error = error as? Parser.Error {
                print(error)
            }
        }

        print("parse ended")
    }


}

