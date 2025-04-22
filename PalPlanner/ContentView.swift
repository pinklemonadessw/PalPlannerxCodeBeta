//
//  ContentView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var petManager = PetManager()
    @StateObject private var shopManager = ShopManager()
    @EnvironmentObject private var audioManager: AudioManager
    
    var body: some View {
        TabView {
            PetView(petManager: petManager)
                .tabItem {
                    Label("Pet", systemImage: "pawprint.fill")
                }
            
            CalendarView(taskManager: taskManager)
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }
            
            ShopView(shopManager: shopManager, petManager: petManager)
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
            
            ActivityView(taskManager: taskManager)
                .tabItem {
                    Label("Activity", systemImage: "list.bullet")
                }
        }
        .accentColor(.purple)
        .environmentObject(taskManager)
        .environmentObject(petManager)
        .environmentObject(shopManager)
        .environmentObject(audioManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AudioManager.shared)
    }
}
