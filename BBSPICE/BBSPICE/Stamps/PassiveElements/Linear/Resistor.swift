//
//  Resistor.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.01.2026.
//

import Foundation


class R : TwoNodeStamp {
    let resistance: Double
    
    init(_ nodeS: Int, _ nodeE: Int, _ resistance: Double) throws {
        if resistance < 0 || !resistance.isFinite { throw StampParameterError.parameterError }
        self.resistance = resistance
        try super.init(nodeS, nodeE)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix? {
        let temp = GMatrix(max(nodeS, nodeE))
        
        try temp.add(nodeS, nodeS, 1 / resistance)
        try temp.add(nodeS, nodeE, -1 / resistance)
        try temp.add(nodeE, nodeS, -1 / resistance)
        try temp.add(nodeE, nodeE, 1 / resistance)
        
        return temp
    }
}
