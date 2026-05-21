//
//  BBSpiceNonLinearSourceTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceNonLinearSourceTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testACVSVoltage() throws {
        let source = try ACVS(1, 0, 2, 10, 50)
        let period = 1 / source.frequency
        
        XCTAssertEqual(source.getVoltage(0), 0, accuracy: 1e-12)
        XCTAssertEqual(source.getVoltage(period / 4), 10, accuracy: 1e-12)
        XCTAssertEqual(source.getVoltage(period / 2), 0, accuracy: 1e-12)
        XCTAssertEqual(source.getVoltage(3 * period / 4), -10, accuracy: 1e-12)
    }
    
    func testACVSGMatrix() throws {
        let source = try ACVS(1, 0, 2, 10, 50)
        
        let gMatrix = try source.getGMatrix()
        
        XCTAssertNotNil(gMatrix)
        XCTAssertEqual(gMatrix?.rows, 2)
        XCTAssertEqual(gMatrix?.columns, 2)
        XCTAssertEqual(gMatrix?.values, [0, 1, 1, 0])
    }
    
    func testACVSIMatrix() throws {
        let source = try ACVS(1, 0, 2, 10, 50)
        let period = 1 / source.frequency
        
        let iMatrix = try source.getIMatrix(period / 4)
        
        XCTAssertNotNil(iMatrix)
        XCTAssertEqual(iMatrix?.rows, 2)
        XCTAssertEqual(iMatrix?.columns, 1)
        XCTAssertEqual(iMatrix?.values[0] ?? 0, 0, accuracy: 1e-12)
        XCTAssertEqual(iMatrix?.values[1] ?? 0, 10, accuracy: 1e-12)
    }
    
}
