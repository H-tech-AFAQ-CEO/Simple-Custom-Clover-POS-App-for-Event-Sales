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

class ItemManagementAdapter(
    private val onItemClick: (MenuItem) -> Unit,
    private val onEditClick: (MenuItem) -> Unit,
    private val onDeleteClick: (MenuItem) -> Unit
) : ListAdapter<MenuItem, ItemManagementAdapter.ItemViewHolder>(ItemDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_management_item, parent, false)
        return ItemViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    inner class ItemViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val emojiTextView: TextView = itemView.findViewById(R.id.textViewEmoji)
        private val nameTextView: TextView = itemView.findViewById(R.id.textViewName)
        private val priceTextView: TextView = itemView.findViewById(R.id.textViewPrice)
        private val categoryTextView: TextView = itemView.findViewById(R.id.textViewCategory)
        private val statusTextView: TextView = itemView.findViewById(R.id.textViewStatus)
        private val editButton: View = itemView.findViewById(R.id.buttonEdit)
        private val deleteButton: View = itemView.findViewById(R.id.buttonDelete)
        
        fun bind(item: MenuItem) {
            emojiTextView.text = item.emoji
            nameTextView.text = item.name
            priceTextView.text = String.format("$%.2f", item.price)
            categoryTextView.text = item.category
            statusTextView.text = if (item.isActive) "Active" else "Inactive"
            statusTextView.setTextColor(
                if (item.isActive) 
                    itemView.context.getColor(android.R.color.holo_green_dark) 
                else 
                    itemView.context.getColor(android.R.color.holo_red_dark)
            )
            
            itemView.setOnClickListener {
                onItemClick(item)
            }
            
            editButton.setOnClickListener {
                onEditClick(item)
            }
            
            deleteButton.setOnClickListener {
                onDeleteClick(item)
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
