import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inventory_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final _profilesStream = Supabase.instance.client
      .from('perfiles')
      .stream(primaryKey: ['id'])
      .order('nombre', ascending: true);

  final _nuevoNombreController = TextEditingController();

  void _seleccionarPerfil(String nombrePerfil) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryScreen(perfilActivo: nombrePerfil),
      ),
    );
  }

  Future<void> _crearPerfil() async {
    final nombre = _nuevoNombreController.text.trim();
    if (nombre.isEmpty) return;

    try {
      await Supabase.instance.client.from('perfiles').insert({'nombre': nombre});
      _nuevoNombreController.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear perfil: $e')),
        );
      }
    }
  }

  void _mostrarDialogoNuevoPerfil() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Integrante'),
        content: TextField(
          controller: _nuevoNombreController,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu nombre (ej. Lautaro)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2848A6),
              foregroundColor: Colors.white,
            ),
            onPressed: _crearPerfil,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('¿Quién está utilizando la app?'),
        backgroundColor: const Color(0xFF2848A6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            ClipOval(
              child: Image.asset(
                'assets/logo.jpeg',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona tu Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2848A6),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _profilesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final perfiles = snapshot.data ?? [];

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: perfiles.length + 1, // +1 para el botón de "Agregar"
                    itemBuilder: (context, index) {
                      if (index == perfiles.length) {
                        // Tarjeta para agregar perfil nuevo
                        return InkWell(
                          onTap: _mostrarDialogoNuevoPerfil,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2848A6),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 44,
                                  color: Color(0xFF2848A6),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Agregar Integrante',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2848A6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final perfil = perfiles[index];
                      final nombre = perfil['nombre'] as String;

                      return InkWell(
                        onTap: () => _seleccionarPerfil(nombre),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2848A6).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF2848A6),
                                child: Text(
                                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                nombre,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}