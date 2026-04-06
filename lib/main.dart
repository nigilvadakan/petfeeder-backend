import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ ADDED

import 'landing_page.dart';
import 'bar.dart';
import 'pet_details_page.dart';
import 'loading_screen.dart';
import 'usage_tracker.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// ✅ ADDED
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const PetFeederApp());
}

class PetFeederApp extends StatefulWidget {
  const PetFeederApp({super.key});

  @override
  State<PetFeederApp> createState() => _PetFeederAppState();
}

class _PetFeederAppState extends State<PetFeederApp> {

  // 🔥 ADD TRACKER (unchanged)
  final tracker = UsageTracker();

  /// ✅ ADDED (FCM setup)
  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔔 Ask permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permission: ${settings.authorizationStatus}");

    // 🔑 Get token
    String? token = await messaging.getToken();
    print("🔥 FCM TOKEN: $token");

    // 💾 Save token to Firebase
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && token != null) {
      await FirebaseDatabase.instance
          .ref("users/$uid")
          .update({"fcmToken": token});
    }

    // 📩 Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message: ${message.notification?.title}");
    });
  }

  @override
  void initState() {
    super.initState();

    tracker.start(); // 🔥 unchanged

    setupFCM(); // ✅ ADDED
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PetFeeder",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthCheck(),
    );
  }
}

// 🔽 BELOW THIS NOTHING CHANGED

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasData) {
          return const CheckPetDetails();
        }

        return const LandingPage();
      },
    );
  }
}

class CheckPetDetails extends StatelessWidget {
  const CheckPetDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder(
      future: FirebaseDatabase.instance.ref("users/$uid/pet").get(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          return const BottomBar();
        }

        return const PetDetailsPage();
      },
    );
  }
}