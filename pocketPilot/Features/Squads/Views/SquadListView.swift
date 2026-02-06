import SwiftUI

struct SquadListView: View {
    @State private var squadService = SquadService.shared
    @State private var showCreateSquad = false
    @State private var showJoinSquad = false
    @State private var selectedSquad: Squad?
    
    var body: some View {
        NavigationStack {
            Group {
                if squadService.isLoading && squadService.squads.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Loading squads...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = squadService.errorMessage, squadService.squads.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Couldn't Load Squads")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            Task {
                                await squadService.fetchSquads()
                            }
                        } label: {
                            Text("Retry")
                                .fontWeight(.bold)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if squadService.squads.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                        
                        VStack(spacing: 8) {
                            Text("No Squads Yet")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Create a squad to split expenses with roommates, friends, or family.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        VStack(spacing: 12) {
                            Button {
                                showCreateSquad = true
                            } label: {
                                Text("Create Squad")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            Button {
                                showJoinSquad = true
                            } label: {
                                Text("Join Squad")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        Spacer()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(squadService.squads) { squad in
                            NavigationLink {
                                SquadSettlementsView(squad: squad)
                            } label: {
                                SquadRow(squad: squad)
                            }
                        }
                        .onDelete(perform: deleteSquad)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Squads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showCreateSquad = true
                        } label: {
                            Label("Create Squad", systemImage: "plus")
                        }
                        Button {
                            showJoinSquad = true
                        } label: {
                            Label("Join Squad", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await squadService.fetchSquads()
            }
            .sheet(isPresented: $showCreateSquad) {
                CreateSquadView()
            }
            .sheet(isPresented: $showJoinSquad) {
                JoinSquadView()
            }
            .task {
                await squadService.fetchSquads()
            }
        }
    }
    
    private func deleteSquad(at offsets: IndexSet) {
        for index in offsets {
            let squad = squadService.squads[index]
            Task {
                try? await squadService.deleteSquad(id: squad.id)
            }
        }
    }
}

struct SquadRow: View {
    let squad: Squad
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                
                Text((squad.name ?? "S").prefix(1).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(squad.name ?? "Unnamed Squad")
                    .font(.headline)
                if let desc = squad.description {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let _ = squad.inviteCode {
                Image(systemName: "qrcode")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
