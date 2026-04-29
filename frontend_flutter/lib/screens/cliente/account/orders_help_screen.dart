import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrdersHelpScreen extends StatefulWidget {
  const OrdersHelpScreen({super.key});

  @override
  State<OrdersHelpScreen> createState() => _OrdersHelpScreenState();
}

class _OrdersHelpScreenState extends State<OrdersHelpScreen> with TickerProviderStateMixin {
  final List<int> _openItems = [];

  bool showPersonalizado = false;
  bool showPredeterminado = false;

  // Agregamos controladores para mantener el estilo visual
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      _openItems.contains(index)
          ? _openItems.remove(index)
          : _openItems.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          'Pedidos',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            /// HEADER
            _buildHeader(),

            const SizedBox(height: 35),

            _sectionTitle("Preguntas frecuentes"),
            const SizedBox(height: 15),

            /// -------------------- REALIZAR PEDIDO --------------------
            _faqItem(
              index: 0,
              question: "¿Cómo realizo un pedido?",
              icon: Icons.shopping_basket_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Puedes realizar pedidos de dos formas dentro de la app. Selecciona el tipo de pedido que deseas conocer:",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),

                  const SizedBox(height: 16),

                  /// BOTÓN PERSONALIZADO
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPersonalizado = !showPersonalizado;
                        showPredeterminado = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: showPersonalizado ? AppTheme.primaryOrange : AppTheme.lightOrange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Menú personalizado",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: showPersonalizado ? Colors.white : Colors.black87,
                            ),
                          ),
                          Icon(
                            showPersonalizado ? Icons.keyboard_arrow_down_rounded : Icons.arrow_forward_ios, 
                            size: 16,
                            color: showPersonalizado ? Colors.white : Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (showPersonalizado) ...[
                    const SizedBox(height: 15),
                    _stepText("1. Selecciona la opción de menú personalizado:", "Desde la pantalla principal debes elegir la opción que te permite crear tu propio pedido. Esta opción está pensada para usuarios que desean armar su comida a medida."),
                    _buildStyledImage('assets/help/pedido_opcion_personalizado.png'),

                    _stepText("2. Selecciona los ingredientes:", "Aquí eliges los ingredientes base. Puedes seleccionar varios y ajustar la cantidad exacta en gramos. Esto permite controlar porciones, dieta o preferencias personales."),
                    _buildStyledImage('assets/help/pedido_paso_ingredientes.png'),

                    _stepText("3. Añade complementos o bebidas:", "Puedes agregar productos adicionales como bebidas, papas o extras. Estos no son obligatorios pero mejoran la experiencia del pedido."),
                    _buildStyledImage('assets/help/pedido_paso_complementos.png'),

                    _stepText("4. Selecciona la dirección:", "Debes indicar dónde quieres recibir el pedido. Puedes elegir direcciones guardadas o escribir una nueva."),
                    _buildStyledImage('assets/help/pedido_paso_direccion.png'),

                    _stepText("5. Selecciona el método de pago:", "Escoge cómo pagarás el pedido. Esto puede incluir efectivo u otros métodos disponibles en la app."),
                    _buildStyledImage('assets/help/pedido_paso_pago.png'),

                    _stepText("6. Revisa el pedido:", "Aquí verificas todo: ingredientes, cantidades, dirección y precio total. Es el paso más importante para evitar errores."),
                    _buildStyledImage('assets/help/pedido_paso_revision.png'),

                    _stepText("7. Confirma el pedido:", "Una vez confirmado, el restaurante recibe la orden y comienza la preparación."),
                    _buildStyledImage('assets/help/pedido_paso_confirmar.png'),
                  ],

                  const SizedBox(height: 20),

                  /// BOTÓN PREDETERMINADO
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPredeterminado = !showPredeterminado;
                        showPersonalizado = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: showPredeterminado ? AppTheme.primaryOrange : AppTheme.lightOrange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Menú predeterminado",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: showPredeterminado ? Colors.white : Colors.black87,
                            ),
                          ),
                          Icon(
                            showPredeterminado ? Icons.keyboard_arrow_down_rounded : Icons.arrow_forward_ios, 
                            size: 16,
                            color: showPredeterminado ? Colors.white : Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (showPredeterminado) ...[
                    const SizedBox(height: 15),
                    _stepText("1. Selecciona el menú:", "Escoge uno de los menús ya preparados disponibles dentro de la aplicación. Estos menús ya vienen configurados con ingredientes definidos, por lo que no necesitas personalizar nada. Es la opción ideal si quieres hacer un pedido rápido sin perder tiempo eligiendo componentes individuales."),
                    _buildStyledImage('assets/help/menu_seleccion.png'),

                    _stepText("2. Agrégalo al carrito:", "Una vez hayas seleccionado el menú, agrégalo al carrito. Aquí puedes decidir la cantidad de unidades que deseas pedir. El carrito irá acumulando todos los productos que selecciones antes de finalizar la compra."),
                    _buildStyledImage('assets/help/menu_carrito.png'),

                    _stepText("3. Ve al carrito:", "En esta sección podrás visualizar el resumen completo de tu pedido. Aquí puedes modificar cantidades, eliminar productos o verificar el precio total antes de continuar. Es importante revisar bien este paso para evitar errores en tu compra."),
                    _buildStyledImage('assets/help/menu_carrito_vista.png'),

                    _stepText("4. Selecciona la dirección:", "Debes indicar la dirección donde deseas recibir tu pedido. Puedes escoger una dirección previamente guardada o ingresar una nueva. Asegúrate de que la información sea correcta para evitar problemas en la entrega."),
                    _buildStyledImage('assets/help/menu_direccion.png'),

                    _stepText("5. Selecciona el método de pago:", "Elige cómo deseas pagar tu pedido. Dependiendo de la aplicación, puedes tener opciones como pago en efectivo, tarjeta u otros métodos disponibles. Selecciona el que mejor se adapte a ti antes de finalizar."),
                    _buildStyledImage('assets/help/menu_pago.png'),

                    _stepText("6. Revisa el pedido:", "Antes de confirmar, verifica todos los detalles: productos seleccionados, cantidades, dirección y método de pago. Este paso es clave para asegurarte de que todo esté correcto y evitar inconvenientes."),
                    _buildStyledImage('assets/help/menu_revision.png'),

                    _stepText("7. Confirma el pedido:", "Una vez todo esté revisado, confirma tu pedido. En este momento el sistema enviará la orden al restaurante para que inicie la preparación."),
                    _buildStyledImage('assets/help/menu_confirmar.png'),
                  ],
                ],
              ),
            ),

            /// -------------------- ESTADO --------------------
            _faqItem(
              index: 1,
              question: "¿Cómo reviso el estado de mi pedido?",
              icon: Icons.track_changes_rounded,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Puedes ver el estado de tu pedido en tiempo real. Cada estado representa una etapa del proceso:"),
                  const SizedBox(height: 12),
                  _statusText("Pendiente:", "Tu pedido fue creado pero aún no ha sido procesado. En este punto puedes editarlo o cancelarlo sin problema."),
                  _buildStyledImage('assets/help/estado_pendiente.png'),
                  _statusText("Activo:", "El restaurante ya comenzó a preparar tu pedido. A partir de aquí ya no se pueden hacer cambios."),
                  _buildStyledImage('assets/help/estado_activo.png'),
                  _statusText("Realizado:", "El pedido ya fue preparado completamente y está listo para ser enviado."),
                  _buildStyledImage('assets/help/estado_preparado.png'),
                  _statusText("Enviado:", "El pedido va en camino hacia tu dirección. Solo debes esperar a recibirlo."),
                  _buildStyledImage('assets/help/estado_enviado.png'),
                ],
              ),
            ),

            /// -------------------- EDITAR / CANCELAR --------------------
            _faqItem(
              index: 2,
              question: "¿Cómo cancelar o editar un pedido?",
              icon: Icons.edit_notifications_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Puedes modificar o cancelar tu pedido únicamente cuando está en estado PENDIENTE.", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Esto significa que el restaurante aún no ha comenzado a prepararlo."),
                  const SizedBox(height: 8),
                  const Text("En este estado puedes cambiar ingredientes, dirección o incluso cancelar completamente el pedido."),
                  const SizedBox(height: 8),
                  const Text("Una vez el pedido pasa a estado ACTIVO, ya no será posible hacer cambios porque ya está en preparación.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text("Por eso es muy importante revisar todos los detalles antes de confirmar."),
                  const SizedBox(height: 15),
                  _buildStyledImage('assets/help/editar_cancelar.png'),
                ],
              ),
            ),

            /// -------------------- HISTORIAL --------------------
            _faqItem(
              index: 3,
              question: "¿Dónde puedo revisar el historial de mis pedidos?",
              icon: Icons.history_rounded,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Puedes ver todos tus pedidos en la sección 'Mis pedidos' dentro de la aplicación."),
                  const SizedBox(height: 8),
                  const Text("Allí encontrarás un historial completo con todos los pedidos realizados, organizados por estado."),
                  const SizedBox(height: 8),
                  const Text("Esto te permite hacer seguimiento, repetir pedidos anteriores o verificar información de compras pasadas."),
                  const SizedBox(height: 15),
                  _buildStyledImage('assets/help/historial_pedidos.png'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SOPORTE PARA DISEÑO UX ---

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.assignment_rounded, size: 40, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Gestión de Pedidos",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          "Todo lo que necesitas saber para comprar y rastrear tus platos favoritos",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textGrey, fontSize: 15),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _faqItem({
    required int index,
    required String question,
    required Widget content,
    required IconData icon,
  }) {
    final isOpen = _openItems.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.05) : const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggle(index),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              icon, 
              color: isOpen ? AppTheme.primaryOrange : Colors.grey,
              size: 22,
            ),
            title: Text(
              question,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isOpen ? AppTheme.primaryOrange : Colors.black87,
              ),
            ),
            trailing: AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isOpen ? AppTheme.primaryOrange : Colors.grey,
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Column(
                children: [
                  Divider(color: Colors.grey.withValues(alpha: 0.1)),
                  const SizedBox(height: 10),
                  content,
                ],
              ),
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _stepText(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryOrange)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _statusText(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
          children: [
            TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }


  Widget _buildStyledImage(String path) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}