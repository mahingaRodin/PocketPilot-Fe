
import SwiftUI

struct CustomSecureField: View {
    let icon: String // SF Symbol name
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isFocused ? .blue : .secondary)
                .frame(width: 24)
                .scaleEffect(isFocused ? 1.1 : 1.0)
                .animation(.springy, value: isFocused)
            
            Group {
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.body)
            .focused($isFocused)
            .autocapitalization(.none)
            .foregroundStyle(.black)
            
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
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
        .colorScheme(.light) // Force light mode for visibility on white background
    }
}

#Preview {
    ZStack {
        Color.blue
        CustomSecureField(icon: "lock.fill", placeholder: "Password", text: .constant("123456"), showPassword: .constant(false))
            .padding()
    }
}
