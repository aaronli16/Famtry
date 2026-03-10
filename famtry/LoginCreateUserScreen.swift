import SwiftUI

struct LoginCreateUserScreen: View {
    @EnvironmentObject var data: PantryData

    @State private var username: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Famtry")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.black)

                    Text("Shared Family Pantry")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your name")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    TextField("e.g. Alice", text: $username)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 24)

                Button(action: {
                    data.createUser(named: username.trimmingCharacters(in: .whitespacesAndNewlines))
                }) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()

                Text("Backend login / signup APIs can be added later. For now this only updates local state.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    LoginCreateUserScreen()
        .environmentObject(PantryData())
}

