//
//  BBSpiceLinearSourceTests.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceLinearSourceTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
 
    @MainActor func testDCCS() async throws {
        let stamps: [Stamp] = try [DCCS(0, 1, 5), R(1, 2, 5), R(2, 3, 5), R(2, 3, 5), R(3, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
    @MainActor func testDCVS() async throws {
        let stamps = try [DCVS(1, 0, 3, 5), R(1, 2, 5), R(2, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
    @MainActor func testVCCS() async throws {
        let stamps: [Stamp] = try [DCVS(1, 0, 3, 5), VCCS(1, 0, 2, 0, 2), R(2, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
    @MainActor func testCCCS() async throws {
        let stamps: [Stamp] = try [DCCS(1, 0, 5), CCCS(1, 0, 2, 0, 3, 2), R(2, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
    @MainActor func testVCVS() async throws {
        let stamps: [Stamp] = try [DCVS(1, 0, 3, 5), VCVS(1, 0, 2, 0, 4, 2), R(2, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
    @MainActor func testCCVS() async throws {
        let stamps: [Stamp] = try [DCCS(1, 0, 5), CCVS(1, 0, 2, 0, 3, 4, 2), R(2, 0, 5)]
        
        let vMatrix = try Solver().solve(stamps, .op)
        XCTAssertNotNil(vMatrix)
    }
    
}
