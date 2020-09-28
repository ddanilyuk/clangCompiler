//
//  Operator.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


enum Operator: String {
    case times = "*"
    case divideBy = "/"
    case plus = "+"
    case minus = "-"
    var precedence: Int {
        switch self {
        case .minus, .plus:
            return 10
        case .times, .divideBy:
            return 20
        }
    }
}
