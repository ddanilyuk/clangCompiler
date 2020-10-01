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
        
        let test7 = """
        int main() {
            return -(16 / 8) / (-2);
        }
        """
        let test8 = """
        int main() {
            return (3 / -3) / (-1.8);
        }
        """
        
        
        let test9 = """
        int main() {
            return -(3 / 3) / -(2.8 / 2) / 2;
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
        
    
        let multiLineText = test9
        
        print("File text:\n\(multiLineText)\n")
                
        do {
            let lexer = try Lexer(code: multiLineText, tokens: &tokens)
            
//            print(lexer.tokensTable)
            
            Parser.globalTokensArray = tokens
            let parser = Parser(tokens: tokens)
            
            
            let node = try parser.parseBlock(blockType: .startPoint)
            print("Tree:\n\(TreePrinter.printTree(root: node))")
            
            print("ASM code: ")
            let asmCode = try node.interpret(isCPPCode: false)
            print(asmCode)

            InfixOperation.isRightCounter = 0
            InfixOperation.isLeftCounter = 0


            print("\nC++ code: ")
            let cppCode = try node.interpret(isCPPCode: true)
            print(cppCode)
            
        } catch let error {
            if let error = error as? CompilerError {
                error.fullErrorDescription(code: multiLineText, tokens: tokens)
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
