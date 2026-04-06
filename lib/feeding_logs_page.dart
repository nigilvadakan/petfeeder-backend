import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class FeedingLogsPage extends StatefulWidget {
  const FeedingLogsPage({super.key});

  @override
  State<FeedingLogsPage> createState() => _FeedingLogsPageState();
}

class _FeedingLogsPageState extends State<FeedingLogsPage> {

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);
  static const Color black = Color(0xFF121212);

  late DatabaseReference ref;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    ref = FirebaseDatabase.instance
        .ref()
        .child("feedingSchedules")
        .child(uid);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final event = snapshot.data as DatabaseEvent;
            final data = event.snapshot.value;

            if (data == null) {
              return const Center(child: Text("No feeding logs yet"));
            }

            final map = Map<String, dynamic>.from(data as Map);

            final list = map.entries.where((entry) {
              final v = Map<String, dynamic>.from(entry.value);
              return v["status"] == "processed" || v["status"] == "done";
            }).toList().reversed.toList();

            int totalFeeds = 0;
            int totalFood = 0;
            int totalWater = 0;

            Map<int, int> weeklyFood = {};
            Map<int, int> weeklyWater = {};

            for (var item in list) {
              final v = Map<String, dynamic>.from(item.value);

              totalFeeds++;
              totalFood += (v["food"] as num).toInt();
              totalWater += (v["water"] as num).toInt();

              final date = DateTime.parse(v["date"]);
              final weekday = date.weekday;

              weeklyFood[weekday] =
                  (weeklyFood[weekday] ?? 0) + (v["food"] as num).toInt();

              weeklyWater[weekday] =
                  (weeklyWater[weekday] ?? 0) + (v["water"] as num).toInt();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 1),

                  /// HEADER
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Feeding ",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: "Analytics",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC9A66B)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Track feeding activity and insights",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 25),

                  /// 🔥 UPDATED STAT CARDS
                  Row(
                    children: [
                      _statCard("Feeds", totalFeeds.toString(), Icons.schedule, Colors.purple),
                      const SizedBox(width: 12),
                      _statCard("Food", "$totalFood g", Icons.restaurant, Colors.orange),
                      const SizedBox(width: 12),
                      _statCard("Water", "$totalWater ml", Icons.water_drop, Colors.blue),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text("Weekly Food Dispensed",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  /// 🔥 SOFT NEURO GRAPH CARD
                  _softCard(
                    child: SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) {
                            int weekday = i + 1;
                            double value =
                            (weeklyFood[weekday] ?? 0).toDouble();

                            return BarChartGroupData(
                              x: weekday,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(6),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text("Food vs Water Consumption",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  /// 🔥 SOFT NEURO GRAPH CARD
                  _softCard(
                    child: SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(7, (i) {
                                int weekday = i + 1;
                                return FlSpot(
                                    weekday.toDouble(),
                                    (weeklyFood[weekday] ?? 0).toDouble());
                              }),
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                            ),
                            LineChartBarData(
                              spots: List.generate(7, (i) {
                                int weekday = i + 1;
                                return FlSpot(
                                    weekday.toDouble(),
                                    (weeklyWater[weekday] ?? 0).toDouble());
                              }),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text("Feeding History",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 15),

                  Column(
                    children: list.map((item) {

                      final v = Map<String, dynamic>.from(item.value);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(22),
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
                        child: Column(
                          children: [

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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(v["time"],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    v["date"].toString().split("T")[0],
                                    style: const TextStyle(color: Colors.white70),
                                  )
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [

                                  Expanded(
                                    child: _block(
                                      icon: Icons.restaurant,
                                      label: "Food",
                                      value: "${v["food"]} g",
                                      color: Colors.orange,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: _block(
                                      icon: Icons.water_drop,
                                      label: "Water",
                                      value: "${v["water"]} ml",
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );

                    }).toList(),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔥 UPDATED STAT CARD WITH COLOR ICON
  static Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F2EF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(title)
          ],
        ),
      ),
    );
  }

  /// 🔥 SOFT CARD
  Widget _softCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: child,
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
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}