//
//  Testers.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 11.10.2020.
//

import Foundation


// MARK:- no indent in multiline is normal
struct Testers {
    
    // MARK:- LAB 1 tests

    let lab1test1 = """
int main() {
    return 2;
}
"""
    

    let lab1test2 = """
int main() {
    return 012;
}
"""
    
    let lab1test3 = """
float main() {
    return 3.4;
}
"""
    
    let lab1error1 = """
float main( {
    return 3.4;
}
"""
    
    // MARK:- LAB 2 tests
    
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
    return (-16 / (-2) / 2);
}
"""
    
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
        
    // MARK:- LAB 3 tests

    /*
     Result: 9
     */
    let lab3test1 =
"""
float main() {
    float answ = -9;
    return -answ;
}
"""
    
    /*
     Result: 3
     */
    let lab3test2 = """
float main() {
    float a = 10 / 5;
    int b = a * 3;
    return b / a;
}
"""
    
    /*
     010 = 8
     Result: 0
     */
    let lab3test3 = """
int main() {
    int deadline;
    deadline = 16;
    int time = 010;
    return -(deadline > time);
}
"""
    
    /*
     a = -4
     b = -12
     Result: 48
     */
    let lab3test4 = """
int main() {
    int a;
    int b;
    a = (14 * 2) / -7 * (2 / 02);
    b = a * (12.0 / 4);
    return a * b;
}
"""

    /*
     a = -4
     b = -12
     Result: 48
     */
    let lab3test5 = """
int main() {
    int a = 6 > 8;
    int b = 10 > 010;
    return a * b;
}
"""
    
    /*
     c not defind
     */
    let lab3error1 = """
int main() {
    int a = 2;
    int b = c * a;
    return a * b;
}
"""
    
    /*
     Missing return
     */
    let lab3error2 = """
int main() {
    float a = -12.3;
    int b = a * a;
    int c = b * b;
}
"""
    
    /*
     Invalid value number
     */
    let lab3error3 = """
float main() {
    int a;
    int b;
    a = 2 * (b = 2);
    return a;
}
"""
    
    /*
     Missing semicolon
     */
    let lab3error4 = """
int main() {
    int value = 3
    return value;
}
"""
    
    /*
     с is not defind
     */
    let lab3error5 = """
int main() {
    int a;
    c = a * 3;
    return a * c;
}
"""
    
    /*
     value 2 already defind
     */
    let lab3error6 = """
int main() {
    int value2;
    value2 = 2;
    int value2 = 4;
    return value2;
}
"""
    
    /*
     < is not defind
     */
    let lab3error7 = """
int main() {
    float value1 = 3.14 < 2;
    return value1;
}
"""
    
    
    
    let lab4test1 = """
int main() {
    int mainVar;
    {
        int secondVar = 5;
        {
            int secondVar = 6;
            int thirdVar = 20;
            secondVar = thirdVar;
        }
        {
            int insideBlock = 15;
            secondVar = insideBlock;
        }
        mainVar = secondVar;
    }
    return mainVar;
}
"""
    
    let lab4test2 = """
int main() {
    int falseVar = 0;
    int bar = falseVar ? (falseVar) : (10 * 4 / 8);
    return (1 * bar) ? bar : -10;
}
"""
    
    let lab4test3 = """
int main() {
    int foo = (0) ? 2 : 4;
    {
        foo = (foo > 4) ? 6 : 8;
    }
    return foo;
}
"""
    
    let lab4test4 = """
int main() {
    int mainVar;
    {
        int secondVar;
        {
            int thirdVar;
            {
                thirdVar = (-4 * (1 > 0)) ? 5 : 10;
            }
            secondVar = 40 / thirdVar;
        }
        mainVar = secondVar;
    }
    return (16 / 020) ? mainVar : 0;
}
"""
    
    let lab4error1 = """
int main() {
    int variable;
    {
        int some = 3;
    }
    return some;
}
"""
    
    let lab4error2 = """
int main() {
    int trueVal = 1;
    float a = trueVal ? 10;
    return a;
}
"""
    
    let lab4error3 = """
int main() {
    int some = 10 / 2 ? 10 : 2;
    return some;
}
"""
    
    let lab4error4 = """
int main() {
    int first = (1) ? int second = 4 : int third = 5;
    return first;
}
"""
    
    let lab4error5 = """
int main() {
    int b;
    int c;
    int a = (1) ? b = 4 : c = 5;
    return first;
}
"""
    
}
