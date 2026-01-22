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
        let url = URL(string: "file:///Users/tataman/Documents/Xcode/BBSPICE/BBSPICE/BBSPICETests/Parser/SimpleCircuit.txt")
        try elementsFromTxt.get(url!)
    }

}
