//
//  Capacitor.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import Foundation

class C : TwoNodeStamp {
    let capacitance: Double
    
    init(_ nodeS: Int, _ nodeE: Int, _ capacitance: Double) throws {
        if capacitance <= 0 || !capacitance.isFinite { throw StampParameterError.parameterError }
        self.capacitance = capacitance
        try super.init(nodeS, nodeE)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix? {
        if case .op = context.command { return nil }
        if context.timeStep <= 0 || !context.timeStep.isFinite { throw StampParameterError.parameterError }
        let temp = GMatrix(max(nodeS, nodeE))
        let conductance = 2 * self.capacitance / context.timeStep
        
        try temp.add(nodeS, nodeS, conductance)
        try temp.add(nodeS, nodeE, -conductance)
        try temp.add(nodeE, nodeS, -conductance)
        try temp.add(nodeE, nodeE, conductance)
        
        return temp
    }
    
    override func getIMatrix(_ context: StampContext) throws -> Matrix? {
        if case .op = context.command { return nil }
        if context.timeStep <= 0 || !context.timeStep.isFinite { throw StampParameterError.parameterError }
        let temp = IMatrix(max(nodeS, nodeE))
        let voltage = context.previousSolution == nil ? context.voltage : context.previousVoltage(nodeS) - context.previousVoltage(nodeE)
        let current = 2 * self.capacitance / context.timeStep * voltage
            
        try temp.add(nodeS, current)
        try temp.add(nodeE, -current)
            
        return temp
    }
}
