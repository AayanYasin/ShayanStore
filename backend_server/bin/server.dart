import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Database connection settings
final settings = ConnectionSettings(
  host: 'localhost',
  port: 3306,
  user: 'root', // Default XAMPP user
  db: 'ecom_db',
);

// Helper for CORS headers
Response _corsResponse(Response response) {
  return response.change(headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  });
}

// Middleware to handle CORS OPTIONS requests
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return _corsResponse(Response.ok(''));
      }
      final response = await innerHandler(request);
      return _corsResponse(response);
    };
  };
}

void main() async {
  final router = Router();

  // ---------------- AUTH ROUTES ----------------

  // POST /signup
  router.post('/signup', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    
    final email = data['email'];
    final password = data['password'];
    final phone = data['phone'] ?? '';
    final address = data['address'] ?? '';

    final conn = await MySqlConnection.connect(settings);
    
    // Check if email exists
    final check = await conn.query('SELECT id FROM users WHERE email = ?', [email]);
    if (check.isNotEmpty) {
      await conn.close();
      return Response.forbidden(jsonEncode({'error': 'Email already exists'}), headers: {'Content-Type': 'application/json'});
    }

    // Insert user with phone and address
    final result = await conn.query(
      'INSERT INTO users (email, password, phone, address) VALUES (?, ?, ?, ?)',
      [email, password, phone, address]
    );
    await conn.close();

    return Response.ok(jsonEncode({'message': 'Signup successful', 'user_id': result.insertId}), headers: {'Content-Type': 'application/json'});
  });

  // POST /login
  router.post('/login', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    
    final email = data['email'];
    final password = data['password'];

    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query(
      'SELECT id FROM users WHERE email = ? AND password = ?',
      [email, password]
    );
    await conn.close();

    if (results.isEmpty) {
      return Response.forbidden(jsonEncode({'error': 'Invalid credentials'}), headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode({'message': 'Login successful', 'user_id': results.first['id']}), headers: {'Content-Type': 'application/json'});
  });

  // ---------------- SHOP ROUTES ----------------

  // GET /products
  router.get('/products', (Request request) async {
    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query('SELECT * FROM products');
    await conn.close();

    final products = results.map((row) => {
      'id': row['id'],
      'name': row['name'],
      'description': row['description'].toString(),
      'price': row['price'],
    }).toList();

    return Response.ok(jsonEncode(products), headers: {'Content-Type': 'application/json'});
  });

  // POST /order (Place an order)
  router.post('/order', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    
    final userId = data['user_id'];
    final items = data['items']; // stringified JSON
    final total = data['total'];

    final conn = await MySqlConnection.connect(settings);
    await conn.query(
      'INSERT INTO orders (user_id, items, total, status) VALUES (?, ?, ?, ?)',
      [userId, items, total, 'Pending']
    );
    await conn.close();

    return Response.ok(jsonEncode({'message': 'Order placed successfully'}), headers: {'Content-Type': 'application/json'});
  });

  // GET /my_orders (Order history for a specific user)
  router.get('/my_orders', (Request request) async {
    final queryParams = request.url.queryParameters;
    final userId = queryParams['user_id'];

    if (userId == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Missing user_id'}));
    }

    final conn = await MySqlConnection.connect(settings);
    // Join with users to also return shipping info for frontend display if needed, but simple is fine.
    // Wait, the frontend wants to display address and phone inside the history? We can just send it along.
    final results = await conn.query('''
      SELECT orders.*, users.phone, users.address
      FROM orders 
      JOIN users ON orders.user_id = users.id 
      WHERE orders.user_id = ? 
      ORDER BY orders.id DESC
    ''', [userId]);
    await conn.close();

    final orders = results.map((row) => {
      'id': row['id'],
      'items': row['items'].toString(),
      'total': row['total'],
      'status': row['status'],
      'phone': row['phone'].toString(),
      'address': row['address'].toString(),
    }).toList();

    return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
  });

  // ---------------- ADMIN ROUTES ----------------

  // GET /orders (Admin sees all orders with full user details)
  router.get('/orders', (Request request) async {
    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query('''
      SELECT orders.*, users.email, users.phone, users.address 
      FROM orders 
      JOIN users ON orders.user_id = users.id 
      ORDER BY orders.id DESC
    ''');
    await conn.close();

    final orders = results.map((row) => {
      'id': row['id'],
      'email': row['email'],
      'phone': row['phone'].toString(),
      'address': row['address'].toString(),
      'items': row['items'].toString(),
      'total': row['total'],
      'status': row['status'],
    }).toList();

    return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
  });

  // POST /update_order (Admin updates status)
  router.post('/update_order', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final orderId = data['id'];

    final conn = await MySqlConnection.connect(settings);
    await conn.query(
      'UPDATE orders SET status = ? WHERE id = ?',
      ['Completed', orderId]
    );
    await conn.close();

    return Response.ok(jsonEncode({'message': 'Order updated successfully'}), headers: {'Content-Type': 'application/json'});
  });

  // ---------------- SERVER START ----------------
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server listening on port ${server.port}');
}
