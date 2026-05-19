//
//  SolverError.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation


enum SolverError : Error, Equatable, CustomStringConvertible {
    case emptyStamps
    case unsupportedCommand
    
    var description: String {
        switch self {
        case .emptyStamps:
            return "Solver: Empty stamps"
        case .unsupportedCommand:
            return "Solver: Unsupported command"
        }
    }
}
