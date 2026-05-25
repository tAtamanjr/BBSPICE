import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var circuitText = ""
    @State private var errorText: String?
    @State private var output: SimulationOutput?
    @State private var isDropTargeted = false
    
    var body: some View {
        Group {
            if let output {
                ResultView(output: output, backAction: backToEditor)
            } else {
                EditorView(
                    circuitText: $circuitText,
                    errorText: errorText,
                    isDropTargeted: isDropTargeted,
                    runAction: runSimulation
                )
                .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted, perform: loadDroppedFile)
            }
        }
        .frame(minWidth: 820, minHeight: 560)
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    private func runSimulation() {
        do {
            let parsed = try Parser().parseText(circuitText)
            let solver = Solver()
            
            switch parsed.command {
            case .op:
                guard let result = try solver.solve(parsed.stamps, parsed.command) else {
                    throw SolverError.numericalDivergence
                }
                output = .operationPoint(result.values)
            case .tran:
                if parsed.showNodes.isEmpty {
                    errorText = "Parser: .tran simulation requires .show nodes"
                    return
                }
                
                let result = try solver.solveTransient(parsed.stamps, parsed.command)
                let series = try Plotter().voltageSeries(result, parsed.showNodes)
                output = .transient(series)
            }
            
            errorText = nil
        } catch {
            output = nil
            errorText = String(describing: error)
        }
    }
    
    private func backToEditor() {
        output = nil
        errorText = nil
    }
    
    private func loadDroppedFile(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            return false
        }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let url = fileURL(item), url.pathExtension.lowercased() == "txt" else {
                DispatchQueue.main.async {
                    errorText = "File loading error: drop a UTF-8 .txt file"
                }
                return
            }
            
            let hasAccess = url.startAccessingSecurityScopedResource()
            let text = try? String(contentsOf: url, encoding: .utf8)
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
            
            guard let text else {
                DispatchQueue.main.async {
                    errorText = "File loading error: drop a UTF-8 .txt file"
                }
                return
            }
            
            DispatchQueue.main.async {
                circuitText = text
                output = nil
                errorText = nil
            }
        }
        
        return true
    }
    
    private func fileURL(_ item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }
        
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        
        return nil
    }
}

private struct EditorView: View {
    @Binding var circuitText: String
    let errorText: String?
    let isDropTargeted: Bool
    let runAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BBSPICE")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text("Circuit description")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: runAction) {
                    Label("Run Simulation", systemImage: "play.fill")
                        .frame(minWidth: 150)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(circuitText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            HStack(alignment: .top, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $circuitText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(10)
                    
                    if circuitText.isEmpty {
                        Text("R 1 0 1000\nDCVS 1 0 5\n.op")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.28), lineWidth: 1)
                }
                
                DropPanel(isDropTargeted: isDropTargeted)
                    .frame(width: 220)
            }
            
            if let errorText {
                Text(errorText)
                    .font(.body)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
        .padding(24)
    }
}

private struct DropPanel: View {
    let isDropTargeted: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundStyle(isDropTargeted ? .blue : .secondary)
            
            Text("Drop .txt file")
                .font(.headline)
            
            Text("File content will replace the circuit description.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(18)
        .background(isDropTargeted ? Color.blue.opacity(0.08) : Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isDropTargeted ? Color.blue : Color.secondary.opacity(0.28), style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
        }
    }
}

private struct ResultView: View {
    let output: SimulationOutput
    let backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BBSPICE")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text(output.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: backAction) {
                    Label("Back", systemImage: "chevron.left")
                        .frame(minWidth: 90)
                }
                .controlSize(.large)
            }
            
            switch output {
            case let .operationPoint(values):
                OperationPointResultView(values: values)
            case let .transient(series):
                VoltagePlotView(series: series)
                    .frame(minWidth: 720, minHeight: 420)
            }
        }
        .padding(24)
    }
}

private struct OperationPointResultView: View {
    let values: [Double]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                ForEach(values.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("x\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(formatValue(values[index]))
                            .font(.system(.title3, design: .monospaced))
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value == 0 {
            return "0"
        }
        
        if abs(value) >= 1000 || abs(value) < 0.001 {
            return String(format: "%.6e", value)
        }
        
        return String(format: "%.6f", value)
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
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        }
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

private enum SimulationOutput {
    case operationPoint([Double])
    case transient([PlotSeries])
    
    var title: String {
        switch self {
        case .operationPoint:
            return "Operation point result"
        case .transient:
            return "Transient voltage result"
        }
    }
}

private struct PlotRange {
    let minTime: Double
    let maxTime: Double
    let minValue: Double
    let maxValue: Double
}
