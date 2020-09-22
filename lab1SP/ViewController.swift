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
        print(lexer.tokens)
//        let parser = Parser(text: fileText)
//        print(parser.parseText())
//        print(TreePrinter.printTree(root: TreeNode.sampleTree))

    }


}

