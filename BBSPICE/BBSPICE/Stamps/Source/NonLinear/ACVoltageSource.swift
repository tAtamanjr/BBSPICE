//
//  ACVoltageSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import Foundation

class ACVS : VoltageSource {
    let frequency: Double
    
    init(_ nodeS : Int, _ nodeE: Int, _ newRow: Int, _ amplitude: Double, _ frequency: Double) throws {
        if newRow < 0 { throw StampParameterError.programFail }
        if !amplitude.isFinite { throw StampParameterError.parameterError }
        if frequency <= 0 || !frequency.isFinite { throw StampParameterError.parameterError }
        self.frequency = frequency
        try super.init(nodeS, nodeE, newRow, amplitude)
    }
    
    func getVoltage(_ h: Double) -> Double {
        return amplitude * sin(2 * Double.pi * frequency * h)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix?  {
        let temp = GMatrix(newRow)
        
        try temp.add(nodeS, newRow, 1)
        try temp.add(nodeE, newRow, -1)
        try temp.add(newRow, nodeE, -1)
        try temp.add(newRow, nodeS, 1)
        
        return temp
    }
    
    override func getIMatrix(_ context: StampContext) throws -> Matrix? {
        let temp = IMatrix(newRow)
        
        try temp.add(newRow, getVoltage(context.time))
        
        return temp
    }
}
