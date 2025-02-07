import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/wiw_data.dart';

class DetailPage extends StatefulWidget {
  final String containerId;
  final String deviceEui;

  const DetailPage({
    super.key,
    required this.containerId,
    required this.deviceEui,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _status = 'Pending';
  String _selectedStatus = 'Pending';
  WiwData? containerData;
  bool isLoading = true;
  String documentId = '';
  final TextEditingController _keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContainerData();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetchContainerData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('data_wiw')
          .where('container-id', isEqualTo: widget.containerId)
          .where('deveui', isEqualTo: widget.deviceEui)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        documentId = snapshot.docs.first.id;
        containerData = WiwData.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>
        );
        setState(() {
          // Normalize action case
          final action = containerData?.action?.toLowerCase() == 'done' 
              ? 'Done' 
              : 'Pending';  // Semua yang bukan 'Done' dianggap 'Pending'
          _status = action;
          _selectedStatus = action;
        });
      }
    } catch (e) {
      print('Error fetching container data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    try {
      // Update status lokal dulu
      final newStatus = _status == 'Pending' ? 'Done' : 'Pending';
      
      // Siapkan data untuk update
      Map<String, dynamic> updateData = {
        'Action': newStatus
      };

      // Jika status berubah menjadi Done
      if (newStatus == 'Done') {
        final now = DateTime.now();
        final formattedDate = '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        updateData['tanggal-troubleshoot'] = formattedDate;
        
        // Tambahkan keterangan jika ada
        if (_keteranganController.text.isNotEmpty) {
          updateData['keterangan-troubleshoot'] = _keteranganController.text;
        }
      }
      
      // Update ke Firestore
      await FirebaseFirestore.instance
          .collection('data_wiw')
          .doc(documentId)
          .update(updateData);

      // Update state setelah berhasil update di Firestore
      setState(() {
        _status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'Done' 
            ? 'Container telah selesai di update' 
            : 'Status container diperbarui'),
          backgroundColor: newStatus == 'Done' ? Colors.green : Colors.blue,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengupdate status'),
          backgroundColor: Colors.red,
        ),
      );
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
                'Detail Container',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Container ID', widget.containerId),
                      const SizedBox(height: 12),
                      _buildInfoRow('Device EUI', widget.deviceEui),
                      const SizedBox(height: 12),
                      _buildInfoRow('Battery', containerData?.battery ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Tanto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Last Update Timestamp', 
                        _formatDateTime(containerData?.lastUpdateTanto)),
                      const SizedBox(height: 8),
                      _buildInfoRow('Last Update Posisi', 
                        containerData?.placeTanto ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Activity', 
                        containerData?.lastActivityTanto ?? 'N/A'),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'API Antares',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Last Update Timestamp', 
                        _formatDateTime(containerData?.lastUpdateAntares)),
                      const SizedBox(height: 8),
                      _buildInfoRow('Last Update Posisi', 
                        '${containerData?.latitude ?? 'N/A'}, ${containerData?.longitude ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Last Place', 
                        containerData?.placeAntares ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Troubleshoot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Pending';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _selectedStatus == 'Pending'
                                        ? const [Color(0xFF4B6CB7), Color(0xFF182848)]
                                        : [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedStatus == 'Pending'
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: _selectedStatus == 'Pending'
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.7),
                                      fontWeight: _selectedStatus == 'Pending'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Done';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _selectedStatus == 'Done'
                                        ? const [Color(0xFF36D1DC), Color(0xFF5B86E5)]
                                        : [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedStatus == 'Done'
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      color: _selectedStatus == 'Done'
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.7),
                                      fontWeight: _selectedStatus == 'Done'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Add keterangan field before status button
                if (_status == 'Pending') Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.note_add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Keterangan Troubleshoot',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextField(
                          controller: _keteranganController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Masukkan keterangan troubleshoot...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF36D1DC),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xFF36D1DC),
                      ),
                    ),
                    onPressed: _updateStatus,
                    child: const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      // Format input: "2025-02-04 02:29:08" atau "03 Feb 25 21:02"
      DateTime? date;
      if (dateStr.contains('-')) {
        // Format Antares
        date = DateTime.parse(dateStr);
      } else {
        // Format Tanto (03 Feb 25 21:02)
        final parts = dateStr.split(' ');
        if (parts.length == 4) {
          final day = parts[0];
          final month = parts[1];
          final year = '20${parts[2]}';
          final time = parts[3];
          date = DateTime.parse('$year-${_getMonthNumber(month)}-$day $time:00');
        }
      }
      
      if (date != null) {
        return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year.toString().substring(2)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return dateStr; // Return original if parsing fails
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getMonthNumber(String monthName) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final index = months.indexOf(monthName) + 1;
    return index.toString().padLeft(2, '0');
  }
}