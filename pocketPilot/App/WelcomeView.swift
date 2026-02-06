import SwiftUI

struct WelcomeView: View {
    let message: String
    
    @State private var isAnimating = false
    @State private var emojiScale: CGFloat = 0.5
    @State private var emojiOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Gradient Overlay
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated App Icon / Logo Placeholder
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                VStack(spacing: 16) {
                    // Message
                    Text(message)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // Fun Emojis
                    HStack(spacing: 20) {
                        Text("🚀")
                        Text("✨")
                        Text("💸")
                    }
                    .font(.largeTitle)
                    .scaleEffect(emojiScale)
                    .opacity(emojiOpacity)
                }
                
                Spacer()
                
                // Loading Indicator
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
                emojiScale = 1.0
                emojiOpacity = 1.0
            }
        }
    }
}

#Preview {
    WelcomeView(message: "Welcome back Headie One 😁 to PocketPilot")
}
