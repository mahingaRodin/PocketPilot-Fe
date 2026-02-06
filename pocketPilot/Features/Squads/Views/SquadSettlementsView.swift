import SwiftUI

struct SquadSettlementsView: View {
    let squad: Squad
    @State private var settlements: [SquadSettlement] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var squadService = SquadService.shared
    
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
                        Task { await loadSettlements() }
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
                    // Action to invite more members
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .task {
            await loadSettlements()
        }
        .refreshable {
            await loadSettlements()
        }
    }
    
    private func loadSettlements() async {
        isLoading = true
        errorMessage = nil
        do {
            settlements = try await squadService.fetchSettlements(squadID: squad.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
