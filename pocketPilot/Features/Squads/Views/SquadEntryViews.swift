import SwiftUI

struct CreateSquadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var squadService = SquadService.shared
    @State private var createdSquad: Squad?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Squad Details") {
                    TextField("Squad Name", text: $name)
                    TextField("Description (Optional)", text: $description)
                }
                
                if let squad = createdSquad {
                    Section("Success!") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your squad has been created.")
                                .font(.headline)
                            
                            HStack {
                                Text("Invite Code:")
                                    .fontWeight(.bold)
                                Text(squad.inviteCode ?? "N/A")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button {
                                    UIPasteboard.general.string = squad.inviteCode
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Create Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if createdSquad == nil {
                        Button("Create") {
                            Task {
                                createdSquad = try? await squadService.createSquad(name: name, description: description.isEmpty ? nil : description)
                                if createdSquad != nil {
                                    // Maybe add a delay or just let the user see the code
                                }
                            }
                        }
                        .disabled(name.isEmpty || squadService.isLoading)
                    } else {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .overlay {
                if squadService.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct JoinSquadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = ""
    @State private var squadService = SquadService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Join a Squad")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Enter the invite code shared with you.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                TextField("Invite Code", text: $inviteCode)
                    .font(.system(.title3, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 40)
                    .autocapitalization(.allCharacters)
                
                if let error = squadService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button {
                    Task {
                        let squad = try? await squadService.joinSquad(inviteCode: inviteCode)
                        if squad != nil {
                            dismiss()
                        }
                    }
                } label: {
                    if squadService.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Join Squad")
                            .fontWeight(.bold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(inviteCode.isEmpty || squadService.isLoading)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Join Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
