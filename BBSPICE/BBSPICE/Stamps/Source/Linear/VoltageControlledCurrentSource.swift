//
//  VoltageControlledCurrentSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.01.2026.
//

import Foundation


class VCCS : ControlledSource {
    let transconductance: Double
    
    init(_ nodeWeP: Int, _ nodeWeM: Int, _ nodeWyP: Int, _ nodeWyM: Int, _ transconductance: Double) throws {
        if !transconductance.isFinite { throw StampParameterError.parameterError }
        self.transconductance = transconductance
        try super.init(nodeWeP, nodeWeM, nodeWyP, nodeWyM)
    }
    
    override func getGMatrix() throws -> Matrix? {
        let temp = GMatrix(max(nodeWeP, nodeWeM, nodeWyP, nodeWyM))
        
        try temp.add(nodeWyP, nodeWeP, transconductance)
        try temp.add(nodeWyP, nodeWeM, -transconductance)
        try temp.add(nodeWyM, nodeWeP, -transconductance)
        try temp.add(nodeWyM, nodeWeM, transconductance)
        
        return temp
    }
}
