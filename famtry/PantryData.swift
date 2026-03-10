//
//  PantryData.swift
//  famtry
//
//  Created by Katie Hsu on 3/9/26.
//

import SwiftUI
import Combine

// MARK: - Models

struct User {
    var id: UUID = UUID()
    var name: String
    var familyId: UUID?
}

struct Family {
    var id: UUID = UUID()
    var name: String
    var members: [UUID]
}

struct PantryItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var expirationDate: Date?
    var owners: [String]
    var isPendingApproval: Bool = false
}

// MARK: - Global App / Pantry State

class PantryData: ObservableObject {
    // Simple user / family state for now.
    // Later you can replace this with real backend data.
    @Published var currentUser: User?
    @Published var currentFamily: Family?

    var hasUser: Bool {
        currentUser != nil
    }

    var hasFamily: Bool {
        currentFamily != nil
    }

    // @Published tells SwiftUI: "Whenever this list changes, refresh the screens!"
    @Published var items: [PantryItem] = [
        PantryItem(name: "Almond Milk", quantity: 2, expirationDate: Date().addingTimeInterval(86400 * 3), owners: ["Alice"]),
        PantryItem(name: "Greek Yogurt", quantity: 5, expirationDate: Date().addingTimeInterval(-86400), owners: ["Bob"])
    ]

    // MARK: - User & Family helpers

    func createUser(named name: String) {
        let user = User(name: name, familyId: nil)
        currentUser = user
    }

    func createFamily(named name: String) {
        guard let user = currentUser else { return }
        let family = Family(name: name, members: [user.id])
        currentFamily = family
        currentUser = User(id: user.id, name: user.name, familyId: family.id)
    }

    func joinFamily(named name: String) {
        // For now we just create a local "joined" family with this name.
        // Later, this should call the backend and fetch the real family by code / id.
        guard let user = currentUser else { return }
        let family = Family(name: name, members: [user.id])
        currentFamily = family
        currentUser = User(id: user.id, name: user.name, familyId: family.id)
    }

    // MARK: - Pantry item helpers

    func addItem(name: String, qty: Int, expiry: Date?, includeExpiry: Bool) {
        let newItem = PantryItem(
            name: name,
            quantity: qty,
            expirationDate: includeExpiry ? expiry : nil,
            owners: ["Me"]
        )
        items.append(newItem)
    }
    
    // Bonus: Add this so you can test deleting items too!
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
