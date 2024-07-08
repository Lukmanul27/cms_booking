import 'package:booking_cms/Admin/dashboard_admin.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/widget/background_gradien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: "AIzaSyCh8uZ--I0BAJnhLf4F8uC75FSejldJ_yY",
              authDomain: "booking-cms-155yg.firebaseapp.com",
              projectId: "booking-cms-155yg",
              storageBucket: "booking-cms-155yg.appspot.com",
              messagingSenderId: "37218947084",
              appId: "1:37218947084:web:36be78ce26b4898ad0de29",
            )
          : DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
