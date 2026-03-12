//
//  famtryApp.swift
//  famtry
//
//  Created by Aaron Li on 3/4/26.
//

import SwiftUI
import UserNotifications

@main
struct famtryApp: App {
    @StateObject private var pantryData = PantryData()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            RootFlowView()
                .environmentObject(pantryData)
                .task {
                    do {
                        try await NotificationManager.shared.requestPermission()
                    } catch {
                        print("Failed to request notification permission: \(error.localizedDescription)")
                    }
                }
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

struct RootFlowView: View {
    @EnvironmentObject var data: PantryData

    var body: some View {
        TabView {
            PantryRootScreen()
                .tabItem {
                    Image(systemName: "house")
                    Text("Pantry")
                }

            ProfileRootScreen()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

struct PantryRootScreen: View {
    @EnvironmentObject var data: PantryData

    var body: some View {
        Group {
            if data.hasUser && !data.hasFamily {
                NavigationView {
                    CreateOrJoinFamilyScreen()
                        .navigationTitle("Family")
                }
            } else {
                PantryOverviewScreen()
            }
        }
    }
}

struct ProfileRootScreen: View {
    var body: some View {
        NavigationView {
            ProfileScreen()
        }
    }
}
