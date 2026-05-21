//
//  DCCurrentSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 20.01.2026.
//

import Foundation


class DCCS : CurrentSource {
    override func getIMatrix(_ h: Double = 0.0, _ v: Double = 0.0) throws -> Matrix? {
        let temp = IMatrix(max(nodeS, nodeE))
        
        try temp.add(nodeS, -current)
        try temp.add(nodeE, current)
        
        return temp
    }
}
