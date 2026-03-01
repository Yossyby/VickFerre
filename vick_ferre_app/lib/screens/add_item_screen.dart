import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

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
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_box_outlined,
              size: 40,
              color: Color(0xFFFF6D00),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Añadir Nuevo Artículo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completa la información del nuevo artículo',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Información Básica',
            children: [
              _buildCustomTextField(
                label: 'Nombre del Artículo *', 
                hintText: 'Ej: Martillo de Goma 16oz'
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Código de Barras *',
                hintText: 'Ej: 7501206636442',
                suffixIcon: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Marca', 
                hintText: 'Ej: Truper'
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Detalles Físicos',
            children: [
              _buildCustomTextField(
                label: 'Color', 
                hintText: 'Ej: Negro, Amarillo'
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                label: 'Material', 
                hintText: 'Ej: Goma, Acero'
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Estado y Ubicación',
            children: [
              _buildDropdownField(
                label: 'Estado Inicial *',
                hintText: 'Seleccionar estado',
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Ubicación *',
                hintText: 'Seleccionar ubicación',
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
                    onPressed: () {},
                    icon: const Icon(Icons.close, color: Colors.black87, size: 20),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      'Registrar',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomTextField({required String label, required String hintText, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: Icon(suffixIcon, color: Colors.grey.shade700, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [], 
          onChanged: (value) {},
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ),
      ],
    );
  }
}