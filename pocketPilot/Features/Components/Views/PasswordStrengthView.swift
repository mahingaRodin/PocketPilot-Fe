
import SwiftUI

struct PasswordStrengthView: View {
    let password: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                ForEach(0..<4) { index in
                    Capsule()
                        .fill(color(for: index).opacity(index < score ? 1 : 0.2))
                        .frame(height: 6)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                        .animation(.springy.delay(Double(index) * 0.1), value: score)
                }
            }
            
            Text(strengthText)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(strengthColor)
                .padding(.leading, 2)
        }
        .padding(.vertical, 4)
    }
    
    private var score: Int {
        let length = password.count
        if length == 0 { return 0 }
        if length < 6 { return 1 }
        if length < 10 { return 2 }
        if length < 14 { return 3 }
        return 4
    }
    
    private var strengthText: String {
        switch score {
        case 0: return ""
        case 1: return "Weak"
        case 2: return "Fair"
        case 3: return "Strong"
        default: return "Excellent"
        }
    }
    
    private var strengthColor: Color {
        color(for: score - 1)
    }
    
    private func color(for index: Int) -> Color {
        switch score {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray.opacity(0.3)
        }
    }
}
