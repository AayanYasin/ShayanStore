import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/theme.dart';

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
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/my_orders?user_id=${widget.userId}'));
      if (response.statusCode == 200) setState(() { orders = jsonDecode(response.body); });
    } finally {
      if(mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.primaryColor,
              width: double.infinity,
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: AppTheme.primaryColor)),
                  const SizedBox(height: 12),
                  const Text('Customer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('ID: ${widget.userId}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              child: orders.isEmpty 
                ? const Center(child: Text("You haven't placed any orders yet.", style: TextStyle(fontSize: 16, color: Colors.grey)))
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(16),
                        title: Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        subtitle: Text('Total: Rs. ${order['total']}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(order['status'], style: TextStyle(color: isPending ? Colors.orange.shade900 : Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
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
                                        Text('Rs. ${product['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            ),
          ],
        ),
    );
  }
}
