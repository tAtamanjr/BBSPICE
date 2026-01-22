//
//  DCVoltageSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 20.01.2026.
//

import Foundation


class DCVS : VoltageSource {
    override func getGMatrix() throws -> Matrix?  {
        let temp = GMatrix(newRow)
        
        try temp.add(nodeS, newRow, 1)
        try temp.add(nodeE, newRow, -1)
        try temp.add(newRow, nodeE, -1)
        try temp.add(newRow, nodeS, 1)
        
        return temp
    }
    
    override func getIMatrix() throws -> Matrix? {
        let temp = IMatrix(newRow)
        
        try temp.add(newRow, amplitude)
        
        return temp
    }
}
