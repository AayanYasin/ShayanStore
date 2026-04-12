import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

const String baseUrl = kIsWeb ? 'http://127.0.0.1:8080' : 'http://10.0.2.2:8080';

void main() {
  runApp(const EcomApp());
}

class EcomApp extends StatelessWidget {
  const EcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shayan Store',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A), brightness: Brightness.light),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true, elevation: 0, 
          backgroundColor: Colors.transparent, foregroundColor: Color(0xFF1E3A8A),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          )
        )
      ),
      home: const AuthScreen(),
    );
  }
}

// ================= 1. AUTHENTICATION =================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> submit() async {
    setState(() => isLoading = true);
    final endpoint = isLogin ? '/login' : '/signup';
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
          if (!isLogin) 'phone': phoneController.text.trim(),
          if (!isLogin) 'address': addressController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShopScreen(userId: data['user_id'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['error'] ?? 'Authentication failed')));
      }
    } catch (e) {
      debugPrint('Auth Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAuthScreen())),
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Login',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.storefront, size: 80, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 24),
              const Text('Shayan Store', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 8),
              Text(isLogin ? 'Welcome back' : 'Create your account', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 48),
              
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email', prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password', prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                obscureText: true,
              ),
              
              if (!isLogin) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number', prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Shipping Address', prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  maxLines: 2,
                ),
              ],
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Login", style: const TextStyle(fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= IMAGE HELPER =================
List<String> _getProductImages(String name) {
  final lower = name.toLowerCase();
  
  if (lower.contains('laptop')) {
    return [
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('headphone')) {
    return [
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1484704849700-f032a568e944?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('phone')) {
    return [
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1523206489230-c012c64b2b48?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('watch')) {
    return [
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('camera')) {
    return [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519638399535-1b036603ac77?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('console')) {
    return [
      'https://images.unsplash.com/photo-1486401899868-0e435ed85128?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('speaker')) {
    return [
      'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('keyboard')) {
    return [
      'https://images.unsplash.com/photo-1595225476474-87563907a212?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('mouse')) {
    return [
      'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?q=80&w=600&auto=format&fit=crop'
    ];
  }
  if (lower.contains('tablet')) {
    return [
      'https://images.unsplash.com/photo-1585790050230-5dd28404ccb9?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=600&auto=format&fit=crop'
    ];
  }
  
  return ['https://images.unsplash.com/photo-1605810230434-7631ac76ec81?q=80&w=600&auto=format&fit=crop'];
}

// ================= 2. SHOP MODULE =================
class ShopScreen extends StatefulWidget {
  final int userId;
  const ShopScreen({super.key, required this.userId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<dynamic> products = [];
  Map<int, dynamic> cart = {}; 
  bool isLoading = true;

  // Search, Sort, and View Filters
  String searchQuery = '';
  String sortBy = 'name_asc'; 
  bool isCompactList = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void addToCart(dynamic product) {
    setState(() {
      int id = product['id'];
      if (cart.containsKey(id)) {
        cart[id]['quantity']++;
      } else {
        cart[id] = {'product': product, 'quantity': 1};
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added ${product['name']} to cart'), 
      duration: const Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartSheet(
        cartData: cart,
        userId: widget.userId,
        onUpdate: (updatedCart) => setState(() => cart = updatedCart),
        onCheckoutSuccess: () => setState(() => cart.clear()),
      ),
    );
  }

  List<dynamic> get filteredProducts {
    var filtered = products.where((p) => p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
    filtered.sort((a, b) {
      if (sortBy == 'name_asc') return a['name'].toString().compareTo(b['name'].toString());
      if (sortBy == 'price_asc') return (a['price'] as num).compareTo(b['price'] as num);
      return (b['price'] as num).compareTo(a['price'] as num);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));
    final displayProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: totalItems > 0 ? _showCartModal : null,
              icon: Badge(
                label: Text('$totalItems'),
                isLabelVisible: totalItems > 0,
                child: const Icon(Icons.shopping_bag_outlined, size: 28),
              ),
            ),
          )
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF1E3A8A))),
                const Spacer(),
                Text('User ID: ${widget.userId}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen(userId: widget.userId)));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false);
            },
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Search & Filter Toolbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.tune),
                      tooltip: 'Sort Options',
                      onSelected: (val) => setState(() => sortBy = val),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'name_asc', child: Text('Sort by Name (A-Z)')),
                        PopupMenuItem(value: 'price_asc', child: Text('Sort by Price (Low)')),
                        PopupMenuItem(value: 'price_desc', child: Text('Sort by Price (High)')),
                      ],
                    ),
                    IconButton(
                      icon: Icon(isCompactList ? Icons.grid_view_rounded : Icons.view_list_rounded),
                      tooltip: 'Toggle View',
                      onPressed: () => setState(() => isCompactList = !isCompactList),
                    ),
                  ],
                ),
              ),
              
              // Product Display
              Expanded(
                child: displayProducts.isEmpty
                  ? const Center(child: Text('No products found matching your search.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayProducts[index];
                        final images = _getProductImages(product['name']);
                        
                        // Compact List View
                        if (isCompactList) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(
                                product: product, onAddToCart: () => addToCart(product),
                              )));
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(images[0], width: 100, height: 100, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text('PKR ${product['price']}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    IconButton.filledTonal(
                                      onPressed: () => addToCart(product),
                                      icon: const Icon(Icons.add),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // Huge Card View
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(
                                product: product, onAddToCart: () => addToCart(product),
                              )));
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: Image.network(images[0], fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                                            const SizedBox(height: 4),
                                            Text('PKR ${product['price']}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                                          ],
                                        ),
                                        IconButton.filled(
                                          onPressed: () => addToCart(product),
                                          icon: const Icon(Icons.add),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              )
            ],
          ),
    );
  }
}

