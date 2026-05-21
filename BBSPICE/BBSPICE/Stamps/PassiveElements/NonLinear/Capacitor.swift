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
    
    override func getGMatrix(_ h: Double = 0.0, _ v: Double = 0.0) throws -> Matrix? {
        if h <= 0 || !h.isFinite { throw StampParameterError.parameterError }
        let temp = GMatrix(max(nodeS, nodeE))
        
        try temp.add(nodeS, nodeS, 2 * self.capacitance / h)
        try temp.add(nodeS, nodeE, -2 * self.capacitance / h)
        try temp.add(nodeE, nodeS, -2 * self.capacitance / h)
        try temp.add(nodeE, nodeE, 2 * self.capacitance / h)
        
        return temp
    }
    
    override func getIMatrix(_ h: Double = 0.0, _ v: Double = 0.0) throws -> Matrix? {
        if h <= 0 || !h.isFinite { throw StampParameterError.parameterError }
        let temp = IMatrix(max(nodeS, nodeE))
            
        try temp.add(nodeS, 2 * self.capacitance / h * v)
        try temp.add(nodeE, -2 * self.capacitance / h * v)
            
        return temp
    }
}
