import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ESTA FUNCIÓN ARREGLA EL ERROR DE "DOCUMENT REFERENCE"
  String validarDato(dynamic campo) {
    if (campo == null) return "N/A";
    if (campo is DocumentReference) {
      return campo.id; // Si es referencia, saca el nombre del documento (ID)
    }
    return campo.toString(); // Si es texto o número, lo pasa a String
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lista de Materiales',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          // Buscador
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o código...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                      onPressed: () {},
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botón Filtros
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune, color: Colors.black87, size: 20),
              label: const Text(
                'Filtros',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // STREAMBUILDER: Aquí es donde sucede la magia
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('Productos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay productos"));
                }

                var productos = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conteo real de productos
                    Text(
                      '${productos.length} artículos en total',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          // Obtenemos los datos de cada producto de forma segura
                          var data = productos[index].data() as Map<String, dynamic>;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildInventoryCard(
                              title: validarDato(data['nombre']),
                              code: validarDato(data['codigo_barras']),
                              status: (data['stock_actual'] ?? 0) > 5 ? "Lleno" : "Bajo",
                              statusColor: (data['stock_actual'] ?? 0) > 5 ? Colors.green : Colors.red,
                              locationStatus: validarDato(data['ubicacion']),
                              color: validarDato(data['color']),
                              material: validarDato(data['material']),
                              brand: validarDato(data['marca']),
                              office: "Sucursal",
                              service: "Herramientas",
                              agency: "Principal",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // WIDGET DE LA TARJETA (Se mantiene igual, solo corregimos el conteo arriba)
  Widget _buildInventoryCard({
    required String title,
    required String code,
    required String status,
    required Color statusColor,
    required String locationStatus,
    required String color,
    required String material,
    required String brand,
    required String office,
    required String service,
    required String agency,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFFF6D00),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Código: $code',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChip(status, statusColor, statusColor.withOpacity(0.1)),
                    const SizedBox(width: 8),
                    _buildChip(locationStatus, Colors.blue.shade700, Colors.blue.shade50, icon: Icons.location_on),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _buildBulletText('Color: $color'),
                    _buildBulletText('Material: $material'),
                    _buildBulletText('Marca: $brand'),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text('Oficina: $office', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Servicio: $service', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Agencia: $agency', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color textColor, Color bgColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('• ', style: TextStyle(color: Colors.grey, fontSize: 14)),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}