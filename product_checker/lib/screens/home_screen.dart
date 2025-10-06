import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/action_button_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Verify Products in Seconds',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          // Search Bar Widget
          const SearchBarWidget(),
          const SizedBox(height: 20),
          // Verify Product Button
          ActionButtonWidget(
            text: 'Verify Product',
            icon: Icons.search,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            iconColor: Colors.white,
            onPressed: () { 
            },
          ),
          const SizedBox(height: 10),
          // Search by Image Button
          ActionButtonWidget(
          text: 'Search by Image', 
          icon: Icons.image_search, 
          backgroundColor: Colors.white, 
          textColor: Colors.black, 
          iconColor: Colors.black, 
          onPressed: () {

          }
          )
        ],
      ),
    );
  }
}