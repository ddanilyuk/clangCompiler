//
//  4-07-Swift-IV-82-Danyliuk.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.10.2020.
//

#if DEBUG
import Foundation

let testers = Testers()

let testCode = """
int main() {
    int some = (0) ? 2 : 4;
    {
        int true = 1;
        some = true ? 6 : 8;
        {
            some = 6;
        }
    }
}
"""

// compile(code: testCode)
compile(code: testers.lab1test1)
#endif


#if !DEBUG
import SwiftWin32
import let WinSDK.CW_USEDEFAULT

@main
final class AppDelegate: ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool {
        
        let code = try String(contentsOfFile: "4-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
        compile(code: code)
        return true
    }
}
#endif


func compile(code: String) {
    var tokens: [Token] = []
        
    do {
        print("File text:\n\(code)\n")
        
        let lexer = try Lexer(code: code, tokens: &tokens)
        
        print(lexer.tokensTable)
        
        let parser = Parser(tokens: tokens)
        
        let node = try parser.parseBlock(blockType: .startPoint)
        print("Tree:\n\(TreePrinter.printTree(root: node))")
        
        print("\nC++ code: ")
        let cppCode = try node.interpret()
        print(cppCode)
        
        try cppCode.write(toFile: "4-07-Swift-IV-82-Danyliuk.cpp", atomically: false, encoding: String.Encoding.utf8)
        
    } catch let error {
        if let error = error as? CompilerError {
            error.fullErrorDescription(code: code, tokens: tokens)
        } else {
            print(error.localizedDescription)
        }
    }
}