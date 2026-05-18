//
//  BBSpiceMatrixTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 20.01.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceMatrixTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    @MainActor func testMatrixCreation() async throws {
        var matrix: Matrix?
        
        matrix = Matrix(3, 3)
        matrix!.show()
        matrix = GMatrix(3)
        matrix!.show()
        matrix = Matrix(3, 1)
        matrix!.show()
        matrix = IMatrix(3)
        matrix!.show()
        matrix = VMatrix([3.0, 2.0, 1.0])
        matrix!.show()
    }

    @MainActor func testMatrixAdd() async throws {
        var matrix: Matrix?
        var matrix1: Matrix?
        var matrix2: Matrix?
        var matrix3: Matrix?
        var matrix4: Matrix?
        
        matrix = Matrix(3, 3)
        matrix!.show()
        
        try matrix!.add(0, 0, 1)
        try matrix!.add(1, 0, 1)
        try matrix!.add(0, 1, 1)
        try matrix!.add(1, 1, 0)
        matrix!.show()
        
        try matrix!.add(1, 1, 1)
        try matrix!.add(1, 2, 2)
        try matrix!.add(2, 1, 3)
        matrix!.show()
        
        matrix1 = Matrix(3, 3)
        matrix2 = Matrix(3, 1)
        
        XCTAssertThrowsError(try matrix1!.add(4, 1, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(4, 1, matrix1!.id))
        }
        XCTAssertThrowsError(try matrix1!.add(1, 4, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(1, 4, matrix1!.id))
        }
        XCTAssertThrowsError(try matrix1!.add(4, 4, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(4, 4, matrix1!.id))
        }
        XCTAssertThrowsError(try matrix2!.add(4, 1, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(4, 1, matrix2!.id))
        }
        XCTAssertThrowsError(try matrix2!.add(1, 4, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(1, 4, matrix2!.id))
        }
        XCTAssertThrowsError(try matrix2!.add(4, 4, 5.0)) { err in
            XCTAssertEqual(err as? MatrixError, .indexOutOfBounds(4, 4, matrix2!.id))
        }
        
        matrix3 = GMatrix(4)
        matrix4 = IMatrix(4)
        
        try matrix3!.add(matrix)
        try matrix3!.add(nil)
        matrix3!.show()
        
        XCTAssertThrowsError(try matrix1!.add(matrix3)) { err in
            XCTAssertEqual(err as? MatrixError, .biggerMatrixToAdd(matrix1!.id, matrix3!.id))
        }
        XCTAssertThrowsError(try matrix2!.add(matrix4)) { err in
            XCTAssertEqual(err as? MatrixError, .biggerMatrixToAdd(matrix2!.id, matrix4!.id))
        }
    }

    @MainActor func testMatrixAddStamps() async throws {
        var matrix: Matrix?
        var matrix1: Matrix?
        var resistor: Stamp?
        var source: Stamp?
        
        matrix = GMatrix(2)
        resistor = try R(0, 1, 1)
        try matrix!.add(resistor!.getGMatrix())
        matrix!.show()
        
        matrix = GMatrix(2)
        resistor = try R(1, 2, 1)
        try matrix!.add(resistor!.getGMatrix())
        matrix!.show()
        
        resistor = try R(2, 3, 1)
        try matrix1 = resistor!.getGMatrix()
        XCTAssertThrowsError(try matrix!.add(matrix1)) { err in
            XCTAssertEqual(err as? MatrixError, .biggerMatrixToAdd(matrix!.id, matrix1!.id))
        }
        
        matrix = IMatrix(2)
        source = try DCCS(0, 1, 1)
        try matrix!.add(source!.getIMatrix())
        matrix!.show()
        
        matrix = IMatrix(2)
        source = try DCCS(1, 2, 1)
        try matrix!.add(source!.getIMatrix())
        matrix!.show()
        
        source = try DCCS(2, 3, 1)
        try matrix1 = source!.getIMatrix()
        XCTAssertThrowsError(try matrix!.add(matrix1)) { err in
            XCTAssertEqual(err as? MatrixError, .biggerMatrixToAdd(matrix!.id, matrix1!.id))
        }
    }
    
//    @MainActor func testMatrixDivision() async throws {
//        let G_Matrix: Matrix? = GMatrix(2)
//        let I_Matrix: Matrix? = IMatrix(2)
//        let f_Matrix: Matrix? = IMatrix(3)
//        
//        XCTAssertThrowsError(try G_Matrix!.devide(nil)) { err in
//            XCTAssertEqual(err as? MatrixError, .matrixIsNil(G_Matrix!.id))
//        }
//        XCTAssertThrowsError(try G_Matrix!.devide(G_Matrix)) { err in
//            XCTAssertEqual(err as? MatrixError, .wrongDimensions(G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns,
//                                                                 G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns))
//        }
//        XCTAssertThrowsError(try G_Matrix!.devide(f_Matrix)) { err in
//            XCTAssertEqual(err as? MatrixError, .wrongDimensions(G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns,
//                                                                 f_Matrix!.id, f_Matrix!.rows, f_Matrix!.columns))
//        }
//        
//        G_Matrix!.values = [0.0, 0.0, 0.0, 0.0]
//        I_Matrix!.values = [1.0, 2.0]
//        XCTAssertThrowsError(try G_Matrix!.devide(I_Matrix)) { err in
//            XCTAssertEqual(err as? MatrixError, .divisionError(G_Matrix!.id, I_Matrix!.id))
//        }
//        
//        G_Matrix!.values = [0.0, 1.0, 2.0, 3.0]
//        I_Matrix!.values = [3.0, 3.0]
//        let V_Matrix = try G_Matrix!.devide(I_Matrix!)
//        V_Matrix!.show()
//    }
    
    @MainActor func testSpeed_50() async throws {
        let (a, b) = try makeSystemForDivisionTest(50)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_100() async throws {
        let (a, b) = try makeSystemForDivisionTest(100)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_200() async throws {
        let (a, b) = try makeSystemForDivisionTest(200)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_500() async throws {
        let (a, b) = try makeSystemForDivisionTest(500)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_1000() async throws {
        let (a, b) = try makeSystemForDivisionTest(1000)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_2000() async throws {
        let (a, b) = try makeSystemForDivisionTest(2000)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
    @MainActor func testSpeed_5000() async throws {
        let (a, b) = try makeSystemForDivisionTest(5000)
        for _ in 0..<3 {
            do {
                _ = try a.devide(b)
            } catch {}
        }
        measure(metrics: [XCTClockMetric()]) {
            do {
                _ = try a.devide(b)
            } catch {}
        }
    }
    
}

private func makeSystemForDivisionTest(_ size: Int) throws -> (A: Matrix, b: Matrix?) {
    let a = GMatrix(size)
    let b = IMatrix(size)

    for i in 1..<size + 1 {
        try a.add(i, i, Double(i))
        try b.add(i, Double(i))
    }

    return (a, b)
}
