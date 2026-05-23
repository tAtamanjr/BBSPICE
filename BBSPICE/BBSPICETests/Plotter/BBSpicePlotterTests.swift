import XCTest
@testable import BBSPICE

final class BBSpicePlotterTests: XCTestCase {
    
    func testVoltageSeries() throws {
        let result = TransientResult(
            time: [0, 0.1, 0.2],
            solutions: [
                VMatrix([1, 2]),
                VMatrix([3, 4]),
                VMatrix([5, 6])
            ]
        )
        
        let series = try Plotter().voltageSeries(result, [1, 2])
        
        XCTAssertEqual(series.count, 2)
        XCTAssertEqual(series[0].node, 1)
        XCTAssertEqual(series[0].points.map(\.time), [0, 0.1, 0.2])
        XCTAssertEqual(series[0].points.map(\.value), [1, 3, 5])
        XCTAssertEqual(series[1].node, 2)
        XCTAssertEqual(series[1].points.map(\.value), [2, 4, 6])
    }
    
    func testWrongNodeIndex() throws {
        let result = TransientResult(time: [0], solutions: [VMatrix([1])])
        
        XCTAssertThrowsError(try Plotter().voltageSeries(result, [2])) { err in
            XCTAssertEqual(err as? PlotterError, .wrongNodeIndex(2))
        }
    }
    
    func testWrongTransientResult() throws {
        let result = TransientResult(time: [0, 1], solutions: [VMatrix([1])])
        
        XCTAssertThrowsError(try Plotter().voltageSeries(result, [1])) { err in
            XCTAssertEqual(err as? PlotterError, .wrongTransientResult)
        }
    }
}
