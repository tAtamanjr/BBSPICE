//
//  BBSpiceLinearPassiveElementsTests.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceLinearPassiveElementsTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    @MainActor func testResistor() async throws {
        let resistor = try R(1, 2, 3.0)
        XCTAssert(resistor.nodeS == 1)
        XCTAssert(resistor.nodeE == 2)
        XCTAssert(resistor.resistance == 3.0)
        
        var stamps: [Stamp] = try [DCCS(0, 1, 5), R(1, 2, 5), R(2, 3, 5), R(2, 3, 5), R(3, 0, 5)]
        var vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
        vMatrix!.show()
        
        stamps = try [DCVS(1, 0, 3, 5), R(1, 2, 5), R(2, 0, 5)]
        vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
        vMatrix!.show()
    }
    
}
