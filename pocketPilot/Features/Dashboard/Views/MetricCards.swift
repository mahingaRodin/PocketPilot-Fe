import SwiftUI

struct SafeToSpendCard: View {
    let data: SafeToSpend
    let formatCurrency: (Double) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safe-to-Spend")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(formatCurrency(data.dailyAllowance))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Daily Allowance")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: data.status)
            }
            
            ProgressView(value: min(1, 1 - (data.monthlyRemaining / (data.monthlyRemaining + 1))), total: 1) // Just a visual placeholder until we have total budget
                .tint(statusColor)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(data.monthlyRemaining))
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Days left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(data.daysRemaining)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var statusColor: Color {
        switch data.status {
        case .onTrack: return .green
        case .caution: return .orange
        case .overspent: return .red
        }
    }
    
    private var statusIcon: String {
        switch data.status {
        case .onTrack: return "checkmark.shield.fill"
        case .caution: return "exclamationmark.shield.fill"
        case .overspent: return "xmark.shield.fill"
        }
    }
}

struct EcoImpactCard: View {
    let data: EcoImpact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Eco Impact")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(data.score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CircularScoreView(score: data.score)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                MetricItem(icon: "cloud.fill", value: "\(Int(data.carbonFootprintKg))kg", label: "CO2 Footprint", color: .gray)
                MetricItem(icon: "tree.fill", value: "\(data.treesToOffset)", label: "Trees to Offset", color: .green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatusBadge: View {
    let status: SafeToSpend.Status
    
    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    private var color: Color {
        switch status {
        case .onTrack: return .green
        case .caution: return .orange
        case .overspent: return .red
        }
    }
}

struct CircularScoreView: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                .frame(width: 44, height: 44)
            
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    LinearGradient(colors: [.green.opacity(0.5), .green], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-90))
            
            Text("\(score)")
                .font(.system(size: 14, weight: .bold))
        }
    }
}

struct MetricItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
