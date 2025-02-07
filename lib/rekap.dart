import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/wiw_data.dart';

class RekapTroubleshoot extends StatefulWidget {
  const RekapTroubleshoot({super.key});

  @override
  State<RekapTroubleshoot> createState() => _RekapTroubleshootState();
}

class _RekapTroubleshootState extends State<RekapTroubleshoot> {
  List<WiwData> doneData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoneData();
  }

  Future<void> _fetchDoneData() async {
    try {
      print('Fetching done data...');
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('data_wiw')
          .get();  // Ambil semua data dulu

      print('Found ${snapshot.docs.length} total documents');
      
      final data = snapshot.docs.map((doc) {
        final mapData = doc.data() as Map<String, dynamic>;
        print('Document data: $mapData');  // Log untuk melihat isi data
        return WiwData.fromMap(mapData);
      }).where((item) => item.action == 'Done')  // Filter yang Done saja
          .toList();

      print('Filtered ${data.length} done items');

      setState(() {
        doneData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching done data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/tanto-logo.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Flexible(
              child: Text(
                'Rekap Troubleshoot',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980),
              Color(0xFF26D0CE),
            ],
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Selesai: ${doneData.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doneData.length,
                itemBuilder: (context, index) {
                  final item = doneData[index];
                  String lastFourDigits = item.deveui?.substring(
                    (item.deveui?.length ?? 4) - 4
                  ) ?? '';
                  String sn = 'Tracker_Lansitec_$lastFourDigits';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Container ${item.containerId ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            item.placeTanto ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Selesai: ${item.tanggalTroubleshoot ?? item.lastUpdateTanto ?? "N/A"}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (item.keteranganTroubleshoot != null && item.keteranganTroubleshoot!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Keterangan: ${item.keteranganTroubleshoot}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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