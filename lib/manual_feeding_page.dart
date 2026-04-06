import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pending_feed_page.dart';

class ManualFeedingPage extends StatefulWidget {
  const ManualFeedingPage({super.key});

  @override
  State<ManualFeedingPage> createState() => _ManualFeedingPageState();
}

class _ManualFeedingPageState extends State<ManualFeedingPage> {

  static const Color primaryDark = Color(0xFF28282B);

  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> slots = [
    {
      "food": TextEditingController(),
      "water": TextEditingController(),
      "time": null
    }
  ];

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
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        slots[index]["time"] = time;
      });
    }
  }

  void addSlot() {
    setState(() {
      slots.add({
        "food": TextEditingController(),
        "water": TextEditingController(),
        "time": null
      });
    });
  }

  Future<void> saveSchedule() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();

    for (var slot in slots) {

      if (slot["time"] == null) continue;

      await db
          .child("feedingSchedules")
          .child(uid)
          .push()
          .set({

        "date": selectedDate.toIso8601String(),
        "time": slot["time"].format(context),

        "food": int.tryParse(slot["food"].text) ?? 0,
        "water": int.tryParse(slot["water"].text) ?? 0,

        "status": "pending",
        "createdAt": DateTime.now().toIso8601String()

      });
    }

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0,10),
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
                    color: Color(0xFFFFE7A0),
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
                    color: Colors.grey,
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
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6E6B4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E6B4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryDark,
          ),
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

              const SizedBox(height: 2),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Manual ",
                      style: TextStyle(color: primaryDark),
                    ),
                    TextSpan(
                      text: "Feeding",
                      style: TextStyle(color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                "Plan your pet’s meal time",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              /// DATE CARD
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
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
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

              /// FEED SLOT ITEMS
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(slots.length),
                  children: List.generate(slots.length, (index) {

                    var slot = slots[index];

                    return Column(
                      children: [

                        _field(
                          "Food Quantity (g)",
                          slot["food"],
                          Icons.restaurant,
                          const Color(0xFFFF9800),
                        ),

                        const SizedBox(height: 12),

                        _field(
                          "Water Quantity (ml)",
                          slot["water"],
                          Icons.water_drop,
                          const Color(0xFF42A5F5),
                        ),

                        const SizedBox(height: 12),

                        InkWell(
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
                                  Icons.schedule,
                                  color: Colors.deepPurple,
                                ),

                                const SizedBox(width: 12),

                                Text(
                                  slot["time"] == null
                                      ? "Select Time"
                                      : slot["time"].format(context),

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              /// ADD SLOT
              GestureDetector(
                onTap: addSlot,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black26),
                  ),

                  child: const Center(
                    child: Text(
                      "+ Add Feeding Slot",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryDark,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              /// SCHEDULE BUTTON
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
                      offset: const Offset(0,6),
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

  Widget _field(
      String label,
      TextEditingController controller,
      IconData icon,
      Color iconColor,
      ) {

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

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}