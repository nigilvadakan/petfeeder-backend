import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UsageTracker with WidgetsBindingObserver {
  DateTime? startTime;
  bool isTracking = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);

    startTime = DateTime.now();
    isTracking = true;

    print("Tracker started");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("STATE: $state");

    /// ✅ APP GOES TO BACKGROUND
    if (state == AppLifecycleState.paused && isTracking) {
      await _saveUsage();
      isTracking = false;
    }

    /// ✅ APP COMES BACK
    if (state == AppLifecycleState.resumed) {
      startTime = DateTime.now();
      isTracking = true;
    }
  }

  Future<void> _saveUsage() async {
    if (startTime == null) return;

    final now = DateTime.now();
    final seconds = now.difference(startTime!).inSeconds;

    /// ❌ Ignore very short sessions (<10 sec)
    if (seconds < 10) {
      print("Too short, ignored");
      return;
    }

    final minutes = seconds ~/ 60;

    /// ❌ Ignore unrealistic sessions (>3 hours)
    if (minutes > 180) {
      print("Unrealistic session ignored: $minutes");
      return;
    }

    print("Saving usage: $minutes min");

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "guest";

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final ref = FirebaseDatabase.instance.ref("usage/$uid/$today");

    final snapshot = await ref.get();

    int existing = 0;
    if (snapshot.exists) {
      existing = snapshot.value as int;
    }

    await ref.set(existing + minutes);

    print("Saved successfully");
  }
}