import 'package:flutter/material.dart';
import 'package:leans/components/themes.dart';
import 'package:leans/components/web_server.dart';
import 'package:leans/pages/drive/drive_home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebServer()),
      ],
      child: const Leans(),
    ),
  );
}

class Leans extends StatelessWidget {
  const Leans({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leans',
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontSize: 24, overflow: TextOverflow.ellipsis),
        ),
        colorScheme: ColorScheme.fromSeed(
          background: const Color.fromARGB(255, 51, 49, 49),
          seedColor: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 104, 102, 102),
        useMaterial3: true,
      ),
      routes: {
        "home": (context) => const HomeScreen(),
        "drive": (context) => const DriveHome(),
      },
      home: const HomeScreen(),
    );
  }
}

///Shows the Home Screen containing all options to select
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = Themes.loadThemes(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Spacer
              const SizedBox(height: 20),
              //Title
              Text(
                "Leans Website",
                style: themes["largTextTheme"],
              ),
              //Spacer
              const SizedBox(height: 20),
              //Drive
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "drive"),
                child: const Text("Drive"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
