//
//  PalPlannerApp.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI

@main
struct PalPlannerApp: App {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .onAppear {
                    // Pre-load the background music when the app starts (explicitly using MP3)
                    audioManager.loadBackgroundMusic(fileName: "background_music")
                }
        }
    }
}
