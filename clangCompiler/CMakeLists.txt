add_executable(4-07-Swift-IV-82-Danyliuk
  4-07-Swift-IV-82-Danyliuk.swift)

# add_subdirectory(Sources)
target_sources(4-07-Swift-IV-82-Danyliuk PRIVATE
  Source/Block.swift
  Source/CompilerError.swift
  Source/Extensions.swift
  Source/Lexer.swift
  Source/ProtocolsAndEnums.swift
  Source/Parser.swift
  Source/Token.swift

  Source/Nodes/FunctionDefinitionNode.swift
  Source/Nodes/NumberNode.swift
  Source/Nodes/ReturnNode.swift
  Source/Nodes/TernaryNode.swift
  Source/Nodes/UnaryNegativeNode.swift
  Source/Nodes/CustomIntNode.swift
  Source/Nodes/BinaryOperationNode.swift
  Source/Nodes/VariableNode.swift


  Source/TreePrinter/TreePrinter.swift
  Source/TreePrinter/TreeRepresentable.swift 
)

target_compile_options(4-07-Swift-IV-82-Danyliuk PRIVATE -parse-as-library)
target_link_libraries(4-07-Swift-IV-82-Danyliuk PRIVATE SwiftWin32)
