//
//  Context.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import Foundation

struct StampContext {
    let time: Double
    let timeStep: Double
    let voltage: Double
    let voltageBE: Double?
    let voltageBC: Double?
    let solution: Matrix?
    let previousSolution: Matrix?
    let command: SolverCommand?
    
    init(
        time: Double = 0.0,
        timeStep: Double = 0.0,
        voltage: Double = 0.0,
        voltageBE: Double? = nil,
        voltageBC: Double? = nil,
        solution: Matrix? = nil,
        previousSolution: Matrix? = nil,
        command: SolverCommand? = nil
    ) {
        self.time = time
        self.timeStep = timeStep
        self.voltage = voltage
        self.voltageBE = voltageBE
        self.voltageBC = voltageBC
        self.solution = solution
        self.previousSolution = previousSolution
        self.command = command
    }
    
    func nodeVoltage(_ node: Int) -> Double {
        guard node > 0, let solution, node <= solution.rows else { return 0.0 }
        return solution.values[node - 1]
    }
    
    func previousVoltage(_ node: Int) -> Double {
        guard node > 0, let previousSolution, node <= previousSolution.rows else { return 0.0 }
        return previousSolution.values[node - 1]
    }
}
