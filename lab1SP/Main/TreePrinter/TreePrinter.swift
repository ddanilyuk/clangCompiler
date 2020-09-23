//
//  TreePrinter.swift
//  TreePrinter
//
//  Created by Денис Данилюк on 23.09.2020.
//


/// Allows for pretty-printing of a structure that is `TreeRepresentable`
public class TreePrinter {
    
    /// A set of options to configure how a tree is printed
    public struct TreePrinterOptions {
        public let spacesPerDepth: Int
        public let spacer: String
        public let verticalLine: String
        public let intermediateConnector: String
        public let finalConnector: String
        public let connectorSuffix: String
        
        public init(spacesPerDepth: Int = 4,
                    spacer: String = " ",
                    verticalLine: String = "│",
                    intermediateConnector: String = "├",
                    finalConnector: String = "└",
                    connectorSuffix: String = "── ")
        {
            self.spacesPerDepth = spacesPerDepth
            self.spacer = spacer
            self.verticalLine = verticalLine
            self.intermediateConnector = intermediateConnector
            self.finalConnector = finalConnector
            self.connectorSuffix = connectorSuffix
        }
        
        /// Alternative defaults that uses characters that are easily
        /// typed on a standard US keyboard.
        public static var alternateDefaults: TreePrinterOptions {
            TreePrinterOptions(spacesPerDepth: 5,
                               spacer: " ",
                               verticalLine: "|",
                               intermediateConnector: "+",
                               finalConnector: "`",
                               connectorSuffix: "-- ")
        }
    }
    

    public static func printTree(root: Node,
                                 options: TreePrinterOptions = TreePrinterOptions()) -> String
    {
        return printNode(node: root,
                         depth: 0,
                         depthsFinished: Set(),
                         options: options)
    }

    private static func printNode(node: Node,
                                  depth: Int,
                                  depthsFinished: Set<Int>,
                                  options: TreePrinterOptions) -> String
    {
        var retVal = ""
        // Prefix the appropriate spaces/pipes.
        for i in 0..<max(depth - 1, 0) * options.spacesPerDepth {
            if i % options.spacesPerDepth == 0 && !depthsFinished.contains(i / options.spacesPerDepth + 1)
            {
                retVal += options.verticalLine
            } else {
                retVal += options.spacer
            }
        }
        
        // Now the correct connector: either an intermediate or a final
        if depth > 0 {
            if depthsFinished.contains(depth) {
                retVal += options.finalConnector
            } else {
                retVal += options.intermediateConnector
            }
            
            // Connector suffix
            retVal += options.connectorSuffix
        }
        // Name
        retVal += node.name
        // Newline to prepare for either sub-tree or next peer
        retVal += "\n"
        
        // Sub-tree
        for (index, subnode) in node.subnodes.enumerated() {
            var newDepthsFinished = depthsFinished
            // There can only be one root node, so if it isn't marked, mark it.
            if depth == 0 {
                newDepthsFinished.insert(depth)
            }
            // If we're the last subnode, mark that depth as finished.
            if index == node.subnodes.count - 1 {
                newDepthsFinished.insert(depth + 1)
            }
            retVal += printNode(node: subnode,
                                depth: depth + 1,
                                depthsFinished: newDepthsFinished,
                                options: options)
        }
        
        return retVal
    }
}
