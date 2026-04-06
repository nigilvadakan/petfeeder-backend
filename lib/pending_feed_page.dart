import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PendingFeedPage extends StatelessWidget {
  const PendingFeedPage({super.key});

  static const Color bgWhite = Colors.white;
  static const Color black = Color(0xFF121212);
  static const Color accentYellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("feedingSchedules")
        .child(uid);

    return Scaffold(
      backgroundColor: bgWhite,

      appBar: AppBar(
        backgroundColor: bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HEADER (FIXED)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Pending ",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Feedings",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: accentYellow,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Upcoming scheduled meals",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final event = snapshot.data as DatabaseEvent;
                  final data = event.snapshot.value;

                  /// 🔥 EMPTY STATE 1
                  if (data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [

                          Text("🐾", style: TextStyle(fontSize: 40)),

                          SizedBox(height: 10),

                          Text(
                            "All caught up!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "No scheduled feedings yet.\nYour pet is waiting 🐶",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }

                  final map = Map<String, dynamic>.from(data as Map);

                  final list = map.entries.where((entry) {
                    final item = Map<String, dynamic>.from(entry.value);
                    return item["status"] == "pending";
                  }).toList();

                  /// 🔥 EMPTY STATE 2
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [

                          Text("🐾", style: TextStyle(fontSize: 40)),

                          SizedBox(height: 10),

                          Text(
                            "All done!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "No pending feedings right now.\nYour pet is happy & well fed ✨",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: list.length,
                    itemBuilder: (context, index) {

                      final key = list[index].key;
                      final item =
                      Map<String, dynamic>.from(list[index].value);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),

                        decoration: BoxDecoration(
                          color: bgWhite,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08), // ✅ fixed
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),

                        child: Column(
                          children: [

                            /// 🔥 BLACK HEADER
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: black,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  topRight: Radius.circular(22),
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [

                                  Text(
                                    item["time"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  Text(
                                    item["date"].toString().split("T")[0],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// CONTENT
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [

                                  Row(
                                    children: [

                                      Expanded(
                                        child: _block(
                                          icon: Icons.restaurant,
                                          label: "Food",
                                          value: "${item["food"]} g",
                                          color: Colors.orange,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: _block(
                                          icon: Icons.water_drop,
                                          label: "Water",
                                          value: "${item["water"]} ml",
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [

                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6),
                                        decoration: BoxDecoration(
                                          color: accentYellow,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          "Pending",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:
                                                const Text("Cancel"),
                                                content: const Text(
                                                    "Cancel this feeding?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context),
                                                    child:
                                                    const Text("No"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await ref
                                                          .child(key)
                                                          .remove();
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: const Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          color:
                                                          Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
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

  Widget _block({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon, color: color, size: 20),

          const SizedBox(height: 6),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}