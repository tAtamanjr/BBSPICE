import XCTest

enum ReferenceComparisonError: Error, Equatable {
    case differentCount(Int, Int)
    case missingColumn(String)
}

struct ReferenceComparison {
    static func maxAbsoluteError(_ lhs: [Double], _ rhs: [Double]) throws -> Double {
        try validateCount(lhs, rhs)
        
        return zip(lhs, rhs)
            .map { abs($0 - $1) }
            .max() ?? 0
    }
    
    static func rmsError(_ lhs: [Double], _ rhs: [Double]) throws -> Double {
        try validateCount(lhs, rhs)
        if lhs.isEmpty { return 0 }
        
        let sum = zip(lhs, rhs)
            .map { pow($0 - $1, 2) }
            .reduce(0, +)
        
        return sqrt(sum / Double(lhs.count))
    }
    
    static func assertAlmostEqual(
        _ lhs: Double,
        _ rhs: Double,
        absoluteTolerance: Double,
        relativeTolerance: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let tolerance = absoluteTolerance + relativeTolerance * abs(rhs)
        XCTAssertLessThanOrEqual(abs(lhs - rhs), tolerance, file: file, line: line)
    }
    
    static func assertAlmostEqual(
        _ lhs: [Double],
        _ rhs: [Double],
        absoluteTolerance: Double,
        relativeTolerance: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        try validateCount(lhs, rhs)
        
        for index in lhs.indices {
            assertAlmostEqual(
                lhs[index],
                rhs[index],
                absoluteTolerance: absoluteTolerance,
                relativeTolerance: relativeTolerance,
                file: file,
                line: line
            )
        }
    }
    
    static func assertColumn(
        _ column: String,
        in actual: ReferenceCSV,
        equals expected: ReferenceCSV,
        absoluteTolerance: Double,
        relativeTolerance: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        guard let actualValues = actual.values(column) else { throw ReferenceComparisonError.missingColumn(column) }
        guard let expectedValues = expected.values(column) else { throw ReferenceComparisonError.missingColumn(column) }
        
        try assertAlmostEqual(
            actualValues,
            expectedValues,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            file: file,
            line: line
        )
    }
    
    private static func validateCount(_ lhs: [Double], _ rhs: [Double]) throws {
        if lhs.count != rhs.count {
            throw ReferenceComparisonError.differentCount(lhs.count, rhs.count)
        }
    }
}
