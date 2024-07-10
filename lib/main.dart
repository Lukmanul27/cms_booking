import 'package:booking_cms/Admin/dashboard_admin.dart';
import 'package:booking_cms/api/firebase_api.dart';
import 'package:booking_cms/firebase_options.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/widget/background_gradien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  
  User? currentUser = FirebaseAuth.instance.currentUser;
  Widget mainView = const MainPage();

  if (currentUser != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isAdmin) {
      mainView = const AdminDashboardScreen();
    } else {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        mainView = DashboardScreen(user_id: currentUser.uid);
      }
    }
  }

  runApp(MyApp(mainView: mainView));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  final Widget mainView;
  const MyApp({required this.mainView, super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cikajang Mini Soccer',
      theme: ThemeData(
        textTheme: GoogleFonts.changaTextTheme(),
      ),
      home: GradientBackground(
        child: mainView,
      ),
    );
  }
}
