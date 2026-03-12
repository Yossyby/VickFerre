import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ¡Importante para conectar a la BD!

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  bool _isProcessing = false;
  final List<Map<String, dynamic>> _cartItems = [];
  late MobileScannerController _scannerController;
  final FirebaseFirestore db = FirebaseFirestore.instance; // Instancia de Firestore

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });
    _scannerController.start();
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
    });
    _scannerController.stop();
  }

  // AQUÍ SUCEDE LA MAGIA DE LA BASE DE DATOS
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || !_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? scannedCode = barcodes.first.rawValue;
      if (scannedCode == null) return;

      setState(() {
        _isProcessing = true;
      });

      try {
        // 1. Buscamos el código en Firebase
        final querySnapshot = await db
            .collection('Productos')
            .where('codigo_barras', isEqualTo: scannedCode)
            .limit(1) // Solo necesitamos encontrar 1
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // 2. Si lo encuentra, sacamos los datos
          final doc = querySnapshot.docs.first;
          final data = doc.data();

          final product = {
            'id': doc.id,
            'name': data['nombre'] ?? 'Producto Desconocido',
            'price': (data['precio_venta'] ?? 0.0).toDouble(),
          };

          _addToCart(product);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Agregado: ${product['name']}'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1000),
            ),
          );
        } else {
          // 3. Si no existe en la BD
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto no encontrado: $scannedCode'),
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Pausa de 2 segundos antes de permitir el siguiente escaneo
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity']++;
      } else {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
        });
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index]['quantity'] += delta;
      if (_cartItems[index]['quantity'] <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  void _showReceiptDialog() {
    _stopScan();
    final double total = _subtotal;
    final double iva = total * 0.16;
    final double totalWithIva = total + iva;
    
    final dateStr = "${DateTime.now().day} de marzo de 2026";
    final timeStr = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6D00),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text('Venta Exitosa', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Ticket de Venta', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text("Vick's Store", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text("Ferretería Truper\nSucursal Centro\nRFC: VST-123456-ABC", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Fecha', style: TextStyle(color: Colors.grey, fontSize: 12)), Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold))]),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Hora', style: TextStyle(color: Colors.grey, fontSize: 12)), Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold))]),
                          ],
                        ),
                        const Divider(height: 30),
                        const Align(alignment: Alignment.centerLeft, child: Text('Productos', style: TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        ..._cartItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text("${item['quantity']} x \$${item['price'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text("\$${(item['price'] * item['quantity']).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                        const Divider(height: 30),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: Colors.grey)), Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 5),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('IVA (16%)', style: TextStyle(color: Colors.grey)), Text("\$${iva.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold))]),
                        const Divider(height: 30),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("\$${totalWithIva.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00)))]),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                          child: const Column(
                            children: [
                              Text('¡Gracias por su compra!', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Esperamos verle pronto', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imprimiendo ticket...')));
                          },
                          icon: const Icon(Icons.print, color: Colors.white),
                          label: const Text('Imprimir Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _cartItems.clear();
                            });
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Nueva Venta', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          color: _isScanning ? Colors.black : const Color(0xFFFF6D00),
          padding: _isScanning ? EdgeInsets.zero : const EdgeInsets.all(24),
          child: _isScanning
              ? SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      Container(
                        width: 250,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFF6D00), width: 3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                          onPressed: _stopScan,
                        ),
                      ),
                      const Positioned(
                        bottom: 20,
                        child: Text(
                          'Apunta al código de barras',
                          style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sistema de Punto de Venta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Escanee productos para agregar a la venta', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(Icons.camera_alt, color: Color(0xFFFF6D00)),
                        label: const Text('Iniciar Escaneo', style: TextStyle(color: Color(0xFFFF6D00), fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF6D00)),
                        const SizedBox(width: 8),
                        Text('Productos Escaneados (${_cartItems.fold(0, (sum, item) => sum + item['quantity'] as int)})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    if (_cartItems.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _cartItems.clear()),
                        child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
                      )
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text('No hay productos escaneados', style: TextStyle(color: Colors.grey.shade600)),
                              Text('Inicie el escaneo para agregar productos', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.shopping_cart, color: Color(0xFFFF6D00), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text("\$${item['price'].toStringAsFixed(2)} c/u", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                child: Row(
                                                  children: [
                                                    IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () => _updateQuantity(index, -1), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                                    Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => _updateQuantity(index, 1), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                onPressed: () => _removeItem(index),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("\$${(item['price'] * item['quantity']).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFF6D00).withValues(alpha: 0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total a Pagar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("\$${_subtotal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFF6D00), fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Productos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("${_cartItems.fold(0, (sum, item) => sum + item['quantity'] as int)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _cartItems.isEmpty ? null : _showReceiptDialog,
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: const Text('Finalizar Venta', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}