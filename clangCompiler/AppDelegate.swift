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
            return (4 - (-5));
        }
        """
        
        // Errors
        let test1 = """
        int main() {
            return -(3 - 2 / 8)ж
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
        int main() {
            return )-3 - 2 / 8;
        }
        """
        
        let test6 = """
        int main() {
            )-3 - 2 / 8;
        }
        """
        // end errors
        
        let test7 = """
        float main() {
            return (-2);
        }
        """
        let test8 = """
        int main() {
            return (3 / -3) / (-1.8);
        }
        """
        
        
        let test9 = """
        int main() {
            return -(32 / 2.2) / -(-4 / 2) / 2;
        }
        """
        
        let test10 = """
        int main() {
            return (10 / -(-16 / 4)) / (-3 / 1);
        }
        """
        
        let multiLineText22 = """
        int main() {
            return (-16 - (-2) - 4);
        }
        """
        
    
        var code = ""

        do {
            #if !DEBUG
                code = try String(contentsOfFile: "2-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.utf8)
            #endif
            
            code = test10
            
            print("File text:\n\(code)\n")

            let lexer = try Lexer(code: code, tokens: &tokens)
            
            print(lexer.tokensTable)
            
            Parser.globalTokensArray = tokens
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


//// Left node code generation
//if leftNode is Int || leftNode is Float {
//    if right.hasSuffix("push eax\n") {
//        codeBufer += "mov eax, \(left)\n"
//    } else {
//        code += "mov eax, \(left)\n"
//    }
//} else if left.hasSuffix("push eax\n") {
//    code += left
//    //            code += "mov eax, ss : [esp]\nadd esp, 4\n"
//    popLeft += "pop eax\n"
//} else if var prefixL = leftNode as? PrefixOperation {
//    prefixL.sideLeft = true
//    if right.hasSuffix("push eax\n") {
//        codeBufer += try prefixL.generatingAsmCode()
//    } else {
//        code += try prefixL.generatingAsmCode()
//    }
//
//} else {
//    code += left
//}
