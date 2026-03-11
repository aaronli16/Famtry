import SwiftUI

struct EditProfileScreen: View {
    @EnvironmentObject var data: PantryData
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var region: String = ""
    @State private var phone: String = ""
    @State private var signature: String = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let genderOptions = ["", "male", "female", "other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option.isEmpty ? "Not set" : option.capitalized)
                                .tag(option)
                        }
                    }
                }
                
                Section("Contact") {
                    TextField("Region", text: $region)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Signature") {
                    TextEditor(text: $signature)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        if let user = data.currentUser {
            name = user.name
            gender = user.gender ?? ""
            region = user.region ?? ""
            phone = user.phone ?? ""
            signature = user.signature ?? ""
        }
    }
    
    private func saveProfile() {
        isSaving = true
        
        Task {
            do {
                try await data.updateProfile(
                    name: name.trimmingCharacters(in: .whitespaces),
                    gender: gender.isEmpty ? nil : gender,
                    region: region.isEmpty ? nil : region,
                    phone: phone.isEmpty ? nil : phone,
                    signature: signature.isEmpty ? nil : signature
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isSaving = false
        }
    }
}

#Preview {
    EditProfileScreen()
        .environmentObject(PantryData())
}
