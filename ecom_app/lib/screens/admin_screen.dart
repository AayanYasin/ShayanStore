import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/theme.dart';

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 80, color: AppTheme.secondaryColor),
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
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/orders'));
      if (response.statusCode == 200) setState(() { orders = jsonDecode(response.body); });
    } finally {
      if(mounted) setState(() => isLoading = false);
    }
  }

  Future<void> markDone(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/update_order'),
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
                  subtitle: Text('Total: Rs. ${order['total']}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
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
