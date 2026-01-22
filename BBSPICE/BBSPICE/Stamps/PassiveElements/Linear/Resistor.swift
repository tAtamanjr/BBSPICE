//
//  Resistor.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.01.2026.
//

import Foundation


class R : TwoNodeStamp {
    let resistance: Double
    
    init(_ nodeS: Int, _ nodeE: Int, _ resistance: Double) throws {
        if resistance < 0 { throw ResistorError.resistanceLessThanZero(nodeS, nodeE, resistance) }
        self.resistance = resistance
        super.init(nodeS, nodeE)
    }
    
    override func getGMatrix() throws -> Matrix? {
        let temp = Matrix(max(nodeS, nodeE), max(nodeS, nodeE))
        
        try temp.add(nodeS, nodeS, 1 / resistance)
        try temp.add(nodeS, nodeE, -1 / resistance)
        try temp.add(nodeE, nodeS, -1 / resistance)
        try temp.add(nodeE, nodeE, 1 / resistance)
        
        return temp
    }
}

enum ResistorError : Error, Equatable, CustomStringConvertible {
    case resistanceLessThanZero(_ nodeS: Int, _ nodeE: Int, _ resistance: Double)
    
    var description: String {
        switch self {
        case let .resistanceLessThanZero(nodeS, nodeE, resistance):
            return "Resistor between nodes \(nodeS) and \(nodeE) has resistance: \(resistance)"
        }
    }
}
