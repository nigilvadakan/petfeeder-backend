import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'schedule_page.dart';
import 'notification_page.dart';
import 'pending_feed_page.dart';
import 'device_status_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  static const Color primaryDark = Color(0xFF28282B);
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  File? _profileImage;


  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');

    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }


  String _getUsername() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user.email!.split('@').first;
    }
    return "User";
  }

  String _getRandomTip() {
    final tips = [
      "A well-fed dog is a happy dog.",
      "Fresh water is as important as food.",
      "Daily walks keep your dog healthy.",
      "Dogs love routine feeding times.",
      "Exercise improves digestion for dogs.",
    ];
    return tips[Random().nextInt(tips.length)];
  }
  void _openCalendarOverlay() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(   // ✅ IMPORTANT
          child: Material(  // ✅ VERY IMPORTANT (fixes touch)
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2EF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: _SmartCalendar(),
            ),
          ),
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();

    /// 1. CREATE CONTROLLER (engine of animation)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    /// 2. DEFINE SLIDE ANIMATION (movement)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3), // start from top
      end: Offset.zero,             // end at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    /// 3. DEFINE FADE ANIMATION (opacity)
    _fadeAnimation = Tween<double>(
      begin: 0,   // invisible
      end: 1,     // fully visible
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    /// 4. START ANIMATION
    _controller.forward();
    loadProfileImage();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final username = _getUsername();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("feedingSchedules")
        .child(uid);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HERO SECTION
            Stack(
              clipBehavior: Clip.none,
              children: [

                /// IMAGE + GRADIENT
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [

                      /// DOG IMAGE
                      Image.asset(
                        "assets/dog.png",
                        fit: BoxFit.cover,
                      ),

                      /// SOFT GRADIENT
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x30FFFFFF),
                              Color(0x80FFF176),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// TIP CARD
                Positioned(
                  bottom: -40,
                  left: 13,
                  right: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFEAEAEA),
                      ),
                    ),
                    child: Row(
                      children: [

                        /// ICON
                        Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3C4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: Color(0xFFDAA520),
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "PawBite Insight",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF28282B),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _getRandomTip(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B6B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                /// CALENDAR
                Positioned(
                  bottom: -150,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _openCalendarOverlay,
                    child: const _WeeklyFeedIndicator(),
                  ),
                ),


                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [

                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFFFFF176),

                                      /// 🔥 IMAGE FROM PROFILE
                                      backgroundImage:
                                      _profileImage != null ? FileImage(_profileImage!) : null,

                                      /// 🔁 FALLBACK (if no image)
                                      child: _profileImage == null
                                          ? Text(
                                        username[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                          : null,
                                    ),

                                    const SizedBox(width: 8),

                                    /// TEXT
                                    Text(
                                      "Hi, $username",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          /// RIGHT → NOTIFICATION ICON
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF28282B),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 175),

            /// SEARCH


            const SizedBox(height: 10),

            /// EXPLORE TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal:20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            Padding(
              padding: EdgeInsets.symmetric(horizontal:20),
              child: Transform.translate(
                offset: Offset(0, -8), // 🔥 move UP
                child: _ExploreGrid(),
              ),
            ),

            const SizedBox(height: 35),

            /// PENDING TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal:20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pending Task",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:20),
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snapshot) {

                  String subtitle = "No Feed Scheduled";

                  if (snapshot.hasData) {

                    final event = snapshot.data as DatabaseEvent;
                    final data = event.snapshot.value;

                    if (data != null) {

                      final map = Map<String, dynamic>.from(data as Map);

                      final list = map.values.toList();

                      list.sort((a, b) {
                        return DateTime.parse(a["createdAt"])
                            .compareTo(DateTime.parse(b["createdAt"]));
                      });

                      final latest = Map<String, dynamic>.from(list.last);

                      subtitle = "Scheduled at ${latest["time"]}";
                    }
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PendingFeedPage(),
                        ),
                      );
                    },
                    child: _TaskCard(
                      color: const Color(0xFFFFF176),
                      icon: Icons.restaurant_menu_rounded,
                      title: "Feeding",
                      subtitle: subtitle,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


/// WEEKLY INDICATOR
class _WeeklyFeedIndicator extends StatelessWidget {

  const _WeeklyFeedIndicator();

  final List<String> days = const ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();
    int today = now.weekday - 1;

    /// find monday of this week
    DateTime startOfWeek = now.subtract(Duration(days: today));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {

          bool isToday = index == today;
          DateTime day = startOfWeek.add(Duration(days: index));

          return Column(
            children: [

              /// DAY NAME
              Text(
                days[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              /// DATE CARD
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 36,
                width: 36,
                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFF1F1F1),

                  borderRadius: BorderRadius.circular(10),

                  boxShadow: isToday
                      ? [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.35),
                      blurRadius: 10,
                    )
                  ]
                      : [],
                ),

                child: Text(
                  "${day.day}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isToday
                        ? Colors.black
                        : const Color(0xFF28282B),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// EXPLORE GRID
class _ExploreGrid extends StatelessWidget {

  const _ExploreGrid();

  @override
  Widget build(BuildContext context) {

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 10,
      children: const [

        _IconCard(
          Icons.calendar_month_rounded,
          "Schedule",
          Color(0xFFFFE5E5),
          Color(0xFFFF6B6B),
        ),

        _IconCard(
          Icons.memory_rounded,
          "Device Status",
          Color(0xFFE5F0FF),
          Color(0xFF4D8CFF),
        ),

      ],
    );
  }
}
class _IconCard extends StatelessWidget {

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _IconCard(this.icon,this.label,this.bgColor,this.iconColor);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {

        if (label == "Schedule") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SchedulePage()),
          );
        }

        if (label == "Device Status") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DeviceStatusPage(),
            ),
          );
        }

      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON CIRCLE (KEEP COLOR SAME)
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15), // light tint
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor, // ✅ SAME RED / BLUE
              ),
            ),

            const SizedBox(height: 12),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF28282B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _TaskCard extends StatelessWidget {

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _TaskCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(icon,color: const Color(0xFF28282B)),
          ),

          const SizedBox(width: 18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _SmartCalendar extends StatefulWidget {
  @override
  State<_SmartCalendar> createState() => _SmartCalendarState();
}

class _SmartCalendarState extends State<_SmartCalendar> {

  DateTime today = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Map<String, String> dayStatus = {};
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseDatabase.instance.ref("feedingSchedules/$uid");
    final snap = await ref.get();

    if (!snap.exists) return;

    final data = Map<String, dynamic>.from(snap.value as Map);

    Map<String, String> temp = {};

    for (var item in data.values) {
      final v = Map<String, dynamic>.from(item);

      final date = (v["date"] ?? "").toString().split("T")[0];
      final status = v["status"];

      if (status == "done" || status == "processed") {
        temp[date] = "fed";
      } else {
        temp[date] = "missed";
      }
    }

    setState(() {
      dayStatus = temp;
    });
  }

  Color _getColor(DateTime day) {

    final key = day.toIso8601String().split("T")[0];

    /// 🟡 TODAY
    if (day.year == today.year &&
        day.month == today.month &&
        day.day == today.day) {
      return const Color(0xFFC9A66B);
    }

    /// 🟢 FED
    if (dayStatus[key] == "fed") {
      return Colors.green;
    }

    /// 🔴 MISSED
    if (day.isBefore(today)) {
      return Colors.red;
    }

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 400, // 👈 NOT FULL SCREEN
      child: Column(
        children: [

          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Feeding Calendar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),

              availableGestures: AvailableGestures.all,

              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {

                  final color = _getColor(day);

                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${day.day}",
                      style: TextStyle(
                        color: color == Colors.transparent
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  );
                },

                selectedBuilder: (context, day, _) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}