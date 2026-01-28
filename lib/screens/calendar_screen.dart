import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String customerName;
  const CalendarScreen({super.key, required this.customerName});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Map<int, bool> milkEntries = {};
  int totalBill = 0;

  void calculateBill(bool isCow) {
    int rate = isCow ? 75 : 85;
    int totalDays = milkEntries.values.where((e) => e).length;
    setState(() {
      totalBill = totalDays * rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.customerName}"),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                "Sobhnath Dairy",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(title: Text("Profile")),
            ListTile(title: Text("Orders")),
            ListTile(title: Text("Logout")),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              DateFormat.yMMMM().format(now),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                int day = index + 1;
                bool selected = milkEntries[day] ?? false;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      milkEntries[day] = !selected;
                    });
                  },
                  child: Card(
                    color: selected ? Colors.green : Colors.white,
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total Bill Till Today: ₹$totalBill",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => calculateBill(true),
                      child: const Text("Cow Milk"),
                    ),
                    ElevatedButton(
                      onPressed: () => calculateBill(false),
                      child: const Text("Buffalo Milk"),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
