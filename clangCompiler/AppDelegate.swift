//
//  AppDelegate.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 22.09.2020.
//

import UIKit

/**
What to do before compiling to exe.
 
import SwiftWin32
import let WinSDK.CW_USEDEFAULT
 */

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var tokens: [Token] = []
        
        let multiLineText1 = """
        int main() {
            return -(3 + 2 * 8);
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
            let lexer = try Lexer(code: oneLineCode, tokens: &tokens)
            
//            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
            
            let node = try parser.parseBlock(blockType: .startPoint)
            print("\nTree:\n\(TreePrinter.printTree(root: node))")
            
//            print("ASM code: ")
//            let asmCode = try node.interpret(isCPPCode: false)
//            print(asmCode)
//
//            print("C++ code: ")
//            let cppCode = try node.interpret(isCPPCode: true)
//            print(cppCode)
            
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: oneLineCode, tokens: tokens)
            } else {
                print(error.localizedDescription)
            }
        }
        
        return true
    }

}
