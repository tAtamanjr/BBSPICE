import XCTest
@testable import BBSPICE

final class ParserFixtureSmokeTests: XCTestCase {
    
    func testCircuitFixturesParse() throws {
        let expectedFixtures: [String: ExpectedFixture] = [
            "VoltageDivider": ExpectedFixture(stampsCount: 3, command: .op, showNodes: []),
            "CurrentSourceResistor": ExpectedFixture(stampsCount: 2, command: .op, showNodes: []),
            "RCTransient": ExpectedFixture(stampsCount: 3, command: .tran(time: 0.005, timeStep: 0.00001), showNodes: [1, 2]),
            "ACSourceResistor": ExpectedFixture(stampsCount: 2, command: .tran(time: 0.002, timeStep: 0.00001), showNodes: [1]),
            "EmitterFollower": ExpectedFixture(stampsCount: 6, command: .tran(time: 0.004, timeStep: 0.00001), showNodes: [2, 4])
        ]
        
        for (name, expected) in expectedFixtures {
            let result = try Parser().parse(circuitURL(name))
            
            XCTAssertEqual(result.stamps.count, expected.stampsCount, name)
            assertCommand(result.command, expected.command, name)
            XCTAssertEqual(result.showNodes, expected.showNodes, name)
            
            if case .op = result.command {
                XCTAssertTrue(result.showNodes.isEmpty, name)
            } else {
                XCTAssertFalse(result.showNodes.isEmpty, name)
            }
        }
    }
    
    func testEveryCircuitFixtureHasReferenceCSV() throws {
        let circuits = try fixtureNames(in: circuitsURL(), extension: "txt")
        let references = try fixtureNames(in: referenceResultsURL(), extension: "csv")
        
        XCTAssertEqual(circuits, references)
    }
    
    private func circuitURL(_ name: String) -> URL {
        circuitsURL()
            .appendingPathComponent(name)
            .appendingPathExtension("txt")
    }
    
    private func circuitsURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Circuits")
    }
    
    private func referenceResultsURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("ReferenceResults")
    }
    
    private func fixtureNames(in url: URL, extension fileExtension: String) throws -> Set<String> {
        let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        
        return Set(files
            .filter { $0.pathExtension == fileExtension }
            .map { $0.deletingPathExtension().lastPathComponent }
        )
    }
    
    private func assertCommand(
        _ actual: SolverCommand,
        _ expected: SolverCommand,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch (actual, expected) {
        case (.op, .op):
            return
        case let (.tran(actualTime, actualTimeStep), .tran(expectedTime, expectedTimeStep)):
            XCTAssertEqual(actualTime, expectedTime, accuracy: 1e-12, message, file: file, line: line)
            XCTAssertEqual(actualTimeStep, expectedTimeStep, accuracy: 1e-12, message, file: file, line: line)
        default:
            XCTFail("Wrong command: \(message)", file: file, line: line)
        }
    }
}

private struct ExpectedFixture {
    let stampsCount: Int
    let command: SolverCommand
    let showNodes: [Int]
}
