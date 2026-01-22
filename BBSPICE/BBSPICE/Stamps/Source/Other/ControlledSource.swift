//
//  ControlledSource.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.01.2026.
//

import Foundation


class ControlledSource : Stamp {
    let nodeWeP: Int
    let nodeWeM: Int
    let nodeWyP: Int
    let nodeWyM: Int
    
    init(_ nodeWeP: Int, _ nodeWeM: Int, _ nodeWyP: Int, _ nodeWyM: Int) {
        self.nodeWeP = nodeWeP
        self.nodeWeM = nodeWeM
        self.nodeWyP = nodeWyP
        self.nodeWyM = nodeWyM
        super.init()
    }
}
