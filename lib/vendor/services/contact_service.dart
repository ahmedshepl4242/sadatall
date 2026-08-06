import 'package:cloud_firestore/cloud_firestore.dart';

class ContactInfo {
  final String whatsapp;
  final String facebook;
  final String phone1;
  final String phone2;

  const ContactInfo({
    required this.whatsapp,
    required this.facebook,
    required this.phone1,
    required this.phone2,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      whatsapp: map['whatsapp']?.toString() ?? '',
      facebook: map['facebook']?.toString() ?? '',
      phone1: map['phone1']?.toString() ?? '',
      phone2: map['phone2']?.toString() ?? '',
    );
  }
}

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ContactInfo?> getContactInfo() async {
    try {
      final doc = await _firestore.collection('settings').doc('contact').get();
      if (doc.exists && doc.data() != null) {
        return ContactInfo.fromMap(doc.data()!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
