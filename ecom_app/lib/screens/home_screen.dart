import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/banner_carousel.dart';
import 'product_detail_screen.dart';
import 'auth_screen.dart'; // For drawer logout

class HomeScreen extends StatefulWidget {
  final int userId;
  final Map<int, dynamic> cart;
  final Function(dynamic, int) onUpdateCartItem;

  const HomeScreen({
    super.key, 
    required this.userId, 
    required this.cart,
    required this.onUpdateCartItem,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String searchQuery = '';
  
  // Category Mock Data
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.category, 'name': 'All'},
    {'icon': Icons.laptop, 'name': 'Laptops'},
    {'icon': Icons.phone_android, 'name': 'Phones'},
    {'icon': Icons.watch, 'name': 'Watches'},
    {'icon': Icons.headphones, 'name': 'Audio'},
  ];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/products'));
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

  List<dynamic> get filteredProducts {
    var filtered = products.where((p) => p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
    if (selectedCategory != 'All') {
      String filterWord = selectedCategory.toLowerCase().substring(0, selectedCategory.length - 1); 
      // simple hack to match "phones" -> "phone"
      filtered = filtered.where((p) => p['name'].toString().toLowerCase().contains(filterWord)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text('Shayan Mart', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)),
        toolbarHeight: 60,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                 decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false);
            },
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchProducts,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Section
                  const BannerCarousel(),
                  
                  // Categories Section
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 8),
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedCategory == categories[index]['name'];
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = categories[index]['name']),
                          child: Container(
                            width: 75,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200, width: 2)
                                  ),
                                  child: Icon(categories[index]['icon'], color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700, size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  categories[index]['name'], 
                                  style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.primaryColor : Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Flash Sale Section (Mock)
                  if (displayProducts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Text('Flash Sale', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Ending in 02:14:59', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayProducts.length > 4 ? 4 : displayProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          return SizedBox(
                            width: 160,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ProductCard(
                                product: product,
                                onTap: () {
                                  final int qty = widget.cart.containsKey(product['id']) ? widget.cart[product['id']]['quantity'] : 0;
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(
                                    product: product, 
                                    initialQuantity: qty,
                                    onUpdateQuantity: (change) => widget.onUpdateCartItem(product, change),
                                  )));
                                },
                                onAdd: () => widget.onUpdateCartItem(product, 1),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Just For You Section
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.recommend, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text('Just For You', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ),

                  displayProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No products found.', style: TextStyle(fontSize: 16, color: Colors.grey))),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7, // Adjust ratio for better looking cards
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                final int qty = widget.cart.containsKey(product['id']) ? widget.cart[product['id']]['quantity'] : 0;
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(
                                  product: product, 
                                  initialQuantity: qty,
                                  onUpdateQuantity: (change) => widget.onUpdateCartItem(product, change),
                                )));
                              },
                              onAdd: () => widget.onUpdateCartItem(product, 1),
                            );
                          },
                        ),
                      ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }
}
