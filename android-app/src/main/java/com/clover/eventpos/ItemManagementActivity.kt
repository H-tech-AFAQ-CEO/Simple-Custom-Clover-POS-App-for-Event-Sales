package com.clover.eventpos

import android.app.AlertDialog
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.clover.eventpos.adapter.ItemManagementAdapter
import com.clover.eventpos.databinding.ActivityItemManagementBinding
import com.clover.eventpos.model.MenuItem
import com.clover.eventpos.utils.DataManager

class ItemManagementActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityItemManagementBinding
    private lateinit var adapter: ItemManagementAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityItemManagementBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        loadItems()
    }
    
    private fun setupUI() {
        // Setup toolbar
        binding.toolbar.title = "Manage Items"
        binding.toolbar.setNavigationOnClickListener {
            finish()
        }
        
        // Setup RecyclerView
        adapter = ItemManagementAdapter(
            onItemClick = { item -> toggleItemActive(item) },
            onEditClick = { item -> showEditItemDialog(item) },
            onDeleteClick = { item -> showDeleteItemDialog(item) }
        )
        binding.recyclerViewItems.apply {
            layoutManager = LinearLayoutManager(this@ItemManagementActivity)
            adapter = this@ItemManagementActivity.adapter
        }
        
        // Setup FAB
        binding.fabAddItem.setOnClickListener { showAddItemDialog() }
    }
    
    private fun loadItems() {
        val allItems = DataManager.getAllItems()
        adapter.submitList(allItems)
    }
    
    private fun toggleItemActive(item: MenuItem) {
        item.isActive = !item.isActive
        DataManager.updateItem(item)
        loadItems()
        Toast.makeText(this, "${item.name} ${if (item.isActive) "activated" else "deactivated"}", Toast.LENGTH_SHORT).show()
    }
    
    private fun showAddItemDialog() {
        showItemDialog(null) { name, price, category, emoji ->
            val newItem = MenuItem(
                id = System.currentTimeMillis().toString(),
                name = name,
                price = price,
                isActive = true,
                emoji = emoji,
                category = category
            )
            DataManager.addItem(newItem)
            loadItems()
            Toast.makeText(this, "Item added successfully", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showEditItemDialog(item: MenuItem) {
        showItemDialog(item) { name, price, category, emoji ->
            val updatedItem = item.copy(
                name = name,
                price = price,
                emoji = emoji,
                category = category
            )
            DataManager.updateItem(updatedItem)
            loadItems()
            Toast.makeText(this, "Item updated successfully", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showDeleteItemDialog(item: MenuItem) {
        AlertDialog.Builder(this)
            .setTitle("Delete Item")
            .setMessage("Are you sure you want to delete ${item.name}?")
            .setPositiveButton("Delete") { _, _ ->
                DataManager.deleteItem(item.id)
                loadItems()
                Toast.makeText(this, "Item deleted successfully", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    private fun showItemDialog(item: MenuItem?, onSave: (String, Double, String, String) -> Unit) {
        val dialogView = layoutInflater.inflate(R.layout.dialog_item, null)
        val nameEditText = dialogView.findViewById<android.widget.EditText>(R.id.editTextName)
        val priceEditText = dialogView.findViewById<android.widget.EditText>(R.id.editTextPrice)
        val categoryEditText = dialogView.findViewById<android.widget.EditText>(R.id.editTextCategory)
        val emojiEditText = dialogView.findViewById<android.widget.EditText>(R.id.editTextEmoji)
        
        // Pre-fill if editing
        item?.let {
            nameEditText.setText(it.name)
            priceEditText.setText(it.price.toString())
            categoryEditText.setText(it.category)
            emojiEditText.setText(it.emoji)
        }
        
        AlertDialog.Builder(this)
            .setTitle(if (item == null) "Add Item" else "Edit Item")
            .setView(dialogView)
            .setPositiveButton("Save") { _, _ ->
                val name = nameEditText.text.toString().trim()
                val priceText = priceEditText.text.toString().trim()
                val category = categoryEditText.text.toString().trim()
                val emoji = emojiEditText.text.toString().trim()
                
                if (name.isEmpty() || priceText.isEmpty() || category.isEmpty() || emoji.isEmpty()) {
                    Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show()
                    return@setPositiveButton
                }
                
                val price = try {
                    priceText.toDouble()
                } catch (e: NumberFormatException) {
                    Toast.makeText(this, "Invalid price", Toast.LENGTH_SHORT).show()
                    return@setPositiveButton
                }
                
                onSave(name, price, category, emoji)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
