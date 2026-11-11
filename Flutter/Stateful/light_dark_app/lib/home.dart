import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Function(ThemeMode) onChangeTheme;
  const Home({super.key, required this.onChangeTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material 3 Test"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onChangeTheme(ThemeMode.dark);
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary
              ),
              child: Text("Dark Theme"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onChangeTheme(ThemeMode.light);
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary
              ),
              child: Text("Light Theme"),
            ),
          ],
        ),
      )
    );
  }
}