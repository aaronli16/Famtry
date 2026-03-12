//
//  AddItemScreen.swift
//  famtry
//
//  Created by Katie Hsu on 3/9/26.
//

import SwiftUI

struct AddItemScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: PantryData // Access the shared data
    
    @State private var itemName: String = ""
    @State private var quantity: Int = 1
    @State private var includeExpiration: Bool = false
    @State private var expirationDate: Date = Date()
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details").foregroundColor(.black)) {
                    TextField("Item Name", text: $itemName)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
                
                Section(header: Text("Freshness").foregroundColor(.black)) {
                    Toggle("Set Expiration Date", isOn: $includeExpiration)
                    if includeExpiration {
                        DatePicker("Date", selection: $expirationDate, displayedComponents: .date)
                    }
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                
                Section {
                    Button(action: {
                        saveItem()
                    }) {
                        Text(isSaving ? "Saving..." : "Add to Pantry")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(canSave ? Color.black : Color.gray)
                    .disabled(!canSave || isSaving)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var canSave: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        data.currentUser != nil &&
        data.currentFamily != nil
    }
    
    private func saveItem() {
//        // Here you would trigger your POST request to the Node.js/Render backend
//        print("Saving \(itemName) to database...")
//        dismiss()
        guard let familyId = data.currentFamily?.id,
              let ownerId = data.currentUser?.id else {
            errorMessage = "You need to be logged in and in a family before adding an item."
            return
            }
                
            let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                errorMessage = "Please enter an item name."
                return
            }
                
            isSaving = true
            errorMessage = nil
            
            Task {
                do {
                    let createdItem = try await APIClient.shared.createItem(
                        familyId: familyId,
                        name: trimmedName,
                        quantity: quantity,
                        expirationDate: includeExpiration ? expirationDate : nil,
                        ownerId: ownerId
                    )
                        
                    await MainActor.run {
                        data.replaceItem(createdItem)
                        isSaving = false
                        dismiss()
                    }
                    Task {
                        await NotificationManager.shared.rescheduleExpirationNotification(for: createdItem)
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isSaving = false
                    }
                }
            }
    }
}
    
    

