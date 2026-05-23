//
//  BBSpiceActiveElementsTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 23.05.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceActiveElementsTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testBJTGMatrix() throws {
        let transistor = try BJT(1, 2, 3, 1e-12, 100, 1)
        let context = StampContext(voltageBE: 0.6, voltageBC: -0.2)
        let model = makeBJTModel(1e-12, 100, 1, 0.6, -0.2)
        
        let gMatrix = try transistor.getGMatrix(context)
        
        XCTAssertNotNil(gMatrix)
        XCTAssertEqual(gMatrix?.rows, 3)
        XCTAssertEqual(gMatrix?.columns, 3)
        XCTAssertEqual(gMatrix?.values[0] ?? 0, model.dIB_dVBE + model.dIB_dVBC, accuracy: 1e-12)
        XCTAssertEqual(gMatrix?.values[1] ?? 0, -model.dIB_dVBC, accuracy: 1e-12)
        XCTAssertEqual(gMatrix?.values[2] ?? 0, -model.dIB_dVBE, accuracy: 1e-12)
        XCTAssertEqual(gMatrix?.values[6] ?? 0, model.dIE_dVBE, accuracy: 1e-12)
        XCTAssertEqual(gMatrix?.values[7] ?? 0, model.dIE_dVBC, accuracy: 1e-12)
        XCTAssertEqual(gMatrix?.values[8] ?? 0, -model.dIE_dVBE, accuracy: 1e-12)
    }
    
    func testBJTIMatrix() throws {
        let transistor = try BJT(1, 2, 3, 1e-12, 100, 1)
        let context = StampContext(voltageBE: 0.6, voltageBC: -0.2)
        let model = makeBJTModel(1e-12, 100, 1, 0.6, -0.2)
        
        let iMatrix = try transistor.getIMatrix(context)
        
        XCTAssertNotNil(iMatrix)
        XCTAssertEqual(iMatrix?.rows, 3)
        XCTAssertEqual(iMatrix?.columns, 1)
        XCTAssertEqual(iMatrix?.values[0] ?? 0, -(model.iB - model.dIB_dVBE * model.vBE - model.dIB_dVBC * model.vBC), accuracy: 1e-12)
        XCTAssertEqual(iMatrix?.values[1] ?? 0, 0, accuracy: 1e-12)
        XCTAssertEqual(iMatrix?.values[2] ?? 0, -(model.iE - model.dIE_dVBE * model.vBE - model.dIE_dVBC * model.vBC), accuracy: 1e-12)
    }
    
    func testBJTContextSolution() throws {
        let transistor = try BJT(1, 2, 3, 1e-12, 100, 1)
        let explicitContext = StampContext(voltageBE: 0.6, voltageBC: -0.2)
        let solutionContext = StampContext(solution: VMatrix([0.6, 0.8, 0.0]))
        
        let explicitGMatrix = try transistor.getGMatrix(explicitContext)
        let solutionGMatrix = try transistor.getGMatrix(solutionContext)
        let explicitIMatrix = try transistor.getIMatrix(explicitContext)
        let solutionIMatrix = try transistor.getIMatrix(solutionContext)
        
        XCTAssertEqual(solutionGMatrix?.values.count, explicitGMatrix?.values.count)
        XCTAssertEqual(solutionIMatrix?.values.count, explicitIMatrix?.values.count)
        
        for index in 0..<(solutionGMatrix?.values.count ?? 0) {
            XCTAssertEqual(solutionGMatrix?.values[index] ?? 0, explicitGMatrix?.values[index] ?? 0, accuracy: 1e-12)
        }
        for index in 0..<(solutionIMatrix?.values.count ?? 0) {
            XCTAssertEqual(solutionIMatrix?.values[index] ?? 0, explicitIMatrix?.values[index] ?? 0, accuracy: 1e-12)
        }
    }
}

private func makeBJTModel(_ Is: Double, _ beta: Double, _ m: Double, _ rawVBE: Double, _ rawVBC: Double) -> TestBJTModel {
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
    
    return TestBJTModel(
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

private struct TestBJTModel {
    let vBE: Double
    let vBC: Double
    let iE: Double
    let iB: Double
    let dIE_dVBE: Double
    let dIE_dVBC: Double
    let dIB_dVBE: Double
    let dIB_dVBC: Double
}
