//
//  ThreeNodeStamp.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 21.05.2026.
//

import Foundation

class ThreeNodeStamp : Stamp {
    let node1: Int
    let node2: Int
    let node3: Int
    
    init(_ node1: Int, _ node2: Int, _ node3: Int) throws {
        if node1 < 0 || node2 < 0 || node3 < 0 { throw StampParameterError.negativeNodeIndex }
        self.node1 = node1
        self.node2 = node2
        self.node3 = node3
        super.init()
    }
}
