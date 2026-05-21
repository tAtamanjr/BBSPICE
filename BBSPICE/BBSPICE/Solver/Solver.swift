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
        case .tran:
            throw SolverError.unsupportedCommand
        }
    }
    
    private func solveOperationPoint(_ stamps: [Stamp]) throws -> Matrix? {
        let context = StampContext(command: .op)
        let size = try matrixSize(stamps, context)
        let gMatrix = GMatrix(size)
        let iMatrix = IMatrix(size)
        
        for stamp in stamps {
            try gMatrix.add(stamp.getGMatrix(context))
            try iMatrix.add(stamp.getIMatrix(context))
        }
        
        return try gMatrix.devide(iMatrix)
    }
    
    private func matrixSize(_ stamps: [Stamp], _ context: StampContext) throws -> Int {
        if stamps.isEmpty { throw SolverError.emptyStamps }
        
        var size = 0
        
        for stamp in stamps {
            if let gMatrix = try stamp.getGMatrix(context) {
                size = max(size, gMatrix.rows)
            }
            if let iMatrix = try stamp.getIMatrix(context) {
                size = max(size, iMatrix.rows)
            }
        }
        
        return size
    }
}
