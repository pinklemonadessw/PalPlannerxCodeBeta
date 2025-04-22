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
        return ownedItems.filter { $0.category == category }
    }
}
