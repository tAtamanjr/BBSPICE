//
//  ElementsFromTXT.swift
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 22.01.2026.
//

import Foundation


struct ElementsFromTXT {
    func get(_ txtFile: URL) throws -> [[String]] {
        let data: String
        do {
            data = try String(contentsOf: txtFile, encoding: .utf8)
        } catch { throw FileReadError.noSuchFile(txtFile) }
        if data.isEmpty { throw FileReadError.emptyFile(txtFile) }
        
        var result: [[String]] = []
        for raw in data.split(whereSeparator: \.isNewline) {
            var line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty || line.hasPrefix("*") { continue }
//            result += line
        }
        
        return result
    }
}

let elementsFromTxt: ElementsFromTXT = ElementsFromTXT()

enum FileReadError : Error, Equatable, CustomStringConvertible {
    case noSuchFile(_ txtFileName: URL)
    case emptyFile(_ txtFileName: URL)
    
    var description: String {
        switch self {
        case let .noSuchFile(txtFileName):
            return "There no such file: \(txtFileName)"
        case let .empty(txtFileName):
            return "File: \(txtFileName) is empty"
        }
    }
}
