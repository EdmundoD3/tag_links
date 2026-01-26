import 'package:flutter/material.dart';

class EmptyIndicator extends StatelessWidget{
  final String title;
  const EmptyIndicator({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}