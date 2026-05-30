import XCTest

final class ReferenceComparisonTests: XCTestCase {
    
    func testMaxAbsoluteError() throws {
        let result = try ReferenceComparison.maxAbsoluteError([1, 2, 3], [1.1, 1.8, 3.05])
        
        XCTAssertEqual(result, 0.2, accuracy: 1e-12)
    }
    
    func testRMSError() throws {
        let result = try ReferenceComparison.rmsError([1, 2, 3], [2, 2, 5])
        
        XCTAssertEqual(result, sqrt(5.0 / 3.0), accuracy: 1e-12)
    }
    
    func testAlmostEqualScalars() {
        ReferenceComparison.assertAlmostEqual(
            1.0001,
            1,
            absoluteTolerance: 0.001,
            relativeTolerance: 0
        )
    }
    
    func testAlmostEqualVectors() throws {
        try ReferenceComparison.assertAlmostEqual(
            [0, 1.0001, 100.01],
            [0, 1, 100],
            absoluteTolerance: 0.001,
            relativeTolerance: 0.001
        )
    }
    
    func testAlmostEqualVectorsDifferentCount() throws {
        XCTAssertThrowsError(
            try ReferenceComparison.assertAlmostEqual(
                [1, 2],
                [1],
                absoluteTolerance: 1e-9,
                relativeTolerance: 1e-9
            )
        ) { error in
            XCTAssertEqual(error as? ReferenceComparisonError, .differentCount(2, 1))
        }
    }
    
    func testMetricDifferentCount() throws {
        XCTAssertThrowsError(try ReferenceComparison.maxAbsoluteError([1, 2], [1])) { error in
            XCTAssertEqual(error as? ReferenceComparisonError, .differentCount(2, 1))
        }
        
        XCTAssertThrowsError(try ReferenceComparison.rmsError([1], [1, 2])) { error in
            XCTAssertEqual(error as? ReferenceComparisonError, .differentCount(1, 2))
        }
    }
    
    func testColumnComparison() throws {
        let actual = ReferenceCSV(columns: ["time", "V(1)"], rows: [[0, 0], [1, 1.0001]])
        let expected = ReferenceCSV(columns: ["time", "V(1)"], rows: [[0, 0], [1, 1]])
        
        try ReferenceComparison.assertColumn(
            "V(1)",
            in: actual,
            equals: expected,
            absoluteTolerance: 0.001,
            relativeTolerance: 0
        )
    }
    
    func testColumnComparisonMissingColumn() throws {
        let actual = ReferenceCSV(columns: ["time", "V(1)"], rows: [[0, 0]])
        let expected = ReferenceCSV(columns: ["time", "V(2)"], rows: [[0, 0]])
        
        XCTAssertThrowsError(
            try ReferenceComparison.assertColumn(
                "V(1)",
                in: actual,
                equals: expected,
                absoluteTolerance: 1e-9,
                relativeTolerance: 1e-9
            )
        ) { error in
            XCTAssertEqual(error as? ReferenceComparisonError, .missingColumn("V(1)"))
        }
    }
}
