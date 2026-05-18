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
        print("Stamp created, id: \(self.id)")
    }
    
    deinit {
        print("Stamp deleted, id: \(self.id)")
    }
    
    func getGMatrix() throws -> Matrix? {
        return nil
    }
    
    func getIMatrix() throws -> Matrix? {
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
