//
//  5-07-Swift-IV-82-Danyliuk.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 29.10.2020.
//

#if DEBUG
import Foundation

let testers = Testers()

//let testCode = """
//int linearVelocity(float period, int radius);
//float getPi();
//
//int main() {
//    int b = 900;
//    b /= getPi();
//    int result = linearVelocity(2.5, 2);
//    return result;
//}
//
//int linearVelocity(float T, int r) {
//    int n = 2 * getPi() * r / T;
//    return n;
//}
//
//float getPi() {
//    return 3.14;
//}
//"""

let testCode = """
int main() {
    int value = 100;

    do {
        value = value / 2;
    } while (value > 10);

    return value;
}
"""

compile(code: testCode)
//compile(code: testers.lab5test1)
#endif


#if !DEBUG
import SwiftWin32
import let WinSDK.CW_USEDEFAULT

@main
final class AppDelegate: ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool {
        
        do {
            let code = try String(contentsOfFile: "5-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
            compile(code: code)
        } catch let error {
            print(error.localizedDescription)
        }
        
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

        try cppCode.write(toFile: "5-07-Swift-IV-82-Danyliuk.cpp", atomically: false, encoding: String.Encoding.utf8)
    } catch let error {
        if let error = error as? CompilerError {
            error.fullErrorDescription(code: code, tokens: tokens)
        } else {
            print(error.localizedDescription)
        }
    }
}
