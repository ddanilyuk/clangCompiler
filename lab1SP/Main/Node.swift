//
//  Nodes.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//

import Foundation


public protocol Node: TreeRepresentable {
    func interpret(isCPPCode: Bool) throws -> String
}
