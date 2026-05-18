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

    func testElementsFromTXT() throws {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("SimpleCircuit.txt")
        let stamps = try Parser().parse(url)
        
        XCTAssert(stamps.count == 5)
        XCTAssert(stamps[0] is R)
        XCTAssert(stamps[1] is R)
        XCTAssert(stamps[2] is R)
        XCTAssert(stamps[3] is R)
        XCTAssert(stamps[4] is DCCS)
        
        let resistor = stamps[0] as? R
        XCTAssert(resistor?.nodeS == 1)
        XCTAssert(resistor?.nodeE == 2)
        XCTAssert(resistor?.resistance == 5)
        
        let currentSource = stamps[4] as? DCCS
        XCTAssert(currentSource?.nodeS == 0)
        XCTAssert(currentSource?.nodeE == 1)
        XCTAssert(currentSource?.current == 5)
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
