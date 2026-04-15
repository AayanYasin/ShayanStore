import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import '../core/theme.dart';

class MainNavigation extends StatefulWidget {
  final int userId;
  const MainNavigation({super.key, required this.userId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Map<int, dynamic> cart = {}; // Shared cart state

  void updateCart(Map<int, dynamic> newCart) {
    setState(() {
      cart = Map<int, dynamic>.from(newCart);
    });
  }

  void clearCart() {
    setState(() {
      cart = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        userId: widget.userId, 
        cart: cart, 
        onUpdateCartItem: (product, change) {
          setState(() {
            int id = product['id'];
            final newCart = Map<int, dynamic>.from(cart);
            if (newCart.containsKey(id)) {
              newCart[id]['quantity'] += change;
              if (newCart[id]['quantity'] <= 0) {
                newCart.remove(id);
              }
            } else if (change > 0) {
              newCart[id] = {'product': product, 'quantity': change};
            }
            cart = newCart;
          });
          
          if (change > 0) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Added ${product['name']} to cart'), 
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: AppTheme.primaryColor,
            ));
          }
        }
      ),
      CartScreen(
        userId: widget.userId,
        cartData: cart,
        onUpdate: updateCart,
        onCheckoutSuccess: clearCart,
        onStartShopping: () {
          setState(() => _currentIndex = 0);
        },
      ),
      OrderHistoryScreen(userId: widget.userId),
    ];

    int totalItems = cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ClipRRect(
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                selectedItemColor: AppTheme.primaryColor,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                items: [
                  const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                    icon: Badge(
                      label: Text('$totalItems'),
                      isLabelVisible: totalItems > 0,
                      child: const Icon(Icons.shopping_cart),
                    ), 
                    label: 'Cart'
                  ),
                  const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
