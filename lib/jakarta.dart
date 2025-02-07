import 'package:flutter/material.dart';
import 'detail.dart';
import 'models/wiw_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JakartaReport extends StatefulWidget {
  const JakartaReport({super.key});

  @override
  State<JakartaReport> createState() => _JakartaReportState();
}

class _JakartaReportState extends State<JakartaReport> {
  String _getMonthNumber(String monthName) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final index = months.indexOf(monthName) + 1;
    return index.toString().padLeft(2, '0');
  }

  DateTime? _parseTantoDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 4) {
        final day = parts[0];
        final month = _getMonthNumber(parts[1]);
        final year = '20${parts[2]}';
        final time = parts[3];
        return DateTime.parse('$year-$month-$day $time:00');
      }
    } catch (e) {
      print('Error parsing Tanto date: $e');
    }
    return null;
  }

  Map<String, List<WiwData>> filterData(List<WiwData> items) {
    Map<String, List<WiwData>> filteredData = {
      'Depo PDI': [],
      'Depo 005': [],
      'Depo Transporindo': [],
      'Depo 111': [],
      'Depo 107': [],
      'Depo 004': [],
    };

    for (var item in items) {
      if (item.action?.toLowerCase() == 'done') continue;

      // Parse dates dan tentukan lokasi terbaru
      DateTime? antaresDate;
      DateTime? tantoDate;

      if (item.lastUpdateAntares != null && item.lastUpdateAntares!.contains('-')) {
        try {
          antaresDate = DateTime.parse(item.lastUpdateAntares!);
        } catch (e) {
          print('Error parsing Antares date: $e');
        }
      }

      tantoDate = _parseTantoDate(item.lastUpdateTanto);

      // Tentukan lokasi berdasarkan update terbaru
      String locationToUse = '';
      if (antaresDate != null && tantoDate != null) {
        if (tantoDate.isAfter(antaresDate)) {
          locationToUse = item.placeTanto?.toLowerCase() ?? '';
        } else {
          locationToUse = item.placeAntares?.toLowerCase() ?? '';
        }
      } else if (tantoDate != null) {
        locationToUse = item.placeTanto?.toLowerCase() ?? '';
      } else if (antaresDate != null) {
        locationToUse = item.placeAntares?.toLowerCase() ?? '';
      } else {
        continue; // Skip jika tidak ada tanggal valid
      }

      // Kategorisasi yang lebih ketat
      bool categorized = false;
      
      // Depo PDI
      if (locationToUse.contains('depo pdi') || 
          locationToUse == 'jkt pdi' ||
          locationToUse == 'pdi' ||
          locationToUse.startsWith('pdi ')) {
        filteredData['Depo PDI']!.add(item);
        categorized = true;
      }
      
      // Depo 005
      if (!categorized && (
          locationToUse.contains('depo 005') || 
          locationToUse == 'jkt 005' ||
          locationToUse.startsWith('005 ') ||
          locationToUse.endsWith(' 005'))) {
        filteredData['Depo 005']!.add(item);
        categorized = true;
      }
      
      // Depo 004
      if (!categorized && (
          locationToUse.contains('depo 004') || 
          locationToUse == 'jkt 004' ||
          locationToUse.startsWith('004 ') ||
          locationToUse.endsWith(' 004'))) {
        filteredData['Depo 004']!.add(item);
        categorized = true;
      }
      
      // Transporindo
      if (!categorized && locationToUse.contains('transporindo')) {
        filteredData['Depo Transporindo']!.add(item);
        categorized = true;
      }
      
      // Depo 111
      if (!categorized && (
          locationToUse.contains('depo 111') || 
          locationToUse == 'jkt 111' ||
          locationToUse.startsWith('111 ') ||
          locationToUse.endsWith(' 111'))) {
        filteredData['Depo 111']!.add(item);
        categorized = true;
      }
      
      // Depo 107
      if (!categorized && (
          locationToUse.contains('depo 107') || 
          locationToUse == 'jkt 107' ||
          locationToUse.startsWith('107 ') ||
          locationToUse.endsWith(' 107'))) {
        filteredData['Depo 107']!.add(item);
      }
    }
    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Laporan Container Jakarta',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('data_wiw')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.docs
              .map((doc) => WiwData.fromMap(doc.data() as Map<String, dynamic>))
              .toList() ?? [];

          final filteredDepoData = filterData(data);
          
          int totalContainers = 0;
          filteredDepoData.forEach((_, items) => totalContainers += items.length);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Total Container: $totalContainers',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDepoData.length,
                    itemBuilder: (context, index) {
                      final depoName = filteredDepoData.keys.elementAt(index);
                      final containers = filteredDepoData[depoName] ?? [];
                      
                      return containers.isEmpty ? const SizedBox() : Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white.withOpacity(0.1),
                        child: ExpansionTile(
                          title: Text(
                            '$depoName (${containers.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: containers.map((item) {
                            String lastFourDigits = item.deveui?.substring(
                              (item.deveui?.length ?? 4) - 4
                            ) ?? '';
                            String sn = 'Tracker_Lansitec_$lastFourDigits';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.status?.toLowerCase() == 'yes' 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                sn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                item.containerId ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                        containerId: item.containerId ?? '',
                                        deviceEui: item.deveui ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Detail'),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
