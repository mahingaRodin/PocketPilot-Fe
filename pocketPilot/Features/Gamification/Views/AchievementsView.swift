import SwiftUI

struct AchievementsView: View {
    @State private var viewModel = GamificationViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        if let profile = viewModel.profile {
                            ProfileHeaderCard(profile: profile)
                                .padding(.top)
                        } else if viewModel.isLoading {
                             ProgressView()
                                 .padding()
                        }
                        
                        // Tabs
                        Picker("Filter", selection: $selectedTab) {
                            Text("All").tag(0)
                            Text("Unlocked").tag(1)
                            Text("Locked").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Achievements Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
                
                // Confetti Effect
                if viewModel.showConfetti {
                    ConfettiView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    viewModel.showConfetti = false
                                }
                            }
                        }
                }
            }
            .navigationTitle("Achievements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.checkAchievements()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.loadAchievements()
                await viewModel.loadProfile()
            }
        }
        .task {
            await viewModel.loadAchievements()
            await viewModel.loadProfile()
        }
    }
    
    var filteredAchievements: [Achievement] {
        switch selectedTab {
        case 1: return viewModel.unlockedAchievements
        case 2: return viewModel.lockedAchievements
        default: return viewModel.achievements
        }
    }
}

// MARK: - Profile Header Card
struct ProfileHeaderCard: View {
    let profile: GamificationProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Points & Rank
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(profile.totalPoints)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Total Points")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("#\(profile.currentRank)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                    }
                    Text("Global Rank")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Stats Row
            HStack(spacing: 30) {
                StatItem(
                    icon: "star.fill",
                    value: "\(profile.achievementsUnlocked)",
                    label: "Unlocked",
                    color: .blue
                )
                
                StatItem(
                    icon: "flame.fill",
                    value: "\(profile.currentStreak)",
                    label: "Day Streak",
                    color: .orange
                )
                
                StatItem(
                    icon: "crown.fill",
                    value: "\(profile.longestStreak)",
                    label: "Best Streak",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with tier border
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        tierGradient :
                        LinearGradient(colors: [Color(.systemGray5), Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 70, height: 70)
                
                if achievement.isUnlocked {
                    Circle()
                        .stroke(tierGradient, lineWidth: 2)
                        .frame(width: 76, height: 76)
                }
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundStyle(achievement.isUnlocked ? .white : .gray)
            }
            .padding(.top, 4)
            
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
            }
            
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text("+\(achievement.points)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.1))
                .clipShape(Capsule())
            } else {
                VStack(spacing: 6) {
                    ProgressView(value: min(achievement.progressPercentage, 100), total: 100)
                        .tint(.blue)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    Text("\(achievement.progress) / \(achievement.requiredValue)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
    
    var tierGradient: LinearGradient {
        let colors: [Color]
        switch achievement.tier.lowercased() {
        case "bronze":
            colors = [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.3, blue: 0.1)]
        case "silver":
            colors = [Color(red: 0.75, green: 0.75, blue: 0.75), Color(red: 0.5, green: 0.5, blue: 0.5)]
        case "gold":
            colors = [.yellow, .orange]
        case "platinum":
            colors = [.purple, .blue]
        default:
            colors = [.blue, .cyan]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Confetti Effect
struct ConfettiView: View {
    @State private var confettiElements: [ConfettiElement] = []
    
    struct ConfettiElement: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let color: Color
        var rotation: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiElements) { element in
                    Rectangle()
                        .fill(element.color)
                        .frame(width: 8, height: 8)
                        .position(x: element.x, y: element.y)
                        .rotationEffect(.degrees(element.rotation))
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    func startConfetti(in size: CGSize) {
        for _ in 0..<60 {
            let element = ConfettiElement(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -100...0),
                color: [.red, .blue, .yellow, .green, .purple, .pink, .orange].randomElement()!,
                rotation: Double.random(in: 0...360)
            )
            confettiElements.append(element)
        }
        
        withAnimation(.easeOut(duration: 2.5)) {
            for i in 0..<confettiElements.count {
                confettiElements[i].y = size.height + 50
                confettiElements[i].x += CGFloat.random(in: -100...100)
                confettiElements[i].rotation += Double.random(in: 360...1080)
            }
        }
    }
}
