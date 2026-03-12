import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildDynamicStatsRow(), // <-- Conectado a Firebase
          const SizedBox(height: 25),
          const Text(
            'Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          _buildQuickActions(),
          const SizedBox(height: 25),
          const Text(
            'Agregados Recientemente', // <-- Cambié el título
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          _buildDynamicRecentActivity(), // <-- Conectado a Firebase
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6D00),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF6D00).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Bienvenido!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Ocampo', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('Sucursal Centro', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS CONECTADOS A FIREBASE ---

  Widget _buildDynamicStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Total de Artículos
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
            builder: (context, snapshot) {
              String total = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
              return _statCard(Icons.inventory, total, 'Total Artículos', true);
            },
          ),
        ),
        const SizedBox(width: 10),
        // 2. Stock Bajo (Productos con menos de 5 en stock_actual)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Productos').where('stock_actual', isLessThan: 5).snapshots(),
            builder: (context, snapshot) {
              String bajos = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
              return _statCard(Icons.warning_amber_rounded, bajos, 'Stock Bajo', false);
            },
          ),
        ),
        const SizedBox(width: 10),
        // 3. Categorías (Contando documentos en la colección 'categorias')
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categorias').snapshots(),
            builder: (context, snapshot) {
              String cats = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
              return _statCard(Icons.category_outlined, cats, 'Categorías', false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicRecentActivity() {
    // Consulta a Firebase: Traer productos ordenados por fecha, máximo 3
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Productos')
          .orderBy('fecha_registro', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D00)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Aún no hay artículos registrados.', style: TextStyle(color: Colors.grey)),
          );
        }

        // Armar una lista de tarjetas con los documentos obtenidos
        return Column(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String nombre = data['nombre'] ?? 'Sin nombre';
            String marca = data['marca'] ?? 'Sin marca';
            int stock = data['stock_actual'] ?? 0;

            // Determinar colores y texto basado en el stock
            bool stockBajo = stock < 5;
            Color badgeColor = stockBajo ? Colors.red : Colors.green;
            Color badgeBgColor = stockBajo ? Colors.red.shade50 : Colors.green.shade50;
            String badgeText = stockBajo ? 'Bajo: $stock' : 'Stock: $stock';

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFFFF6D00)),
                ),
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(marca, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(badgeText, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES (UI) ---

  Widget _statCard(IconData icon, String value, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFFF6D00) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isPrimary ? const Color(0xFFFF6D00).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: isPrimary ? Colors.white : const Color(0xFFFF6D00), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isPrimary ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            _actionCard(Icons.qr_code_scanner, 'Escanear Artículo', 'Escanea código de barras', true, () => onNavigate(1)),
            const SizedBox(width: 15),
            _actionCard(Icons.inventory_2_outlined, 'Inventario', 'Ver lista completa', false, () => onNavigate(3)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _actionCard(Icons.add_box_outlined, 'Añadir Artículo', 'Registrar nuevo ítem', false, () => onNavigate(2)),
            const SizedBox(width: 15),
            _actionCard(Icons.bar_chart_outlined, 'Reportes', 'Ver estadísticas', false, () => onNavigate(4)),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, String subtitle, bool isPrimary, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, 
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFFFF6D00) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: isPrimary ? Colors.white : const Color(0xFFFF6D00)),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isPrimary ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11, color: isPrimary ? Colors.white70 : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}