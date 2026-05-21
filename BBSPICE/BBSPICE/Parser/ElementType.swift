//
//  ElementType.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation

enum ElementType {
    case resistor
    case capacitor
    case DCCS
    case DCVS
    case ACVS
    case CCCS
    case VCCS
    case CCVS
    case VCVS
    
    init(_ rawValue: String, _ lineNumber: Int) throws {
        switch rawValue {
        case "R":
            self = .resistor
        case "C":
            self = .capacitor
        case "DCCS":
            self = .DCCS
        case "DCVS":
            self = .DCVS
        case "ACVS":
            self = .ACVS
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
        case .resistor, .capacitor, .DCCS, .DCVS:
            return 4
        case .ACVS:
            return 5
        case .VCCS, .VCVS:
            return 6
        case .CCCS, .CCVS:
            return 7
        }
    }
    
    var nodeIndexes: [Int] {
        switch self {
        case .resistor, .capacitor, .DCCS, .DCVS, .ACVS:
            return [1, 2]
        case .CCCS, .VCCS, .CCVS, .VCVS:
            return [1, 2, 3, 4]
        }
    }
}
