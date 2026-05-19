package com.clover.eventpos.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.clover.eventpos.R
import com.clover.eventpos.model.MenuItem

class ItemAdapter(
    private val onItemClick: (MenuItem) -> Unit
) : ListAdapter<MenuItem, ItemAdapter.ItemViewHolder>(ItemDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_item_card, parent, false)
        return ItemViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    inner class ItemViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val emojiTextView: TextView = itemView.findViewById(R.id.textViewEmoji)
        private val nameTextView: TextView = itemView.findViewById(R.id.textViewName)
        private val priceTextView: TextView = itemView.findViewById(R.id.textViewPrice)
        
        fun bind(item: MenuItem) {
            emojiTextView.text = item.emoji
            nameTextView.text = item.name
            priceTextView.text = String.format("$%.2f", item.price)
            
            itemView.setOnClickListener {
                onItemClick(item)
            }
        }
    }
}

class ItemDiffCallback : DiffUtil.ItemCallback<MenuItem>() {
    override fun areItemsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
        return oldItem.id == newItem.id
    }
    
    override fun areContentsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
        return oldItem == newItem
    }
}
