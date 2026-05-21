//
//  BBSpiceStampErrorTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceStampErrorTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testParameterError() throws {
        XCTAssertThrowsError(try R(1, 2, -3)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try DCCS(1, 2, Double.infinity)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try C(1, 2, 0)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try C(1, 2, Double.infinity)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try ACVS(1, 0, 2, 1, 0)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try ACVS(1, 0, 2, 1, Double.infinity)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try C(1, 2, 1).getGMatrix(0)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
        XCTAssertThrowsError(try C(1, 2, 1).getIMatrix(0, 1)) { err in
            XCTAssertEqual(err as? StampParameterError, .parameterError)
        }
    }
    
    func testNegativeNodeIndex() throws {
        XCTAssertThrowsError(try R(-1, 2, 3)) { err in
            XCTAssertEqual(err as? StampParameterError, .negativeNodeIndex)
        }
        XCTAssertThrowsError(try DCCS(-1, 2, 1)) { err in
            XCTAssertEqual(err as? StampParameterError, .negativeNodeIndex)
        }
        XCTAssertThrowsError(try C(-1, 2, 1)) { err in
            XCTAssertEqual(err as? StampParameterError, .negativeNodeIndex)
        }
    }
    
}
