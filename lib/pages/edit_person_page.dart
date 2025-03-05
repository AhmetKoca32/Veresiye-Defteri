import 'package:flutter/material.dart';

class EditPersonPage extends StatefulWidget {
  final Map<String, dynamic> person;
  final Function(Map<String, dynamic>) onEditPerson;

  const EditPersonPage({
    super.key,
    required this.person,
    required this.onEditPerson,
  });

  @override
  State<EditPersonPage> createState() => _EditPersonPageState();
}

class _EditPersonPageState extends State<EditPersonPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  String selectedAmountType = "Alınacak"; // Varsayılan değer

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
      text: widget.person['firstName'],
    );
    lastNameController = TextEditingController(text: widget.person['lastName']);
    phoneController = TextEditingController(text: widget.person['phone']);
    descriptionController = TextEditingController(
      text: widget.person['description'],
    );
    amountController = TextEditingController(
      text: widget.person['amount'].toString(),
    );
    selectedAmountType = widget.person['amountType'] ?? "Alınacak";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kişiyi Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "Ad"),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Soyad"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Telefon"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Açıklama"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Miktar"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedAmountType,
              decoration: const InputDecoration(labelText: "Tür"),
              items:
                  ["Alınacak", "Verilecek"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedAmountType = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onEditPerson({
                  'id': widget.person['id'], // ID'yi ekliyoruz
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                  'phone': phoneController.text,
                  'description': descriptionController.text,
                  'amount': double.tryParse(amountController.text) ?? 0,
                  'amountType': selectedAmountType,
                });
                Navigator.pop(context);
              },

              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
