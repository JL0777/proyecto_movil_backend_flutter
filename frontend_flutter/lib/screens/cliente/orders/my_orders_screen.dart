import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: const [
                Text(
                  'Mis Pedidos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryOrange,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 44,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes pedidos aún',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tus pedidos aparecerán aquí',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}