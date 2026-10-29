import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_product_screen.dart';
import 'profile_selection_screen.dart';

class InventoryScreen extends StatefulWidget {
  final String perfilActivo;

  const InventoryScreen({super.key, required this.perfilActivo});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _productosStream = Supabase.instance.client
      .from('productos')
      .stream(primaryKey: ['id'])
      .order('id', ascending: false);

  void _navegarAgregarOEditar([Map<String, dynamic>? producto]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          perfilActivo: widget.perfilActivo,
          productoAEditar: producto,
        ),
      ),
    );
  }

  Future<void> _eliminarProducto(int id) async {
    try {
      await Supabase.instance.client.from('productos').delete().eq('id', id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  void _cambiarPerfil() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo.jpeg',
                height: 34,
                width: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ADU Stock',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Cambiar Perfil',
            onPressed: _cambiarPerfil,
          ),
        ],
        backgroundColor: const Color(0xFF2848A6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF2848A6).withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Color(0xFF2848A6)),
                    const SizedBox(width: 6),
                    Text(
                      'Perfil: ${widget.perfilActivo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2848A6),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'EN VIVO 🟢',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final productos = snapshot.data ?? [];

                if (productos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay insumos registrados.\nToca + para agregar uno.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    final modificadoPor = producto['ultima_modificacion_por'] ?? 'Desconocido';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          producto['nombre'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Cantidad: ${producto['cantidad']}'),
                            Text(
                              'Editado por: $modificadoPor',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF2848A6)),
                              onPressed: () => _navegarAgregarOEditar(producto),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _eliminarProducto(producto['id']),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2848A6),
        foregroundColor: Colors.white,
        onPressed: () => _navegarAgregarOEditar(),
        child: const Icon(Icons.add),
      ),
    );
  }
}