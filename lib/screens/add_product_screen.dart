import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productoAEditar;
  final String perfilActivo;

  const AddProductScreen({
    super.key,
    required this.perfilActivo,
    this.productoAEditar,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  bool _isLoading = false;

  bool get esEdicion => widget.productoAEditar != null;

  @override
  void initState() {
    super.initState();
    if (esEdicion) {
      _nombreController.text = widget.productoAEditar!['nombre'] ?? '';
      _cantidadController.text = widget.productoAEditar!['cantidad'] ?? '';
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    final cantidad = _cantidadController.text.trim();

    if (nombre.isEmpty || cantidad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa ambos campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      if (esEdicion) {
        await supabase.from('productos').update({
          'nombre': nombre,
          'cantidad': cantidad,
          'ultima_modificacion_por': widget.perfilActivo,
        }).eq('id', widget.productoAEditar!['id']);
      } else {
        await supabase.from('productos').insert({
          'nombre': nombre,
          'cantidad': cantidad,
          'ultima_modificacion_por': widget.perfilActivo,
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Insumo' : 'Nuevo Insumo'),
        backgroundColor: const Color(0xFF2848A6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto / insumo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad o presentación (ej: 5 cajas, 20 unidades)',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2848A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _guardar,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        esEdicion ? 'Guardar Cambios' : 'Agregar Insumo',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}