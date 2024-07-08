import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationService {
  static const String _serverKey = 'YOUR_SERVER_KEY'; // Ganti dengan server key Anda

  static Future<void> sendNotification(String token, String title, String body) async {
    final Uri fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      fcmUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': 'Sample FCM Message',
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notifikasi terkirim');
    } else {
      print('Gagal mengirim notifikasi. Status: ${response.statusCode}');
    }
  }
}
