//
//  PetView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI
import QuartzCore
import UIKit  // Added for UIImage

// Extension to create random colors
extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

struct PetView: View {
    @ObservedObject var petManager: PetManager
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingNameChange = false
    @State private var showingFeedAlert = false
    @State private var breathingScale: CGFloat = 1.0
    @State private var showingBall = false
    @State private var ballPosition = CGPoint(x: 0, y: 0)
    @State private var ballVelocity = CGVector(dx: 0, dy: 0)
    @State private var lastUpdateTime: TimeInterval = 0
    @State private var displayLink: CADisplayLink?
    
    // Physics constants
    let gravity: CGFloat = 1000 // Gravity acceleration (points/s²)
    let damping: CGFloat = 0.8 // Energy loss on collision
    let frameRate: Double = 1/60 // 60 FPS
    
    // Geometry information for collision detection
    @State private var petFrame: CGRect = .zero
    @State private var screenBounds: CGRect = .zero
    @State private var buttonFrames: [String: CGRect] = [:]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
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
                        ZStack {
                            // Base pet image
                            Image(petManager.mood.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                            
                            // Clothing overlay
                            if let clothingItem = petManager.equippedItems[.clothing] {
                                let imageName = "clothing_\(clothingItem.name.lowercased().replacingOccurrences(of: " ", with: "_"))"
                                
                                if UIImage(named: imageName) != nil {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .offset(y: 0)
                                } else if UIImage(named: clothingItem.imageName) != nil {
                                    // Fallback to using the direct image name from the item
                                    Image(clothingItem.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .offset(y: 0)
                                }
                            }
                            
                            // Accessory overlay
                            if let accessoryItem = petManager.equippedItems[.accessory] {
                                let imageName = "accessory_\(accessoryItem.name.lowercased().replacingOccurrences(of: " ", with: "_"))"
                                
                                if UIImage(named: imageName) != nil {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                } else if UIImage(named: accessoryItem.imageName) != nil {
                                    Image(accessoryItem.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                }
                            }
                        }
                        .scaleEffect(breathingScale)
                        .animation(
                            Animation.easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: true),
                            value: breathingScale
                        )
                        .background(
                            GeometryReader { petGeo -> Color in
                                DispatchQueue.main.async {
                                    self.petFrame = CGRect(
                                        x: petGeo.frame(in: .global).minX + 50,
                                        y: petGeo.frame(in: .global).minY + 50,
                                        width: petGeo.size.width,
                                        height: petGeo.size.height
                                    )
                                }
                                return Color.clear
                            }
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
                            if petManager.hasFoodEquipped() {
                                petManager.feed()
                            } else {
                                showingFeedAlert = true
                            }
                        }) {
                            VStack {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 24))
                                Text("Feed")
                            }
                            .frame(width: 80, height: 80)
                            .background(petManager.hasFoodEquipped() ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        self.buttonFrames["feed"] = CGRect(
                                            x: geo.frame(in: .global).minX,
                                            y: geo.frame(in: .global).minY,
                                            width: geo.size.width,
                                            height: geo.size.height
                                        )
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        
                        Button(action: {
                            petManager.play()
                            
                            // Check if ball is in inventory and drop it
                            if hasBallInInventory() {
                                dropBall(in: geometry)
                            }
                        }) {
                            VStack {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 24))
                                Text("Play")
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(12)
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        self.buttonFrames["play"] = CGRect(
                                            x: geo.frame(in: .global).minX,
                                            y: geo.frame(in: .global).minY,
                                            width: geo.size.width,
                                            height: geo.size.height
                                        )
                                    }
                                    return Color.clear
                                }
                            )
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
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        self.buttonFrames["rename"] = CGRect(
                                            x: geo.frame(in: .global).minX,
                                            y: geo.frame(in: .global).minY,
                                            width: geo.size.width,
                                            height: geo.size.height
                                        )
                                    }
                                    return Color.clear
                                }
                            )
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
                .alert("No Food Equipped", isPresented: $showingFeedAlert) {
                    Button("OK", role: .cancel) { }
                    Button("Go to Inventory") { 
                        // Here we'd navigate to inventory, but we'll just dismiss for now
                    }
                } message: {
                    Text("You need to equip a food item from your inventory before feeding your pet.")
                }
                .onAppear {
                    // Only update the screen bounds
                    screenBounds = UIScreen.main.bounds
                }
                
                // Ball overlay
                if showingBall {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .position(ballPosition)
                }
            }
        }
    }
    
    // Check if ball is in inventory
    private func hasBallInInventory() -> Bool {
        return petManager.equippedItems.values.contains { $0.name == "Ball" } ||
               (petManager.equippedItems[.toy]?.name == "Ball")
    }
    
    // Start the ball animation
    private func dropBall(in geometry: GeometryProxy) {
        // Reset ball state
        showingBall = true
        
        // Initial position (center-top of screen)
        ballPosition = CGPoint(x: geometry.size.width / 2, y: 50)
        
        // Initial velocity
        ballVelocity = CGVector(dx: CGFloat.random(in: -100...300), dy: 0)
        
        // Start the animation loop
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        displayLink?.invalidate()
        lastUpdateTime = CACurrentMediaTime()
        
        // For tracking total elapsed time
        let startTime = CACurrentMediaTime()
        
        // Use a Timer instead of CADisplayLink for cross-platform compatibility
        Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            updateBallPhysics()
            
            // Check total elapsed time since animation started
            let elapsedTime = CACurrentMediaTime() - startTime
            
            // Stop after exactly 5 seconds regardless of ball state
            if elapsedTime >= 5.0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    showingBall = false
                }
            }
        }
        
        // Backup timer to ensure ball disappears after 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            DispatchQueue.main.async {
                showingBall = false
            }
        }
    }
    
    private func updateBallPhysics() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Apply gravity
        ballVelocity.dy += gravity * CGFloat(deltaTime)
        
        // Update position
        ballPosition.x += ballVelocity.dx * CGFloat(deltaTime)
        ballPosition.y += ballVelocity.dy * CGFloat(deltaTime)
        
        // Ball radius
        let ballRadius: CGFloat = 15
        
        // Check for collisions with screen edges
        if ballPosition.x - ballRadius < 0 {
            ballPosition.x = ballRadius
            ballVelocity.dx = -ballVelocity.dx * damping
        } else if ballPosition.x + ballRadius > screenBounds.width {
            ballPosition.x = screenBounds.width - ballRadius
            ballVelocity.dx = -ballVelocity.dx * damping
        }
        
        // Add a small offset to allow the ball to bounce lower than the screen's bottom edge
        let bottomOffset: CGFloat = 60
        if ballPosition.y + ballRadius > screenBounds.height + bottomOffset {
            ballPosition.y = screenBounds.height + bottomOffset - ballRadius
            ballVelocity.dy = -ballVelocity.dy * damping
        }
        
        // Check for collisions with pet
        let petCollisionRect = CGRect(
            x: petFrame.minX - ballRadius,
            y: petFrame.minY - ballRadius,
            width: petFrame.width + ballRadius * 2,
            height: petFrame.height + ballRadius * 2
        ).insetBy(dx: -ballRadius, dy: -ballRadius)
        
        let ballRect = CGRect(x: ballPosition.x - ballRadius, y: ballPosition.y - ballRadius, width: ballRadius * 2, height: ballRadius * 2)
        let intersection = petCollisionRect.intersection(ballRect)
        
        if !intersection.isNull && !intersection.isEmpty {
            // Determine which side of the pet was hit
            let ballCenter = CGPoint(x: ballPosition.x, y: ballPosition.y)
            let petCenter = CGPoint(x: petFrame.midX, y: petFrame.midY)
            
            let dx = ballCenter.x - petCenter.x
            let dy = ballCenter.y - petCenter.y
            
            if abs(dx) > abs(dy) {
                // Hit on left or right
                ballVelocity.dx = -ballVelocity.dx * damping
                ballPosition.x += dx > 0 ? ballRadius : -ballRadius
            } else {
                // Hit on top or bottom
                ballVelocity.dy = -ballVelocity.dy * damping
                ballPosition.y += dy > 0 ? ballRadius : -ballRadius
            }
        }
        
        // Check for collisions with buttons
        for (buttonName, buttonFrame) in buttonFrames {
            if buttonFrame.contains(CGPoint(x: ballPosition.x, y: ballPosition.y)) {
                // Bounce off the button
                if buttonName == "feed" {
                    if petManager.hasFoodEquipped() {
                        petManager.feed()
                    } else {
                        showingFeedAlert = true
                    }
                } else if buttonName == "play" {
                    petManager.play()
                } else if buttonName == "rename" {
                    showingNameChange = true
                }
                
                // Determine bounce direction
                let buttonCenter = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
                let dx = ballPosition.x - buttonCenter.x
                let dy = ballPosition.y - buttonCenter.y
                
                if abs(dx) > abs(dy) {
                    ballVelocity.dx = -ballVelocity.dx * damping
                } else {
                    ballVelocity.dy = -ballVelocity.dy * damping
                }
            }
        }
        
        // Apply some air resistance to gradually slow the ball
        ballVelocity.dx *= 0.99
        ballVelocity.dy *= 0.99
        
        // Stop ball if moving too slowly
        if abs(ballVelocity.dx) < 5 && abs(ballVelocity.dy) < 5 && ballPosition.y > screenBounds.height + bottomOffset - ballRadius * 2 {
            showingBall = false
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
