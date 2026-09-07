import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String staticMapUrl;
  final String googleMapsUrl;
  final String label;
  final String note;
  final DateTime? timestamp;

  LocationModel({
    this.id = '',
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    this.staticMapUrl = '',
    this.googleMapsUrl = '',
    this.label = 'Current Location',
    this.note = '',
    this.timestamp,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map, String id) {
    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return LocationModel(
      id: id,
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      postalCode: map['postalCode']?.toString() ?? '',
      staticMapUrl: map['staticMapUrl']?.toString() ?? '',
      googleMapsUrl: map['googleMapsUrl']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Current Location',
      note: map['note']?.toString() ?? '',
      timestamp: parseDate(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'staticMapUrl': staticMapUrl,
      'googleMapsUrl': googleMapsUrl,
      'label': label,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  LocationModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? staticMapUrl,
    String? googleMapsUrl,
    String? label,
    String? note,
    DateTime? timestamp,
  }) {
    return LocationModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      staticMapUrl: staticMapUrl ?? this.staticMapUrl,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      label: label ?? this.label,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
