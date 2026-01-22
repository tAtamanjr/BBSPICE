//
//  CurrentSource.swift
//  BBSPICETests
//
//  Created by Oleksandr Bolbat on 19.01.2026.
//

import Foundation


class CurrentSource : TwoNodeStamp {
    let current: Double
    
    init(_ nodeS: Int, _ nodeE: Int, _ current: Double) {
        self.current = current
        super.init(nodeS, nodeE)
    }
}
