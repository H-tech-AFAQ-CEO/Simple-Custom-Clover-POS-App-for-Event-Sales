# Clover Event POS App

A fast, simple custom Clover POS app designed for event sales with minimal checkout steps.

## Features

### Core Functionality
- **Fast Checkout**: Maximum 3 screens to complete payment
- **Large Item Buttons**: Easy-to-tap interface for quick ordering
- **Real-time Cart**: Running subtotal and item count always visible
- **Tip Options**: 0%, 15%, 18%, 20%, 25% tip selections
- **Clover Integration**: Native payment processing with proper order creation

### Item Management
- **Add/Edit/Delete Items**: Full CRUD operations for menu items
- **Activate/Deactivate**: Enable/disable items based on event needs
- **Item Categories**: Organize items by Food, Drinks, Snacks
- **Emoji Icons**: Visual appeal for faster item recognition

### Payment Processing
- **Multiple Payment Methods**: Tap, insert, or swipe cards
- **Clover Order Creation**: Proper line-item reporting
- **Tip Integration**: Tips included in Clover orders
- **Automatic Return**: Returns to main screen after successful payment

## Technical Details

### Architecture
- **Language**: Kotlin
- **SDK**: Clover Android SDK v447.1
- **UI**: Material Design Components
- **Data Storage**: Local in-memory storage (no backend required)
- **Target SDK**: Android 34 (API 34)
- **Min SDK**: Android 28 (API 28)

### Project Structure
```
android-app/
├── src/main/java/com/clover/eventpos/
│   ├── MainActivity.kt              # Main sales screen
│   ├── CheckoutActivity.kt          # Checkout and tip selection
│   ├── PaymentActivity.kt           # Payment processing
│   ├── ItemManagementActivity.kt    # Item management
│   ├── model/
│   │   ├── MenuItem.kt              # Menu item data model
│   │   └── CartItem.kt              # Cart item data model
│   ├── adapter/
│   │   ├── ItemAdapter.kt           # Items grid adapter
│   │   ├── CartAdapter.kt           # Cart items adapter
│   │   └── ItemManagementAdapter.kt # Item management adapter
│   └── utils/
│       └── DataManager.kt           # Data management utility
├── src/main/res/
│   ├── layout/                      # XML layout files
│   ├── values/                      # Strings, themes, colors
│   └── menu/                        # Menu resources
└── build.gradle                     # App build configuration
```

## Installation Instructions

### Prerequisites
- Android Studio Arctic Fox or later
- Clover Developer Account
- Clover device for testing

### Setup Steps

1. **Clone/Download the Project**
   ```bash
   git clone <repository-url>
   cd android-app
   ```

2. **Open in Android Studio**
   - Open Android Studio
   - Select "Open an existing project"
   - Navigate to the `android-app` directory

3. **Configure Clover SDK**
   - Add your Clover app credentials to `AndroidManifest.xml`
   - Ensure proper permissions are set

4. **Build and Install**
   ```bash
   ./gradlew assembleDebug
   ```
   - Install the APK on your Clover device
   - Or use Android Studio's run button

### Private Deployment

Since this is a private app deployment:

1. **Generate Signed APK**
   - Build → Generate Signed Bundle/APK
   - Select APK
   - Create or use existing keystore
   - Build release variant

2. **Install on Clover Devices**
   - Enable "Install from unknown sources" on Clover devices
   - Transfer APK to devices (USB, cloud storage, etc.)
   - Install APK on both devices

3. **Configure Merchant Account**
   - Ensure both devices are logged into the same Clover merchant account
   - Test payment processing with test transactions

## Default Items

The app comes pre-configured with 15 default items:

### Food
- Classic Burger - $12.99 🍔
- Cheese Fries - $6.49 🍟
- Grilled Chicken - $14.99 🍗
- Hot Dog - $5.99 🌭
- Nachos - $8.49 🫔
- Pizza Slice - $4.99 🍕

### Drinks
- Soft Drink - $2.99 🥤
- Water Bottle - $1.99 💧
- Lemonade - $3.49 🍋
- Energy Drink - $3.99 ⚡
- Beer - $6.99 🍺

### Snacks
- Cotton Candy - $4.49 🍭 (Inactive)
- Popcorn - $3.99 🍿
- Ice Cream - $5.49 🍦 (Inactive)
- Pretzel - $4.99 🥨

## Usage Workflow

1. **Main Screen**: Tap items to add to cart
2. **Checkout**: Review order, select tip, tap "Pay Now"
3. **Payment**: Choose payment method (tap/insert/swipe)
4. **Success**: Automatic return to main screen

## Clover Integration

### Order Creation
- Creates proper Clover orders with line items
- Includes quantities and individual prices
- Tips added as separate line items
- Proper order totals and subtotals

### Payment Processing
- Uses Clover PaymentConnector for secure processing
- Supports all Clover payment methods
- Handles payment success/failure states
- Proper error handling and user feedback

### Reporting
- All transactions appear in Clover reporting
- Item-level sales tracking
- Tip reporting
- Multi-device synchronization

## Support

For technical support or questions:
- Check Android Studio logcat for error messages
- Ensure Clover SDK is properly configured
- Verify device permissions and network connectivity
- Test with Clover's sandbox environment first

---

**Developer: Cascade AI Assistant**  
**Version: 1.0**  
**Last Updated: May 7, 2026**
