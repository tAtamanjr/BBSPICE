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
        source = DCCS(0, 1, 1)
        try matrix!.add(source!.getIMatrix())
        matrix!.show()
        
        matrix = IMatrix(2)
        source = DCCS(1, 2, 1)
        try matrix!.add(source!.getIMatrix())
        matrix!.show()
        
        source = DCCS(2, 3, 1)
        try matrix1 = source!.getIMatrix()
        XCTAssertThrowsError(try matrix!.add(matrix1)) { err in
            XCTAssertEqual(err as? MatrixError, .biggerMatrixToAdd(matrix!.id, matrix1!.id))
        }
    }
    
    @MainActor func testMatrixDivision() async throws {
        let G_Matrix: Matrix? = GMatrix(2)
        let I_Matrix: Matrix? = IMatrix(2)
        let f_Matrix: Matrix? = IMatrix(3)
        
        XCTAssertThrowsError(try G_Matrix!.devide(nil)) { err in
            XCTAssertEqual(err as? MatrixError, .matrixIsNil(G_Matrix!.id))
        }
        XCTAssertThrowsError(try G_Matrix!.devide(G_Matrix)) { err in
            XCTAssertEqual(err as? MatrixError, .wrongDimensions(G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns,
                                                                 G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns))
        }
        XCTAssertThrowsError(try G_Matrix!.devide(f_Matrix)) { err in
            XCTAssertEqual(err as? MatrixError, .wrongDimensions(G_Matrix!.id, G_Matrix!.rows, G_Matrix!.columns,
                                                                 f_Matrix!.id, f_Matrix!.rows, f_Matrix!.columns))
        }
        
        G_Matrix!.values = [0.0, 0.0, 0.0, 0.0]
        I_Matrix!.values = [1.0, 2.0]
        XCTAssertThrowsError(try G_Matrix!.devide(I_Matrix)) { err in
            XCTAssertEqual(err as? MatrixError, .divisionError(G_Matrix!.id, I_Matrix!.id))
        }
        
        G_Matrix!.values = [0.0, 1.0, 2.0, 3.0]
        I_Matrix!.values = [3.0, 3.0]
        let V_Matrix = try G_Matrix!.devide(I_Matrix!)
        V_Matrix!.show()
    }
 
//    @MainActor func testSpeed() throws {
    func testSpeed() throws {
        let system = try makeSystemForSpeedTest(3)

        for _ in 0..<3 {
            let a = system.a
            let b = system.b
            _ = try a.devide(b)
        }

        measure(metrics: [XCTClockMetric()]) {
            do {
                let a = system.a
                let b = system.b
                _ = try a.devide(b)
            } catch {}
        }
    }
    
}

private func makeSystemForSpeedTest(_ size: Int) throws -> (a: Matrix, b: Matrix) {
    precondition(size > 0)
    
    let a = GMatrix(size)
    let b = IMatrix(size)
    
    for i in 1..<size + 1 {
        try b.add(i, Double(i))
    }
    
    for i in 1..<size + 1 {
        var sum: Double = 0.0
        
        for j in 1..<size + 1 where j != i {
            let v = 0.001 * Double(i + 2 * j)
            try a.add(i, j, v)
            sum += abs(v)
        }
        
        let diag = sum + 1.0
        try a.add(i, i, diag)
    }
    
    return (a, b)
}
