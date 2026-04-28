import 'package:flutter/material.dart';

class CocinaVoiceCommands {
  static String convertirNumeros(String texto) {
    final respaldo = {
      // Compuestos primero (más largos)
      'treinta y uno': '31', 'treinta y dos': '32',
      'treinta y tres': '33', 'treinta y cuatro': '34',
      'treinta y cinco': '35', 'treinta y seis': '36',
      'treinta y siete': '37', 'treinta y ocho': '38',
      'treinta y nueve': '39', 'cuarenta y uno': '41',
      'cuarenta y dos': '42', 'cuarenta y tres': '43',
      'cuarenta y cuatro': '44', 'cuarenta y cinco': '45',
      'cincuenta y uno': '51', 'cincuenta y dos': '52',
      'veintiuno': '21', 'veintidós': '22', 'veintidos': '22',
      'veintitrés': '23', 'veintitres': '23', 'veinticuatro': '24',
      'veinticinco': '25', 'veintiséis': '26', 'veintiseis': '26',
      'veintisiete': '27', 'veintiocho': '28', 'veintinueve': '29',
      // Simples
      'cero': '0', 'uno': '1', 'dos': '2', 'tres': '3',
      'cuatro': '4', 'cinco': '5', 'seis': '6', 'siete': '7',
      'ocho': '8', 'nueve': '9', 'diez': '10', 'once': '11',
      'doce': '12', 'trece': '13', 'catorce': '14', 'quince': '15',
      'dieciséis': '16', 'dieciseis': '16', 'diecisiete': '17',
      'dieciocho': '18', 'diecinueve': '19', 'veinte': '20',
      'treinta': '30', 'cuarenta': '40', 'cincuenta': '50',
    };

    final claves = respaldo.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final palabra in claves) {
      texto = texto.replaceAll(palabra, respaldo[palabra]!);
    }
    return texto;
  }

  // Retorna índice del tab o -1 si no es navegación
  static int detectarNavegacion(String texto) {
    if (texto.contains('nuevos') ||
        texto.contains('nuevo') ||
        texto.contains('pendientes') ||
        texto.contains('pendiente')) {
      return 1;
    }
    if (texto.contains('preparación') ||
        texto.contains('preparacion') ||
        texto.contains('preparando') ||
        texto.contains('activos') ||
        texto.contains('en proceso')) {
      return 0;
    }
    if (texto.contains('realizados') ||
        texto.contains('realizado') ||
        texto.contains('listos') ||
        texto.contains('terminados') ||
        texto.contains('hechos')) {
      return 2;
    }
    return -1;
  }

  static void procesarPedido({
    required String texto,
    required List<dynamic> pedidos,
    required Function(int, String) onCambiarEstado,
    required Function(Map<String, dynamic>, int) onVerPedido,
    required Function(Map<String, dynamic>, int) onVerCliente,
    required Function(String, Color) onFeedback,
  }) {
    final regExp = RegExp(r'pedido\s+(\d+)');
    final match = regExp.firstMatch(texto);

    if (match == null) {
      onFeedback('No entendí el número de pedido', Colors.red);
      return;
    }

    final numeroPedido = int.parse(match.group(1)!);
    if (numeroPedido < 1 || numeroPedido > pedidos.length) {
      onFeedback('Pedido #$numeroPedido no existe', Colors.red);
      return;
    }

    // ✅ Buscar por posición en la lista
    final pedido = pedidos[numeroPedido - 1];

    if (texto.contains('activo') ||
        texto.contains('preparar') ||
        texto.contains('en proceso')) {
      onCambiarEstado(pedido['id'], 'Activo');
      onFeedback('Pedido #$numeroPedido → Activo ✓', Colors.orange);
    } else if (texto.contains('realizado') ||
        texto.contains('listo') ||
        texto.contains('terminado') ||
        texto.contains('hecho')) {
      onCambiarEstado(pedido['id'], 'Realizado');
      onFeedback('Pedido #$numeroPedido → Realizado ✓', Colors.green);
    } else if (texto.contains('enviado') ||
        texto.contains('enviar') ||
        texto.contains('despachar') ||
        texto.contains('despachado')) {
      onCambiarEstado(pedido['id'], 'Enviado');
      onFeedback('Pedido #$numeroPedido → Enviado ✓', Colors.blue);
    } else if (texto.contains('cliente') ||
        texto.contains('información') ||
        texto.contains('informacion') ||
        texto.contains('info')) {
      onVerCliente(pedido, numeroPedido);
      onFeedback('Abriendo cliente #$numeroPedido ✓', Colors.teal);
    } else if (texto.contains('detalle') ||
        texto.contains('ver') ||
        texto.contains('mostrar') ||
        texto.contains('abrir')) {
      onVerPedido(pedido, numeroPedido);
      onFeedback('Abriendo pedido #$numeroPedido ✓', Colors.indigo);
    } else {
      onFeedback('Di: "pedido 3 activo", "pedido 5 listo"', Colors.red);
    }
  }
}
