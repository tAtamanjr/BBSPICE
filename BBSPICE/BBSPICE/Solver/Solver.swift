//
//  Solver.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation


class Solver {
    func solve(_ stamps: [Stamp], _ command: SolverCommand) throws -> Matrix? {
        switch command {
        case .op:
            return try solveOperationPoint(stamps)
        }
    }
    
    private func solveOperationPoint(_ stamps: [Stamp]) throws -> Matrix? {
        let size = try matrixSize(stamps)
        let gMatrix = GMatrix(size)
        let iMatrix = IMatrix(size)
        
        for stamp in stamps {
            try gMatrix.add(stamp.getGMatrix())
            try iMatrix.add(stamp.getIMatrix())
        }
        
        return try gMatrix.devide(iMatrix)
    }
    
    private func matrixSize(_ stamps: [Stamp]) throws -> Int {
        if stamps.isEmpty { throw SolverError.emptyStamps }
        
        var size = 0
        
        for stamp in stamps {
            if let gMatrix = try stamp.getGMatrix() {
                size = max(size, gMatrix.rows)
            }
            if let iMatrix = try stamp.getIMatrix() {
                size = max(size, iMatrix.rows)
            }
        }
        
        return size
    }
}
