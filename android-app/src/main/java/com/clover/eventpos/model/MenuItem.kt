package com.clover.eventpos.model

data class MenuItem(
    val id: String,
    var name: String,
    var price: Double,
    var isActive: Boolean,
    var emoji: String,
    var category: String
)
