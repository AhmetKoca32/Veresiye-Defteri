import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Firestore referansı
  final CollectionReference people = FirebaseFirestore.instance.collection(
    'people',
  );

  // Kişi ekleme
  Future<void> addPerson(Map<String, dynamic> person) async {
    try {
      await people.add({
        'firstName': person['firstName'],
        'lastName': person['lastName'],
        'phone': person['phone'],
        'description': person['description'],
        'amount': person['amount'],
        'amountType': person['amountType'],
      });
    } catch (e) {
      print("Error adding person: $e");
    }
  }

  // Kişi silme
  Future<void> deletePerson(String documentId) async {
    try {
      await people.doc(documentId).delete();
    } catch (e) {
      print("Error deleting person: $e");
    }
  }

  // Kişi güncelleme
  Future<void> updatePerson(
    String documentId,
    Map<String, dynamic> updatedPerson,
  ) async {
    try {
      await people.doc(documentId).update({
        'firstName': updatedPerson['firstName'],
        'lastName': updatedPerson['lastName'],
        'phone': updatedPerson['phone'],
        'description': updatedPerson['description'],
        'amount': updatedPerson['amount'],
        'amountType': updatedPerson['amountType'],
      });
    } catch (e) {
      print("Error updating person: $e");
    }
  }

  // Firestore'dan veri çekme
  Stream<List<Map<String, dynamic>>> getPeople() {
    return people.snapshots().map((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> peopleList = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // 📌 Firestore belgesinin ID'sini ekliyoruz
        peopleList.add(data);
      }
      return peopleList;
    });
  }
}
