import 'dart:convert';

import 'package:http/http.dart' as http;

class UserReservationSubmittedNotification {
  final String id = 'user_1';
  final String title = 'Reservasi Berhasil Diajukan';
  final String body = 'Mohon untuk menunggu validasi reservasi Anda.';
}

class UserReservationFailedNotification {
  final String id = 'user_2';
  final String title = 'Reservasi Gagal';
  final String body = 'Reservasi Anda gagal. Silakan periksa kembali detailnya.';
}

class UserReservationSuccessfulNotification {
  final String id = 'user_3';
  final String title = 'Reservasi Berhasil';
  final String body = 'Silakan datang 30 menit sebelum tanggal, waktu, pukul yang Anda pesan dan lakukan konfirmasi.';
}

class AdminNewReservationNotification {
  final String id = 'admin_1';
  final String title = 'Ada Permintaan Reservasi Baru';
  final String body = 'Mohon untuk memeriksa permintaan reservasi baru.';
}

class NotificationService {
  static const String projectId = 'booking-cms-155yg';
  static const String accessToken = '.a0AXooCgvLi_12yNzi2nIeaxwradQzwSnsj1v8RocUAzinEvD9vrWYSFjd3IMyPe-pN0fveKR5jrqTZRSw9T9gcGgLy5ARDqdUO29BcBdCCiTqzCmC0dqfISumD31lO9owhqIu_V6qibv5Wnt031OQ93EewYW7TbzdW46FaCgYKAewSARASFQHGX2MibDMRkTs_k0m1MEKunxJZyg0171';

  static Future<void> sendNotification(String token, String title, String body) async {
    try {
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

// Example usage:
void main() async {
  String userToken = 'USER_FCM_TOKEN_HERE'; // Replace with actual user FCM token
  String adminToken = 'ADMIN_FCM_TOKEN_HERE'; // Replace with actual admin FCM token

  // Send user notifications
  await NotificationService.sendNotification(
    userToken,
    UserReservationSubmittedNotification().title,
    UserReservationSubmittedNotification().body,
  );

  await NotificationService.sendNotification(
    userToken,
    UserReservationFailedNotification().title,
    UserReservationFailedNotification().body,
  );

  await NotificationService.sendNotification(
    userToken,
    UserReservationSuccessfulNotification().title,
    UserReservationSuccessfulNotification().body,
  );

  // Send admin notification
  await NotificationService.sendNotification(
    adminToken,
    AdminNewReservationNotification().title,
    AdminNewReservationNotification().body,
  );
}
