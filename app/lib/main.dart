import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CloverPOSApp());
}

// ─────────────────────────────────────────────
//  THEME & DESIGN TOKENS
// ─────────────────────────────────────────────
class AppTheme {
  static const Color background   = Color(0xFFF8F6F2);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF2F0EB);
  static const Color primary      = Color(0xFF1A1A2E);
  static const Color accent       = Color(0xFFE8A838);
  static const Color accentLight  = Color(0xFFFFF3D6);
  static const Color success      = Color(0xFF2D9B6F);
  static const Color successLight = Color(0xFFE8F7F1);
  static const Color danger       = Color(0xFFD94F3D);
  static const Color dangerLight  = Color(0xFFFDEDEB);
  static const Color textPrimary  = Color(0xFF1A1A2E);
  static const Color textSecondary= Color(0xFF6B6B7B);
  static const Color textMuted    = Color(0xFFABABBB);
  static const Color border       = Color(0xFFE8E6E0);
  static const Color shadow       = Color(0x12000000);
  static const Color cardShadow   = Color(0x18000000);

  static const String fontDisplay = 'Georgia';
  static const String fontBody    = 'Georgia';

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    fontFamily: fontBody,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surface,
      background: background,
    ),
  );
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class MenuItem {
  String id;
  String name;
  double price;
  bool isActive;
  String emoji;
  String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    required this.emoji,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'price': price,
    'isActive': isActive, 'emoji': emoji, 'category': category,
  };

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    id: j['id'], name: j['name'], price: (j['price'] as num).toDouble(),
    isActive: j['isActive'], emoji: j['emoji'], category: j['category'],
  );
}

class CartItem {
  MenuItem item;
  int quantity;
  CartItem({required this.item, required this.quantity});
  double get total => item.price * quantity;
}

class AppState extends ChangeNotifier {
  List<MenuItem> _items = [];
  Map<String, CartItem> _cart = {};
  int _currentScreen = 0; // 0=sales, 1=checkout, 2=payment, 3=success, 4=manage
  double _selectedTip = 0;
  bool _paymentProcessing = false;

  // Default items
  AppState() {
    _items = [
      MenuItem(id: '1', name: 'Classic Burger', price: 12.99, isActive: true, emoji: '🍔', category: 'Food'),
      MenuItem(id: '2', name: 'Cheese Fries', price: 6.49, isActive: true, emoji: '🍟', category: 'Food'),
      MenuItem(id: '3', name: 'Grilled Chicken', price: 14.99, isActive: true, emoji: '🍗', category: 'Food'),
      MenuItem(id: '4', name: 'Hot Dog', price: 5.99, isActive: true, emoji: '🌭', category: 'Food'),
      MenuItem(id: '5', name: 'Nachos', price: 8.49, isActive: true, emoji: '🫔', category: 'Food'),
      MenuItem(id: '6', name: 'Pizza Slice', price: 4.99, isActive: true, emoji: '🍕', category: 'Food'),
      MenuItem(id: '7', name: 'Soft Drink', price: 2.99, isActive: true, emoji: '🥤', category: 'Drinks'),
      MenuItem(id: '8', name: 'Water Bottle', price: 1.99, isActive: true, emoji: '💧', category: 'Drinks'),
      MenuItem(id: '9', name: 'Lemonade', price: 3.49, isActive: true, emoji: '🍋', category: 'Drinks'),
      MenuItem(id: '10', name: 'Energy Drink', price: 3.99, isActive: true, emoji: '⚡', category: 'Drinks'),
      MenuItem(id: '11', name: 'Beer', price: 6.99, isActive: true, emoji: '🍺', category: 'Drinks'),
      MenuItem(id: '12', name: 'Cotton Candy', price: 4.49, isActive: false, emoji: '🍭', category: 'Snacks'),
      MenuItem(id: '13', name: 'Popcorn', price: 3.99, isActive: true, emoji: '🍿', category: 'Snacks'),
      MenuItem(id: '14', name: 'Ice Cream', price: 5.49, isActive: false, emoji: '🍦', category: 'Snacks'),
      MenuItem(id: '15', name: 'Pretzel', price: 4.99, isActive: true, emoji: '🥨', category: 'Snacks'),
    ];
  }

  List<MenuItem> get items => _items;
  List<MenuItem> get activeItems => _items.where((i) => i.isActive).toList();
  Map<String, CartItem> get cart => _cart;
  int get currentScreen => _currentScreen;
  double get selectedTip => _selectedTip;
  bool get paymentProcessing => _paymentProcessing;

  double get subtotal => _cart.values.fold(0, (s, i) => s + i.total);
  double get tipAmount => subtotal * _selectedTip;
  double get total => subtotal + tipAmount;
  int get cartCount => _cart.values.fold(0, (s, i) => s + i.quantity);

