//
//  LU.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 06.03.2026.
//

import Foundation


#if canImport(LU)
import LU
#else
@_silgen_name("LU_Decomposition")
func LU_Decomposition(_ LU: UnsafeMutablePointer<Double>?, _ size: Int, _ permutation: UnsafeMutablePointer<UInt>?) -> Int32
@_silgen_name("LU_Solve")
func LU_Solve(_ LU: UnsafeMutablePointer<Double>?, _ size: Int, _ permutation: UnsafeMutablePointer<UInt>?,
              _ I: UnsafeMutablePointer<Double>?, _ V: UnsafeMutablePointer<Double>?, _ buffer: UnsafeMutablePointer<Double>?) -> Int32
#endif



func LU_Division(_ G: [Double], _ I: inout [Double], _ size: Int) -> [Double] {
    var LU = G
    var permutation = Array<UInt>(repeating: 0, count: size)
    var buffer = Array<Double>(repeating: 0.0, count: size)
    var V = Array<Double>(repeating: 0.0, count: size)
    
    let err1 = LU.withUnsafeMutableBufferPointer { LU_Ptr -> Int32 in
        permutation.withUnsafeMutableBufferPointer { PermutationPtr -> Int32 in
            return Int32(LU_Decomposition(LU_Ptr.baseAddress, size, PermutationPtr.baseAddress))
        }
    }
    
    precondition(err1 == 0, "LU_Decomposition Failed")
    
    let err2 = LU.withUnsafeMutableBufferPointer { LU_Ptr -> Int32 in
        permutation.withUnsafeMutableBufferPointer { PermutationPtr -> Int32 in
            V.withUnsafeMutableBufferPointer { V_Ptr -> Int32 in
                I.withUnsafeMutableBufferPointer { I_Ptr -> Int32 in
                    buffer.withUnsafeMutableBufferPointer { BufferPtr -> Int32 in
                        return Int32(LU_Solve(LU_Ptr.baseAddress, size, PermutationPtr.baseAddress,
                                              I_Ptr.baseAddress, V_Ptr.baseAddress, BufferPtr.baseAddress))
                    }
                }
            }
        }
    }
    
    precondition(err2 == 0, "LU_Solve Failed")
    
    return V
}
