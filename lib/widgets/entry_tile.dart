import 'package:flutter/material.dart';
import '../models/milk_entry.dart';

class EntryTile extends StatelessWidget {
  final MilkEntry entry;
  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${entry.quantity} L'),
      subtitle: Text('${entry.date.toLocal().toString().split(' ')[0]} — By ${entry.addedBy}'),
    );
  }
}
