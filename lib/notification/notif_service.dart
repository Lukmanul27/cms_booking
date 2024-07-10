import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String serverKey = 'YOUR_SERVER_KEY';
  static const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/booking-cms-155yg/messages:send';

  static Future<void> sendNotification(String token, String title, String body) async {
    final Map<String, dynamic> notification = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
        }
      }
    };

    final response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: {
        'Authorization': 'Bearer $serverKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(notification),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification sent successfully.');
      }
    } else {
      if (kDebugMode) {
        print('Failed to send notification. Response: ${response.body}');
      }
    }
  }
}
