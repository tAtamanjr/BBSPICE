import Foundation
import SwiftUI

struct ContentView: View {
    private let series: [PlotSeries]
    private let title: String
    private let errorText: String?
    
    init() {
        do {
            let url = try Self.emitterFollowerURL()
            let parsed = try Parser().parse(url)
            let result = try Solver().solveTransient(parsed.stamps, parsed.command)
            self.series = try Plotter().voltageSeries(result, parsed.showNodes)
            self.title = "Emitter follower transient voltage"
            self.errorText = nil
        } catch {
            self.series = []
            self.title = "Emitter follower transient voltage"
            self.errorText = String(describing: error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BBSPICE")
                .font(.title)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.headline)
            
            if let errorText {
                Text(errorText)
                    .foregroundStyle(.red)
                    .font(.body)
            } else {
                VoltagePlotView(series: series)
                    .frame(minWidth: 720, minHeight: 420)
            }
        }
        .padding(24)
    }
    
    private static func emitterFollowerURL() throws -> URL {
        if let url = Bundle.main.url(forResource: "EmitterFollowerCircuit", withExtension: "txt") {
            return url
        }
        
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("EmitterFollowerCircuit.txt")
    }
}

struct VoltagePlotView: View {
    let series: [PlotSeries]
    
    private let colors: [Color] = [.blue, .red, .green, .orange, .purple]
    
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(x: 64, y: 24, width: size.width - 96, height: size.height - 88)
            let range = plotRange()
            
            drawAxes(&context, rect, range)
            
            for index in series.indices {
                drawSeries(&context, series[index], rect, range, colors[index % colors.count])
            }
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(series.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(colors[index % colors.count])
                            .frame(width: 18, height: 3)
                        Text("Node \(item.node)")
                            .font(.caption)
                    }
                }
            }
            .padding(.leading, 64)
            .padding(.top, 32)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func plotRange() -> PlotRange {
        let points = series.flatMap(\.points)
        let minTime = points.map(\.time).min() ?? 0
        let maxTime = points.map(\.time).max() ?? 1
        var minValue = points.map(\.value).min() ?? -1
        var maxValue = points.map(\.value).max() ?? 1
        
        if minValue == maxValue {
            minValue -= 1
            maxValue += 1
        }
        
        return PlotRange(minTime: minTime, maxTime: maxTime, minValue: minValue, maxValue: maxValue)
    }
    
    private func drawAxes(_ context: inout GraphicsContext, _ rect: CGRect, _ range: PlotRange) {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.stroke(path, with: .color(.secondary), lineWidth: 1)
        
        for step in 0...4 {
            let ratio = Double(step) / 4
            let y = rect.maxY - rect.height * ratio
            var grid = Path()
            grid.move(to: CGPoint(x: rect.minX, y: y))
            grid.addLine(to: CGPoint(x: rect.maxX, y: y))
            context.stroke(grid, with: .color(.secondary.opacity(0.18)), lineWidth: 1)
            
            let value = range.minValue + (range.maxValue - range.minValue) * ratio
            context.draw(Text(String(format: "%.2f V", value)).font(.caption), at: CGPoint(x: 28, y: y), anchor: .leading)
        }
        
        for step in 0...4 {
            let ratio = Double(step) / 4
            let x = rect.minX + rect.width * ratio
            var grid = Path()
            grid.move(to: CGPoint(x: x, y: rect.minY))
            grid.addLine(to: CGPoint(x: x, y: rect.maxY))
            context.stroke(grid, with: .color(.secondary.opacity(0.18)), lineWidth: 1)
            
            let time = range.minTime + (range.maxTime - range.minTime) * ratio
            context.draw(Text(formatTime(time)).font(.caption), at: CGPoint(x: x, y: rect.maxY + 18), anchor: .top)
        }
        
        context.draw(Text("time").font(.caption), at: CGPoint(x: rect.midX, y: rect.maxY + 46))
    }
    
    private func drawSeries(_ context: inout GraphicsContext, _ series: PlotSeries, _ rect: CGRect, _ range: PlotRange, _ color: Color) {
        guard let first = series.points.first else { return }
        
        var path = Path()
        path.move(to: point(first, rect, range))
        
        for plotPoint in series.points.dropFirst() {
            path.addLine(to: point(plotPoint, rect, range))
        }
        
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    private func point(_ plotPoint: PlotPoint, _ rect: CGRect, _ range: PlotRange) -> CGPoint {
        let timeScale = range.maxTime == range.minTime ? 0 : (plotPoint.time - range.minTime) / (range.maxTime - range.minTime)
        let valueScale = (plotPoint.value - range.minValue) / (range.maxValue - range.minValue)
        
        return CGPoint(
            x: rect.minX + rect.width * timeScale,
            y: rect.maxY - rect.height * valueScale
        )
    }
    
    private func formatTime(_ time: Double) -> String {
        if abs(time) < 1 {
            return String(format: "%.2f ms", time * 1000)
        }
        
        return String(format: "%.2f s", time)
    }
}

private struct PlotRange {
    let minTime: Double
    let maxTime: Double
    let minValue: Double
    let maxValue: Double
}

#Preview {
    ContentView()
}
