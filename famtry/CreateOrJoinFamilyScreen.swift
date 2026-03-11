import SwiftUI

struct CreateOrJoinFamilyScreen: View {
    @EnvironmentObject var data: PantryData
    @Environment(\.dismiss) var dismiss

    @State private var mode: Mode = .create
    @State private var familyNameToCreate: String = ""
    @State private var familyIdToJoin: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var verifiedFamilyName: String?
    @State private var isVerifying: Bool = false
    
    // Search state
    @State private var searchText: String = ""
    @State private var searchResults: [Family] = []
    @State private var isSearching: Bool = false

    enum Mode: String, CaseIterable, Identifiable {
        case create = "Create Family"
        case join = "Join Family"

        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Choose Family")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    if let name = data.currentUser?.name {
                        Text("Welcome, \(name)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("You need to log in before creating or joining a family.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }

                Picker("", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .onChange(of: mode) { _, _ in
                    verifiedFamilyName = nil
                    errorMessage = nil
                    searchText = ""
                    searchResults = []
                }

                if data.currentUser != nil {
                    Group {
                        if mode == .create {
                            createFamilyView
                        } else {
                            joinFamilyView
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
        }
    }

    private var createFamilyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a new family")
                .font(.subheadline)
                .foregroundColor(.black)

            TextField("Family name (e.g. Wang Family)", text: $familyNameToCreate)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundColor(.black)

            Button(action: {
                submitCreateFamily()
            }) {
                Text(isSubmitting ? "Please wait..." : "Create family and open pantry")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.black)
                    .cornerRadius(10)
            }
            .disabled(isSubmitting || familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 24)
    }

    private var joinFamilyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Join an existing family")
                .font(.subheadline)
                .foregroundColor(.black)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search by name...", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: searchText) { _, newValue in
                        performSearch(query: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )

            // Search results
            if isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select a family to join:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(searchResults, id: \.id) { family in
                        Button {
                            selectFamily(family)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(family.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    
                                    Text("\(family.memberIds.count) members")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                }
            } else if searchText.isEmpty {
                Text("Enter a family name to search")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else if searchText.count >= 2 {
                Text("No families found matching \"\(searchText)\"")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func performSearch(query: String) {
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        Task {
            do {
                let results = try await data.searchFamilies(query: query)
                searchResults = results
            } catch {
                // Silently fail - user can try again
            }
            isSearching = false
        }
    }

    private func selectFamily(_ family: Family) {
        isSubmitting = true
        
        Task {
            do {
                try await data.joinFamily(familyId: family.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    private func submitCreateFamily() {
        errorMessage = nil
        isSubmitting = true

        guard data.currentUser != nil else {
            errorMessage = "Please log in first from the Profile tab."
            isSubmitting = false
            return
        }

        let trimmed = familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                try await data.createFamily(named: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}

#Preview {
    CreateOrJoinFamilyScreen()
        .environmentObject(PantryData())
}
