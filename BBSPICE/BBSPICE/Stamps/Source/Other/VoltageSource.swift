//
//  VoltageSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 20.01.2026.
//

import Foundation


class VoltageSource : TwoNodeStamp {
    let newRow: Int
    let amplitude: Double
    
    init(_ nodeS : Int, _ nodeE: Int, _ newRow: Int, _ amplitude: Double) throws {
        if newRow < 0 { throw StampParameterError.programFail }
        if !amplitude.isFinite { throw StampParameterError.parameterError }
        self.newRow = newRow
        self.amplitude = amplitude
        try super.init(nodeS, nodeE)
    }
}
