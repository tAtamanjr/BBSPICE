//
//  BBSpiceSolverTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceSolverTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testOperationPoint() throws {
        let stamps: [Stamp] = try [DCVS(1, 0, 2, 5), R(1, 0, 5)]
        
        let result = try Solver().solve(stamps, .op)
        
        XCTAssertNotNil(result)
        XCTAssert(result!.rows == 2)
        XCTAssert(result!.columns == 1)
        XCTAssertEqual(result!.values[0], 5, accuracy: 1e-9)
    }
    
    func testEmptyStamps() throws {
        XCTAssertThrowsError(try Solver().solve([], .op)) { err in
            XCTAssertEqual(err as? SolverError, .emptyStamps)
        }
    }
    
}
