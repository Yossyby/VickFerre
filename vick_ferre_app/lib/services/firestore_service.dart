import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> agregarProducto() async {
    await db.collection("productos").add({
      "nombre": "Martillo",
      "precio": 150,
      "stock": 20
    });
  }

}