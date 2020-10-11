//
//  Testers.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 11.10.2020.
//

import Foundation


struct Testers {
    
    // MARK:- LAB 2 tests
    
    // Errors
    let lab2error1 = """
        int main() {
            return -(3 - 2 / 8)g
        }
        """
    
    let lab2error2 = """
        int main() {
            return -(3 + 2 / 8);
        }
        """
    
    let lab2error3 = """
        int main() {
            return 3 s 2 / 8;
        }
        """
    
    let lab2error4 = """
        int main() {
            return --3 - 2 / 8;
        }
        """
    
    let lab2error5 = """
        in main() {
            return (-3 - 2 / 8);
        }
        """
    
    let lab2error6 = """
        int main()
            return -16 / 7 / 8;
        }
        """
    // end errors
    
    // -2
    let lab2test1 = """
        float main() {
            return -2.4;
        }
        """
    
    // -3 / -1 = 3
    let lab2test2 = """
        int main() {
            return (-9 / -03) / (-1.8);
        }
        """
    
    // -16 / - (-2) / 2 = - 16 / 2 / 2 = -4
    let lab2test3 = """
        int main() {
            return -(32 / 2.2) / -(-4 / 2) / 2;
        }
        """
    
    let lab2test4 = """
        int main() {
            return 16.3 / 2 / 02 / 2;
        }
        """
    
    let lab2test5 = """
        int main() {
            return (-16 - (-2) - 4);
        }
        """

    
    // MARK:- LAB 3 tests

    let lab3test1 = """
        int main() {
            float asw = -9;
            return -asw;
        }
        """
    
    let lab3test2 = """
        int main() {
            int a = 10 / 5;
            int b = a * 3;
            return -b;
        }
        """
    
    let lab3test3 = """
        int main() {
            int a = 10 / 5;
            int b = a * 3;
            return -b;
        }
        """
    
    let lab3test4 = """
        int main() {
            int a;
            a = 1 / 1;
            a = 3 / a / (4 / 2);
            int b = 2;
            a = b / 2;
            return a / b;
        }
        """
    
    
    let lab3error1 = """
        
        """
    
}
