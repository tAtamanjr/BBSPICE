//
//  VoltageControlledVoltageSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.01.2026.
//

import Foundation


class VCVS : ControlledSource {
    let newRow: Int
    let gain: Double
    
    init(_ nodeWeP: Int, _ nodeWeM: Int, _ nodeWyP: Int, _ nodeWyM: Int, _ newRow: Int, _ gain: Double) throws {
        if newRow < 0 { throw StampParameterError.programFail }
        if !gain.isFinite { throw StampParameterError.parameterError }
        self.newRow = newRow
        self.gain = gain
        try super.init(nodeWeP, nodeWeM, nodeWyP, nodeWyM)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix? {
        let temp = GMatrix(newRow)
        
        try temp.add(nodeWyP, newRow, 1)
        try temp.add(nodeWyM, newRow, -1)
        try temp.add(newRow, nodeWyP, 1)
        try temp.add(newRow, nodeWyM, -1)
        try temp.add(newRow, nodeWeP, -gain)
        try temp.add(newRow, nodeWeM, gain)
        
        return temp
    }
}
