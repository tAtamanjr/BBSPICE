//
//  ParserError.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation

enum ParserError : Error, Equatable, CustomStringConvertible {
    case unknownElement(_ line: Int)
    case wrongParametersCount(_ line: Int)
    case wrongParameterType(_ line: Int)
    case wrongStampParameters(_ line: Int)
    case missingCommand
    case multipleCommands(_ line: Int)
    case programFail(_ line: Int)
    
    var description: String {
        switch self {
        case let .unknownElement(line):
            return "Parser: Unknown element at line \(line)"
        case let .wrongParametersCount(line):
            return "Parser: Wrong parameters count at line \(line)"
        case let .wrongParameterType(line):
            return "Parser: Wrong parameter type at line \(line)"
        case let .wrongStampParameters(line):
            return "Parser: Wrong stamp parameters at line \(line)"
        case .missingCommand:
            return "Parser: Missing command"
        case let .multipleCommands(line):
            return "Parser: Multiple commands at line \(line)"
        case let .programFail(line):
            return "Parser: Program failed at line \(line)"
        }
    }
}
