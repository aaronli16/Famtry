import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var data: PantryData

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                header

                if let user = data.currentUser {
                    loggedInSection(user: user)
                } else {
                    loggedOutSection
                }

                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Profile")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.black)

            Text("Account")
                .font(.headline)
                .foregroundColor(.black)
        }
    }

    private var loggedOutSection: some View {
        VStack(spacing: 16) {
            Text("You are not logged in.")
                .font(.subheadline)
                .foregroundColor(.black)

            NavigationLink {
                LoginCreateUserScreen(mode: .login)
            } label: {
                Text("Log In")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .cornerRadius(10)
            }

            NavigationLink {
                LoginCreateUserScreen(mode: .register)
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
    }

    private func loggedInSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user.name)
                    .font(.body)
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user.email)
                    .font(.body)
                    .foregroundColor(.black)
            }

            if let family = data.currentFamily {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Family")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(family.name)
                        .font(.body)
                        .foregroundColor(.black)
                    Text("ID: \(family.id)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                NavigationLink {
                    CreateOrJoinFamilyScreen()
                        .navigationTitle("Family")
                } label: {
                    Text("Create or Join Family")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    NavigationView {
        ProfileScreen()
            .environmentObject(PantryData())
    }
}

