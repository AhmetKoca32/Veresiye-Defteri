import 'package:flutter/material.dart';
import 'package:veresiye_app/service/firestore_service.dart';

class AddPersonPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddPerson;

  const AddPersonPage({super.key, required this.onAddPerson});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedAmountType = 'Alınacak'; // 'Alınacak' veya 'Verilecek'
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> addPerson() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phone = phoneController.text.trim();
    String description = descriptionController.text.trim();
    String amountText = amountController.text.trim();

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        phone.isNotEmpty &&
        description.isNotEmpty &&
        amountText.isNotEmpty) {
      // Aynı isim ve soyisimdeki kişiyi kontrol et
      var existingPerson =
          await _firestoreService.people
              .where('firstName', isEqualTo: firstName)
              .where('lastName', isEqualTo: lastName)
              .get();

      if (existingPerson.docs.isNotEmpty) {
        // Eğer aynı isim ve soyisimde kişi varsa uyarı ver
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bu kişi zaten mevcut!')));
        return;
      }

      // Kişiyi Firestore'a ekle
      Map<String, dynamic> newPerson = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'description': description,
        'amount': double.tryParse(amountText) ?? 0,
        'amountType': selectedAmountType,
      };

      await _firestoreService.addPerson(newPerson);
      widget.onAddPerson(newPerson);

      // Sayfayı kapatıp ana ekrana dön
      Navigator.pop(context);
    } else {
      // Eğer gerekli alanlar boşsa kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kişi Ekle'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Kişi Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Kişi Soyadı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Miktar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'Verilecek',
                      groupValue: selectedAmountType,
                      onChanged: (String? value) {
                        setState(() {
                          selectedAmountType = value!;
                        });
                      },
                      activeColor:
                          selectedAmountType == 'Verilecek'
                              ? Colors.red
                              : Colors.black,
                    ),
                    const Text('Verilecek'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Alınacak',
                      groupValue: selectedAmountType,
                      onChanged: (String? value) {
                        setState(() {
                          selectedAmountType = value!;
                        });
                      },
                      activeColor:
                          selectedAmountType == 'Alınacak'
                              ? Colors.blue
                              : Colors.black,
                    ),
                    const Text('Alınacak'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addPerson,
              child: const Text('Kişi Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
