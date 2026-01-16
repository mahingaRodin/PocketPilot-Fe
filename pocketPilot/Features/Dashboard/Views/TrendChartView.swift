
import SwiftUI
import Charts

struct TrendChartView: View {
    let data: [(date: Date, amount: Double)]
    
    // Compute gradient colors
    let gradient = LinearGradient(
        colors: [.purple.opacity(0.8), .blue.opacity(0.5), .blue.opacity(0.1)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trend")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if data.isEmpty {
                VStack {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.3))
                        .padding()
                    Text("No trend data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            } else {
                Chart {
                    ForEach(data, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Amount", item.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        } // Always show small dots
                        
                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Amount", item.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(gradient)
                    }
                    
                    if let maxEntry = data.max(by: { $0.amount < $1.amount }) {
                        PointMark(
                            x: .value("Date", maxEntry.date),
                            y: .value("Amount", maxEntry.amount)
                        )
                        .foregroundStyle(.purple)
                        .symbolSize(100)
                        .annotation(position: .top) {
                            Text(maxEntry.amount.formatted(.currency(code: "USD")))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        AxisGridLine()
                        AxisTick()
                        // Ensure optional date unwrapping is safe or rely on stride
                        if let date = value.as(Date.self) {
                            AxisValueLabel(format: .dateTime.day().month())
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            }
        }
    }
}
