import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reports',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}