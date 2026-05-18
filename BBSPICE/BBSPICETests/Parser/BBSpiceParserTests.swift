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
        let stamps = try Parser().parse(url)
        
        XCTAssert(stamps.count == 7)
        XCTAssert(stamps[0] is R)
        XCTAssert(stamps[1] is DCCS)
        XCTAssert(stamps[2] is DCVS)
        XCTAssert(stamps[3] is VCCS)
        XCTAssert(stamps[4] is VCVS)
        XCTAssert(stamps[5] is CCCS)
        XCTAssert(stamps[6] is CCVS)
        
        let resistor = stamps[0] as? R
        XCTAssert(resistor?.resistance == 10)
        
        let currentSource = stamps[1] as? DCCS
        XCTAssert(currentSource?.current == 2)
        
        let voltageSource = stamps[2] as? DCVS
        XCTAssert(voltageSource?.amplitude == 5)
        XCTAssert(voltageSource?.newRow == 7)
        
        let voltageControlledCurrentSource = stamps[3] as? VCCS
        XCTAssert(voltageControlledCurrentSource?.transconductance == 0.5)
        
        let voltageControlledVoltageSource = stamps[4] as? VCVS
        XCTAssert(voltageControlledVoltageSource?.gain == 2)
        XCTAssert(voltageControlledVoltageSource?.newRow == 8)
        
        let currentControlledCurrentSource = stamps[5] as? CCCS
        XCTAssert(currentControlledCurrentSource?.gain == 3)
        XCTAssert(currentControlledCurrentSource?.inputVoltage == 1)
        XCTAssert(currentControlledCurrentSource?.newRow == 9)
        
        let currentControlledVoltageSource = stamps[6] as? CCVS
        XCTAssert(currentControlledVoltageSource?.transresistance == 4)
        XCTAssert(currentControlledVoltageSource?.inputVoltage == 1)
        XCTAssert(currentControlledVoltageSource?.newRow == 10)
        XCTAssert(currentControlledVoltageSource?.newRow2 == 11)
    }
    
    func testParserErrors() throws {
        XCTAssertThrowsError(try Parser().parse(makeTestFile("X 1 2 5"))) { err in
            XCTAssertEqual(err as? ParserError, .unknownElement(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 2"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParametersCount(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R 1 two 5"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongParameterType(1))
        }
        XCTAssertThrowsError(try Parser().parse(makeTestFile("R -1 2 5"))) { err in
            XCTAssertEqual(err as? ParserError, .wrongStampParameters(1))
        }
    }

}

private func makeTestFile(_ text: String) throws -> URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("txt")
    try text.write(to: url, atomically: true, encoding: .utf8)
    return url
}
