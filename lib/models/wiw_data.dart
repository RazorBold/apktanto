import 'package:cloud_firestore/cloud_firestore.dart';

class WiwData {
  final String? action;
  final String? activityAntares;
  final double? latitude;
  final double? longitude;
  final String? battery;
  final String? containerId;
  final String? containerStatus;
  final String? deveui;
  final String? lastUpdateAntares;
  final String? lastUpdateTanto;
  final String? lastActivityTanto;
  final String? no;
  final String? placeAntares;
  final String? placeTanto;
  final String? status;
  final DateTime? timestamp;
  final String? tanggalTroubleshoot;
  final String? keteranganTroubleshoot;

  WiwData({
    this.action,
    this.activityAntares,
    this.latitude,
    this.longitude,
    this.battery,
    this.containerId,
    this.containerStatus,
    this.deveui,
    this.lastUpdateAntares,
    this.lastUpdateTanto,
    this.lastActivityTanto,
    this.no,
    this.placeAntares,
    this.placeTanto,
    this.status,
    this.timestamp,
    this.tanggalTroubleshoot,
    this.keteranganTroubleshoot,
  });

  factory WiwData.fromMap(Map<String, dynamic> map) {
    return WiwData(
      action: map['Action'] as String?,
      activityAntares: map['Activity-antares'] as String?,
      latitude: map['Latitude'] != null ? double.tryParse(map['Latitude'].toString()) : null,
      longitude: map['Longitude'] != null ? double.tryParse(map['Longitude'].toString()) : null,
      battery: map['battery'] as String?,
      containerId: map['container-id'] as String?,
      containerStatus: map['container-status'] as String?,
      deveui: map['deveui'] as String?,
      lastUpdateAntares: map['last-update-antares'] as String?,
      lastUpdateTanto: map['last-update-tanto'] as String?,
      lastActivityTanto: map['lastactivity-tanto'] as String?,
      no: map['no']?.toString(),
      placeAntares: map['place-antares'] as String?,
      placeTanto: map['place-tanto'] as String?,
      status: map['status'] as String?,
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      tanggalTroubleshoot: map['tanggal-troubleshoot'] as String?,
      keteranganTroubleshoot: map['keterangan-troubleshoot'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deveui': deveui,
      'containerId': containerId,
      'status': status,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
} 