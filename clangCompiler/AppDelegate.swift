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

        let testCode = """
        int main() {
            int a;
            return a;
        }
        """
        
        let testers = Testers()
        
        var code = ""

        do {
            #if !DEBUG
            code = try String(contentsOfFile: "3-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
            #endif
            
            code = testers.lab3test1
//            code = testCode
            
            print("File text:\n\(code)\n")

            let lexer = try Lexer(code: code, tokens: &tokens)
            
            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
                        
            let node = try parser.parseBlock(blockType: .startPoint)
            print("Tree:\n\(TreePrinter.printTree(root: node))")

//            print("ASM code: ")
//            let asmCode = try node.interpret(isCPPCode: false)
//            print(asmCode)

            #if !DEBUG
                try asmCode.write(toFile: "Sources/3-07-Swift-IV-82-Danyliuk.asm", atomically: false, encoding: String.Encoding.utf8)
            #endif
            
            print("\nC++ code: ")
            let cppCode = try node.interpret(isCPPCode: true)
            print(cppCode)

            #if !DEBUG
                // "\" may cause error
                try cppCode.write(toFile: "3-07-Swift-IV-82-Danyliuk.cpp", atomically: false, encoding: String.Encoding.utf8)
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
