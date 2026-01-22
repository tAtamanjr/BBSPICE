//
//  BBSpiceLinearPassiveElementsTests.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceLinearPassiveElementsTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    @MainActor func testResistor() async throws {
        var stamps: [Stamp] = try [DCCS(0, 1, 5), R(1, 2, 5), R(2, 3, 5), R(2, 3, 5), R(3, 0, 5)]
        
        var GMatrix: Matrix? = Matrix(3, 3)
        var IMatrix: Matrix? = Matrix(3, 1)
        
        for stamp in stamps {
            try GMatrix!.add(stamp.getGMatrix())
            try IMatrix!.add(stamp.getIMatrix())
        }
        
        GMatrix!.show()
        IMatrix!.show()
        
        var VMatrix = try GMatrix!.devide(IMatrix)
        VMatrix!.show()
        
        stamps = try [DCVS(1, 0, 3, 5), R(1, 2, 5), R(2, 0, 5)]
        
        GMatrix = Matrix(3, 3)
        IMatrix = Matrix(3, 1)
        
        for stamp in stamps {
            try GMatrix!.add(stamp.getGMatrix())
            try IMatrix!.add(stamp.getIMatrix())
        }
        
        GMatrix!.show()
        IMatrix!.show()
        
        VMatrix = try GMatrix!.devide(IMatrix)
        VMatrix!.show()
    }
    
}
