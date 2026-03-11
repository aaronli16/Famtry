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
    var id: String
    var name: String
    var email: String
    var familyId: String?
}

struct Family {
    var id: String
    var name: String
    var memberIds: [String]
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

    @MainActor
    func register(name: String, email: String, password: String) async throws {
        let apiUser = try await APIClient.shared.register(name: name, email: email, password: password)
        let familyId = apiUser.familyIdResolved
        currentUser = User(
            id: apiUser.id,
            name: apiUser.name,
            email: apiUser.email,
            familyId: familyId
        )
        if let familyId {
            let family = try await APIClient.shared.getFamily(id: familyId)
            currentFamily = Family(id: family.id, name: family.name, memberIds: family.memberIds)
        }
    }

    @MainActor
    func login(email: String, password: String) async throws {
        let response = try await APIClient.shared.login(email: email, password: password)
        let familyId = response.user.familyIdResolved
        currentUser = User(
            id: response.user.id,
            name: response.user.name,
            email: response.user.email,
            familyId: familyId
        )
        if let familyId {
            let family = try await APIClient.shared.getFamily(id: familyId)
            currentFamily = Family(id: family.id, name: family.name, memberIds: family.memberIds)
        }
    }

    @MainActor
    func createFamily(named name: String) async throws {
        guard let userId = currentUser?.id else { return }
        let family = try await APIClient.shared.createFamily(name: name, userId: userId)
        currentFamily = Family(id: family.id, name: family.name, memberIds: family.memberIds)
        if var user = currentUser {
            user.familyId = family.id
            currentUser = user
        }
    }

    @MainActor
    func joinFamily(familyId: String) async throws {
        guard let userId = currentUser?.id else { return }
        let family = try await APIClient.shared.joinFamily(familyId: familyId, userId: userId)
        currentFamily = Family(id: family.id, name: family.name, memberIds: family.memberIds)
        if var user = currentUser {
            user.familyId = family.id
            currentUser = user
        }
    }

    // MARK: - Logout

    @MainActor
    func logout() {
        currentUser = nil
        currentFamily = nil
        items = []
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
