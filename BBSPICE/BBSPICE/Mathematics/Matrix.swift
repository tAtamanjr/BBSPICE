//
//  Matrix.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.01.2026.
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
        print("Matrix created, rows: \(self.rows), columns: \(self.columns), id: \(self.id)")
    }
    
    deinit {
        print("Matrix deleted, rows: \(self.rows), columns: \(self.columns), id: \(self.id)")
    }
    
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
    
//    func devide(_ matrix: Matrix?) throws -> Matrix? {
//        if matrix == nil {
//            throw MatrixError.matrixIsNil(id)
//        }
//        if self.rows != self.columns || matrix!.rows != self.rows || matrix!.columns != 1 {
//            throw MatrixError.wrongDimensions(id, rows, columns, matrix!.id, matrix!.rows, matrix!.columns)
//        }
//
//        if self.rows > Int(Int32.max) {
//            throw MatrixError.toBigMatrix(id, matrix!.id, rows)
//        }
//        
//        var a = Array(repeating: 0.0, count: rows * columns)
//        for r in 0..<rows {
//                for c in 0..<columns {
//                    a[c * rows + r] = self.values[r * columns + c]
//                }
//            }
//        var copy = matrix!.values
//
//        var n: Int32 = Int32(self.rows)
//        var nrhs: Int32 = 1
//        var lda: Int32 = n
//        var ldb: Int32 = n
//        var ipiv = [Int32](repeating: 0, count: Int(n))
//        var info: Int32 = 0
//
//        a.withUnsafeMutableBufferPointer { aBuff in
//            copy.withUnsafeMutableBufferPointer { copyBuff in
//                ipiv.withUnsafeMutableBufferPointer { ipivBuff in
//                    dgesv_(&n, &nrhs, aBuff.baseAddress!, &lda, ipivBuff.baseAddress!, copyBuff.baseAddress!, &ldb, &info)
//                }
//            }
//        }
////        dgesv_(&n, &nrhs, &a, &lda, &ipiv, &copy, &ldb, &info)
//
//        if info != 0 {
//            throw MatrixError.divisionError(id, matrix!.id)
//        }
//        
////        let result = IMatrix(self.rows)
////        result.values = copy
//        return VMatrix(copy)
//        
////        var n: __LAPACK_int = __LAPACK_int(rows)
////        var nrhs: __LAPACK_int = 1
////        var lda: __LAPACK_int = n
////        var ldb: __LAPACK_int = n
////        var ipiv = [__LAPACK_int](repeating: 0, count: rows)
////        var info: __LAPACK_int = 0
////        
////        a.withUnsafeMutableBufferPointer { aBuf in
////            copy.withUnsafeMutableBufferPointer { bBuf in
////                ipiv.withUnsafeMutableBufferPointer { pBuf in
////                    __CLPK_dgesv(
////                        &n, &nrhs,
////                        aBuf.baseAddress!, &lda,
////                        pBuf.baseAddress!,
////                        bBuf.baseAddress!, &ldb,
////                        &info
////                    )
////                }
////            }
////        }
////        
////        if info != 0 {
////                throw MatrixError.divisionError(id, matrix!.id)
////            }
////
////            let result = IMatrix(self.rows)
////            result.values = copy
////            return result
//    }
    
    func devide(_ matrix: Matrix?) throws -> Matrix? {
        guard let matrix else { throw MatrixError.matrixIsNil(id) }
        if self.rows != self.columns || matrix.rows != self.rows || matrix.columns != 1 {
            throw MatrixError.wrongDimensions(id, rows, columns, matrix.id, matrix.rows, matrix.columns)
        }
        
        let n = self.rows
        let aLocal = self.values           // row-major n*n
        let bLocal = matrix.values         // length n (n x 1)
        
        precondition(aLocal.count == n * n)
        precondition(bLocal.count == n)
        
        var output = [Double](repeating: 0.0, count: n)
        var solveError: Error?
        
        aLocal.withUnsafeBufferPointer { aBuf in
            bLocal.withUnsafeBufferPointer { bBuf in
                // A: n x n, row-major, stride = n
                let A = la_matrix_from_double_buffer(
                    aBuf.baseAddress!, la_count_t(n), la_count_t(n),
                    la_count_t(n),
                    la_hint_t(LA_NO_HINT),
                    la_attribute_t(LA_DEFAULT_ATTRIBUTES)
                )
                
                // b: n x 1, row-major, stride = 1
                let B = la_matrix_from_double_buffer(
                    bBuf.baseAddress!, la_count_t(n), la_count_t(1),
                    la_count_t(1),
                    la_hint_t(LA_NO_HINT),
                    la_attribute_t(LA_DEFAULT_ATTRIBUTES)
                )
                
                let X = la_solve(A, B)
                if la_status(X) != LA_SUCCESS {
                    solveError = MatrixError.divisionError(self.id, matrix.id)
                    return
                }
                
                output.withUnsafeMutableBufferPointer { outBuf in
                    la_matrix_to_double_buffer(outBuf.baseAddress!, la_count_t(1), X)
                }
            }
        }
        
        if let err = solveError { throw err }
        
        let result = IMatrix(n)
        result.values = output
        return result
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
