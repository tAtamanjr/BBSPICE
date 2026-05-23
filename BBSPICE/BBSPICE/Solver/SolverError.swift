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
    case numericalDivergence
    case notConverged
    case wrongTransientParameters
    
    var description: String {
        switch self {
        case .emptyStamps:
            return "Solver: Empty stamps"
        case .unsupportedCommand:
            return "Solver: Unsupported command"
        case .numericalDivergence:
            return "Solver: Numerical divergence"
        case .notConverged:
            return "Solver: Newton-Raphson did not converge"
        case .wrongTransientParameters:
            return "Solver: Wrong transient parameters"
        }
    }
}
