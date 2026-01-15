
import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isFocused ? .blue : .secondary)
                .frame(width: 24)
                .scaleEffect(isFocused ? 1.1 : 1.0)
                .animation(.springy, value: isFocused)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .focused($isFocused)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isFocused ? .white : .white.opacity(0.8))
                .shadow(color: isFocused ? .black.opacity(0.1) : .clear, radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? .blue.opacity(0.3) : .clear, lineWidth: 1)
        )
        .animation(.gentle, value: isFocused)
    }
}

#Preview {
    ZStack {
        Color.blue
        CustomTextField(icon: "person.fill", placeholder: "Name", text: .constant(""))
            .padding()
    }
}