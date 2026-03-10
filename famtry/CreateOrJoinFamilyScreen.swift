import SwiftUI

struct CreateOrJoinFamilyScreen: View {
    @EnvironmentObject var data: PantryData

    @State private var mode: Mode = .create
    @State private var familyNameToCreate: String = ""
    @State private var familyNameToJoin: String = ""

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

                Group {
                    if mode == .create {
                        createFamilyView
                    } else {
                        joinFamilyView
                    }
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
                let trimmed = familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines)
                data.createFamily(named: trimmed)
            }) {
                Text("Create family and open pantry")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.black)
                    .cornerRadius(10)
            }
            .disabled(familyNameToCreate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 24)
    }

    private var joinFamilyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Join an existing family")
                .font(.subheadline)
                .foregroundColor(.black)

            TextField("Family name or invite code (placeholder for now)", text: $familyNameToJoin)
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
                let trimmed = familyNameToJoin.trimmingCharacters(in: .whitespacesAndNewlines)
                data.joinFamily(named: trimmed)
            }) {
                Text("Join family and open pantry")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(familyNameToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.black)
                    .cornerRadius(10)
            }
            .disabled(familyNameToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Text("Later this can use a real invite code: call backend, validate, and load the actual family. For now it only creates a local placeholder family object.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    CreateOrJoinFamilyScreen()
        .environmentObject(PantryData())
}

