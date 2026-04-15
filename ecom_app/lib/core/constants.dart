import 'package:flutter/foundation.dart';

class AppConstants {
  static const String baseUrl = kIsWeb ? 'http://127.0.0.1:8080' : 'http://10.0.2.2:8080';
  
  // Banner Image Placeholders
  static const List<String> promoBanners = [
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80', // End of season sale
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&q=80', // Up to 50% fashion
    'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?auto=format&fit=crop&q=80', // Tech Week
  ];

  static List<String> getProductImages(String name) {
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
}
