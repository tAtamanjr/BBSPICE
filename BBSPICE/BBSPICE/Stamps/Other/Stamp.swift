//
//  Stamp.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 30.12.2025.
//

import Foundation


class Stamp {
    let id: UUID
    
    init() {
        self.id = UUID()
    }
    
    func getGMatrix(_ h: Double = 0.0, _ v: Double = 0.0) throws -> Matrix? {
        return nil
    }
    
    func getIMatrix(_ h: Double = 0.0, _ v: Double = 0.0) throws -> Matrix? {
        return nil
    }
}

enum StampParameterError : Error, Equatable, CustomStringConvertible {
    case negativeNodeIndex
    case parameterError
    case programFail
    
    var description: String {
        switch self {
        case .negativeNodeIndex:
            return "Stamp: Negative node index"
        case .parameterError:
            return "Stamp: Parameters error"
        case .programFail:
            return "Stamp: Program failed"
        }
    }
}
