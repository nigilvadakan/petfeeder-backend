
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceStatusPage extends StatefulWidget {
  const DeviceStatusPage({super.key});

  @override
  State<DeviceStatusPage> createState() => _DeviceStatusPageState();
}

class _DeviceStatusPageState extends State<DeviceStatusPage>
    with SingleTickerProviderStateMixin {

  static const double totalFood = 500;
  static const double totalWater = 500;

  double currentFood = 500;
  double currentWater = 500;

  late DatabaseReference scheduleRef;
  late DatabaseReference deviceRef;

  AnimationController? waveController;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    scheduleRef = FirebaseDatabase.instance.ref("feedingSchedules/$uid");
    deviceRef = FirebaseDatabase.instance.ref("deviceStatus/$uid");

    _initDeviceData();
    _listenToDevice();
    _listenToSchedule();

    waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    waveController?.dispose();
    super.dispose();
  }

  void _initDeviceData() async {
    final snap = await deviceRef.get();
    if (!snap.exists) {
      await deviceRef.set({
        "food": totalFood,
        "water": totalWater,
      });
    }
  }

  /// ✅ FIXED TYPE CAST
  void _listenToDevice() {
    deviceRef.onValue.listen((event) {
      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return;

      final data = Map<String, dynamic>.from(raw as Map);

      setState(() {
        currentFood = (data['food'] ?? totalFood).toDouble();
        currentWater = (data['water'] ?? totalWater).toDouble();
      });
    });
  }

  /// ✅ FULL FIXED LOGIC (NO UI CHANGE)
  void _listenToSchedule() {
    scheduleRef.onValue.listen((event) async {

      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return;

      final userSchedules = Map<String, dynamic>.from(raw as Map);

      for (var scheduleEntry in userSchedules.entries) {

        final scheduleId = scheduleEntry.key;
        final data = Map<String, dynamic>.from(scheduleEntry.value as Map);

        if (data['status'] != "done") continue;

        final foodUsed = (data['food'] ?? 0).toDouble();
        final waterUsed = (data['water'] ?? 0).toDouble();

        await Future.delayed(const Duration(milliseconds: 200));

        /// ✅ SAFE TRANSACTION
        await deviceRef.runTransaction((currentData) {
          if (currentData == null || currentData is! Map) {
            return Transaction.abort();
          }

          final current = Map<String, dynamic>.from(currentData as Map);

          current['food'] =
              (current['food'] - foodUsed).clamp(0, totalFood);

          current['water'] =
              (current['water'] - waterUsed).clamp(0, totalWater);

          return Transaction.success(current);
        });

        /// ✅ PREVENT REPEAT
        await scheduleRef.child(scheduleId).update({
          "status": "processed"
        });
      }
    });
  }

  void _refillDialog(String type) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Refill $type"),
          content: Text("Did you refill the $type container?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                if (type == "Food") {
                  await deviceRef.update({"food": totalFood});
                }
                if (type == "Water") {
                  await deviceRef.update({"water": totalWater});
                }
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  // ================== YOUR UI (UNCHANGED) ==================

  @override
  Widget build(BuildContext context) {

    final foodPercent = (currentFood / totalFood) * 100;
    final waterPercent = (currentWater / totalWater) * 100;

    const fixedBattery = 86.0;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Text(
                    "Device ",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC9A66B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade100,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _ultraBattery("Food", foodPercent, true)),
                    Expanded(child: _ultraBattery("Water", waterPercent, false)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade100,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Battery",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    Stack(
                      children: [

                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          height: 20,
                          width: MediaQuery.of(context).size.width *
                              (fixedBattery / 100) *
                              0.75,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC9A66B),
                                Color(0xFFE0C097),

                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "86%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ultraBattery(String title, double value, bool isFood) {
    final isLow = value < 20;

    final gradientColors = isFood
        ? [Colors.orange, Colors.deepOrange]
        : [Colors.blue, Colors.cyan];

    return Column(
      children: [

        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 14),

        Container(
          width: 70,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              if (isLow)
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 20,
                )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [

                /// EMPTY (white)
                Positioned.fill(
                  child: Container(color: Colors.white),
                ),

                /// FILL (this is the real percentage)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: 180 * (value.clamp(0, 100) / 100),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ),

        Container(
          width: 24,
          height: 6,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(height: 12),

        Text("${value.toInt()}%",
            style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),


        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const  Color(0xFFC9A66B),
            foregroundColor: Colors.black,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => _refillDialog(title),
          child: const Text("Refill"),
        ),
      ],
    );
  }
}class WavePainter extends CustomPainter {
  final double animationValue;
  final double fillPercent;

  WavePainter(this.animationValue, this.fillPercent);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()..color = Colors.white.withOpacity(0.85);

    final path = Path();

    final waveHeight = 20.0;
    final baseHeight = size.height * (1 - fillPercent);

    path.moveTo(0, 0);
    path.lineTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight +
            math.sin((i / size.width * 2 * math.pi) +
                (animationValue * 2 * math.pi)) *
                waveHeight,
      );
    }

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}