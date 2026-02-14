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
        var resistor = try R(1, 2, 3.0)
        XCTAssert(resistor.nodeS == 1)
        XCTAssert(resistor.nodeE == 2)
        XCTAssert(resistor.resistance == 3.0)
        
        XCTAssertThrowsError(try resistor = R(1, 2, -3.0)) { err in
            XCTAssertEqual(err as? ResistorError, .negativeResistance(1, 2, -3.0))
        }
        
        resistor = try R(["R", "1", "2", "3.0"])
        XCTAssert(resistor.nodeS == 1)
        XCTAssert(resistor.nodeE == 2)
        XCTAssert(resistor.resistance == 3.0)
        
        XCTAssertThrowsError(try resistor = R([])) { err in
            XCTAssertEqual(err as? ResistorError, .wrongDescription(0))
        }
        XCTAssertThrowsError(try resistor = R(["", "1", "2", "3.0"])) { err in
            XCTAssertEqual(err as? ResistorError, .wrongDescription(0))
        }
        XCTAssertThrowsError(try resistor = R(["R", "l", "2", "3.0"])) { err in
            XCTAssertEqual(err as? ResistorError, .wrongDescription(1))
        }
        XCTAssertThrowsError(try resistor = R(["R", "1", "2", "l.0"])) { err in
            XCTAssertEqual(err as? ResistorError, .wrongDescription(1))
        }
        XCTAssertThrowsError(try resistor = R(["R", "1", "2", "-3.0"])) { err in
            XCTAssertEqual(err as? ResistorError, .negativeResistance(1, 2, -3.0))
        }
        
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
