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
        
        
        
        // Errors
        let test1 = """
        int main() {
            return -(3 - 2 / 8)g
        }
        """
        
        let test2 = """
        int main() {
            return -(3 + 2 / 8);
        }
        """
        
        let test3 = """
        int main() {
            return 3 s 2 / 8;
        }
        """
        
        let test4 = """
        int main() {
            return --3 - 2 / 8;
        }
        """
        
        let test5 = """
        in main() {
            return (-3 - 2 / 8);
        }
        """
        
        let test6 = """
        int main()
            return -16 / 7 / 8;
        }
        """
        // end errors
        
        // -2
        let test7 = """
        float main() {
            return -2.4;
        }
        """
        
        // -3 / -1 = 3
        let test8 = """
        int main() {
            return (-9 / -03) / (-1.8);
        }
        """
        
        // -16 / - (-2) / 2 = - 16 / 2 / 2 = -4
        let test9 = """
        int main() {
            return -(32 / 2.2) / -(-4 / 2) / 2;
        }
        """
        
        let test10 = """
        int main() {
            return 16.3 / 2 / 02 / 2;
        }
        """
        
        let test11 = """
        int main() {
            return (-16 - (-2) - 4);
        }
        """
        
        
        let testX = """
        int main() {
            int a = 1;
            return 10 > 3 * 2;
        }
        """
    
        let _ = [test1, test2, test3, test4, test5, test6, test7, test8, test9, test10, test11]
        
        var code = ""

        do {
            #if !DEBUG
            code = try String(contentsOfFile: "2-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
            #endif
            
            code = testX
            
            print("File text:\n\(code)\n")

            let lexer = try Lexer(code: code, tokens: &tokens)
            
            print(lexer.tokensTable)
            
            let parser = Parser(tokens: tokens)
                        
            let node = try parser.parseBlock(blockType: .startPoint)
            print("Tree:\n\(TreePrinter.printTree(root: node))")
            
            print("ASM code: ")
            let asmCode = try node.interpret(isCPPCode: false)
            print(asmCode)

            #if !DEBUG
                try asmCode.write(toFile: "2-07-Swift-IV-82-Danyliuk.asm", atomically: false, encoding: String.Encoding.utf8)
            #endif
            
            print("\nC++ code: ")
            let cppCode = try node.interpret(isCPPCode: true)
            print(cppCode)

            #if !DEBUG
                // "\" may cause error
                try cppCode.write(toFile: "Source/2-07-Swift-IV-82-Danyliuk.cpp", atomically: false, encoding: String.Encoding.utf8)
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
