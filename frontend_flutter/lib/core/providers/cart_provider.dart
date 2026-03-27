import 'package:flutter/material.dart';

class CartItem {
  final int? menuId;
  final int? ingredienteId;
  final String nombre;
  final double precio;
  int cantidad;

  CartItem({
    this.menuId,
    this.ingredienteId,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
  });

  Map<String, dynamic> toItem() {
    if (menuId != null) {
      return {'menuId': menuId, 'cantidad': cantidad};
    }
    return {'ingredienteId': ingredienteId, 'cantidad': cantidad};
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, i) => sum + i.cantidad);

  double get total =>
      _items.fold(0, (sum, i) => sum + (i.precio * i.cantidad));

  double get iva => total - (total / 1.19);

  double get subtotal => total - iva;

  bool get isEmpty => _items.isEmpty;

  void agregarMenu(Map<String, dynamic> menu, int cantidad) {
    // ← cast explícito a int para evitar comparación dynamic == int fallida
    final id = int.parse(menu['id'].toString());

    final index = _items.indexWhere((i) => i.menuId == id);

    if (index != -1) {
      _items[index].cantidad += cantidad;
    } else {
      _items.add(
        CartItem(
          menuId: id,
          nombre: menu['nombre'].toString(),
          precio: double.parse(menu['precio'].toString()),
          cantidad: cantidad,
        ),
      );
    }
    notifyListeners();
  }

  void agregarIngrediente(Map<String, dynamic> ingrediente, int cantidad) {
    // ← cast explícito a int
    final id = int.parse(ingrediente['id'].toString());

    final index = _items.indexWhere((i) => i.ingredienteId == id);

    if (index != -1) {
      _items[index].cantidad += cantidad;
    } else {
      _items.add(
        CartItem(
          ingredienteId: id,
          nombre: ingrediente['nombre'].toString(),
          precio: double.parse(ingrediente['precio'].toString()),
          cantidad: cantidad,
        ),
      );
    }
    notifyListeners();
  }

  void eliminarItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void incrementar(int index) {
    _items[index].cantidad++;
    notifyListeners();
  }

  void decrementar(int index) {
    if (_items[index].cantidad > 1) {
      _items[index].cantidad--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> buildItems() {
    return _items.map((i) => i.toItem()).toList();
  }
}