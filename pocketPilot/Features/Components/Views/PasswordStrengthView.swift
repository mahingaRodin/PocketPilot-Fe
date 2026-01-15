
import SwiftUI

struct PasswordStrengthView: View {
    let password: String
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color(for: index))
                    .frame(height: 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func color(for index: Int) -> Color {
        let length = password.count
        if length == 0 { return .gray.opacity(0.3) }
        
        // Simple strength logic
        let score = min(length / 2, 4)
        
        if index < score {
            switch score {
            case 1: return .red
            case 2: return .orange
            case 3: return .yellow
            default: return .green
            }
        } else {
            return .gray.opacity(0.3)
        }
    }
}
