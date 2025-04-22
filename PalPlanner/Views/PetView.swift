//
//  PetView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var petManager: PetManager
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingNameChange = false
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                // Pet stats
                HStack {
                    VStack(alignment: .leading) {
                        Text("Happiness")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: petManager.happiness, color: .pink)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: petManager.energy, color: .blue)
                    }
                }
                .padding()
                
                Spacer()
                
                // Pet display area
                VStack {
                    // Pet image based on mood with breathing animation
                    Image(petManager.mood.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(breathingScale)
                        .animation(
                            Animation.easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: true),
                            value: breathingScale
                        )
                        .onAppear {
                            // Start the breathing animation
                            withAnimation {
                                breathingScale = 1.05
                            }
                        }
                        .padding()
                    
                    Text(petManager.petName)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Mood: \(petManager.mood.rawValue.capitalized)")
                        .foregroundColor(petManager.mood.color)
                        .padding(.bottom)
                    
                    // Equipped items display (placeholder)
                    if !petManager.equippedItems.isEmpty {
                        HStack(spacing: 20) {
                            ForEach(Array(petManager.equippedItems.keys), id: \.self) { category in
                                if let item = petManager.equippedItems[category] {
                                    VStack {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(.purple)
                                        
                                        Text(item.name)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                // Interaction buttons
                HStack(spacing: 30) {
                    Button(action: {
                        petManager.feed()
                    }) {
                        VStack {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 24))
                            Text("Feed")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        petManager.play()
                    }) {
                        VStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24))
                            Text("Play")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingNameChange = true
                    }) {
                        VStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                            Text("Rename")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("My Pet")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    audioManager.toggleMute()
                }) {
                    Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundColor(.purple)
                }
            )
            .alert("Rename Your Pet", isPresented: $showingNameChange) {
                TextField("Pet Name", text: $petManager.petName)
                Button("Cancel", role: .cancel) { }
                Button("Save") { }
            } message: {
                Text("Enter a new name for your pet")
            }
            .onAppear {
                // Load background music when the view appears (explicitly using MP3)
                audioManager.loadBackgroundMusic(fileName: "background_music")
            }
        }
    }
}

struct ProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(color)
            }
            .cornerRadius(4)
        }
        .frame(height: 8)
    }
}
