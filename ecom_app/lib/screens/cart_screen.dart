import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/theme.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  final Map<int, dynamic> cartData;
  final Function(Map<int, dynamic>) onUpdate;
  final VoidCallback onCheckoutSuccess;
  final VoidCallback onStartShopping;

  const CartScreen({
    super.key, 
    required this.userId, 
    required this.cartData, 
    required this.onUpdate, 
    required this.onCheckoutSuccess,
    required this.onStartShopping,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<int, dynamic> _cart;
  bool isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cartData);
  }

  @override
  void didUpdateWidget(covariant CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cartData != oldWidget.cartData) {
      _cart = Map.from(widget.cartData);
    }
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
        Uri.parse('${AppConstants.baseUrl}/order'),
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')),
        );
      }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
      ),
      body: _cart.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: widget.onStartShopping,
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Start Shopping'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                )
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _cart.length,
            itemBuilder: (context, index) {
              final key = _cart.keys.elementAt(index);
              final item = _cart[key];
              final product = item['product'];
              
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200)
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(AppConstants.getProductImages(product['name'])[0], width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Text('Rs. ${product['price']}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
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
      bottomNavigationBar: _cart.isNotEmpty ? Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))]
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text('Rs. ${totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
              SizedBox(
                width: 160,
                height: 50,
                child: FilledButton(
                  onPressed: isCheckingOut ? null : _checkout,
                  child: isCheckingOut
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Check Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }
}
