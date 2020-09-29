//
//  Nodes.swift
//  clangCompiler
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public protocol Node: TreeRepresentable {
    func interpret(isCPPCode: Bool) throws -> String
}


public protocol ValueNode: Node {
    func getValue() -> Float
}
