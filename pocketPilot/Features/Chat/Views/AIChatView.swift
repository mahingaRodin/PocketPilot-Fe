import SwiftUI

struct AIChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var showQuickQuestions = true
    @FocusState private var isInputFocused: Bool
    
    // Quick question suggestions
    let quickQuestions = [
        "Why am I spending so much?",
        "How's my budget?",
        "Give me savings tips",
        "Show my top expenses",
        "Compare to last month",
        "What's unusual?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Quick Questions (only show at start)
                            if showQuickQuestions && viewModel.messages.count <= 1 {
                                QuickQuestionsView(questions: quickQuestions) { question in
                                    messageText = question
                                    sendMessage()
                                    showQuickQuestions = false
                                }
                                .padding(.top)
                            }
                            
                            // Chat Messages
                            ForEach(viewModel.messages) { bubble in
                                ChatBubbleView(bubble: bubble)
                                    .id(bubble.id)
                            }
                            
                            // Loading indicator
                            if viewModel.isLoading {
                                HStack {
                                    TypingIndicatorView()
                                    Spacer()
                                }
                                .padding(.leading)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // Text input
                        TextField("Ask me anything...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .lineLimit(1...5)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        // Send button
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: messageText.isEmpty ? "paperplane" : "paperplane.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(messageText.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(messageText.isEmpty || viewModel.isLoading)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showQuickQuestions.toggle()
                        } label: {
                            Label("Quick Questions", systemImage: "questionmark.circle")
                        }
                        
                        Button {
                            Task {
                                await viewModel.loadHistory()
                            }
                        } label: {
                            Label("Load History", systemImage: "clock")
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                await viewModel.clearHistory()
                            }
                        } label: {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            isInputFocused = true
            Task {
                 await viewModel.loadHistory()
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        showQuickQuestions = false
        
        Task {
            await viewModel.sendMessage(text)
        }
    }
}

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let bubble: ChatBubble
    
    var body: some View {
        HStack {
            if bubble.isUser { Spacer() }
            
            VStack(alignment: bubble.isUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(bubble.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(bubble.isUser ? Color.blue.gradient : Color(.systemGray5).gradient)
                    .foregroundStyle(bubble.isUser ? .white : .primary)
                    .clipShape(ChatBubbleShape(isUser: bubble.isUser))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                
                // Timestamp
                Text(formatTime(bubble.timestamp))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 280, alignment: bubble.isUser ? .trailing : .leading)
            
            if !bubble.isUser { Spacer() }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatBubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Quick Questions View
struct QuickQuestionsView: View {
    let questions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try asking:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(questions, id: \.self) { question in
                        Button {
                            onSelect(question)
                        } label: {
                            Text(question)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Typing Indicator
struct TypingIndicatorView: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .offset(y: animationAmount)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .onAppear {
            animationAmount = -4
        }
    }
}
