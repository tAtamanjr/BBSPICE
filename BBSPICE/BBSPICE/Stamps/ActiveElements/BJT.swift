//
//  BJT.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import Foundation

class BJT : ThreeNodeStamp {
    let Is: Double
    let beta: Double
    let m: Double
    
    init(_ nodeBase: Int, _ nodeCollector: Int, _ nodeEmitter: Int, _ Is: Double, _ beta: Double, _ m: Double) throws {
        if Is <= 0 || beta <= 0 || m <= 0 { throw StampParameterError.parameterError }
        if !Is.isFinite || !beta.isFinite || !m.isFinite { throw StampParameterError.parameterError }
        self.Is = Is
        self.beta = beta
        self.m = m
        try super.init(nodeBase, nodeCollector, nodeEmitter)
    }
    
    override func getGMatrix(_ context: StampContext) throws -> Matrix? {
        let model = makeModel(context)
        let temp = GMatrix(max(node1, node2, node3))
        
        try temp.add(node1, node1, model.dIB_dVBE + model.dIB_dVBC)
        try temp.add(node1, node2, -model.dIB_dVBC)
        try temp.add(node1, node3, -model.dIB_dVBE)
        
        try temp.add(node3, node1, model.dIE_dVBE)
        try temp.add(node3, node2, model.dIE_dVBC)
        try temp.add(node3, node3, -model.dIE_dVBE)
            
        return temp
    }
    
    override func getIMatrix(_ context: StampContext) throws -> Matrix? {
        let model = makeModel(context)
        let temp = IMatrix(max(node1, node2, node3))
        
        try temp.add(node1, -(model.iB - model.dIB_dVBE * model.vBE - model.dIB_dVBC * model.vBC))
        try temp.add(node3, -(model.iE - model.dIE_dVBE * model.vBE - model.dIE_dVBC * model.vBC))
        
        return temp
    }
    
    private func makeModel(_ context: StampContext) -> BJTModel {
        let rawVBE = context.voltageBE ?? context.nodeVoltage(node1) - context.nodeVoltage(node3)
        let rawVBC = context.voltageBC ?? context.nodeVoltage(node1) - context.nodeVoltage(node2)
        let vBE = min(max(rawVBE, -0.8), 1.0)
        let vBC = min(max(rawVBC, -0.8), 1.0)
        let thermalVoltage = 0.025
        
        let iBE = Is * (exp(vBE / (m * thermalVoltage)) - 1)
        var gBE = Is / (m * thermalVoltage) * exp(vBE / (m * thermalVoltage))
        
        if vBE < -0.7 { gBE = 1e-9 }
        if vBE > 0.8 { gBE = max(gBE, 0.1) }
        
        let iBC = Is * (exp(vBC / (m * thermalVoltage)) - 1)
        var gBC = Is / (m * thermalVoltage) * exp(vBC / (m * thermalVoltage))
        
        if vBC < -0.7 { gBC = 1e-9 }
        if vBC > 0.8 { gBC = max(gBC, 0.1) }
        
        let betaRatio = beta / (beta + 1)
        let iE = -betaRatio * iBE + 0.5 * iBC
        let iB = (1 - betaRatio) * iBE + 0.5 * iBC
        let dIE_dVBE = -betaRatio * gBE
        let dIE_dVBC = 0.5 * gBC
        let dIB_dVBE = (1 - betaRatio) * gBE
        let dIB_dVBC = 0.5 * gBC
        
        return BJTModel(
            vBE: vBE,
            vBC: vBC,
            iE: iE,
            iB: iB,
            dIE_dVBE: dIE_dVBE,
            dIE_dVBC: dIE_dVBC,
            dIB_dVBE: dIB_dVBE,
            dIB_dVBC: dIB_dVBC
        )
    }
}

private struct BJTModel {
    let vBE: Double
    let vBC: Double
    let iE: Double
    let iB: Double
    let dIE_dVBE: Double
    let dIE_dVBC: Double
    let dIB_dVBE: Double
    let dIB_dVBC: Double
}
