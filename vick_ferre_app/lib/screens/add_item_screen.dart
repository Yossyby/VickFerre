import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(); 
  
  // <-- NUEVOS: Controladores para precios
  final TextEditingController _precioProveedorController = TextEditingController();
  final TextEditingController _precioVentaController = TextEditingController();
  
  String? _selectedUbicacion;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _escanearCodigo() async {
    final String? codigoEscaneado = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            height: 350,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6D00),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  width: double.infinity,
                  child: const Text(
                    'Escanea el código de barras',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ClipRect(
                    child: MobileScanner(
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                          Navigator.pop(context, barcodes.first.rawValue);
                        }
                      },
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    if (codigoEscaneado != null) {
      setState(() {
        _codigoController.text = codigoEscaneado;
      });
    }
  }

  Future<void> _registrarProducto() async {
    // Validamos que nombre, código, stock y PRECIOS no estén vacíos
    if (_nombreController.text.isEmpty || 
        _codigoController.text.isEmpty || 
        _stockController.text.isEmpty ||
        _precioProveedorController.text.isEmpty ||
        _precioVentaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena los campos obligatorios (*)')),
      );
      return;
    }

    try {
      await _db.collection('Productos').add({
        'nombre': _nombreController.text.trim(),
        'codigo_barras': _codigoController.text.trim(),
        'marca': _marcaController.text.trim(),
        'color': _colorController.text.trim(),
        'material': _materialController.text.trim(),
        'ubicacion': _selectedUbicacion ?? 'Sin ubicación',
        'stock_actual': int.tryParse(_stockController.text.trim()) ?? 0,
        // <-- NUEVOS: Guardamos los precios como decimales (double)
        'precio_proveedor': double.tryParse(_precioProveedorController.text.trim()) ?? 0.0,
        'precio_venta': double.tryParse(_precioVentaController.text.trim()) ?? 0.0,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto registrado con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
        _nombreController.clear();
        _codigoController.clear();
        _marcaController.clear();
        _colorController.clear();
        _materialController.clear();
        _stockController.clear();
        _precioProveedorController.clear(); // Limpiamos precios
        _precioVentaController.clear();
        setState(() {
          _selectedUbicacion = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFFFF0E5), shape: BoxShape.circle),
            child: const Icon(Icons.add_box_outlined, size: 40, color: Color(0xFFFF6D00)),
          ),
          const SizedBox(height: 16),
          const Text('Añadir Nuevo Artículo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Completa la información del nuevo artículo', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          
          _buildSectionCard(
            title: 'Información Básica',
            children: [
              _buildCustomTextField(
                label: 'Nombre del Artículo *', 
                hintText: 'Ej: Martillo de Goma 16oz',
                controller: _nombreController,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Código de Barras *',
                hintText: 'Ej: 7501206636442',
                suffixIcon: Icons.camera_alt_outlined,
                controller: _codigoController,
                onSuffixPressed: _escanearCodigo, 
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Marca', 
                hintText: 'Ej: Truper',
                controller: _marcaController,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Detalles Físicos',
            children: [
              _buildCustomTextField(label: 'Color', hintText: 'Ej: Negro, Amarillo', controller: _colorController),
              const SizedBox(height: 16),
              _buildCustomTextField(label: 'Material', hintText: 'Ej: Goma, Acero', controller: _materialController),
            ],
          ),
          const SizedBox(height: 16),

          // <-- NUEVA SECCIÓN: PRECIOS
          _buildSectionCard(
            title: 'Precios',
            children: [
              _buildCustomTextField(
                label: 'Precio Proveedor (Compra) *',
                hintText: 'Ej: 120.50',
                controller: _precioProveedorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Precio de Venta *',
                hintText: 'Ej: 200.00',
                controller: _precioVentaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Inventario y Ubicación',
            children: [
              _buildCustomTextField(
                label: 'Stock Inicial *',
                hintText: 'Ej: 50',
                controller: _stockController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Ubicación *',
                hintText: 'Seleccionar ubicación',
                items: ['Pasillo A-12', 'Mostrador B', 'Bodega'],
                value: _selectedUbicacion,
                onChanged: (val) => setState(() => _selectedUbicacion = val),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black87, size: 20),
                    label: const Text('Cancelar', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _registrarProducto,
                    icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    label: const Text('Registrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label, 
    required String hintText, 
    IconData? suffixIcon,
    required TextEditingController controller,
    VoidCallback? onSuffixPressed,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      child: IconButton(
                        icon: Icon(suffixIcon, color: Colors.grey.shade700, size: 20),
                        onPressed: onSuffixPressed,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label, 
    required String hintText,
    required List<String> items,
    String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ),
      ],
    );
  }
}