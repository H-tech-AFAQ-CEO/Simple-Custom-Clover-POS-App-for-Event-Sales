package com.clover.eventpos

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import com.clover.eventpos.adapter.ItemAdapter
import com.clover.eventpos.databinding.ActivityMainBinding
import com.clover.eventpos.model.CartItem
import com.clover.eventpos.model.MenuItem
import com.clover.eventpos.utils.DataManager

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var itemAdapter: ItemAdapter
    private val cartItems = mutableListOf<CartItem>()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        loadItems()
    }
    
    private fun setupUI() {
        // Setup toolbar
        binding.toolbar.title = "Event POS"
        binding.toolbar.inflateMenu(R.menu.main_menu)
        binding.toolbar.setOnMenuItemClickListener { menuItem ->
            when (menuItem.itemId) {
                R.id.action_manage_items -> {
                    startActivity(Intent(this, ItemManagementActivity::class.java))
                    true
                }
                else -> false
            }
        }
        
        // Setup RecyclerView
        itemAdapter = ItemAdapter { item -> addToCart(item) }
        binding.recyclerViewItems.apply {
            layoutManager = GridLayoutManager(this@MainActivity, 3)
            adapter = itemAdapter
        }
        
        // Setup button listeners
        binding.buttonCheckout.setOnClickListener { 
            if (cartItems.isNotEmpty()) {
                startActivity(Intent(this, CheckoutActivity::class.java))
            } else {
                Toast.makeText(this, "Cart is empty", Toast.LENGTH_SHORT).show()
            }
        }
        
        binding.buttonClearCart.setOnClickListener {
            cartItems.clear()
            updateCartDisplay()
        }
    }
    
    private fun loadItems() {
        val activeItems = DataManager.getActiveItems()
        itemAdapter.submitList(activeItems)
    }
    
    private fun addToCart(item: MenuItem) {
        val existingItem = cartItems.find { it.menuItem.id == item.id }
        if (existingItem != null) {
            existingItem.quantity++
        } else {
            cartItems.add(CartItem(item, 1))
        }
        updateCartDisplay()
    }
    
    private fun updateCartDisplay() {
        val subtotal = cartItems.sumOf { it.menuItem.price * it.quantity }
        val itemCount = cartItems.sumOf { it.quantity }
        
        binding.textViewCartCount.text = "$itemCount items"
        binding.textViewSubtotal.text = String.format("$%.2f", subtotal)
        
        DataManager.cartItems.clear()
        DataManager.cartItems.addAll(cartItems)
    }
    
    override fun onResume() {
        super.onResume()
        loadItems() // Refresh items in case they were modified
    }
}
