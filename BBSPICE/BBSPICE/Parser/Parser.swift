//
//  Parser.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import Foundation


class Parser {
    func parse(_ url: URL) throws -> ParserResult {
        let text = try String(contentsOf: url, encoding: .utf8)
        return try parseText(text)
    }
    
    func parseText(_ text: String) throws -> ParserResult {
        var lines: [ParserLine] = []
        var stamps: [Stamp] = []
        var command: SolverCommand?
        var showNodes: [Int] = []
        var showLineNumber: Int?
        var nodeCount = 0
        
        for (index, line) in text.components(separatedBy: .newlines).enumerated() {
            let lineNumber = index + 1
            let tokens = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            guard let firstToken = tokens.first else { continue }
            
            if firstToken.hasPrefix("*") { continue }
            if firstToken == ".show" {
                if showLineNumber != nil { throw ParserError.multipleShowCommands(lineNumber) }
                showNodes = try parseShow(tokens, lineNumber)
                showLineNumber = lineNumber
                continue
            }
            if let parsedCommand = try parseCommand(tokens, lineNumber) {
                if command != nil { throw ParserError.multipleCommands(lineNumber) }
                command = parsedCommand
                continue
            }
            
            let elementType = try ElementType(firstToken, lineNumber)
            if tokens.count != elementType.parametersCount { throw ParserError.wrongParametersCount(lineNumber) }
            
            let parserLine = ParserLine(lineNumber, elementType, tokens)
            lines.append(parserLine)
            
            for nodeIndex in elementType.nodeIndexes {
                nodeCount = max(nodeCount, try parseInt(tokens[nodeIndex], lineNumber))
            }
        }
        
        var newRowAmount = 0
        
        for line in lines {
            switch line.elementType {
            case .resistor:
                stamps.append(try makeResistor(line.tokens, line.lineNumber))
            case .capacitor:
                stamps.append(try makeCapacitor(line.tokens, line.lineNumber))
            case .DCCS:
                stamps.append(try makeDCCS(line.tokens, line.lineNumber))
            case .DCVS:
                newRowAmount += 1
                stamps.append(try makeDCVS(line.tokens, line.lineNumber, nodeCount + newRowAmount))
            case .ACVS:
                newRowAmount += 1
                stamps.append(try makeACVS(line.tokens, line.lineNumber, nodeCount + newRowAmount))
            case .CCCS:
                newRowAmount += 1
                stamps.append(try makeCCCS(line.tokens, line.lineNumber, nodeCount + newRowAmount))
            case .VCCS:
                stamps.append(try makeVCCS(line.tokens, line.lineNumber))
            case .CCVS:
                newRowAmount += 1
                let newRow = nodeCount + newRowAmount
                newRowAmount += 1
                stamps.append(try makeCCVS(line.tokens, line.lineNumber, newRow, nodeCount + newRowAmount))
            case .VCVS:
                newRowAmount += 1
                stamps.append(try makeVCVS(line.tokens, line.lineNumber, nodeCount + newRowAmount))
            case .BJT:
                stamps.append(try makeBJT(line.tokens, line.lineNumber))
            }
        }
        
        guard let command else { throw ParserError.missingCommand }
        if showLineNumber != nil {
            if case .tran = command {} else {
                throw ParserError.showWithoutTransient(showLineNumber!)
            }
        }
        
        return ParserResult(stamps, command, showNodes)
    }
    
