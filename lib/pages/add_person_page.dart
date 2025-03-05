import 'package:flutter/material.dart';

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

  void addPerson() {
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        amountController.text.isNotEmpty) {
      Map<String, dynamic> newPerson = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phone': phoneController.text,
        'description': descriptionController.text,
        'amount': double.tryParse(amountController.text) ?? 0,
        'amountType': selectedAmountType,
      };
      widget.onAddPerson(newPerson);

      // Sayfayı kapatıp ana sayfaya dön
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
        backgroundColor: const Color(0xFF222831),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Yeni kişi ekleme formu
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
