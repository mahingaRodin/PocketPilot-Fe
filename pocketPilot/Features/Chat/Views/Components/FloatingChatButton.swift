import SwiftUI

struct FloatingChatButton: View {
    @State private var showChat = false
    
    var body: some View {
        Button {
            showChat = true
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showChat) {
            AIChatView()
        }
    }
}
