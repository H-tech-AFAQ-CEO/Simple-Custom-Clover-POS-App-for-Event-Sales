package com.clover.eventpos

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.clover.eventpos.adapter.CartAdapter
import com.clover.eventpos.databinding.ActivityCheckoutBinding
import com.clover.eventpos.utils.DataManager

class CheckoutActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityCheckoutBinding
    private lateinit var cartAdapter: CartAdapter
    private var selectedTipPercentage = 0.15
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckoutBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        loadCartItems()
    }
    
    private fun setupUI() {
        // Setup toolbar
        binding.toolbar.title = "Checkout"
        binding.toolbar.setNavigationOnClickListener {
            finish()
        }
        
        // Setup RecyclerView
        cartAdapter = CartAdapter()
        binding.recyclerViewCart.apply {
            layoutManager = LinearLayoutManager(this@CheckoutActivity)
            adapter = cartAdapter
        }
        
        // Setup tip buttons
        binding.buttonTip0.setOnClickListener { selectTip(0.0) }
        binding.buttonTip15.setOnClickListener { selectTip(0.15) }
        binding.buttonTip18.setOnClickListener { selectTip(0.18) }
        binding.buttonTip20.setOnClickListener { selectTip(0.20) }
        binding.buttonTip25.setOnClickListener { selectTip(0.25) }
        
        // Setup pay button
        binding.buttonPay.setOnClickListener { processPayment() }
        
        // Select default tip
        selectTip(0.15)
    }
    
    private fun loadCartItems() {
        cartAdapter.submitList(DataManager.cartItems.toList())
        updateTotals()
    }
    
    private fun selectTip(percentage: Double) {
        selectedTipPercentage = percentage
        
        // Reset all button backgrounds
        val tipButtons = listOf(
            binding.buttonTip0, binding.buttonTip15, binding.buttonTip18,
            binding.buttonTip20, binding.buttonTip25
        )
        tipButtons.forEach { it.isSelected = false }
        
        // Select the clicked button
        when (percentage) {
            0.0 -> binding.buttonTip0.isSelected = true
            0.15 -> binding.buttonTip15.isSelected = true
            0.18 -> binding.buttonTip18.isSelected = true
            0.20 -> binding.buttonTip20.isSelected = true
            0.25 -> binding.buttonTip25.isSelected = true
        }
        
        updateTotals()
    }
    
    private fun updateTotals() {
        val subtotal = DataManager.cartItems.sumOf { it.menuItem.price * it.quantity }
        val tipAmount = subtotal * selectedTipPercentage
        val total = subtotal + tipAmount
        
        binding.textViewSubtotal.text = String.format("$%.2f", subtotal)
        binding.textViewTip.text = String.format("$%.2f", tipAmount)
        binding.textViewTotal.text = String.format("$%.2f", total)
        
        // Update pay button
        binding.buttonPay.text = "PAY NOW • ${String.format("$%.2f", total)}"
    }
    
    private fun processPayment() {
        if (DataManager.cartItems.isEmpty()) {
            Toast.makeText(this, "Cart is empty", Toast.LENGTH_SHORT).show()
            return
        }
        
        // Store tip percentage for payment processing
        DataManager.selectedTipPercentage = selectedTipPercentage
        
        // Launch payment activity
        startActivity(Intent(this, PaymentActivity::class.java))
    }
}
