import 'package:flutter/material.dart';

class ProtifyHome extends StatelessWidget {
  const ProtifyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Protify Demonstration", style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
          },
        ),
      ),
    );
  }
}
