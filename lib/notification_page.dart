import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  late DatabaseReference notifRef;
  late DatabaseReference deviceRef;

  static const double total = 500;

  /// 🔥 SAME COLORS AS SETTINGS PAGE
  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  bool wasFoodLow = false;
  bool wasWaterLow = false;

  Set<String> handledSchedules = {};

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    notifRef = FirebaseDatabase.instance.ref("notifications/$uid");
    deviceRef = FirebaseDatabase.instance.ref("deviceStatus/$uid");

    _listenDevice();
    _listenSchedules();
  }

  void _listenDevice() {
    deviceRef.onValue.listen((event) {

      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final food = (data['food'] ?? 0).toDouble();
      final water = (data['water'] ?? 0).toDouble();

      final foodPercent = (food / total) * 100;
      final waterPercent = (water / total) * 100;

      final isFoodLow = foodPercent < 20;
      final isWaterLow = waterPercent < 20;

      if (isFoodLow && !wasFoodLow) {
        _push("Food level below 20%. Please refill.");
      }

      if (isWaterLow && !wasWaterLow) {
        _push("Water level below 20%. Please refill.");
      }

      wasFoodLow = isFoodLow;
      wasWaterLow = isWaterLow;
    });
  }
  void _listenSchedules() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final scheduleRef =
    FirebaseDatabase.instance.ref("feedingSchedules/$uid");

    scheduleRef.onValue.listen((event) async {
      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return;

      final schedules = Map<String, dynamic>.from(raw);

      for (var entry in schedules.entries) {
        final scheduleId = entry.key;
        final data = Map<String, dynamic>.from(entry.value);

        final status = data['status'];

        /// ✅ ONLY when DONE
        if (status != "done") continue;

        /// ✅ PREVENT DUPLICATION
        if (handledSchedules.contains(scheduleId)) continue;

        handledSchedules.add(scheduleId);

        /// 🔥 PUSH NOTIFICATION
        await _push("Feeding completed successfully 🐶");
      }
    });
  }

  Future<void> _push(String msg) async {
    await notifRef.push().set({
      "message": msg,
      "time": DateTime.now().toString(),
    });
  }

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("notifications/$uid");

    return Scaffold(
      backgroundColor: bgColor,

      /// 🔥 SAME APPBAR STYLE AS SETTINGS
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HEADER (MATCH SETTINGS STYLE)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Your alerts and updates",
                style: TextStyle(color: Colors.black54),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 LIST
            Expanded(
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final event = snapshot.data as DatabaseEvent;
                  final data = event.snapshot.value;

                  if (data == null) {
                    return const Center(child: Text("No notifications"));
                  }

                  final map = Map<String, dynamic>.from(data as Map);
                  final list = map.entries.toList().reversed.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,

                    itemBuilder: (context, index) {

                      final entry = list[index];
                      final item = Map<String, dynamic>.from(entry.value);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),

                        child: Dismissible(
                          key: Key(entry.key),
                          direction: DismissDirection.endToStart,

                          onDismissed: (_) {
                            ref.child(entry.key).remove();
                          },

                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Clear",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          /// 🔥 NEUMORPHIC CARD (LIKE SETTINGS)
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),

                            child: Row(
                              children: [

                                /// ICON STYLE MATCHED
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.9),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 4,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Color(0xFFC9A66B),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                /// TEXT
                                Expanded(
                                  child: Text(
                                    item["message"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: primaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}