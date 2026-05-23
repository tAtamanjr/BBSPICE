//
//  SolverCommand.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 18.05.2026.
//

import Foundation


nonisolated enum SolverCommand: Equatable {
    case op
    case tran(time: Double, timeStep: Double)
}
