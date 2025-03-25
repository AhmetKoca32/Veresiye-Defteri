import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veresiye_app/service/firestore_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // FirestoreService örneğini alalım
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Geçmişi'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          // Geçmişi temizleme butonu
          ElevatedButton(
            onPressed: () async {
              await firestoreService.clearHistory(); // Geçmişi temizle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geçmiş başarıyla temizlendi!')),
              );
            },
            child: const Text('Geçmişi Temizle'),
          ),

          // Firestore'dan veri çekme ve listeleme
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('HesapGecmisi')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Veriler yüklenirken hata oluştu.'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz geçmişte işlem yok.'));
                }

                var historyList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    var historyItem =
                        historyList[index].data() as Map<String, dynamic>;

                    // Ödeme türünü kontrol et ve renk seçimini yap
                    Color amountColor =
                        historyItem['amountType'] == 'Alınacak'
                            ? Colors.blue
                            : Colors.red;

                    String transactionText =
                        historyItem['amountType'] == 'Alınacak'
                            ? 'Borç Alındı'
                            : 'Borç Ödendi';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          '${historyItem['firstName']} ${historyItem['lastName']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '$transactionText: ${historyItem['amount']} TL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: amountColor, // Ödeme türüne göre renk
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
