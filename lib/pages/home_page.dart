import 'package:flutter/material.dart';
import 'package:veresiye_app/service/firestore_service.dart';

import 'edit_person_page.dart';
import 'hesap_gecmisi.dart'; // Hesap Geçmişi sayfasını import ettik.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> filteredPeopleList = [];
  List<Map<String, dynamic>> allPeopleList = [];

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void filterList() {
    String firstNameQuery = firstNameController.text.toLowerCase();
    String lastNameQuery = lastNameController.text.toLowerCase();
    String phoneQuery = phoneController.text;

    setState(() {
      filteredPeopleList =
          allPeopleList.where((person) {
            bool matchesFirstName =
                firstNameQuery.isEmpty ||
                (person['firstName']?.toLowerCase() ?? '').contains(
                  firstNameQuery,
                );
            bool matchesLastName =
                lastNameQuery.isEmpty ||
                (person['lastName']?.toLowerCase() ?? '').contains(
                  lastNameQuery,
                );
            bool matchesPhone =
                phoneQuery.isEmpty ||
                (person['phone'] ?? '').contains(phoneQuery);

            return matchesFirstName && matchesLastName && matchesPhone;
          }).toList();
    });
  }

  void addPerson(Map<String, dynamic> person) {
    firestoreService.addPerson(person);
  }

  void deletePerson(String? documentId) {
    if (documentId != null) {
      firestoreService.deletePerson(documentId).then((_) {
        setState(() {
          filteredPeopleList =
              allPeopleList
                  .where((person) => person['id'] != documentId)
                  .toList();
        });
      });
    }
  }

  void updatePerson(String? documentId, Map<String, dynamic> updatedPerson) {
    if (documentId != null) {
      firestoreService.updatePerson(documentId, updatedPerson).then((_) {
        setState(() {
          filteredPeopleList =
              allPeopleList.where((person) {
                bool matchesFirstName =
                    firstNameController.text.isEmpty ||
                    (person['firstName']?.toLowerCase() ?? '').contains(
                      firstNameController.text.toLowerCase(),
                    );
                bool matchesLastName =
                    lastNameController.text.isEmpty ||
                    (person['lastName']?.toLowerCase() ?? '').contains(
                      lastNameController.text.toLowerCase(),
                    );
                bool matchesPhone =
                    phoneController.text.isEmpty ||
                    (person['phone'] ?? '').contains(phoneController.text);

                return matchesFirstName && matchesLastName && matchesPhone;
              }).toList();
        });
      });
    }
  }

  void showDescriptionDialog(String description) {
    showDialog(
      context: context,
      barrierDismissible: true, // Dialog dışına tıklanınca kapanacak
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Açıklama'),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void markAsPaid(String documentId, Map<String, dynamic> person) async {
    try {
      // Ödeme türünü kontrol et
      String paymentStatus = '';
      Color statusColor = Colors.black;

      if (person['amountType'] == 'Verilecek') {
        paymentStatus = 'Borç ödendi';
        statusColor =
            Colors.red[500]!; // Burada belirli bir renk tonu seçiyoruz
      } else if (person['amountType'] == 'Alınacak') {
        paymentStatus = 'Borç alındı';
        statusColor =
            Colors.blue[500]!; // Burada da belirli bir renk tonu seçiyoruz
      }

      // Ödeme durumu bilgisini geçiş sayfasına gönder
      await firestoreService.addToHistory({
        ...person,
        'paymentStatus': paymentStatus,
        'statusColor':
            statusColor.value, // Renk değeri olarak .value kullanıyoruz
      });

      // Sonra mevcut koleksiyondan sil
      await firestoreService.deletePerson(documentId);

      setState(() {
        filteredPeopleList.removeWhere((p) => p['id'] == documentId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentStatus),
          backgroundColor: Color(statusColor.value), // Color kullanımı
        ),
      );
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu, tekrar deneyin!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Veresiye Defteri',
          style: TextStyle(
            color:
                Colors.white, // Burada istediğiniz renk kodunu yazabilirsiniz
          ),
        ),
        backgroundColor: const Color(0xFF222831),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(), // Geçmiş sayfası
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Ad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: filterList, child: const Text('Ara')),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>( 
                stream: firestoreService.getPeople(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  } else if (snapshot.hasData) {
                    allPeopleList = snapshot.data!;
                    if (filteredPeopleList.isEmpty) {
                      filteredPeopleList =
                          allPeopleList; // Başlangıçta tüm verileri göster
                    }
                    return ListView.builder(
                      itemCount: filteredPeopleList.length,
                      itemBuilder: (context, index) {
                        var person = filteredPeopleList[index];
                        String? personId = person['id'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ad: ${person['firstName'] ?? 'Bilinmiyor'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Soyad: ${person['lastName'] ?? 'Bilinmiyor'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Telefon: ${person['phone'] ?? 'Bilinmiyor'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDescriptionDialog(
                                          person['description'] ??
                                              'Açıklama bulunmuyor.',
                                        );
                                      },
                                      child: const Text('Açıklamayı Göster'),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      person['amountType'] == 'Alınacak'
                                          ? 'Alınacak: ${person['amount'] ?? 0} TL'
                                          : 'Verilecek: ${person['amount'] ?? 0} TL',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            person['amountType'] == 'Alınacak'
                                                ? Colors.blue
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (personId != null) {
                                      if (value == 'Sil') {
                                        deletePerson(personId); // Silme işlemi
                                      } else if (value == 'Düzenle') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => EditPersonPage(
                                                  person: person,
                                                  onEditPerson: (
                                                    updatedPerson,
                                                  ) {
                                                    updatePerson(
                                                      personId,
                                                      updatedPerson,
                                                    ); // Güncelleme işlemi
                                                  },
                                                ),
                                          ),
                                        );
                                      } else if (value == 'Ödendi') {
                                        markAsPaid(
                                          personId,
                                          person,
                                        ); // Ödendi olarak işaretleme
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['Sil', 'Düzenle', 'Ödendi'].map((
                                      String choice,
                                    ) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
