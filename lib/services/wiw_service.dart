import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wiw_data.dart';

class WiwService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream untuk mendapatkan data secara real-time
  Stream<List<WiwData>> getWiwDataStream() {
    return _firestore
        .collection('data_wiw')
        .snapshots()
        .asyncMap((snapshot) async {
      List<WiwData> allData = [];
      
      for (var doc in snapshot.docs) {
        // Mengambil subcollection untuk setiap dokumen
        var subcollectionSnapshot = await doc.reference.collection('data').get();
        
        // Mengkonversi setiap dokumen dalam subcollection menjadi WiwData
        var wiwDataList = subcollectionSnapshot.docs.map((subDoc) {
          return WiwData.fromMap(subDoc.data());
        }).toList();
        
        allData.addAll(wiwDataList);
      }
      
      return allData;
    });
  }

  // Future untuk mendapatkan data sekali
  Future<List<WiwData>> getWiwData() async {
    List<WiwData> allData = [];
    
    try {
      print('Starting Firestore query...');
      // Mengambil langsung dari collection data_wiw
      var snapshot = await _firestore.collection('data_wiw').get();
      print('Documents count: ${snapshot.docs.length}');
      
      // Konversi dokumen langsung ke WiwData
      allData = snapshot.docs.map((doc) {
        print('Processing document: ${doc.id}');
        print('Document data: ${doc.data()}');
        return WiwData.fromMap(doc.data());
      }).toList();
      
      print('Total data collected: ${allData.length}');
      return allData;
    } catch (e, stackTrace) {
      print('Error fetching WIW data: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
} 