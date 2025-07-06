import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("A N A L Y T I C S", style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20
          )),
        ),
        leading: IconButton(
          onPressed: () async {
            await Future.delayed(Duration(milliseconds: 100));
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.inversePrimary)
        ),
        actions: [  // Placeholder Icon so that title centered
          IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
        ],
      ),

      body: Center(
        child: Text("Coming in Version 1.3", 
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16.5)
        )
      ),
    );
  }
}