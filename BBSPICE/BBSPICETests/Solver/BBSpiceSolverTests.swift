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
    
    func testOperationPointWithParsedACVSAndCapacitor() throws {
        let result = try Parser().parse(makeTestFile("""
        ACVS 1 0 10 50
        C 1 0 0.001
        R 1 0 5
        .op
        """))
        
        let solution = try Solver().solve(result.stamps, result.command)
        
        XCTAssertNotNil(solution)
        XCTAssert(solution!.rows == 2)
        XCTAssert(solution!.columns == 1)
        XCTAssertEqual(solution!.values[0], 0, accuracy: 1e-9)
    }
    
    func testEmptyStamps() throws {
        XCTAssertThrowsError(try Solver().solve([], .op)) { err in
            XCTAssertEqual(err as? SolverError, .emptyStamps)
        }
    }
    
}

private func makeTestFile(_ text: String) throws -> URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("txt")
    try text.write(to: url, atomically: true, encoding: .utf8)
    return url
}
