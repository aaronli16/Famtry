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

            Text("Ask a family member for the family code and paste it below.")
                .font(.caption)
                .foregroundColor(.gray)

            TextField("Enter family code", text: $familyIdToJoin)
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
                submitJoinFamily()
            }) {
                Text(isSubmitting ? "Joining..." : "Join Family")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(familyIdToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.black)
                    .cornerRadius(10)
            }
            .disabled(isSubmitting || familyIdToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func submitJoinFamily() {
        errorMessage = nil
        isSubmitting = true

        let trimmed = familyIdToJoin.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                try await data.joinFamily(familyId: trimmed)
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
