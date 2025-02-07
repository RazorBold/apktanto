import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail.dart';
import 'models/wiw_data.dart';

class SurabayaReport extends StatefulWidget {
  const SurabayaReport({super.key});

  @override
  State<SurabayaReport> createState() => _SurabayaReportState();
}

class _SurabayaReportState extends State<SurabayaReport> {
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
      'Depo 02 SBY': [],
      'Depo Surabaya 1': [],
      'Depo Surabaya 4': [],
    };

    for (var item in items) {
      if (item.action?.toLowerCase() == 'done') continue;

      // Parse dates
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

      // Determine which location to use based on most recent update
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
        continue; // Skip if no valid dates
      }

      // Kategorisasi yang lebih ketat
      bool categorized = false;
      
      // Depo 02 SBY
      if (locationToUse.contains('depo 02') || 
          locationToUse.contains('sby2') || 
          locationToUse.contains('sby 2')) {
        filteredData['Depo 02 SBY']!.add(item);
        categorized = true;
      }
      
      // Depo Surabaya 1
      if (!categorized && (
          locationToUse.contains('depo surabaya 1') || 
          locationToUse.contains('sby1') || 
          locationToUse.contains('sby 1'))) {
        filteredData['Depo Surabaya 1']!.add(item);
        categorized = true;
      }
      
      // Depo Surabaya 4
      if (!categorized && (
          locationToUse.contains('depo surabaya 4') || 
          locationToUse.contains('sby4') || 
          locationToUse.contains('sby 4'))) {
        filteredData['Depo Surabaya 4']!.add(item);
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
              'Laporan Container Surabaya',
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
                                onPressed: () {
                                  Navigator.push(
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