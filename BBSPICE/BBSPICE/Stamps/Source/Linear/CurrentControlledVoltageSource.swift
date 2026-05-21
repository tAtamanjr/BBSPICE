//
//  VoltageControlledVoltageSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.01.2026.
//

import Foundation


class CCVS : ControlledSource {
    let newRow: Int
    let newRow2: Int
    let transresistance: Double
    let inputVoltage: Double
    
    init(_ nodeWeP: Int, _ nodeWeM: Int, _ nodeWyP: Int, _ nodeWyM: Int, _ newRow: Int, _ newRow2: Int,
         _ transresistance: Double, _ inputVoltage: Double = 0.0) throws {
        if newRow < 0 || newRow2 < 0 { throw StampParameterError.programFail }
        if !transresistance.isFinite || !inputVoltage.isFinite { throw StampParameterError.parameterError }
        self.newRow = newRow
        self.newRow2 = newRow2
        self.transresistance = transresistance
        self.inputVoltage = inputVoltage
        try super.init(nodeWeP, nodeWeM, nodeWyP, nodeWyM)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix? {
        let temp = GMatrix(newRow2)
        
        try temp.add(nodeWyP, newRow2, 1)
        try temp.add(nodeWyM, newRow2, -1)
        try temp.add(nodeWeP, newRow, 1)
        try temp.add(nodeWeM, newRow, -1)
        try temp.add(newRow, nodeWeP, 1)
        try temp.add(newRow, nodeWeM, -1)
        try temp.add(newRow2, nodeWyP, 1)
        try temp.add(newRow2, nodeWyM, -1)
        try temp.add(newRow2, newRow, transresistance)
        
        return temp
    }
    
    override func getIMatrix(_ context: StampContext) throws -> Matrix? {
        let temp: Matrix? = IMatrix(newRow)
        
        try temp!.add(newRow, inputVoltage)
        
        return temp
    }
}
