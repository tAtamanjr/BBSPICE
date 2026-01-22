//
//  TwoNodeStamp.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.01.2026.
//

import Foundation


class TwoNodeStamp : Stamp {
    let nodeS: Int
    let nodeE: Int
    
    init(_ nodeS: Int, _ nodeE: Int) {
        self.nodeS = nodeS
        self.nodeE = nodeE
        super.init()
    }
}
