//
//  BBSpiceLUDivisionTests.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 07.03.2026.
//

import XCTest
@testable import BBSPICE


final class BBSpiceLUDivisionTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    @MainActor func testLUDivision() async throws {
        var G: [Double] = [3.0, 2.0, -1.0, 2.0, -2.0, 4.0, -1.0, 0.5, -1.0]
        var I: [Double] = [1.0, -2.0, 0.0]
        let size: Int = 3
        
        var V: [Double] = LU_Division(G, &I, size)
        
        print(V)
        
        G = [0.0, 2.0, 1.0, 1.0, -2.0, -3.0, 2.0, 1.0, 1.0]
        I = [3.0, -4.0, 5.0]
        
        V = LU_Division(G, &I, size)
        
        print(V)
    }
    
    @MainActor func testSpeed_100() async throws {
        let size = 100
        var (G, I) = try makeSystemForDivisionTest(size)
        for _ in 0..<3 {
            _ = LU_Division(G, &I, size)
        }
        measure(metrics: [XCTClockMetric()]) {
            _ = LU_Division(G, &I, size)
        }
    }
    
}

private func makeSystemForDivisionTest(_ size: Int) throws -> (G: [Double], I: [Double]) {
    var G = Array<Double>(repeating: 0.0, count: size * size)
    var I = Array<Double>(repeating: 0.0, count: size)

    for i in 0..<size {
        G[i * size + i] = Double(i + 1)
        I[i] = Double(i + 1)
    }

    return (G, I)
}