// ================= 3. PRODUCT DETAILS (CAROUSEL) =================
class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  final VoidCallback onAddToCart;

  const ProductDetailScreen({super.key, required this.product, required this.onAddToCart});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<String> images;

  @override
  void initState() {
    super.initState();
    images = _getProductImages(widget.product['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(images[index], fit: BoxFit.cover, width: double.infinity);
                    },
                  ),
                  Positioned(
                    bottom: 20, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.product['name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2))),
                      const SizedBox(width: 16),
                      Text('PKR ${widget.product['price']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(widget.product['description'] ?? 'No description available.', style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 48),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))]
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () {
                widget.onAddToCart();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Add to Bag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= 4. CART & CHECKOUT =================
class CartSheet extends StatefulWidget {
  final Map<int, dynamic> cartData;
  final int userId;
  final Function(Map<int, dynamic>) onUpdate;
  final VoidCallback onCheckoutSuccess;

  const CartSheet({super.key, required this.cartData, required this.userId, required this.onUpdate, required this.onCheckoutSuccess});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  late Map<int, dynamic> _cart;
  bool isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cartData);
  }

  void _updateQuantity(int id, int change) {
    setState(() {
      _cart[id]['quantity'] += change;
      if (_cart[id]['quantity'] <= 0) {
        _cart.remove(id);
      }
      widget.onUpdate(_cart);
    });
  }

  Future<void> _checkout() async {
    setState(() => isCheckingOut = true);
    double total = _cart.values.fold(0, (sum, item) {
      double p = item['product']['price'] is int ? (item['product']['price'] as int).toDouble() : item['product']['price'];
      return sum + (p * item['quantity']);
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'items': jsonEncode(_cart.values.toList()),
          'total': total,
        }),
      );

      if (response.statusCode == 200) {
        widget.onCheckoutSuccess();
        if (!mounted) return;
        Navigator.pop(context); 
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Order Confirmed!'),
            content: const Text('Your transaction was successful. You can track this order in your History tab.'),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Great!'))],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          )
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
    } finally {
      if (mounted) setState(() => isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalValue = _cart.values.fold(0, (sum, item) {
      double p = item['product']['price'] is int ? (item['product']['price'] as int).toDouble() : item['product']['price'];
      return sum + (p * item['quantity']);
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Bag', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                IconButton(icon: const Icon(Icons.close, size: 28), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('Your bag is empty', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final key = _cart.keys.elementAt(index);
                    final item = _cart[key];
                    final product = item['product'];
                    
                    return Card(
                      elevation: 0,
                      color: Colors.grey[100],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_getProductImages(product['name'])[0], width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('PKR ${product['price']}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => _updateQuantity(key, -1), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                  Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => _updateQuantity(key, 1), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))]
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: isCheckingOut ? null : _checkout,
                    child: isCheckingOut
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Checkout  •  PKR ${totalValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// ================= 5. EXPANDABLE ORDER HISTORY =================
class OrderHistoryScreen extends StatefulWidget {
  final int userId;
  const OrderHistoryScreen({super.key, required this.userId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my_orders?user_id=${widget.userId}'));
      if (response.statusCode == 200) setState(() { orders = jsonDecode(response.body); });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : orders.isEmpty 
          ? const Center(child: Text("You haven't placed any orders yet.", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isPending = order['status'] == 'Pending';
              
              List<dynamic> items = [];
              try { items = jsonDecode(order['items']); } catch(_) {}

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  title: Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  subtitle: Text('Total: PKR ${order['total']}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(order['status'], style: TextStyle(color: isPending ? Colors.orange.shade900 : Colors.green.shade900, fontWeight: FontWeight.bold)),
                  ),
                  children: [
                    const Divider(height: 1),
                    Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Items Purchased:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ...items.map((item) {
                            final product = item['product'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item['quantity']}x ${product['name']}'),
                                  Text('PKR ${product['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 32),
                          const Text('Shipping Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(children: [const Icon(Icons.phone, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(order['phone'] ?? 'N/A')]),
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(order['address'] ?? 'N/A'))]),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}

// ================= 6. ADMIN SYSTEM =================
class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 80, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 32),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Master Password', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (passwordController.text == 'admin123') {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Master Password')));
                    }
                  },
                  child: const Text('Access Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) setState(() { orders = jsonDecode(response.body); });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> markDone(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': orderId}),
      );
      if (response.statusCode == 200) fetchOrders(); 
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Fulfillment', style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isPending = order['status'] == 'Pending';
              
              List<dynamic> items = [];
              try { items = jsonDecode(order['items']); } catch(_) {}

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  title: Text('Order #${order['id']} - ${order['email']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  subtitle: Text('Total: PKR ${order['total']}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  trailing: Icon(isPending ? Icons.pending_actions : Icons.check_circle, color: isPending ? Colors.orange : Colors.green),
                  children: [
                    const Divider(height: 1),
                    Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Customer Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Phone: ${order['phone']}'),
                          Text('Address: ${order['address']}'),
                          const Divider(height: 32),
                          const Text('Items to Fulfill:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...items.map((item) {
                            final p = item['product'];
                            return Text('• ${item['quantity']}x ${p['name']}');
                          }),
                          if (isPending) ...[
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () => markDone(order['id']),
                              style: FilledButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Mark as Shipped / Completed', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
