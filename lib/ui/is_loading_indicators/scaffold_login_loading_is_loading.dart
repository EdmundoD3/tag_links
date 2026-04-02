import 'package:flutter/material.dart';

class ScaffoldLoginLoading extends StatelessWidget {
  const ScaffoldLoginLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
