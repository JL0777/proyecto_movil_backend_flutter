import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../account/my_addresses_screen.dart';

class DeliveryHelpScreen extends StatefulWidget {
  const DeliveryHelpScreen({super.key});

  @override
  State<DeliveryHelpScreen> createState() => _DeliveryHelpScreenState();
}

class _DeliveryHelpScreenState extends State<DeliveryHelpScreen>
    with TickerProviderStateMixin {
  final List<bool> _expanded = [false, false];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController, 
      curve: Curves.easeInOut
    );

    _fadeController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Fondo ligeramente gris para que resalten las tarjetas
      appBar: AppBar(
        title: const Text(
          'Centro de Ayuda',
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
            /// HEADER CON DISEÑO MEJORADO
            _buildAnimatedHeader(),

            const SizedBox(height: 35),

            _sectionTitle("Preguntas Frecuentes"),
            const SizedBox(height: 15),

            /// PREGUNTA 1
            _faq(
              index: 0,
              title: "¿Dónde puedo gestionar mis direcciones?",
              icon: Icons.map_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dentro de la aplicación encontrarás un apartado llamado “Mis direcciones”.",
                    style: TextStyle(height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Desde allí podrás administrar completamente tus ubicaciones de entrega.",
                    style: TextStyle(height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // CORRECCIÓN: withValues en lugar de withOpacity
                      color: AppTheme.lightOrange.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _bulletItem("Ver todas tus direcciones"),
                        _bulletItem("Agregar nuevas ubicaciones"),
                        _bulletItem("Editar direcciones existentes"),
                        _bulletItem("Eliminar lo que no necesites"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildActionButton(context),

                  const SizedBox(height: 25),

                  const Text(
                    "Además, si estás realizando un pedido y aún no tienes una dirección registrada, el sistema te permitirá crear una directamente en ese momento.",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                  ),

                  const SizedBox(height: 15),
                  _img("assets/help/delivery_addresses_screen.png"),
                ],
              ),
            ),

            /// PREGUNTA 2
            _faq(
              index: 1,
              title: "¿Qué elementos debe tener mi dirección?",
              icon: Icons.fact_check_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Para registrar correctamente una dirección, debes completar la siguiente información:",
                    style: TextStyle(height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  _field(
                    "Barrio (obligatorio)",
                    "Indica el sector o zona donde se encuentra tu vivienda.",
                    "assets/help/delivery_field_barrio.png",
                  ),

                  _field(
                    "Dirección (obligatorio)",
                    "Incluye calle, carrera y número exacto.",
                    "assets/help/delivery_field_direccion.png",
                  ),

                  _field(
                    "Tipo de vivienda (obligatorio)",
                    "Selecciona si es casa, apartamento, oficina u otro.",
                    "assets/help/delivery_field_tipo.png",
                  ),

                  _field(
                    "Torre/Apartamento (opcional)",
                    "Especifica detalles de propiedad horizontal.",
                    "assets/help/delivery_field_torre.png",
                  ),

                  _field(
                    "Instrucciones (opcional)",
                    "Agrega referencias para el repartidor.",
                    "assets/help/delivery_field_instrucciones.png",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Círculos decorativos de fondo
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                // CORRECCIÓN: withValues
                color: AppTheme.primaryOrange.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                // CORRECCIÓN: withValues
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            // El logo original estilizado
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // CORRECCIÓN: withValues
                    color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(
                  color: AppTheme.primaryOrange,
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 45,
                color: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Gestión de direcciones",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Aprende cómo registrar, editar y utilizar tus direcciones dentro de la app",
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 15,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryOrange),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyAddressesScreen(),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryOrange, Color(0xFFFF8C42)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // CORRECCIÓN: withValues
                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ir a Mis direcciones",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faq({
    required int index,
    required String title,
    required Widget content,
    required IconData icon,
  }) {
    bool isExp = _expanded[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // CORRECCIÓN: withValues
          color: isExp ? AppTheme.primaryOrange.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: withValues
            color: isExp 
                ? AppTheme.primaryOrange.withValues(alpha: 0.1) 
                : const Color(0x08000000),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: GlobalKey(), // Fuerza refresco visual
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExp ? AppTheme.primaryOrange : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: isExp ? Colors.white : Colors.grey[600]
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isExp ? AppTheme.primaryOrange : Colors.black87,
            ),
          ),
          initiallyExpanded: _expanded[index],
          onExpansionChanged: (val) {
            setState(() => _expanded[index] = val);
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 0),
              child: Divider(color: Colors.grey.withValues(alpha: 0.1), height: 1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: content,
            )
          ],
        ),
      ),
    );
  }

  Widget _img(String path) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: withValues
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _field(String title, String desc, String img) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 3,
              backgroundColor: AppTheme.primaryOrange,
            ),
            const SizedBox(width: 8),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          desc, 
          style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)
        ),
        const SizedBox(height: 12),
        _img(img),
        const SizedBox(height: 24),
      ],
    );
  }
}