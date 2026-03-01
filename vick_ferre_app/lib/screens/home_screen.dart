import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 25),
          const Text(
            'Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          _buildQuickActions(),
          const SizedBox(height: 25),
          const Text(
            'Actividad Reciente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          _buildRecentActivityCard(),
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
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard(Icons.inventory, '150', 'Total Artículos'),
        _statCard(Icons.qr_code, '23', 'Escaneados Hoy'),
        _statCard(Icons.trending_up, '58%', 'Progreso Total'),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFF6D00)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            _actionCard(Icons.qr_code_scanner, 'Escanear Artículo', 'Escanea código de barras', true),
            const SizedBox(width: 15),
            _actionCard(Icons.inventory_2_outlined, 'Inventario', 'Ver lista completa', false),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _actionCard(Icons.add_box_outlined, 'Añadir Artículo', 'Registrar nuevo ítem', false),
            const SizedBox(width: 15),
            _actionCard(Icons.bar_chart_outlined, 'Reportes', 'Ver estadísticas', false),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, String subtitle, bool isPrimary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF6D00) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
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
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.qr_code_scanner, color: Color(0xFFFF6D00)),
        ),
        title: const Text('Martillo de Goma 16oz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Escaneado hace 5 min', style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
          child: const Text('Lleno', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}