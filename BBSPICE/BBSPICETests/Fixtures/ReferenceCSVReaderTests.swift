import XCTest
@testable import BBSPICE

final class ReferenceCSVReaderTests: XCTestCase {
    
    func testReadOperationPointReference() throws {
        let reference = try ReferenceCSVReader().read(referenceURL("VoltageDivider"))
        
        XCTAssertEqual(reference.columns, ["V(1)", "V(2)"])
        XCTAssertEqual(reference.rowCount, 1)
        XCTAssertEqual(reference.value(0, "V(1)"), 5)
        XCTAssertEqual(reference.value(0, "V(2)"), 2.5)
        XCTAssertEqual(reference.values("V(1)"), [5])
    }
    
    func testReadTransientReference() throws {
        let reference = try ReferenceCSVReader().read(referenceURL("ACSourceResistor"))
        
        XCTAssertEqual(reference.columns, ["time", "V(1)"])
        XCTAssertEqual(reference.rowCount, 5)
        XCTAssertEqual(reference.values("time"), [0, 0.00025, 0.0005, 0.00075, 0.001])
        XCTAssertEqual(reference.values("V(1)"), [0, 10, 0, -10, 0])
    }
    
    func testReaderErrors() throws {
        XCTAssertThrowsError(try ReferenceCSVReader().readText("")) { error in
            XCTAssertEqual(error as? ReferenceCSVReaderError, .emptyFile)
        }
        
        XCTAssertThrowsError(try ReferenceCSVReader().readText("time,\n0,1")) { error in
            XCTAssertEqual(error as? ReferenceCSVReaderError, .emptyHeader)
        }
        
        XCTAssertThrowsError(try ReferenceCSVReader().readText("time,V(1)\n0")) { error in
            XCTAssertEqual(error as? ReferenceCSVReaderError, .wrongColumnsCount(2))
        }
        
        XCTAssertThrowsError(try ReferenceCSVReader().readText("time,V(1)\n0,error")) { error in
            XCTAssertEqual(error as? ReferenceCSVReaderError, .wrongValue(2, "V(1)"))
        }
    }
    
    private func referenceURL(_ name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("ReferenceResults")
            .appendingPathComponent(name)
            .appendingPathExtension("csv")
    }
}
