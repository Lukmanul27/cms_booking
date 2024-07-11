import 'package:booking_cms/widget/widget_admin/custom_appbar.dart';
import 'package:booking_cms/widget/widget_admin/sidebar_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KelolaUser extends StatefulWidget {
  const KelolaUser({super.key});

  @override
  State<KelolaUser> createState() => _KelolaUserState();
}

class _KelolaUserState extends State<KelolaUser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _editUser(
      String docId, String username, String email, String role) async {
    _usernameController.text = username;
    _emailController.text = email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: TextEditingController(text: role),
              enabled: false,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _firestore.collection('users').doc(docId).update({
                'username': _usernameController.text,
                'email': _emailController.text,
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String docId) async {
    await _firestore.collection('users').doc(docId).delete();
  }

  Future<void> _changeUserRole(String docId, String currentRole) async {
    String newRole = currentRole == 'admin' ? 'user' : 'admin';
    await _firestore.collection('users').doc(docId).update({
      'role': newRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        padding: const EdgeInsets.all(16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Admins',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('role', isEqualTo: 'admin')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No Admins Found',
                            style: TextStyle(color: Colors.white)));
                  }
        
                  final admins = snapshot.data!.docs;
        
                  return ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      final admin = admins[index];
                      final adminData = admin.data() as Map<String, dynamic>;
        
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            adminData['username'] ?? 'No Username',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            adminData['email'] ?? 'No Email',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  _editUser(admin.id, adminData['username'],
                                      adminData['email'], adminData['role']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  _deleteUser(admin.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.swap_horizontal_circle,
                                    color: Colors.white),
                                onPressed: () {
                                  _changeUserRole(
                                      admin.id, adminData['role']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('role', isEqualTo: 'user')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No Users Found',
                            style: TextStyle(color: Colors.white)));
                  }
        
                  final users = snapshot.data!.docs;
        
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final userData = user.data() as Map<String, dynamic>;
        
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            userData['username'] ?? 'No Username',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            userData['email'] ?? 'No Email',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  _editUser(user.id, userData['username'],
                                      userData['email'], userData['role']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  _deleteUser(user.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.swap_horizontal_circle,
                                    color: Colors.white),
                                onPressed: () {
                                  _changeUserRole(user.id, userData['role']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': token,
      });
    }
  }
}
