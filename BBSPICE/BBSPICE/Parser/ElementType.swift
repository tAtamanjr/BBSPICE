//
//  ElementType.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation

enum ElementType {
    case resistor
    case DCCS
    case DCVS
    case CCCS
    case VCCS
    case CCVS
    case VCVS
    
    init(_ rawValue: String, _ lineNumber: Int) throws {
        switch rawValue {
        case "R":
            self = .resistor
        case "DCCS":
            self = .DCCS
        case "DCVS":
            self = .DCVS
        case "CCCS":
            self = .CCCS
        case "VCCS":
            self = .VCCS
        case "CCVS":
            self = .CCVS
        case "VCVS":
            self = .VCVS
        default:
            throw ParserError.unknownElement(lineNumber)
        }
    }
    
    var parametersCount: Int {
        switch self {
        case .resistor, .DCCS, .DCVS:
            return 4
        case .VCCS, .VCVS:
            return 6
        case .CCCS, .CCVS:
            return 7
        }
    }
    
    var nodeIndexes: [Int] {
        switch self {
        case .resistor, .DCCS, .DCVS:
            return [1, 2]
        case .CCCS, .VCCS, .CCVS, .VCVS:
            return [1, 2, 3, 4]
        }
    }
}
