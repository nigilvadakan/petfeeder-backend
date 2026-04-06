import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pending_feed_page.dart';

class AutomaticFeedingPage extends StatefulWidget {
  const AutomaticFeedingPage({super.key});

  @override
  State<AutomaticFeedingPage> createState() => _AutomaticFeedingPageState();
}

class _AutomaticFeedingPageState extends State<AutomaticFeedingPage> {

  static const Color primaryDark = Color(0xFF28282B);

  /// UPDATED BLUE BACKGROUND
  static const Color autoBlueBG = Color(0xFFDCE9FF);

  DateTime selectedDate = DateTime.now();

  int feedsPerDay = 3;

  double foodPerFeed = 0;
  double waterPerFeed = 0;

  List<TimeOfDay?> times = [];

  void setRecommendedTimes() {
    if (feedsPerDay == 2) {
      times = [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
      ];
    }

    else if (feedsPerDay == 3) {
      times = [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 13, minute: 0),
        const TimeOfDay(hour: 19, minute: 0),
      ];
    }

    else if (feedsPerDay == 4) {
      times = [
        const TimeOfDay(hour: 7, minute: 0),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 17, minute: 0),
        const TimeOfDay(hour: 21, minute: 0),
      ];
    }
  }

  Future<void> loadPetData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
    await FirebaseDatabase.instance.ref("users/$uid/pet").get();

    final data = snapshot.value as Map;

    double weight = double.parse(data["weight"].toString());

    int ageYears = int.parse(data["age"].toString());

    calculateFeed(weight, ageYears);
  }

  void calculateFeed(double weightKg, int ageYears) {
    double rer = 70 * pow(weightKg, 0.75).toDouble();

    double multiplier;

    if (ageYears < 1) {
      multiplier = 2.0;
    }
    else if (ageYears < 7) {
      multiplier = 1.6;
    }
    else {
      multiplier = 1.2;
    }

    double dailyCalories = rer * multiplier;

    double foodPerDay = (dailyCalories / 350) * 100;

    double waterPerDay = weightKg * 55;

    setState(() {
      foodPerFeed = foodPerDay / feedsPerDay;
      waterPerFeed = waterPerDay / feedsPerDay;
    });
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: times[index] ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        times[index] = time;
      });
    }
  }

  Future<void> saveSchedule() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();

    for (var time in times) {
      if (time == null) continue;

      await db
          .child("feedingSchedules")
          .child(uid)
          .push()
          .set({

        "date": selectedDate.toIso8601String(),
        "time": time.format(context),

        "food": foodPerFeed.round(),
        "water": waterPerFeed.round(),

        "status": "pending",
        "createdAt": DateTime.now().toIso8601String()
      });
    }

    /// CONFIRMATION DIALOG (BLUE THEME)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PendingFeedPage(),
            ),
          );
        });

        return Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(26),

            decoration: BoxDecoration(
              color: autoBlueBG,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 34,
                    color: primaryDark,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Feed Scheduled",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: primaryDark,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Your feeding schedule has been saved",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.none,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    setRecommendedTimes();
    loadPetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: autoBlueBG,

      appBar: AppBar(
        backgroundColor: autoBlueBG,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Automatic ",
                      style: TextStyle(color: primaryDark),
                    ),
                    TextSpan(
                      text: "Feeding",
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                "Smart feeding based on pet profile",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              InkWell(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [

                      const Icon(Icons.calendar_today),

                      const SizedBox(width: 12),

                      Text(
                        "${selectedDate.day}-${selectedDate
                            .month}-${selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      const Icon(Icons.keyboard_arrow_down)

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// FOOD CARD
              _infoCard(
                "Recommended Food",
                "${foodPerFeed.round()} g",
                Icons.restaurant,
              ),

              const SizedBox(height: 14),

              /// WATER CARD
              _infoCard(
                "Recommended Water",
                "${waterPerFeed.round()} ml",
                Icons.water_drop,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Feeds per day",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    DropdownButton<int>(
                      value: feedsPerDay,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 2, child: Text("2")),
                        DropdownMenuItem(value: 3, child: Text("3")),
                        DropdownMenuItem(value: 4, child: Text("4")),
                      ],
                      onChanged: (v) {
                        feedsPerDay = v!;

                        setRecommendedTimes();
                        loadPetData();

                        setState(() {});
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Column(
                children: List.generate(times.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),

                    child: InkWell(

                      onTap: () => pickTime(index),

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Row(
                          children: [

                            const Icon(
                                Icons.schedule, color: Colors.deepPurple),

                            const SizedBox(width: 12),

                            Text(
                              times[index] == null
                                  ? "Select Time"
                                  : times[index]!.format(context),

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                height: 55,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E2E2E),
                      Color(0xFF1C1C1C)
                    ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),

                child: Material(
                  color: Colors.transparent,

                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: saveSchedule,

                    child: const Center(
                      child: Text(
                        "Schedule Feeding",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title,
      String value,
      IconData icon,) {
    Color iconColor = primaryDark;

    if (icon == Icons.restaurant) {
      iconColor = const Color(0xFFFF8A00);
    }

    if (icon == Icons.water_drop) {
      iconColor = const Color(0xFF1E88E5);
    }

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Icon(icon, color: iconColor),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(title),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}