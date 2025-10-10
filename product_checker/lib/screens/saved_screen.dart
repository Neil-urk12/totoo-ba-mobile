import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Saved',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}