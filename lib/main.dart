import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/preferences_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PreferencesProvider(),
        ),
        ChangeNotifierProxyProvider<PreferencesProvider, BookProvider>(
          create: (context) {
            final preferencesProvider = Provider.of<PreferencesProvider>(context, listen: false);
            return BookProvider(preferencesProvider);
          },
          update: (context, preferencesProvider, bookProvider) {
            if (bookProvider == null) {
              return BookProvider(preferencesProvider);
            } else {
              bookProvider.updatePreferences(preferencesProvider);
              return bookProvider;
            }
          },
        ),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, preferencesProvider, child) {
          return MaterialApp(
            theme: preferencesProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomeScreen(),
            debugShowCheckedModeBanner: false, // Remove debug label
          );
        },
      ),
    );
  }
}
