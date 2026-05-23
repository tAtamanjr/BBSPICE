import Foundation

struct PlotPoint: Equatable, Identifiable {
    let id = UUID()
    let time: Double
    let value: Double
}

struct PlotSeries: Equatable, Identifiable {
    let id = UUID()
    let node: Int
    let points: [PlotPoint]
}

class Plotter {
    func voltageSeries(_ result: TransientResult, _ nodes: [Int]) throws -> [PlotSeries] {
        if result.time.count != result.solutions.count {
            throw PlotterError.wrongTransientResult
        }
        
        var series: [PlotSeries] = []
        
        for node in nodes {
            if node < 1 {
                throw PlotterError.wrongNodeIndex(node)
            }
            
            var points: [PlotPoint] = []
            
            for index in 0..<result.time.count {
                let solution = result.solutions[index]
                
                if node > solution.values.count {
                    throw PlotterError.wrongNodeIndex(node)
                }
                
                points.append(PlotPoint(time: result.time[index], value: solution.values[node - 1]))
            }
            
            series.append(PlotSeries(node: node, points: points))
        }
        
        return series
    }
}

enum PlotterError: Error, Equatable, CustomStringConvertible {
    case wrongTransientResult
    case wrongNodeIndex(_ node: Int)
    
    var description: String {
        switch self {
        case .wrongTransientResult:
            return "Plotter: Wrong transient result"
        case let .wrongNodeIndex(node):
            return "Plotter: Wrong node index \(node)"
        }
    }
}
