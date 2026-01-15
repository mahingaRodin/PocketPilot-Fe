
import SwiftUI

struct CustomSecureField: View {
    let icon: String // SF Symbol name
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.gray)
                .frame(width: 20)
            
            if showPassword {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        Color.blue
        CustomSecureField(icon: "lock.fill", placeholder: "Password", text: .constant("123456"), showPassword: .constant(false))
            .padding()
    }
}
