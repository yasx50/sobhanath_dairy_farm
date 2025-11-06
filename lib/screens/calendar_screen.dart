import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/firebase_service.dart';
import '../models/milk_entry.dart';

class CalendarScreen extends StatefulWidget {
  final String customerId;
  const CalendarScreen({super.key, required this.customerId});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  final FirebaseService _svc = FirebaseService();
  Map<DateTime, List<MilkEntry>> events = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final start = DateTime.now().subtract(const Duration(days: 365));
    final end = DateTime.now().add(const Duration(days: 365));
    final all = await _svc.getEntriesForCustomerBetween(widget.customerId, start, end);
    final map = <DateTime, List<MilkEntry>>{};
    for (var e in all) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    setState(() => events = map);
  }

  List<MilkEntry> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020,1,1),
            lastDay: DateTime.utc(2030,12,31),
            focusedDay: _focused,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
              final entries = _getEventsForDay(selected);
              showModalBottomSheet(context: context, builder: (_) => _entriesSheet(entries, selected));
            },
            eventLoader: _getEventsForDay,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // open add entry screen/dialog for _focused date
          _openAddEntry(context, _focused);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _entriesSheet(List<MilkEntry> entries, DateTime date) {
    return ListView(
      children: [
        ListTile(title: Text('Entries for ${date.toLocal().toString().split(' ')[0]}')),
        ...entries.map((e) => ListTile(
          title: Text('${e.quantity} L'),
          subtitle: Text('By: ${e.addedBy}'),
        )),
      ],
    );
  }

  void _openAddEntry(BuildContext ctx, DateTime date) {
    showDialog(context: ctx, builder: (_) {
      double qty = 0;
      return AlertDialog(
        title: const Text('Add milk entry'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity (liters)'),
          onChanged: (v) => qty = double.tryParse(v) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (qty <= 0) return;
            final entry = MilkEntry(id: '', customerId: widget.customerId, date: date, quantity: qty, addedBy: 'owner');
            await FirebaseService().addMilkEntry(entry);
            Navigator.pop(ctx);
            _loadEntries();
          }, child: const Text('Save'))
        ],
      );
    });
  }
}
