import 'package:booking_cms/main_page.dart';
import 'package:booking_cms/user_pages/detail/usernotif.dart';
import 'package:booking_cms/user_pages/menu/akun_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool hasNewNotification;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.hasNewNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        leading: const _MenuButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBarTitle(title: title),
            _AppBarSubtitle(subtitle: subtitle),
          ],
        ),
        actions: [_NotificationButton(hasNewNotification: hasNewNotification)],
        backgroundColor: const Color(0xFF4CAF50), // Green shade for soccer field
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _AppBarTitle extends StatelessWidget {
  final String title;
  const _AppBarTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Cikajang Mini Soccer',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _AppBarSubtitle extends StatelessWidget {
  final String subtitle;

  const _AppBarSubtitle({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
      onSelected: (value) async {
        if (value == 'Akun') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AkunScreen(),
            ),
          );
        } else if (value == 'Logout') {
          await FirebaseAuth.instance.signOut();
          Get.offAll(() => const MainPage());
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'Akun',
            child: ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Akun'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Logout',
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ),
        ];
      },
    );
  }
}

class _NotificationButton extends StatefulWidget {
  final bool hasNewNotification;

  const _NotificationButton({required this.hasNewNotification});

  @override
  __NotificationButtonState createState() => __NotificationButtonState();
}

class __NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    _controller.forward().then((value) => _controller.reverse());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: NotificationScreen(), // Example usage
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: _onPressed,
          icon: ScaleTransition(
            scale: _animation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          iconSize: 40,
          splashColor: Colors.transparent,
        ),
        if (widget.hasNewNotification)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
