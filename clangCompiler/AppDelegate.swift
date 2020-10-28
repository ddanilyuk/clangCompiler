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

//        let testCode = """
//        int main() {
//            int some = 4;
//            {
//                int tr = 5;
//                {
//                    int tr = 6;
//                    int inSecondBlock;
//                    inSecondBlock = 2;
//                    tr = inSecondBlock;
//                }
//                {
//                    int tr = 7;
//                    int inThirdBlock = 10;
//                    tr = inThirdBlock;
//                    some = tr;
//                }
//            }
//            return some;
//        }
//        """
        let testCode = """
        int main() {
            int some = (0) ? 2 : 4;
            {
                int true = 1;
                some = true ? 6 : 8;
            }
            return some;
        }
        """
        
        let testers = Testers()
        
        var code = ""

        do {
            #if !DEBUG
            code = try String(contentsOfFile: "4-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
            #endif
            
            code = testers.lab4error5
//            code = testCode
            
            print("File text:\n\(code)\n")

            let lexer = try Lexer(code: code, tokens: &tokens)
            
            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
                        
            let node = try parser.parseBlock(blockType: .startPoint)
            print("Tree:\n\(TreePrinter.printTree(root: node))")

            print("\nC++ code: ")
            let cppCode = try node.interpret()
            print(cppCode)

            #if !DEBUG
                try cppCode.write(toFile: "4-07-Swift-IV-82-Danyliuk.cpp", atomically: false, encoding: String.Encoding.utf8)
            #endif
            
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: code, tokens: tokens)
            } else {
                print(error.localizedDescription)
            }
        }
        
        return true
    }
}
