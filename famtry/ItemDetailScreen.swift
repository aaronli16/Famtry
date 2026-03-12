//
//  ItemDetailScreen.swift
//  famtry
//
//  Created by Katharina Cheng on 3/10/26.
//

import SwiftUI

struct ItemDetailScreen: View {
    @EnvironmentObject var data: PantryData
    
    let itemId: String
    
    @State private var item: PantryItem?
    @State private var isLoading = true
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading item...")
            } else if let item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        itemInfoCard(item)
                        quantityCard(item)
                        ownershipCard(item)
                        
                        if isOwner(item), !item.pendingOwners.isEmpty {
                            pendingRequestsCard(item)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Item Detail")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                VStack(spacing: 12) {
                    Text("Unable to load item.")
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .task {
            await loadItem()
        }
    }
    
    private func itemInfoCard(_ item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Owners: \(item.ownerNames)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let expirationDate = item.expirationDate {
                Text("Expires: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func quantityCard(_ item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quantity")
                .font(.headline)
            
            HStack {
                Button {
                    Task { await updateQuantity(to: max(0, item.quantity - 1)) }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.black)
                }
                .disabled(!isOwner(item) || isSubmitting || item.quantity == 0)
                
                Spacer()
                
                Text("\(item.quantity)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    Task { await updateQuantity(to: item.quantity + 1) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.black)
                }
                .disabled(!isOwner(item) || isSubmitting)
            }
            
            if !isOwner(item) {
                Text("Only owners can modify quantity.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func ownershipCard(_ item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ownership")
                .font(.headline)
            
            if isOwner(item) {
                Text("You are an owner of this item.")
                    .foregroundColor(.green)
            } else if hasPendingRequest(item) {
                Text("Your ownership request is pending.")
                    .foregroundColor(.orange)
            } else {
                Button {
                    Task { await requestOwnership() }
                } label: {
                    Text(isSubmitting ? "Submitting..." : "Request Ownership")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .disabled(isSubmitting)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func pendingRequestsCard(_ item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pending Requests")
                .font(.headline)
            
            ForEach(item.pendingOwners) { pendingUser in
                VStack(alignment: .leading, spacing: 8) {
                    Text(pendingUser.name)
                        .fontWeight(.medium)
                    
                    HStack {
                        Button("Reject") {
                            Task { await reject(userId: pendingUser.id) }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .foregroundColor(.black)
                        .disabled(isSubmitting)
                        
                        Button("Approve") {
                            Task { await approve(userId: pendingUser.id) }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isSubmitting)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func isOwner(_ item: PantryItem) -> Bool {
        guard let userId = data.currentUser?.id else { return false }
        return item.owners.contains(where: { $0.id == userId })
    }
    
    private func hasPendingRequest(_ item: PantryItem) -> Bool {
        guard let userId = data.currentUser?.id else { return false }
        return item.pendingOwners.contains(where: { $0.id == userId })
    }
    
    @MainActor
    private func loadItem() async {
        isLoading = true
        errorMessage = nil
        
        do {
            item = try await data.refreshItem(itemId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    private func updateQuantity(to newQuantity: Int) async {
        guard let userId = data.currentUser?.id,
              let currentItem = item else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let updated = try await APIClient.shared.updateItem(
                id: currentItem.id,
                quantity: newQuantity,
                expirationDate: currentItem.expirationDate,
                userId: userId
            )
            item = updated
            data.replaceItem(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    @MainActor
    private func requestOwnership() async {
        guard let userId = data.currentUser?.id,
              let currentItem = item else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let updated = try await APIClient.shared.requestOwnership(itemId: currentItem.id, userId: userId)
            item = updated
            data.replaceItem(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    @MainActor
    private func approve(userId: String) async {
        guard let approverId = data.currentUser?.id,
              let currentItem = item else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let updated = try await APIClient.shared.approveOwnership(
                itemId: currentItem.id,
                requestedUserId: userId,
                approverId: approverId
            )
            item = updated
            data.replaceItem(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    @MainActor
    private func reject(userId: String) async {
        guard let approverId = data.currentUser?.id,
              let currentItem = item else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let updated = try await APIClient.shared.rejectOwnership(
                itemId: currentItem.id,
                requestedUserId: userId,
                approverId: approverId
            )
            item = updated
            data.replaceItem(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}
