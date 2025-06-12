//
//  PRTimerApp.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

@main
struct PRTimerApp: App {
    @StateObject private var userSettings = UserSettings.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSettings)
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.checkAuthorizationStatus()
                    if !notificationManager.isAuthorized {
                        await notificationManager.requestPermissions()
                    }
                }
        }
    }
}
