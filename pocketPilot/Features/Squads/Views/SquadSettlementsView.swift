import SwiftUI

struct SquadSettlementsView: View {
    let squad: Squad
    @State private var settlements: [SquadSettlement] = []
    @State private var members: [SquadMemberResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var squadService = SquadService.shared
    @State private var showInviteSheet = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Calculating settlements...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadData() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if settlements.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("All Settled Up!")
                        .font(.headline)
                    Text("No outstanding debts in this squad.")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        if members.isEmpty {
                            Text("No members yet")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(members) { member in
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading) {
                                        Text("\(member.firstName) \(member.lastName)")
                                            .font(.body)
                                        Text(member.role.rawValue.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Squad Members")
                    }
                    
                    Section {
                        ForEach(settlements) { settlement in
                            SettlementRow(settlement: settlement)
                        }
                    } header: {
                        Text("Suggested Payments")
                    } footer: {
                        Text("These optimized transactions minimize the total number of payments needed to settle all debts.")
                    }
                }
            }
        }
        .navigationTitle(squad.name ?? "Squad Settlements")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showInviteSheet = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteView(inviteCode: squad.inviteCode ?? "N/A")
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedSettlements = squadService.fetchSettlements(squadID: squad.id)
            async let fetchedMembers = squadService.fetchMembers(squadID: squad.id)
            
            self.settlements = try await fetchedSettlements
            self.members = try await fetchedMembers
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct InviteView: View {
    let inviteCode: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Invite Members")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Share this code with your friends to let them join your squad.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 12) {
                    Text(inviteCode)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        )
                    
                    Button {
                        UIPasteboard.general.string = inviteCode
                    } label: {
                        Label("Copy Code", systemImage: "doc.on.doc")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

struct SettlementRow: View {
    let settlement: SquadSettlement
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(settlement.fromUserName)
                        .fontWeight(.bold)
                    Text("pays")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                    Text(settlement.toUserName)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            Text(formatCurrency(settlement.amount))
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
