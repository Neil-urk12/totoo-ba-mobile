import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/action_button_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Verify Products in Seconds',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Search Bar Widget
            const SearchBarWidget(),
            const SizedBox(height: 20),
            // Verify Product Button
            ActionButtonWidget(
              text: 'Verify Product',
              icon: Icons.search,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              iconColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () { 
              },
            ),
            const SizedBox(height: 10),
            // Search by Image Button
            ActionButtonWidget(
              text: 'Search by Image', 
              icon: Icons.image_search, 
              backgroundColor: Theme.of(context).colorScheme.surface, 
              textColor: Theme.of(context).colorScheme.onSurface, 
              iconColor: Theme.of(context).colorScheme.onSurface, 
              onPressed: () {

              }
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}