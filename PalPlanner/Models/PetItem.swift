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
    var isOwned: Bool = false
    var isEquipped: Bool = false
    
    static var sampleItems: [ShopItem] {
        [
            ShopItem(name: "Pizza", description: "A tasty treat for your pet", price: 50, category: .food, imageName: "pizza"),
            ShopItem(name: "Ball", description: "A fun toy to play with", price: 30, category: .toy, imageName: "circle.fill"),
            ShopItem(name: "T-Shirt", description: "A stylish shirt for your pet", price: 100, category: .clothing, imageName: "tshirt.fill"),
            ShopItem(name: "Sunglasses", description: "Cool shades for your pet", price: 75, category: .accessory, imageName: "eyeglasses")
        ]
    }
}
