//
//  PetManager.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import Foundation
import Combine
import SwiftUI

enum PetMood: String, CaseIterable {
    case happy
    case neutral
    case sad
    
    var imageName: String {
        switch self {
        case .happy: return "pet_happy"
        case .neutral: return "pet_neutral"
        case .sad: return "pet_sad"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .green
        case .neutral: return .yellow
        case .sad: return .red
        }
    }
}

class PetManager: ObservableObject {
    @Published var petName: String = "Timo"
    @Published var mood: PetMood = .happy
    @Published var happiness: Double = 0.8
    @Published var energy: Double = 0.7
    @Published var equippedItems: [ItemCategory: ShopItem] = [:]
    
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.decreaseStats()
        }
    }
    
    private func decreaseStats() {
        happiness = max(0, happiness - 0.05)
        energy = max(0, energy - 0.05)
        updateMood()
    }
    
    func updateMood() {
        let average = (happiness + energy) / 2
        
        if average > 0.7 {
            mood = .happy
        } else if average > 0.4 {
            mood = .neutral
        } else {
            mood = .sad
        }
        
        objectWillChange.send()
    }
    
    func feed() -> Bool {
        // Check if a food item is equipped
        if equippedItems[.food] != nil {
            energy = min(1.0, energy + 0.2)
            updateMood()
            return true
        }
        return false
    }
    
    func hasFoodEquipped() -> Bool {
        return equippedItems[.food] != nil
    }
    
    func play() {
        happiness = min(1.0, happiness + 0.2)
        energy = max(0, energy - 0.1)
        updateMood()
    }
    
    func equipItem(_ item: ShopItem) {
        equippedItems[item.category] = item
        objectWillChange.send()
    }
    
    func unequipItem(category: ItemCategory) {
        equippedItems.removeValue(forKey: category)
        objectWillChange.send()
    }
}