    private func makeResistor(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        do {
            return try R(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseDouble(tokens[3], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeCapacitor(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        do {
            return try C(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseDouble(tokens[3], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeDCCS(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        do {
            return try DCCS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseDouble(tokens[3], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeDCVS(_ tokens: [String], _ lineNumber: Int, _ newRow: Int) throws -> Stamp {
        do {
            return try DCVS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                newRow,
                parseDouble(tokens[3], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeACVS(_ tokens: [String], _ lineNumber: Int, _ newRow: Int) throws -> Stamp {
        do {
            return try ACVS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                newRow,
                parseDouble(tokens[3], lineNumber),
                parseDouble(tokens[4], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeCCCS(_ tokens: [String], _ lineNumber: Int, _ newRow: Int) throws -> Stamp {
        do {
            return try CCCS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseInt(tokens[3], lineNumber),
                parseInt(tokens[4], lineNumber),
                newRow,
                parseDouble(tokens[5], lineNumber),
                parseDouble(tokens[6], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeVCCS(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        do {
            return try VCCS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseInt(tokens[3], lineNumber),
                parseInt(tokens[4], lineNumber),
                parseDouble(tokens[5], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeCCVS(_ tokens: [String], _ lineNumber: Int, _ newRow: Int, _ newRow2: Int) throws -> Stamp {
        do {
            return try CCVS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseInt(tokens[3], lineNumber),
                parseInt(tokens[4], lineNumber),
                newRow,
                newRow2,
                parseDouble(tokens[5], lineNumber),
                parseDouble(tokens[6], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeVCVS(_ tokens: [String], _ lineNumber: Int, _ newRow: Int) throws -> Stamp {
        do {
            return try VCVS(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseInt(tokens[3], lineNumber),
                parseInt(tokens[4], lineNumber),
                newRow,
                parseDouble(tokens[5], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func makeBJT(_ tokens: [String], _ lineNumber: Int) throws -> Stamp {
        do {
            return try BJT(
                parseInt(tokens[1], lineNumber),
                parseInt(tokens[2], lineNumber),
                parseInt(tokens[3], lineNumber),
                parseDouble(tokens[4], lineNumber),
                parseDouble(tokens[5], lineNumber),
                parseDouble(tokens[6], lineNumber)
            )
        } catch let error as StampParameterError {
            throw parserError(error, lineNumber)
        }
    }
    
    private func parseInt(_ token: String, _ lineNumber: Int) throws -> Int {
        guard let value = Int(token) else { throw ParserError.wrongParameterType(lineNumber) }
        return value
    }
    
    private func parseDouble(_ token: String, _ lineNumber: Int) throws -> Double {
        if let value = Double(token) {
            return value
        }
        
        guard let suffix = token.last,
              let multiplier = multiplier(suffix) else {
            throw ParserError.wrongParameterType(lineNumber)
        }
        
        let numberPart = String(token.dropLast())
        guard !numberPart.isEmpty,
              let value = Double(numberPart) else {
            throw ParserError.wrongParameterType(lineNumber)
        }
        
        return value * multiplier
    }
    
    private func multiplier(_ suffix: Character) -> Double? {
        switch suffix {
        case "G":
            return 1e9
        case "M":
            return 1e6
        case "k":
            return 1e3
        case "m":
            return 1e-3
        case "u":
            return 1e-6
        case "n":
            return 1e-9
        case "p":
            return 1e-12
        default:
            return nil
        }
    }
    
    private func parseCommand(_ tokens: [String], _ lineNumber: Int) throws -> SolverCommand? {
        switch tokens[0] {
        case ".op":
            if tokens.count != 1 { throw ParserError.wrongParametersCount(lineNumber) }
            return .op
        case ".tran":
            if tokens.count != 3 { throw ParserError.wrongParametersCount(lineNumber) }
            let time = try parseDouble(tokens[1], lineNumber)
            let timeStep = try parseDouble(tokens[2], lineNumber)
            if time <= 0 || timeStep <= 0 || timeStep > time || !time.isFinite || !timeStep.isFinite {
                throw ParserError.wrongStampParameters(lineNumber)
            }
            return .tran(time: time, timeStep: timeStep)
        default:
            return nil
        }
    }
    
    private func parseShow(_ tokens: [String], _ lineNumber: Int) throws -> [Int] {
        if tokens.count < 2 { throw ParserError.wrongParametersCount(lineNumber) }
        
        var nodes: [Int] = []
        
        for token in tokens.dropFirst() {
            let node = try parseInt(token, lineNumber)
            if node < 0 { throw ParserError.wrongStampParameters(lineNumber) }
            nodes.append(node)
        }
        
        return nodes
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

struct ParserResult {
    let stamps: [Stamp]
    let command: SolverCommand
    let showNodes: [Int]
    
    init(_ stamps: [Stamp], _ command: SolverCommand, _ showNodes: [Int] = []) {
        self.stamps = stamps
        self.command = command
        self.showNodes = showNodes
    }
}

struct ParserLine {
    let lineNumber: Int
    let elementType: ElementType
    let tokens: [String]
    
    init(_ lineNumber: Int, _ elementType: ElementType, _ tokens: [String]) {
        self.lineNumber = lineNumber
        self.elementType = elementType
        self.tokens = tokens
    }
}
