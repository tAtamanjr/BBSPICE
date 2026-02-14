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
        if resistance < 0 { throw ResistorError.negativeResistance(nodeS, nodeE, resistance) }
        self.resistance = resistance
        super.init(nodeS, nodeE)
    }
    
    init(_ description: [String]) throws {
        if description.isEmpty || description[0] != "R" { throw ResistorError.wrongDescription(0) }
        let (s, e, r) = (Int(description[1]), Int(description[2]), Double(description[3]))
        if s == nil || e == nil || r == nil { throw ResistorError.wrongDescription(1) }
        if r! < 0 { throw ResistorError.negativeResistance(s!, e!, r!) }
        self.resistance = r!
        super.init(s!, e!)
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
    case wrongDescription(_ corrupsion: Int)
    case negativeResistance(_ nodeS: Int, _ nodeE: Int, _ resistance: Double)
    
    var description: String {
        switch self {
        case let .wrongDescription(corruption):
            return corruption == 0 ? "Description of wrong element" : "Wrong parameters for resistor"
        case let .negativeResistance(nodeS, nodeE, resistance):
            return "Resistor between nodes \(nodeS) and \(nodeE) has negative resistance: \(resistance)"
        }
    }
}
