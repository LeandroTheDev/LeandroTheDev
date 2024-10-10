import 'package:flutter/material.dart';
import 'package:leans/pages/protify/home.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const isDebug = !bool.fromEnvironment('dart.vm.product');

void main() {
  runApp(const Leans());
}

class Leans extends StatelessWidget {
  //Colors variables
  static const Map<String, Color> colors = {
    "primary": Color.fromARGB(255, 78, 78, 78),
    "secondary": Color.fromARGB(255, 42, 128, 168),
    "tertiary": Colors.white,
    "seedColor": Colors.lightBlueAccent,
    "background": Color.fromARGB(255, 51, 49, 49),
  };
  static final String driveAddress = html.window.location.host.split(":").first;
  static const int drivePorts = 7878;
  const Leans({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leans',
      theme: ThemeData(
        //--------------
        //Colors
        //--------------
        colorScheme: ColorScheme.fromSeed(
          //Default Colors
          seedColor: colors["seedColor"]!,

          //Used in large interfaces
          primary: colors["primary"]!,
          //Used in buttons
          secondary: colors["secondary"]!,
          //Used in visibility things like texts
          tertiary: colors["tertiary"],
        ),
        // Used in small interfaces
        primaryColor: colors["primary"],
        //Used in borders
        secondaryHeaderColor: colors["secondary"],
        //Scafolld background
        scaffoldBackgroundColor: const Color.fromARGB(255, 104, 102, 102),
        useMaterial3: true,

        //--------------
        //Widgets Themes
        //--------------
        iconTheme: IconThemeData(
          color: colors["tertiary"],
        ),
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
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors["tertiary"]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors["secondary"]!),
          ),
        ),
        dialogTheme: DialogTheme(
          titleTextStyle: TextStyle(color: colors["tertiary"], fontSize: 24, overflow: TextOverflow.ellipsis),
          contentTextStyle: TextStyle(color: colors["tertiary"], fontSize: 16, overflow: TextOverflow.ellipsis),
          backgroundColor: colors["primary"],
        ),
        dialogBackgroundColor: colors["primary"],
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.blue.withOpacity(0.3),
          selectionHandleColor: Colors.blue,
        ),
      ),
      routes: {
        "home": (context) => const HomeScreen(),
        "protify": (context) => const ProtifyHome(),
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
    final screenSize = MediaQuery.of(context).size;
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              //Spacer
              const SizedBox(height: 20),
              //Drive
              Container(
                width: screenSize.width,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: screenSize.width < 1000 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    //Drive Title
                    Text(
                      "The best location to save your files is here, in the drive.",
                      maxLines: 99,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    //Drive Button
                    SizedBox(
                      width: 110,
                      child: FittedBox(
                        child: Row(
                          children: [
                            // Enter Button
                            ElevatedButton(
                              onPressed: () => html.window.location.href = "http://${Leans.driveAddress}:${Leans.drivePorts}",
                              child: Row(
                                children: [
                                  const Text("Drive"),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Image.asset("assets/drive.png"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Reans
              Container(
                width: screenSize.width,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: screenSize.width < 1000 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    //Reans Title
                    Text(
                      "Reans is a user-friendly remote server creation tool that allows you to create custom servers or use predefined ones for games and software.",
                      maxLines: 99,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    //Reans Button
                    SizedBox( 
                      width: 110,
                      child: FittedBox(
                        child: ElevatedButton(
                          onPressed: null,
                          child: Row(
                            children: [
                              Text(
                                "Reans",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 24,
                                  child: Image.asset("assets/rens.png", fit: BoxFit.fitWidth),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Protify
              Container(
                width: screenSize.width,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Protify Title
                    Text(
                      "Protify is a software designed to easily run games and softwares in linux, a light-weight launcher that uses proton, you can easily customize the launch parameters for the games and softwares.",
                      maxLines: 99,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    //Protify Button
                    SizedBox(
                      width: 250,
                      child: FittedBox(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, "protify"),
                          child: Row(
                            children: [
                              const Text("Protify Demonstration"),
                              const SizedBox(width: 5),
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Image.asset("assets/protify.png"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Larita
              Container(
                width: screenSize.width,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: screenSize.width < 1000 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    //Larita Title
                    Text(
                      "Feeling alone? Larita can fix that.",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    //Larita Button
                    SizedBox(
                      width: 230,
                      child: FittedBox(
                        child: ElevatedButton(
                          onPressed: null,
                          child: Row(
                            children: [
                              Text(
                                "Larita (Under Maintence)",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 24,
                                  child: Image.asset("assets/larita.png", fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
