package com.clover.eventpos

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.clover.eventpos.databinding.ActivityPaymentBinding
import com.clover.eventpos.utils.DataManager
import com.clover.sdk.v1.Intents
import com.clover.sdk.v3.order.Order
import com.clover.sdk.v3.order.OrderConnector
import com.clover.sdk.v3.payments.Payment
import com.clover.sdk.v3.payments.PaymentConnector
import com.clover.sdk.v3.payments.PaymentIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PaymentActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityPaymentBinding
    private var orderConnector: OrderConnector? = null
    private var paymentConnector: PaymentConnector? = null
    private var currentOrder: Order? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPaymentBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        initializeCloverConnectors()
        createOrder()
    }
    
    private fun setupUI() {
        // Setup toolbar
        binding.toolbar.title = "Payment"
        binding.toolbar.setNavigationOnClickListener {
            finish()
        }
        
        // Display total amount
        val subtotal = DataManager.cartItems.sumOf { it.menuItem.price * it.quantity }
        val tipAmount = subtotal * DataManager.selectedTipPercentage
        val total = subtotal + tipAmount
        
        binding.textViewAmount.text = String.format("$%.2f", total)
        binding.textViewItems.text = "${DataManager.cartItems.size} items"
        
        // Setup payment method buttons
        binding.buttonTapToPay.setOnClickListener { processPayment("tap") }
        binding.buttonInsertCard.setOnClickListener { processPayment("insert") }
        binding.buttonSwipeCard.setOnClickListener { processPayment("swipe") }
    }
    
    private fun initializeCloverConnectors() {
        try {
            orderConnector = OrderConnector(this, null, null)
            orderConnector?.connect()
            
            paymentConnector = PaymentConnector(this, null, null)
            paymentConnector?.connect()
        } catch (e: Exception) {
            Toast.makeText(this, "Error initializing Clover: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }
    
    private fun createOrder() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val order = Order().apply {
                    // Add line items
                    DataManager.cartItems.forEach { cartItem ->
                        val lineItem = com.clover.sdk.v3.order.LineItem().apply {
                            name = cartItem.menuItem.name
                            price = (cartItem.menuItem.price * 100).toLong() // Convert to cents
                            quantity = cartItem.quantity.toLong()
                            unitPrice = (cartItem.menuItem.price * 100).toLong()
                        }
                        addLineItem(lineItem)
                    }
                    
                    // Add tip if applicable
                    val subtotal = DataManager.cartItems.sumOf { it.menuItem.price * it.quantity }
                    val tipAmount = subtotal * DataManager.selectedTipPercentage
                    if (tipAmount > 0) {
                        val tipLineItem = com.clover.sdk.v3.order.LineItem().apply {
                            name = "Tip"
                            price = (tipAmount * 100).toLong()
                            quantity = 1
                            isRefundable = false
                        }
                        addLineItem(tipLineItem)
                    }
                }
                
                currentOrder = orderConnector?.createOrder(order)
                
                withContext(Dispatchers.Main) {
                    binding.textViewStatus.text = "Order created successfully"
                    binding.buttonTapToPay.isEnabled = true
                    binding.buttonInsertCard.isEnabled = true
                    binding.buttonSwipeCard.isEnabled = true
                }
                
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@PaymentActivity, "Error creating order: ${e.message}", Toast.LENGTH_LONG).show()
                    finish()
                }
            }
        }
    }
    
    private fun processPayment(method: String) {
        currentOrder?.let { order ->
            binding.textViewStatus.text = "Processing payment..."
            binding.buttonTapToPay.isEnabled = false
            binding.buttonInsertCard.isEnabled = false
            binding.buttonSwipeCard.isEnabled = false
            
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val total = order.total
                    val paymentIntent = PaymentIntent().apply {
                        amount = total
                        tipAmount = order.tipAmount
                        orderId = order.id
                    }
                    
                    val payment = paymentConnector?.takePayment(paymentIntent)
                    
                    withContext(Dispatchers.Main) {
                        handlePaymentResult(payment)
                    }
                    
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@PaymentActivity, "Payment failed: ${e.message}", Toast.LENGTH_LONG).show()
                        binding.textViewStatus.text = "Payment failed"
                        binding.buttonTapToPay.isEnabled = true
                        binding.buttonInsertCard.isEnabled = true
                        binding.buttonSwipeCard.isEnabled = true
                    }
                }
            }
        }
    }
    
    private fun handlePaymentResult(payment: Payment?) {
        if (payment?.isSuccess == true) {
            binding.textViewStatus.text = "Payment successful!"
            
            // Clear cart and return to main screen after delay
            CoroutineScope(Dispatchers.Main).launch {
                kotlinx.coroutines.delay(2000)
                
                // Clear cart
                DataManager.cartItems.clear()
                DataManager.selectedTipPercentage = 0.15
                
                // Return to main screen
                val intent = Intent(this@PaymentActivity, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                finish()
            }
        } else {
            binding.textViewStatus.text = "Payment failed"
            binding.buttonTapToPay.isEnabled = true
            binding.buttonInsertCard.isEnabled = true
            binding.buttonSwipeCard.isEnabled = true
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        orderConnector?.disconnect()
        paymentConnector?.disconnect()
    }
}
