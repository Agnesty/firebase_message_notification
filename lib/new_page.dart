import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NewPage extends StatelessWidget {
  final String info;
  const NewPage({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latihan Firebase Messaging'),
      ),
      body: Center(child: Text(info),),
    );
  }
}