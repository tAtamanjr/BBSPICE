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
    
    init(_ nodeS : Int, _ nodeE: Int, _ newRow: Int, _ amplitude: Double) {
        self.newRow = newRow
        self.amplitude = amplitude
        super.init(nodeS, nodeE)
    }
}
