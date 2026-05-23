//
//  Solver.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation


class Solver {
    private let maxNewtonRaphsonIterations = 50
    private let allCloseTolerance = 1e-9
    private let divergenceLimit = 1e4
    
    func solve(_ stamps: [Stamp], _ command: SolverCommand) throws -> Matrix? {
        switch command {
        case .op:
            return try solveOperationPoint(stamps)
        case let .tran(time, timeStep):
            return try solveTransient(stamps, time, timeStep).solutions.last
        }
    }
    
    func solveTransient(_ stamps: [Stamp], _ command: SolverCommand) throws -> TransientResult {
        switch command {
        case .op:
            throw SolverError.unsupportedCommand
        case let .tran(time, timeStep):
            return try solveTransient(stamps, time, timeStep)
        }
    }
    
    func solveTransient(_ stamps: [Stamp], _ time: Double, _ timeStep: Double) throws -> TransientResult {
        if time <= 0 || timeStep <= 0 || timeStep > time || !time.isFinite || !timeStep.isFinite {
            throw SolverError.wrongTransientParameters
        }
        
        let initialContext = StampContext(timeStep: timeStep, command: .tran(time: time, timeStep: timeStep))
        let size = try matrixSize(stamps, initialContext)
        let steps = Int((time / timeStep).rounded(.down))
        
        guard var previousSolution = try solveOperationPoint(stamps) else { throw SolverError.numericalDivergence }
        
        var timeValues = [0.0]
        var solutions = [previousSolution]
        
        for step in 1...steps {
            let currentTime = Double(step) * timeStep
            let solution = try solveTransientStep(stamps, size, currentTime, time, timeStep, previousSolution)
            
            timeValues.append(currentTime)
            solutions.append(solution)
            previousSolution = solution
        }
        
        return TransientResult(time: timeValues, solutions: solutions)
    }
    
    private func solveOperationPoint(_ stamps: [Stamp]) throws -> Matrix? {
        let initialContext = StampContext(command: .op)
        let size = try matrixSize(stamps, initialContext)
        var previousSolution: Matrix = VMatrix(Array(repeating: 0.0, count: size))
        
        for _ in 0..<maxNewtonRaphsonIterations {
            let context = StampContext(solution: previousSolution, command: .op)
            let solution = try solveLinearSystem(stamps, size, context)
            
            if hasDiverged(solution) { throw SolverError.numericalDivergence }
            if allClose(solution, previousSolution) { return solution }
            
            previousSolution = solution
        }
        
        throw SolverError.notConverged
    }
    
    private func solveLinearSystem(_ stamps: [Stamp], _ size: Int, _ context: StampContext) throws -> Matrix {
        let gMatrix = GMatrix(size)
        let iMatrix = IMatrix(size)
        
        for stamp in stamps {
            try gMatrix.add(stamp.getGMatrix(context))
            try iMatrix.add(stamp.getIMatrix(context))
        }
        guard let solution = try gMatrix.devide(iMatrix) else { throw SolverError.numericalDivergence }
        return solution
    }
    
    private func solveTransientStep(
        _ stamps: [Stamp],
        _ size: Int,
        _ currentTime: Double,
        _ time: Double,
        _ timeStep: Double,
        _ previousSolution: Matrix
    ) throws -> Matrix {
        var currentSolution = previousSolution
        
        for _ in 0..<maxNewtonRaphsonIterations {
            let context = StampContext(
                time: currentTime,
                timeStep: timeStep,
                solution: currentSolution,
                previousSolution: previousSolution,
                command: .tran(time: time, timeStep: timeStep)
            )
            let solution = try solveLinearSystem(stamps, size, context)
            
            if hasDiverged(solution) { throw SolverError.numericalDivergence }
            if allClose(solution, currentSolution) { return solution }
            
            currentSolution = solution
        }
        
        throw SolverError.notConverged
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
    
    private func allClose(_ matrix1: Matrix, _ matrix2: Matrix) -> Bool {
        guard matrix1.values.count == matrix2.values.count else { return false }
        
        for index in 0..<matrix1.values.count {
            if abs(matrix1.values[index] - matrix2.values[index]) > allCloseTolerance {
                return false
            }
        }
        
        return true
    }
    
    private func hasDiverged(_ matrix: Matrix) -> Bool {
        for value in matrix.values {
            if !value.isFinite || abs(value) > divergenceLimit { return true }
        }
        
        return false
    }
}

struct TransientResult {
    let time: [Double]
    let solutions: [Matrix]
}
