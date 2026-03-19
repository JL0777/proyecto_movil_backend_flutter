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

  double get subtotal =>
      _items.fold(0, (sum, i) => sum + (i.precio * i.cantidad));

  double get iva => subtotal * 0.19;

  double get total => subtotal + iva;

  bool get isEmpty => _items.isEmpty;

  void agregarMenu(Map<String, dynamic> menu, int cantidad) {
    final id = menu['id'];
    final existente = _items.firstWhere(
      (i) => i.menuId == id,
      orElse: () => CartItem(menuId: -1, nombre: '', precio: 0),
    );

    if (existente.menuId == id) {
      existente.cantidad += cantidad;
    } else {
      _items.add(CartItem(
        menuId: id,
        nombre: menu['nombre'],
        precio: double.parse(menu['precio'].toString()),
        cantidad: cantidad,
      ));
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