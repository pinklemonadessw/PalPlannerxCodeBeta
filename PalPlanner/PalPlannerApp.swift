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
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .onAppear {
                    // Pre-load the background music when the app starts
                    do {
                        // Verify the file exists
                        if let musicPath = Bundle.main.path(forResource: "background_music", ofType: "mp3") {
                            print("Background music found at: \(musicPath)")
                            audioManager.loadBackgroundMusic(fileName: "background_music")
                            
                            
                            let sampleRate = 48000
                            let startSample: Double = 2935474
                            let endSample: Double = 5863572
                            
                            // Convert samples to seconds
                            let startTime = startSample / Double(sampleRate)
                            let endTime = endSample / Double(sampleRate)
                            
                            print("Setting loop from \(startTime) to \(endTime) seconds (samples \(Int(startSample))-\(Int(endSample)))")
                            audioManager.setupCustomLoopPoints(start: startTime, end: endTime)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print(audioManager.getPlaybackInfo())
                            }
                        } else {
                            print("ERROR: background_music.mp3 file not found in bundle")
                        }
                    } catch {
                        print("Error loading background music: \(error)")
                    }
                    
                    // Request notification permissions
                    notificationManager.requestAuthorization()
                }
        }
    }
}
