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
  //Colors variables
  static const Map<String, Color> colors = {
    "primary": Color.fromARGB(255, 121, 118, 118),
    "secondary": Color.fromARGB(255, 42, 128, 168),
    "tertiary": Colors.white,
    "seedColor": Colors.lightBlueAccent,
    "background": Color.fromARGB(255, 51, 49, 49),
  };
  const Leans({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leans',
      theme: ThemeData(
          //--------------
          //Colors
          //--------------
          colorScheme: ColorScheme.fromSeed(
            //Default Colors
            background: colors["background"],
            seedColor: colors["seedColor"]!,

            //Used in large interfaces
            primary: colors["primary"]!,
            //Used in buttons
            secondary: colors["secondary"]!,
            //Used in visibility things like texts
            tertiary: colors["tertiary"],
          ),
          //Used in small interfaces
          primaryColor: colors["primary"],
          //Used in borders
          secondaryHeaderColor: colors["secondary"],
          //Scafolld background
          scaffoldBackgroundColor: const Color.fromARGB(255, 104, 102, 102),
          useMaterial3: true,

          //--------------
          //Widgets Themes
          //--------------
          textTheme: TextTheme(
            titleLarge: TextStyle(color: colors["tertiary"], fontSize: 24, overflow: TextOverflow.ellipsis),
            titleMedium: TextStyle(color: colors["tertiary"], fontSize: 16, overflow: TextOverflow.ellipsis),
            titleSmall: TextStyle(color: colors["tertiary"], fontSize: 6, overflow: TextOverflow.ellipsis),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors["secondary"],
              foregroundColor: colors["tertiary"],
              surfaceTintColor: colors["secondary"],
              shadowColor: colors["secondary"],
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colors["secondary"]!),
            ),
          ),
          dialogBackgroundColor: colors["background"]),
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
