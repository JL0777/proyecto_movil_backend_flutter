import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';

class CartModal extends StatelessWidget {
  const CartModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.lightOrange,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryOrange, width: 2),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: AppTheme.primaryOrange,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agrega productos para continuar',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}