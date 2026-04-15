import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  final int initialQuantity;
  final Function(int) onUpdateQuantity;

  const ProductDetailScreen({
    super.key, 
    required this.product, 
    required this.initialQuantity,
    required this.onUpdateQuantity,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<String> images;
  late int _localQuantity;

  @override
  void initState() {
    super.initState();
    images = AppConstants.getProductImages(widget.product['name']);
    _localQuantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(icon: const Icon(Icons.share, color: Colors.black87), onPressed: () {}),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 450,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final img = Image.network(images[index], fit: BoxFit.cover, width: double.infinity);
                      return index == 0 ? Hero(tag: 'product_image_${widget.product['id']}', child: img) : img;
                    },
                  ),
                  Positioned(
                    bottom: 20, right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_currentPage + 1}/${images.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Title
                    Text('Rs. ${widget.product['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                    const SizedBox(height: 8),
                    Text(widget.product['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3)),
                    
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const Icon(Icons.star_half, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text('4.8 (120 reviews)', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const Divider(height: 48),
                    
                    const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.product['description'] ?? 'High quality product available at the best price. Free shipping included.', style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                    
                     const SizedBox(height: 24),
                     // Mock Delivery options
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.grey.shade100,
                         borderRadius: BorderRadius.circular(12)
                       ),
                       child: Column(
                         children: [
                           Row(children: [
                             const Icon(Icons.local_shipping_outlined, color: Colors.grey),
                             const SizedBox(width: 12),
                             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                               Text('Standard Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                               Text('3 - 5 Days', style: TextStyle(color: Colors.grey, fontSize: 12))
                             ])),
                             const Text('Free', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                           ]),
                         ],
                       ),
                     ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.storefront_outlined), tooltip: 'Store'),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), tooltip: 'Chat'),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: _localQuantity > 0 
                     ? Container(
                         decoration: BoxDecoration(
                           color: AppTheme.primaryColor.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(25),
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: [
                             IconButton(
                               icon: const Icon(Icons.remove, color: AppTheme.primaryColor),
                               onPressed: () {
                                 setState(() => _localQuantity--);
                                 widget.onUpdateQuantity(-1);
                               },
                             ),
                             Text('$_localQuantity in Cart', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                             IconButton(
                               icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                               onPressed: () {
                                 setState(() => _localQuantity++);
                                 widget.onUpdateQuantity(1);
                               },
                             ),
                           ],
                         ),
                       )
                     : FilledButton(
                         onPressed: () {
                           setState(() => _localQuantity = 1);
                           widget.onUpdateQuantity(1);
                         },
                         child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                       ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
