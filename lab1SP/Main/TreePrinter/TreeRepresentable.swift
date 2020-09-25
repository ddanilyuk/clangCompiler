//
//  TreeRepresentable.swift
//  lab1SP
//
//  Created by Денис Данилюк on 23.09.2020.
//


/// Objects that are `TreeRepresentable` can be printed using `TreePrinter`
public protocol TreeRepresentable {
    
    /// Gets the name of this node
    var name: String { get }
    
    /// Gets the subnodes of this node
    var subnodes: [Node] { get }
}
