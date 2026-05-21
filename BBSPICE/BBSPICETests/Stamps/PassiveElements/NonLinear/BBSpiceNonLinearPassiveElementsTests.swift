//
//  BBSpiceNonLinearPassiveElementsTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceNonLinearPassiveElementsTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testCapacitorGMatrix() throws {
        let capacitor = try C(1, 2, 2)
        
        let gMatrix = try capacitor.getGMatrix(0.5)
        
        XCTAssertNotNil(gMatrix)
        XCTAssertEqual(gMatrix?.rows, 2)
        XCTAssertEqual(gMatrix?.columns, 2)
        XCTAssertEqual(gMatrix?.values, [8, -8, -8, 8])
    }
    
    func testCapacitorIMatrix() throws {
        let capacitor = try C(1, 2, 2)
        
        let iMatrix = try capacitor.getIMatrix(0.5, 3)
        
        XCTAssertNotNil(iMatrix)
        XCTAssertEqual(iMatrix?.rows, 2)
        XCTAssertEqual(iMatrix?.columns, 1)
        XCTAssertEqual(iMatrix?.values, [24, -24])
    }
    
}
