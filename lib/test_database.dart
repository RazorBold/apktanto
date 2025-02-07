import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/wiw_data.dart';

class TestDatabase extends StatefulWidget {
  const TestDatabase({super.key});

  @override
  State<TestDatabase> createState() => _TestDatabaseState();
}

class _TestDatabaseState extends State<TestDatabase> {
  List<WiwData> testData = [];
  bool isLoading = false;

  Future<void> _fetchTestData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('data_wiw')
          .limit(100)  // Ambil 5 data saja
          .get();

      print('Found ${snapshot.docs.length} documents');
      
      final data = snapshot.docs.map((doc) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
        return WiwData.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        testData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching test data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Database'),
        backgroundColor: const Color(0xFF1A2980),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _fetchTestData,
                child: const Text('Fetch 5 Documents'),
              ),
            ),
            if (isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              Expanded(
                child: ListView.builder(
                  itemCount: testData.length,
                  itemBuilder: (context, index) {
                    final item = testData[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('DevEUI: ${item.deveui ?? "N/A"}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Container ID: ${item.containerId ?? "N/A"}'),
                            Text('Status: ${item.status ?? "N/A"}'),
                            Text('Battery: ${item.battery ?? "N/A"}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 