package com.clover.eventpos.model

data class CartItem(
    val menuItem: MenuItem,
    var quantity: Int
) {
    fun getTotal(): Double = menuItem.price * quantity
}
