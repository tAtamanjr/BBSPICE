//
//  Parser.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import Foundation


class Parser {
    func parse(_ url: URL) throws -> [Stamp] {
        let text = try String(contentsOf: url)
        var stamps: [Stamp] = []
        
        for (index, line) in text.components(separatedBy: .newlines).enumerated() {
            let lineNumber = index + 1
            let tokens = line.split(separator: " ").map(String.init)
            guard let firstToken = tokens.first else { continue }
            
            if firstToken.hasPrefix("*") || firstToken == ".op" { continue }
            
            let elementType = try ElementType(firstToken, lineNumber)
            
            switch elementType {
            case .resistor:
                if tokens.count != 4 { throw ParserError.wrongParametersCount(lineNumber) }
                stamps.append(try makeResistor(tokens, lineNumber))
            case .DCCS:
                if tokens.count != 4 { throw ParserError.wrongParametersCount(lineNumber) }
                stamps.append(try makeDCCS(tokens, lineNumber))
            }
        }
        
        return stamps
    }
    
    private func makeResistor(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        guard let nodeS = Int(tokens[1]), let nodeE = Int(tokens[2]), let resistance = Double(tokens[3]) else {
            throw ParserError.wrongParameterType(lineNumber)
        }
        
        do {
            return try R(nodeS, nodeE, resistance)
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeDCCS(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        guard let nodeS = Int(tokens[1]), let nodeE = Int(tokens[2]), let current = Double(tokens[3]) else {
            throw ParserError.wrongParameterType(lineNumber)
        }
        
        do {
            return try DCCS(nodeS, nodeE, current)
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func parserError(_ error: StampParameterError, _ lineNumber: Int) -> ParserError {
        switch error {
        case .negativeNodeIndex, .parameterError:
            return .wrongStampParameters(lineNumber)
        case .programFail:
            return .programFail(lineNumber)
        }
    }
}

enum ElementType {
    case resistor
    case DCCS
    
    init(_ rawValue: String, _ lineNumber: Int) throws {
        switch rawValue {
        case "R":
            self = .resistor
        case "DCCS":
            self = .DCCS
        default:
            throw ParserError.unknownElement(lineNumber)
        }
    }
}

enum ParserError : Error, Equatable, CustomStringConvertible {
    case unknownElement(_ line: Int)
    case wrongParametersCount(_ line: Int)
    case wrongParameterType(_ line: Int)
    case wrongStampParameters(_ line: Int)
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
        case let .programFail(line):
            return "Parser: Program failed at line \(line)"
        }
    }
}
