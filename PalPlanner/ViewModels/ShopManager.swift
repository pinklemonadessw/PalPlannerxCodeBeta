//
//  ShopManager.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import Foundation
import Combine

class ShopManager: ObservableObject {
    @Published var shopItems: [ShopItem] = ShopItem.sampleItems
    @Published var ownedItems: [ShopItem] = []
    
    init() {
        // Ensure basic pet food is in owned items from the start
        addBasicPetFoodToInventory()
    }
    
    private func addBasicPetFoodToInventory() {
        // Find the basic pet food item and add it to owned items if not already there
        if let basicFood = shopItems.first(where: { $0.name == "Basic Pet Food" && $0.category == .food }) {
            if !ownedItems.contains(where: { $0.id == basicFood.id }) {
                ownedItems.append(basicFood)
            }
        }
    }
    
    func purchaseItem(_ item: ShopItem, using taskManager: TaskManager) -> Bool {
        if taskManager.palPoints >= item.price {
            taskManager.palPoints -= item.price
            
            if let index = shopItems.firstIndex(where: { $0.id == item.id }) {
                var updatedItem = shopItems[index]
                updatedItem.isOwned = true
                shopItems[index] = updatedItem
                ownedItems.append(updatedItem)
            }
            
            objectWillChange.send()
            return true
        }
        return false
    }
    
    func itemsByCategory(_ category: ItemCategory) -> [ShopItem] {
        return shopItems.filter { $0.category == category }
    }
    
    func ownedItemsByCategory(_ category: ItemCategory) -> [ShopItem] {
        // Ensure basic pet food is always in owned items
        addBasicPetFoodToInventory()
        return ownedItems.filter { $0.category == category }
    }
}
