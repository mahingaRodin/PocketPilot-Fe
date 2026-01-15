
import SwiftUI

struct SuccessOverlayView: View {
    let message: String
    @Binding var isPresented: Bool
    
    @State private var checkmarkScale = 0.0
    @State private var textOpacity = 0.0
    @State private var cardScale = 0.8
    @State private var circleStroke = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(.blue.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: circleStroke)
                        .stroke(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .scaleEffect(checkmarkScale)
                }
                
                Text(message)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .opacity(textOpacity)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(cardScale)
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardScale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                circleStroke = 1.0
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.5)) {
                checkmarkScale = 1.0
            }
            
            withAnimation(.gentle.delay(0.7)) {
                textOpacity = 1.0
            }
            
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.gentle) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SuccessOverlayView(message: "Update Successful", isPresented: .constant(true))
}