  void addToCart(MenuItem item) {
    if (_cart.containsKey(item.id)) {
      _cart[item.id]!.quantity++;
    } else {
      _cart[item.id] = CartItem(item: item, quantity: 1);
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    if (_cart.containsKey(itemId)) {
      if (_cart[itemId]!.quantity > 1) {
        _cart[itemId]!.quantity--;
      } else {
        _cart.remove(itemId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _selectedTip = 0;
    notifyListeners();
  }

  void setScreen(int screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setTip(double tip) {
    _selectedTip = tip;
    notifyListeners();
  }

  void setPaymentProcessing(bool v) {
    _paymentProcessing = v;
    notifyListeners();
  }

  void toggleItemActive(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].isActive = !_items[idx].isActive;
      notifyListeners();
    }
  }

  void addItem(MenuItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(MenuItem updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) { _items[idx] = updated; notifyListeners(); }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    _cart.remove(id);
    notifyListeners();
  }

  Future<void> processPayment() async {
    setPaymentProcessing(true);
    await Future.delayed(const Duration(seconds: 2));
    setPaymentProcessing(false);
    setScreen(3);
    await Future.delayed(const Duration(seconds: 3));
    clearCart();
    setScreen(0);
  }
}

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────
class CloverPOSApp extends StatelessWidget {
  const CloverPOSApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: AppState(),
      child: MaterialApp(
        title: 'Swift POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AppShell(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SIMPLE STATE MANAGEMENT (no extra packages)
// ─────────────────────────────────────────────
class ChangeNotifierProvider extends InheritedNotifier<AppState> {
  const ChangeNotifierProvider({
    super.key,
    required AppState create,
    required super.child,
  }) : super(notifier: create);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChangeNotifierProvider>()!.notifier!;
  }
}

// ─────────────────────────────────────────────
//  APP SHELL – routes between screens
// ─────────────────────────────────────────────
class AppShell extends StatelessWidget {
  const AppShell({super.key});
  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    switch (state.currentScreen) {
      case 0: return const SalesScreen();
      case 1: return const CheckoutScreen();
      case 2: return const PaymentScreen();
      case 3: return const SuccessScreen();
      case 4: return const ManageItemsScreen();
      default: return const SalesScreen();
    }
  }
}

// ─────────────────────────────────────────────
//  SCREEN 1 — SALES
// ─────────────────────────────────────────────
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    final items = state.activeItems;
    final categories = ['All', ...{...items.map((i) => i.category)}];
    final filtered = _selectedCategory == 'All'
        ? items
        : items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, state),
          _buildCategoryBar(categories),
          Expanded(child: _buildGrid(filtered, state)),
          if (state.cartCount > 0) _buildCartBar(state, context),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(children: [
        // Logo
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia'))),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Swift POS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
          Text('Event Sales Terminal', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 0.2)),
        ]),
        const Spacer(),
        _headerBtn(Icons.bar_chart_rounded, 'Reports', () {}),
        const SizedBox(width: 8),
        _headerBtn(Icons.tune_rounded, 'Manage', () => ChangeNotifierProvider.of(context).setScreen(4)),
      ]),
    );
  }

  Widget _headerBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Icon(icon, size: 15, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildCategoryBar(List<String> categories) {
    return Container(
      height: 46,
      color: AppTheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final sel = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
              ),
              child: Center(child: Text(cat, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppTheme.textSecondary,
              ))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<MenuItem> items, AppState state) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textMuted),
        const SizedBox(height: 12),
        Text('No active items', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
      ]));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.88,
        crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _ItemCard(item: items[i], state: state),
    );
  }

  Widget _buildCartBar(AppState state, BuildContext context) {
    return GestureDetector(
      onTap: () => state.setScreen(1),
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${state.cartCount} item${state.cartCount != 1 ? 's' : ''} in cart',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('\$${state.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Review Order', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ]),
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  final MenuItem item;
  final AppState state;
  const _ItemCard({required this.item, required this.state});
  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _tapCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _tapCtrl.dispose(); super.dispose(); }

  void _onTap() async {
    HapticFeedback.lightImpact();
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
    widget.state.addToCart(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final qty = widget.state.cart[widget.item.id]?.quantity ?? 0;
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: qty > 0 ? AppTheme.accent : AppTheme.border, width: qty > 0 ? 2 : 1),
            boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(widget.item.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(widget.item.name, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\$${widget.item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ]),
            ),
            if (qty > 0) Positioned(
              top: 6, right: 6,
              child: GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); widget.state.removeFromCart(widget.item.id); },
                child: Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                  child: Center(child: Text('$qty', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w800))),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 2 — CHECKOUT (Order Review + Tip)
// ─────────────────────────────────────────────
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _buildOrderCard(state),
            const SizedBox(height: 16),
            _buildTipCard(state),
            const SizedBox(height: 16),
            _buildSummaryCard(state),
          ]),
        )),
        _buildPayButton(context, state),
      ])),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => ChangeNotifierProvider.of(context).setScreen(0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order Review', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('Confirm items & tip', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  Widget _buildOrderCard(AppState state) {
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.accent),
          const SizedBox(width: 8),
          const Text('Order Items', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text('${state.cartCount} items', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 14),
        ...state.cart.values.map((ci) => _CartRow(cartItem: ci, state: state)),
      ]),
    );
  }

  Widget _buildTipCard(AppState state) {
    final tips = [0.0, 0.15, 0.18, 0.20, 0.25];
    final labels = ['No Tip', '15%', '18%', '20%', '25%'];
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.volunteer_activism_rounded, size: 18, color: AppTheme.accent),
          SizedBox(width: 8),
          Text('Add a Tip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 14),
        Row(children: List.generate(tips.length, (i) {
          final sel = state.selectedTip == tips[i];
          return Expanded(child: GestureDetector(
            onTap: () => state.setTip(tips[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < tips.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
              ),
              child: Column(children: [
                Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textPrimary)),
                if (tips[i] > 0) ...[
                  const SizedBox(height: 2),
                  Text('\$${(state.subtotal * tips[i]).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 10, color: sel ? Colors.white70 : AppTheme.textMuted)),
                ],
              ]),
            ),
          ));
        })),
      ]),
    );
  }

  Widget _buildSummaryCard(AppState state) {
    return _Card(
      child: Column(children: [
        _SummaryRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _SummaryRow('Tip (${(state.selectedTip * 100).toInt()}%)', '\$${state.tipAmount.toStringAsFixed(2)}'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: AppTheme.border, height: 1),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('\$${state.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accent)),
        ]),
      ]),
    );
  }

  Widget _buildPayButton(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => state.setScreen(2),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppTheme.success,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Pay Now  •  \$${state.total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem cartItem;
  final AppState state;
  const _CartRow({required this.cartItem, required this.state});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(cartItem.item.emoji, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cartItem.item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Text('\$${cartItem.item.price.toStringAsFixed(2)} each', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ])),
        Row(children: [
          _QtyBtn(icon: Icons.remove_rounded, onTap: () => state.removeFromCart(cartItem.item.id)),
          Container(
            width: 32,
            child: Center(child: Text('${cartItem.quantity}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
          ),
          _QtyBtn(icon: Icons.add_rounded, onTap: () => state.addToCart(cartItem.item)),
        ]),
        const SizedBox(width: 8),
        Text('\$${cartItem.total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(7), border: Border.all(color: AppTheme.border)),
      child: Icon(icon, size: 14, color: AppTheme.textPrimary),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    ],
  );
}

// ─────────────────────────────────────────────
//  SCREEN 3 — PAYMENT
// ─────────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Column(children: [
        _buildHeader(context, state),
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildAmountDisplay(state),
            const SizedBox(height: 40),
            _buildPaymentMethods(state),
            const SizedBox(height: 40),
            if (state.paymentProcessing) _buildProcessing() else _buildTapPrompt(),
          ]),
        ))),
      ])),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(color: AppTheme.surface, border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        GestureDetector(
          onTap: () => state.setScreen(1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('Clover terminal active', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Terminal Ready', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAmountDisplay(AppState state) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(children: [
        const Text('TOTAL DUE', style: TextStyle(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Text('\$${state.total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -2, fontFamily: 'Georgia')),
        if (state.tipAmount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
            child: Text('Includes \$${state.tipAmount.toStringAsFixed(2)} tip',
              style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }

  Widget _buildPaymentMethods(AppState state) {
    final methods = [
      {'icon': Icons.contactless_rounded, 'label': 'Tap'},
      {'icon': Icons.credit_card_rounded, 'label': 'Chip'},
      {'icon': Icons.swipe_rounded, 'label': 'Swipe'},
    ];
    return Row(children: methods.map((m) {
      return Expanded(child: GestureDetector(
        onTap: () { HapticFeedback.mediumImpact(); state.processPayment(); },
        child: Container(
          margin: EdgeInsets.only(right: methods.last == m ? 0 : 10),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
            boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(children: [
            Icon(m['icon'] as IconData, size: 30, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(m['label'] as String,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ]),
        ),
      ));
    }).toList());
  }

  Widget _buildProcessing() {
    return Column(children: [
      AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05 + 0.08 * _pulseCtrl.value),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary.withOpacity(0.2 + 0.3 * _pulseCtrl.value), width: 2),
          ),
          child: const Center(child: SizedBox(
            width: 36, height: 36,
            child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
          )),
        ),
      ),
      const SizedBox(height: 16),
      const Text('Processing Payment...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      const SizedBox(height: 6),
      const Text('Please keep card in place', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildTapPrompt() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentLight.withOpacity(0.5 + 0.5 * _pulseCtrl.value),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.contactless_rounded, size: 40, color: AppTheme.accent)),
        ),
        const SizedBox(height: 16),
        const Text('Ready for Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        const Text('Tap a payment method above to process', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 4 — SUCCESS
// ─────────────────────────────────────────────
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});
  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    return Scaffold(
      backgroundColor: AppTheme.successLight,
      body: SafeArea(child: Center(child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 110, height: 110,
              decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Payment Approved!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontFamily: 'Georgia')),
          const SizedBox(height: 8),
          Text('\$${state.total.toStringAsFixed(2)} charged successfully',
            style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10)],
            ),
            child: Row(children: [
              const Icon(Icons.receipt_rounded, color: AppTheme.success, size: 22),
              const SizedBox(width: 10),
              const Text('Receipt sent • Order recorded in Clover',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(height: 50),
          const Text('Returning to sales...', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          const SizedBox(width: 200, child: LinearProgressIndicator(
            color: AppTheme.success,
            backgroundColor: Color(0xFFB8E8D4),
          )),
        ]),
      ))),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 5 — MANAGE ITEMS
// ─────────────────────────────────────────────
class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});
  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ChangeNotifierProvider.of(context);
    final items = state.items;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Column(children: [
        _buildHeader(context, state),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: items.length,
          itemBuilder: (ctx, i) => _ManageItemRow(item: items[i], state: state),
        )),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showItemDialog(context, state, null),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    final active = state.items.where((i) => i.isActive).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(color: AppTheme.surface, border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        GestureDetector(
          onTap: () => state.setScreen(0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manage Items', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('$active active • ${state.items.length} total', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  void _showItemDialog(BuildContext context, AppState state, MenuItem? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(2) : '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🍔');
    String category = existing?.category ?? 'Food';
    final categories = ['Food', 'Drinks', 'Snacks', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModalState) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(existing == null ? 'Add New Item' : 'Edit Item',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Spacer(),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              SizedBox(width: 70, child: _inputField('Emoji', emojiCtrl, center: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('Item Name', nameCtrl)),
            ]),
            const SizedBox(height: 12),
            _inputField('Price (\$)', priceCtrl, isNumber: true),
            const SizedBox(height: 12),
            const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(children: categories.map((cat) {
              final sel = cat == category;
              return GestureDetector(
                onTap: () => setModalState(() => category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
                  ),
                  child: Text(cat, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList()),
            const SizedBox(height: 24),
            Row(children: [
              if (existing != null) ...[
                GestureDetector(
                  onTap: () { state.deleteItem(existing.id); Navigator.pop(context); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppTheme.dangerLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete_rounded, color: AppTheme.danger, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: GestureDetector(
                onTap: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  if (name.isEmpty || price <= 0) return;
                  if (existing == null) {
                    state.addItem(MenuItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name, price: price, isActive: true,
                      emoji: emojiCtrl.text.trim().isEmpty ? '🍔' : emojiCtrl.text.trim(),
                      category: category,
                    ));
                  } else {
                    state.updateItem(MenuItem(
                      id: existing.id, name: name, price: price,
                      isActive: existing.isActive,
                      emoji: emojiCtrl.text.trim().isEmpty ? '🍔' : emojiCtrl.text.trim(),
                      category: category,
                    ));
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(
                    existing == null ? 'Add Item' : 'Save Changes',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  )),
                ),
              )),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      )),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {bool isNumber = false, bool center = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: TextField(
          controller: ctrl,
          textAlign: center ? TextAlign.center : TextAlign.start,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: InputBorder.none,
          ),
        ),
      ),
    ]);
  }
}

class _ManageItemRow extends StatelessWidget {
  final MenuItem item;
  final AppState state;
  const _ManageItemRow({required this.item, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.isActive ? AppTheme.border : AppTheme.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4)],
      ),
      child: Opacity(
        opacity: item.isActive ? 1.0 : 0.55,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.isActive ? AppTheme.accentLight : AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 22))),
          ),
          title: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          subtitle: Text('${item.category}  •  \$${item.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () => (context.findAncestorStateOfType<_ManageItemsScreenState>()!)
                  ._showItemDialog(context, state, item),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); state.toggleItemActive(item.id); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 26,
                decoration: BoxDecoration(
                  color: item.isActive ? AppTheme.success : AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: item.isActive ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
      boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}