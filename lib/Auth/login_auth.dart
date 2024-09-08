import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  static bool isLoggedIn = false;
  static bool isAdmin = false;

  static Future<void> login(String email, String password) async {
    // Logika autentikasi
    // Set isLoggedIn dan isAdmin ke true sesuai dengan logika autentikasi
    isLoggedIn = true;
    isAdmin = email == 'admin@cms.com' && password == 'adminpassword'; // Ubah isAdmin menjadi true jika email adalah admin@cms.com dan password sesuai

    // Simpan status login dan peran pengguna ke SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
    prefs.setBool('isAdmin', isAdmin);
  }

  static Future<void> logout() async {
    // Logika logout
    isLoggedIn = false;
    isAdmin = false;

    // Hapus status login dan peran pengguna dari SharedPreferences saat logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('isAdmin');
  }

  static Future<void> loadLoginStatus() async {
    // Memuat status login dan peran pengguna dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    isAdmin = prefs.getBool('isAdmin') ?? false;
  }
}
