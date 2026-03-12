import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../../../core/session/session_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final UserService _userService = UserService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Map<String,dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {

    final u = await SessionManager.getUser();

    if (!mounted) return;

    if (u != null) {

      setState(() {

        user = u;

        _nameController.text = u['nombre'] ?? "";
        _emailController.text = u['email'] ?? "";
        _phoneController.text = u['telefono'] ?? "";

      });

    }

  }

  void _showMessage(String msg,{bool ok=false}){

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

  }

  Future<void> _updateName() async {

    if(_nameController.text.trim().isEmpty){
      _showMessage("El nombre no puede estar vacío");
      return;
    }

    setState(()=>_loading=true);

    final result = await _userService.updateName(
      _nameController.text.trim(),
    );

    if (!mounted) return;

    setState(()=>_loading=false);

    if(result["success"]){

      await _loadUser();

      _showMessage("Nombre actualizado",ok:true);

    }else{

      _showMessage(result["error"]);

    }

  }

  Future<void> _updateEmail() async {

    String email = _emailController.text.trim();

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(!emailRegex.hasMatch(email)){
      _showMessage("Correo inválido");
      return;
    }

    setState(()=>_loading=true);

    final result = await _userService.updateEmail(
      user!["email"],
      email,
    );

    if (!mounted) return;

    setState(()=>_loading=false);

    if(result["success"]){

      await _loadUser();

      _showMessage("Correo actualizado",ok:true);

    }else{

      _showMessage(result["error"]);

    }

  }

  Future<void> _updatePhone() async {

    String phone = _phoneController.text.trim();

    final phoneRegex = RegExp(r'^[0-9]{7,15}$');

    if(!phoneRegex.hasMatch(phone)){
      _showMessage("Teléfono inválido. Solo números.");
      return;
    }

    setState(()=>_loading=true);

    final result = await _userService.updatePhone(
      user!["telefono"],
      phone,
    );

    if (!mounted) return;

    setState(()=>_loading=false);

    if(result["success"]){

      await _loadUser();

      _showMessage("Teléfono actualizado",ok:true);

    }else{

      _showMessage(result["error"]);

    }

  }

  Future<void> _updatePassword() async {

    if(_newPasswordController.text.length < 6){

      _showMessage("La contraseña debe tener mínimo 6 caracteres");
      return;

    }

    if(_newPasswordController.text !=
        _confirmPasswordController.text){

      _showMessage("Las contraseñas no coinciden");
      return;

    }

    setState(()=>_loading=true);

    final result = await _userService.updatePassword(

      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),

    );

    if (!mounted) return;

    setState(()=>_loading=false);

    if(result["success"]){

      _showMessage("Contraseña actualizada",ok:true);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

    }else{

      _showMessage(result["error"]);

    }

  }

  Widget _input(String label,TextEditingController c,
      {bool pass=false, TextInputType type = TextInputType.text}){

    return TextField(
      controller:c,
      obscureText:pass,
      keyboardType:type,
      decoration:InputDecoration(labelText:label),
    );

  }

  @override
  Widget build(BuildContext context) {

    if(user==null){

      return const Scaffold(
        body:Center(child:CircularProgressIndicator()),
      );

    }

    return Scaffold(

      appBar:AppBar(
        title:const Text("Editar perfil"),
      ),

      body:SingleChildScrollView(

        padding:const EdgeInsets.all(20),

        child:Column(

          children:[

            _input("Nombre",_nameController),

            const SizedBox(height:10),

            ElevatedButton(
              onPressed:_updateName,
              child:const Text("Actualizar nombre"),
            ),

            const Divider(),

            _input("Correo",_emailController),

            const SizedBox(height:10),

            ElevatedButton(
              onPressed:_updateEmail,
              child:const Text("Actualizar correo"),
            ),

            const Divider(),

            _input("Teléfono",_phoneController,type: TextInputType.phone),

            const SizedBox(height:10),

            ElevatedButton(
              onPressed:_updatePhone,
              child:const Text("Actualizar teléfono"),
            ),

            const Divider(),

            _input("Contraseña actual",_currentPasswordController,pass:true),
            _input("Nueva contraseña",_newPasswordController,pass:true),
            _input("Confirmar contraseña",_confirmPasswordController,pass:true),

            const SizedBox(height:10),

            ElevatedButton(
              onPressed:_updatePassword,
              child:const Text("Cambiar contraseña"),
            ),

            if(_loading)
              const Padding(
                padding:EdgeInsets.all(20),
                child:CircularProgressIndicator(),
              )

          ],

        ),

      ),

    );

  }

}