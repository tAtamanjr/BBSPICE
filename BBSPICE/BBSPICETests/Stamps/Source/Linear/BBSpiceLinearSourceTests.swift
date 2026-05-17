//
//  BBSpiceLinearSourceTests.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceLinearSourceTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
 
    @MainActor func testDCCS() async throws {
        let stamps: [Stamp] = try [DCCS(0, 1, 5), R(1, 2, 5), R(2, 3, 5), R(2, 3, 5), R(3, 0, 5)]
        
        let G_Matrix: Matrix? = Matrix(3, 3)
        let I_Matrix: Matrix? = Matrix(3, 1)
        
        for stamp in stamps {
            try G_Matrix!.add(stamp.getGMatrix())
            try I_Matrix!.add(stamp.getIMatrix())
        }
        
        G_Matrix!.show()
        I_Matrix!.show()
        
        let VMatrix = try G_Matrix!.devide(I_Matrix)
        VMatrix!.show()
    }
    
    @MainActor func testDCVS() async throws {
        let stamps = try [DCVS(1, 0, 3, 5), R(1, 2, 5), R(2, 0, 5)]
        
        let G_Matrix: Matrix? = Matrix(3, 3)
        let I_Mtarix: Matrix? = Matrix(3, 1)
        
        for stamp in stamps {
            try G_Matrix!.add(stamp.getGMatrix())
            try I_Mtarix!.add(stamp.getIMatrix())
        }
        
        G_Matrix!.show()
        I_Mtarix!.show()
        
        let VMatrix = try G_Matrix!.devide(I_Mtarix)
        VMatrix!.show()
    }
    
    @MainActor func testVCCS() async throws {
        let stamps: [Stamp] = try [DCVS(1, 0, 3, 5), VCCS(1, 0, 2, 0, 2), R(2, 0, 5)]
        
        let Gmatrix: Matrix? = GMatrix(3)
        let Imatrix: Matrix? = IMatrix(3)
        
        for stamp in stamps {
            try Gmatrix!.add(stamp.getGMatrix())
            try Imatrix!.add(stamp.getIMatrix())
        }
        
        Gmatrix!.show()
        Imatrix!.show()
        
        let VMatrix = try Gmatrix!.devide(Imatrix)
        VMatrix!.show()
    }
    
    @MainActor func testCCCS() async throws {
        let stamps: [Stamp] = try [DCCS(1, 0, 5), CCCS(1, 0, 2, 0, 3, 2), R(2, 0, 5)]
        
        let Gmatrix: Matrix? = GMatrix(3)
        let Imatrix: Matrix? = IMatrix(3)
        
        for stamp in stamps {
            try Gmatrix!.add(stamp.getGMatrix())
            try Imatrix!.add(stamp.getIMatrix())
        }
        
        Gmatrix!.show()
        Imatrix!.show()
        
        let VMatrix = try Gmatrix!.devide(Imatrix)
        VMatrix!.show()
    }
    
    @MainActor func testVCVS() async throws {
        let stamps: [Stamp] = try [DCVS(1, 0, 3, 5), VCVS(1, 0, 2, 0, 4, 2), R(2, 0, 5)]
        
        let Gmatrix: Matrix? = GMatrix(4)
        let Imatrix: Matrix? = IMatrix(4)
        
        for stamp in stamps {
            try Gmatrix!.add(stamp.getGMatrix())
            try Imatrix!.add(stamp.getIMatrix())
        }
        
        Gmatrix!.show()
        Imatrix!.show()
        
        let VMatrix = try Gmatrix!.devide(Imatrix)
        VMatrix!.show()
    }
    
    @MainActor func testCCVS() async throws {
        let stamps: [Stamp] = try [DCCS(1, 0, 5), CCVS(1, 0, 2, 0, 3, 4, 2), R(2, 0, 5)]
        
        let Gmatrix: Matrix? = GMatrix(4)
        let Imatrix: Matrix? = IMatrix(4)
        
        for stamp in stamps {
            try Gmatrix!.add(stamp.getGMatrix())
            try Imatrix!.add(stamp.getIMatrix())
        }
        
        Gmatrix!.show()
        Imatrix!.show()
        
        let VMatrix = try Gmatrix!.devide(Imatrix)
        VMatrix!.show()
    }
    
}
