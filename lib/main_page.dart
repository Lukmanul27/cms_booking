import 'package:booking_cms/Auth/login_screen.dart';
import 'package:booking_cms/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cikajang Mini Soccer',
      theme: ThemeData(
        textTheme: GoogleFonts.changaTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green shade for soccer field
              Color(0xFF388E3C), // Darker green shade for contrast
              Color(0xFF1B5E20), // Even darker green shade for depth
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/assets/img/logo.png",
                  width: 120,
                  height: 120,
                ),
                Text(
                  'Cikajang Mini Soccer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.changa(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 100),
                Text(
                  'Selamat Datang\ndi Aplikasi Booking\nLapangan Mini Soccer!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.changa(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Selanjutnya',
                    style: GoogleFonts.changa(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF141414),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
