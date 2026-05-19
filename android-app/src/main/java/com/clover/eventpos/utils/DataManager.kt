package com.clover.eventpos.utils

import com.clover.eventpos.model.MenuItem
import com.clover.eventpos.model.CartItem

object DataManager {
    
    private val items = mutableListOf<MenuItem>()
    val cartItems = mutableListOf<CartItem>()
    var selectedTipPercentage: Double = 0.15
    
    init {
        initializeDefaultItems()
    }
    
    private fun initializeDefaultItems() {
        items.addAll(listOf(
            MenuItem("1", "Classic Burger", 12.99, true, "🍔", "Food"),
            MenuItem("2", "Cheese Fries", 6.49, true, "🍟", "Food"),
            MenuItem("3", "Grilled Chicken", 14.99, true, "🍗", "Food"),
            MenuItem("4", "Hot Dog", 5.99, true, "🌭", "Food"),
            MenuItem("5", "Nachos", 8.49, true, "🫔", "Food"),
            MenuItem("6", "Pizza Slice", 4.99, true, "🍕", "Food"),
            MenuItem("7", "Soft Drink", 2.99, true, "🥤", "Drinks"),
            MenuItem("8", "Water Bottle", 1.99, true, "💧", "Drinks"),
            MenuItem("9", "Lemonade", 3.49, true, "🍋", "Drinks"),
            MenuItem("10", "Energy Drink", 3.99, true, "⚡", "Drinks"),
            MenuItem("11", "Beer", 6.99, true, "🍺", "Drinks"),
            MenuItem("12", "Cotton Candy", 4.49, false, "🍭", "Snacks"),
            MenuItem("13", "Popcorn", 3.99, true, "🍿", "Snacks"),
            MenuItem("14", "Ice Cream", 5.49, false, "🍦", "Snacks"),
            MenuItem("15", "Pretzel", 4.99, true, "🥨", "Snacks")
        ))
    }
    
    fun getAllItems(): List<MenuItem> = items.toList()
    
    fun getActiveItems(): List<MenuItem> = items.filter { it.isActive }
    
    fun addItem(item: MenuItem) {
        items.add(item)
    }
    
    fun updateItem(item: MenuItem) {
        val index = items.indexOfFirst { it.id == item.id }
        if (index != -1) {
            items[index] = item
        }
    }
    
    fun deleteItem(itemId: String) {
        items.removeAll { it.id == itemId }
        cartItems.removeAll { it.menuItem.id == itemId }
    }
    
    fun getItemById(itemId: String): MenuItem? {
        return items.find { it.id == itemId }
    }
}
