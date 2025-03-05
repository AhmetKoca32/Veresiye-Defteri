import 'package:flutter/material.dart';
import 'package:veresiye_app/service/firestore_service.dart';

import 'add_person_page.dart';
import 'edit_person_page.dart';

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
                                    // Açıklamayı butona tıklayınca gösterecek buton
                                    ElevatedButton(
                                      onPressed: () {
                                        showDescriptionDialog(
                                          person['description'] ??
                                              'Açıklama yok',
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
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['Sil', 'Düzenle'].map((
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
                  }
                  return const Center(child: Text('No data available'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPersonPage(onAddPerson: addPerson),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
