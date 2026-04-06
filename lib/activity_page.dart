import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  late AnimationController _controller;
  late Animation<double> _animation;

  Future<Map<String, int>> fetchUsage() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "guest";

    final ref = FirebaseDatabase.instance.ref("usage/$uid");
    final snapshot = await ref.get();

    Map<String, int> result = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((date, value) {
        final day = DateTime.parse(date);
        final weekday = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][day.weekday - 1];
        result[weekday] = value;
      });
    }

    return result;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDetails(String day, int value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(day),
        content: Text("Usage: $value minutes"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final todayIndex = DateTime.now().weekday - 1;
    final days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, int>>(
          future: fetchUsage(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            final maxVal = data.values.reduce((a, b) => a > b ? a : b);

            _controller.forward();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),

                  const Text(
                    "My Activity",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Your weekly app usage",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.entries.map((e) {

                            final index = days.indexOf(e.key);
                            final isToday = index == todayIndex;

                            final heightFactor = maxVal == 0
                                ? 0.0
                                : (e.value / maxVal) * _animation.value;

                            return GestureDetector(
                              onTap: () => _showDetails(e.key, e.value),
                              child: Column(
                                children: [

                                  Text("${e.value}",
                                      style: const TextStyle(fontSize: 10)),

                                  const SizedBox(height: 5),

                                  Container(
                                    width: isToday ? 22 : 18,
                                    height: 120,
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: heightFactor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFD6B885),
                                              Color(0xFFC9A66B),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: isToday
                                              ? [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                              : [],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );

                          }).toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Summary",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Total: ${data.values.reduce((a, b) => a + b)} mins",
                        ),

                        Text(
                          "Average: ${(data.values.reduce((a, b) => a + b) / 7).toStringAsFixed(1)} mins/day",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}