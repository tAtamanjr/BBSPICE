import Foundation

struct ReferenceCSV: Equatable {
    let columns: [String]
    let rows: [[Double]]
    
    var rowCount: Int {
        rows.count
    }
    
    func values(_ column: String) -> [Double]? {
        guard let index = columns.firstIndex(of: column) else { return nil }
        return rows.map { $0[index] }
    }
    
    func value(_ row: Int, _ column: String) -> Double? {
        guard rows.indices.contains(row),
              let columnIndex = columns.firstIndex(of: column) else {
            return nil
        }
        
        return rows[row][columnIndex]
    }
}

struct ReferenceCSVReader {
    func read(_ url: URL) throws -> ReferenceCSV {
        let text = try String(contentsOf: url, encoding: .utf8)
        return try readText(text)
    }
    
    func readText(_ text: String) throws -> ReferenceCSV {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard let header = lines.first else { throw ReferenceCSVReaderError.emptyFile }
        
        let columns = header.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if columns.contains(where: { $0.isEmpty }) { throw ReferenceCSVReaderError.emptyHeader }
        
        var rows: [[Double]] = []
        
        for (index, line) in lines.dropFirst().enumerated() {
            let lineNumber = index + 2
            let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            
            if values.count != columns.count {
                throw ReferenceCSVReaderError.wrongColumnsCount(lineNumber)
            }
            
            rows.append(try values.enumerated().map { valueIndex, value in
                guard let number = Double(value) else {
                    throw ReferenceCSVReaderError.wrongValue(lineNumber, columns[valueIndex])
                }
                
                return number
            })
        }
        
        return ReferenceCSV(columns: columns, rows: rows)
    }
}

enum ReferenceCSVReaderError: Error, Equatable {
    case emptyFile
    case emptyHeader
    case wrongColumnsCount(Int)
    case wrongValue(Int, String)
}
