//
//  CurrentControlledCurrentSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import Foundation


class CCCS : ControlledSource {
    let newRow: Int
    let gain: Double
    let inputVoltage: Double
    
    init(_ nodeWeP: Int, _ nodeWeM: Int, _ nodeWyP: Int, _ nodeWyM: Int, _ newRow: Int, _ gain: Double, _ inputVoltage: Double = 0) {
        self.newRow = newRow
        self.gain = gain
        self.inputVoltage = inputVoltage
        super.init(nodeWeP, nodeWeM, nodeWyP, nodeWyM)
    }
    
    override func getGMatrix() throws -> Matrix? {
        let temp: Matrix? = GMatrix(newRow)
        
        try temp!.add(nodeWyP, newRow, gain)
        try temp!.add(nodeWyM, newRow, -gain)
        try temp!.add(nodeWeP, newRow, 1)
        try temp!.add(nodeWeM, newRow, -1)
        try temp!.add(newRow, nodeWeP, 1)
        try temp!.add(newRow, nodeWeM, -1)
        
        return temp
    }
    
    override func getIMatrix() throws -> Matrix? {
        let temp: Matrix? = IMatrix(newRow)
        
        try temp!.add(newRow, inputVoltage)
        
        return temp
    }
}
