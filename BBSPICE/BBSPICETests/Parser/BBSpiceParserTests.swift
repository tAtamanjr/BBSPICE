//
//  BBSpiceParserTests.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import XCTest
@testable import BBSPICE

final class BBSpiceParserTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testAllElementsFromTXT() throws {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("AllElementsCircuit.txt")
        let result = try Parser().parse(url)
        let stamps = result.stamps
        
        XCTAssertEqual(result.command, .op)
        XCTAssert(stamps.count == 9)
        XCTAssert(stamps[0] is R)
        XCTAssert(stamps[1] is C)
        XCTAssert(stamps[2] is DCCS)
        XCTAssert(stamps[3] is DCVS)
        XCTAssert(stamps[4] is ACVS)
        XCTAssert(stamps[5] is VCCS)
        XCTAssert(stamps[6] is VCVS)
        XCTAssert(stamps[7] is CCCS)
        XCTAssert(stamps[8] is CCVS)
        
        let resistor = stamps[0] as? R
        XCTAssert(resistor?.resistance == 10)
        
        let capacitor = stamps[1] as? C
        XCTAssert(capacitor?.capacitance == 0.001)
        
        let currentSource = stamps[2] as? DCCS
        XCTAssert(currentSource?.current == 2)
        
        let voltageSource = stamps[3] as? DCVS
        XCTAssert(voltageSource?.amplitude == 5)
        XCTAssert(voltageSource?.newRow == 7)
        
        let ACVoltageSource = stamps[4] as? ACVS
        XCTAssert(ACVoltageSource?.amplitude == 10)
        XCTAssert(ACVoltageSource?.frequency == 50)
        XCTAssert(ACVoltageSource?.newRow == 8)
        
        let voltageControlledCurrentSource = stamps[5] as? VCCS
        XCTAssert(voltageControlledCurrentSource?.transconductance == 0.5)
        
        let voltageControlledVoltageSource = stamps[6] as? VCVS
        XCTAssert(voltageControlledVoltageSource?.gain == 2)
        XCTAssert(voltageControlledVoltageSource?.newRow == 9)
        
        let currentControlledCurrentSource = stamps[7] as? CCCS
        XCTAssert(currentControlledCurrentSource?.gain == 3)
        XCTAssert(currentControlledCurrentSource?.inputVoltage == 1)
        XCTAssert(currentControlledCurrentSource?.newRow == 10)
        
        let currentControlledVoltageSource = stamps[8] as? CCVS
        XCTAssert(currentControlledVoltageSource?.transresistance == 4)
        XCTAssert(currentControlledVoltageSource?.inputVoltage == 1)
        XCTAssert(currentControlledVoltageSource?.newRow == 11)
        XCTAssert(currentControlledVoltageSource?.newRow2 == 12)
    }
    
    func testParserErrors() throws {
        XCTAssertThrowsError(try Parser().parse(makeTestFile("X 1 2 5\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .unknownElement(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParametersCount(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 two 5\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParameterType(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R -1 2 5\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongStampParameters(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("C 1 2 0\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongStampParameters(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("ACVS 1 0 5 0\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongStampParameters(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("ACVS 1 0 5\n.op"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParametersCount(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5"))) { err in
            XCTAssertEqual(err as? ParserError, .missingCommand)
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.op\n.tran 1 0.1"))) { err in
            XCTAssertEqual(err as? ParserError, .multipleCommands(3))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.tran 1"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParametersCount(2))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.tran 1 0"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongStampParameters(2))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.tran one 0.1"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParameterType(2))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.op\n.show 1"))) { err in
            XCTAssertEqual(err as? ParserError, .showWithoutTransient(3))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.tran 1 0.1\n.show 1\n.show 2"))) { err in
            XCTAssertEqual(err as? ParserError, .multipleShowCommands(4))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2 5\n.tran 1 0.1\n.show two"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParameterType(3))
        }
    }
    
    func testTransientCommand() throws {
        let result = try Parser().parse(makeTestFile("R 1 2 5\n.tran 1 0.1\n.show 1 2"))
        
        XCTAssertEqual(result.command, .tran(time: 1, timeStep: 0.1))
        XCTAssertEqual(result.showNodes, [1, 2])
        XCTAssert(result.stamps.count == 1)
        XCTAssert(result.stamps[0] is R)
    }

}

private func makeTestFile(_ text: String) throws -> URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("txt")
    try text.write(to: url, atomically: true, encoding: .utf8)
    return url
}
