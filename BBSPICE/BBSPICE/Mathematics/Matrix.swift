//
//  Matrix.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 28.01.2026.
//

import Foundation
import Accelerate

class Matrix {
    let id: UUID
    let rows: Int
    let columns: Int
    var values: [Double]

    init(_ rows: Int, _ columns: Int) {
        self.id = UUID()
        self.rows = rows
        self.columns = columns
        self.values = Array(repeating: 0.0, count: rows * columns)
//        print("Matrix created, rows: \(self.rows), columns: \(self.columns), id: \(self.id)")
    }
    
//    deinit {
//        print("Matrix deleted, rows: \(self.rows), columns: \(self.columns), id: \(self.id)")
//    }
    
    func show() {
        var matrix = "Matrix rows: \(self.rows), columns: \(self.columns), id: \(self.id): ["
        for i in 0..<values.count {
            if i % columns == 0 {
                matrix += "\n\t"
            }
            matrix += "\(values[i])"
            i != values.count - 1 ? (matrix += ", ") : (matrix += "\n]")
        }
        print(matrix)
    }

    func add(_ row: Int, _ column: Int, _ value: Double) throws {
        if row > rows || column > columns { throw MatrixError.indexOutOfBounds(row, column, id) }
        if row == 0 || column == 0 || value == 0 { return }
        values[columns * (row - 1) + (column - 1)] += value
    }

    func add(_ row: Int, _ value: Double) throws {
        if row > rows { throw MatrixError.indexOutOfBounds(row, 1, id) }
        if row == 0 || value == 0 { return }
        values[row - 1] += value
    }
    
    func add(_ matrix: Matrix?) throws {
        if matrix == nil { return }
        if matrix!.rows > rows || matrix!.columns > columns { throw MatrixError.biggerMatrixToAdd(id, matrix!.id) }
        for i in 0..<matrix!.values.count {
            if matrix!.values[i] != 0 {
                values[columns * Int(i / matrix!.columns) + i % matrix!.columns] += matrix!.values[i]
            }
        }
    }

    func devide(_ matrix: Matrix?) throws -> Matrix? {
        if matrix == nil {
            throw MatrixError.matrixIsNil(id)
        }
        if self.rows != self.columns || matrix!.rows != self.rows || matrix!.columns != 1 {
            throw MatrixError.wrongDimensions(id, rows, columns, matrix!.id, matrix!.rows, matrix!.columns)
        }

        if self.rows > Int(Int32.max) {
            throw MatrixError.toBigMatrix(id, matrix!.id, rows)
        }
            
        var a = Array(repeating: 0.0, count: rows * columns)
        for r in 0..<rows {
                for c in 0..<columns {
                    a[c * rows + r] = self.values[r * columns + c]
                }
            }
        var copy = matrix!.values

        var n: __LAPACK_int = __LAPACK_int(self.rows)
        var nrhs: __LAPACK_int = 1
        var lda = n
        var ldb = n
        var ipiv = [__LAPACK_int](repeating: 0, count: Int(n))
        var info: __LAPACK_int = 0

        dgesv_(&n, &nrhs, &a, &lda, &ipiv, &copy, &ldb, &info)

        if info != 0 {
            throw MatrixError.divisionError(id, matrix!.id)
        }
            
        return VMatrix(copy)
    }
}

class GMatrix : Matrix {
    init(_ size: Int) { super.init(size, size) }
}

class IMatrix : Matrix {
    init(_ size: Int) { super.init(size, 1) }
}

class VMatrix : Matrix {
    init(_ values: [Double]) {
        super.init(values.count, 1)
        self.values = values
    }
}

enum MatrixError : Error, Equatable, CustomStringConvertible {
    case indexOutOfBounds(_ row: Int, _ column: Int, _ id: UUID)
    case biggerMatrixToAdd(_ id1: UUID, _ id2: UUID)
    case matrixIsNil(_ id: UUID)
    case wrongDimensions(_ id1: UUID, _ rows1: Int, _ columns1: Int, _ id2: UUID, _ rows2: Int, _ columns2: Int)
    case toBigMatrix(_ id1: UUID, _ id2: UUID, _ rows: Int)
    case divisionError(_ id1: UUID, _ id2: UUID)

    var description: String {
        switch self {
        case let .indexOutOfBounds(row, column, id):
            return "Index out of bounds: \(row)x\(column) for matrix id: \(id)"
        case let .biggerMatrixToAdd(id1, id2):
            return "Matrix id: \(id1) is smaller than matrix id: \(id2)"
        case let .matrixIsNil(id):
            return "Matrix: \(id) got nil for division"
        case let .wrongDimensions(id1, rows1, columns1, id2, rows2, columns2):
            return "Matrix: \(id1) of size \(rows1)x\(rows2) got matrix: \(id2) of size \(columns1)x\(columns2) for division"
        case let .toBigMatrix(id1, id2, rows):
            return "Matrix: \(id1) and matrix \(id2) are to big(rows: \(rows)), cannot devide"
        case let .divisionError(id1, id2):
            return "Matrix: \(id1) and matrix \(id2) cannot be devided"
        }
    }
}
