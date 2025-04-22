//
//  ShopView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//
import SwiftUI

struct ShopView: View {
    @ObservedObject var shopManager: ShopManager
    @ObservedObject var petManager: PetManager
    @EnvironmentObject var taskManager: TaskManager
    @State private var selectedCategory: ItemCategory = .food
    @State private var showingInventory = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Points display
                HStack {
                    Image("palpoint-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("\(taskManager.palPoints) PalPoints")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        showingInventory.toggle()
                    }) {
                        Text(showingInventory ? "Shop" : "Inventory")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Shop items or inventory
                if showingInventory {
                    // Inventory view
                    let ownedItems = shopManager.ownedItemsByCategory(selectedCategory)
                    
                    if ownedItems.isEmpty {
                        VStack {
                            Spacer()
                            Text("You don't own any \(selectedCategory.rawValue) items yet")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(ownedItems) { item in
                                    InventoryItemView(item: item, petManager: petManager)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Shop view
                    let items = shopManager.itemsByCategory(selectedCategory)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(items) { item in
                                ShopItemView(
                                    item: item,
                                    shopManager: shopManager,
                                    taskManager: taskManager
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CategoryButton: View {
    let category: ItemCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                
                Text(category.rawValue.capitalized)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.purple.opacity(0.3) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(isSelected ? .purple : .primary)
        }
    }
}

struct ShopItemView: View {
    let item: ShopItem
    @ObservedObject var shopManager: ShopManager
    @ObservedObject var taskManager: TaskManager
    @State private var showingPurchaseAlert = false
    @State private var purchaseSuccess = false
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 100)
                
                Image(systemName: item.imageName)
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .frame(height: 36)
            
            HStack {
                Image("palpoint-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text("\(item.price)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    if item.isOwned {
                        // Already owned
                    } else if taskManager.palPoints >= item.price {
                        purchaseSuccess = shopManager.purchaseItem(item, using: taskManager)
                        showingPurchaseAlert = true
                    } else {
                        showingPurchaseAlert = true
                    }
                }) {
                    Text(item.isOwned ? "Owned" : "Buy")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(item.isOwned ? Color.gray.opacity(0.3) : Color.purple)
                        .foregroundColor(item.isOwned ? .secondary : .white)
                        .cornerRadius(8)
                }
                .disabled(item.isOwned)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert(purchaseSuccess ? "Purchase Successful" : "Purchase Failed", isPresented: $showingPurchaseAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if purchaseSuccess {
                Text("You've purchased \(item.name)!")
            } else {
                Text("You don't have enough PalPoints to purchase this item.")
            }
        }
    }
}

struct InventoryItemView: View {
    let item: ShopItem
    @ObservedObject var petManager: PetManager
    @State private var isEquipped: Bool = false
    
    init(item: ShopItem, petManager: PetManager) {
        self.item = item
        self.petManager = petManager
        self._isEquipped = State(initialValue: petManager.equippedItems[item.category]?.id == item.id)
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 100)
                
                Image(systemName: item.imageName)
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            
            Button(action: {
                if isEquipped {
                    petManager.unequipItem(category: item.category)
                } else {
                    petManager.equipItem(item)
                }
                isEquipped.toggle()
            }) {
                Text(isEquipped ? "Unequip" : "Equip")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(isEquipped ? Color.gray.opacity(0.3) : Color.purple)
                    .foregroundColor(isEquipped ? .secondary : .white)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
