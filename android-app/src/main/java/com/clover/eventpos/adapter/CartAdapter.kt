package com.clover.eventpos.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.clover.eventpos.R
import com.clover.eventpos.model.CartItem

class CartAdapter : ListAdapter<CartItem, CartAdapter.CartViewHolder>(CartDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CartViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_cart_item, parent, false)
        return CartViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: CartViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    inner class CartViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val emojiTextView: TextView = itemView.findViewById(R.id.textViewEmoji)
        private val nameTextView: TextView = itemView.findViewById(R.id.textViewName)
        private val priceTextView: TextView = itemView.findViewById(R.id.textViewPrice)
        private val quantityTextView: TextView = itemView.findViewById(R.id.textViewQuantity)
        private val totalTextView: TextView = itemView.findViewById(R.id.textViewTotal)
        
        fun bind(cartItem: CartItem) {
            emojiTextView.text = cartItem.menuItem.emoji
            nameTextView.text = cartItem.menuItem.name
            priceTextView.text = String.format("$%.2f", cartItem.menuItem.price)
            quantityTextView.text = cartItem.quantity.toString()
            totalTextView.text = String.format("$%.2f", cartItem.getTotal())
        }
    }
}

class CartDiffCallback : DiffUtil.ItemCallback<CartItem>() {
    override fun areItemsTheSame(oldItem: CartItem, newItem: CartItem): Boolean {
        return oldItem.menuItem.id == newItem.menuItem.id
    }
    
    override fun areContentsTheSame(oldItem: CartItem, newItem: CartItem): Boolean {
        return oldItem == newItem
    }
}
