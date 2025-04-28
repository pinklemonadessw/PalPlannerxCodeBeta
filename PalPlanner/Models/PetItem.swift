//
//  PetItem.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import Foundation
import SwiftUI

enum ItemCategory: String, CaseIterable, Codable {
    case food
    case toy
    case clothing
    case accessory
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .toy: return "gamecontroller.fill"
        case .clothing: return "tshirt.fill"
        case .accessory: return "crown.fill"
        }
    }
}

struct ShopItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var price: Int
    var category: ItemCategory
    var imageName: String
    var isSystemImage: Bool = true  // True for SF Symbols, false for custom images
    var isOwned: Bool = false
    var isEquipped: Bool = false
    
    static var sampleItems: [ShopItem] {
        [
            ShopItem(name: "Basic Pet Food", description: "Free basic food for your pet", price: 0, category: .food, imageName: "pet_food", isSystemImage: false, isOwned: true),
            ShopItem(name: "Pizza", description: "A tasty treat for your pet", price: 50, category: .food, imageName: "pizza_icon", isSystemImage: false),
            ShopItem(name: "Burger", description: "Beef, cheese, and buns!", price: 50, category: .food, imageName: "burger_icon", isSystemImage: false),
            ShopItem(name: "Ball", description: "A fun toy to play with", price: 30, category: .toy, imageName: "ball_icon", isSystemImage: false),
            ShopItem(name: "T-Shirt", description: "A basic shirt for your pet", price: 100, category: .clothing, imageName: "tshirt_icon", isSystemImage: false),
            ShopItem(name: "Eyeglasses", description: "These help with blindness", price: 75, category: .accessory, imageName: "eyeglasses_icon", isSystemImage: false)
        ]
    }
}
