//
//  ViewController.swift
//  lab1SP
//
//  Created by Денис Данилюк on 22.09.2020.
//

import UIKit


var tokens: [Token] = []

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let multiLineText1 = """
        int main() {
            return 2;
        }
        """
        
        let multiLineText2 = """
        int main() {
            return 012;
        }
        """
        
        let multiLineText3 = """
        float main() {
            return 3.4;
        }
        """
        let multiLineText4 = """
        float main) {
            return 3.4;
        }
        """
        let multiLineText5 = """
        int main() {
            return 3.4;
        }
        """
        
        let multiLineText6 = """
        float main() {
            return 04;
        }
        """
                
        let multiLineText = multiLineText1
        
        let oneLineCode = multiLineText.oneLineCode
        print("File text:\n\(multiLineText)\n")
        
        print("One line code:\n\(oneLineCode)\n")
        
        do {
            let lexer = try Lexer(code: oneLineCode)
                        
            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
            
            let node = try parser.parseBlock(blockType: .startPoint)
            print("\nTree:\n\(TreePrinter.printTree(root: node))")
            
            print("ASM code: ")
            let asmCode = try node.interpret(isCPPCode: false)
            print(asmCode)

            print("C++ code: ")
            let cppCode = try node.interpret(isCPPCode: true)
            print(cppCode)
                        
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: oneLineCode, tokens: tokens)
            }
        }
    }
}
