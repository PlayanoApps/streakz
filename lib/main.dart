import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:habit_tracker/habit_database.dart";
import "package:habit_tracker/pages/home_page.dart";
import "package:habit_tracker/pages/onboarding.dart";
import "package:habit_tracker/theme_provider.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database (await to not block the UI stream)
  // These are asynchronous function that can run in parallel
  await HabitDatabase.initialize();
  await HabitDatabase.saveFirstLaunchSettings();

  // Onboarding screen
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  /* Load data in main instead of in home widget */
  final themeProvider = ThemeProvider();  // Open instance here instead of in runApp
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitDatabase()),
        ChangeNotifierProvider(create: (context) => themeProvider)     // pass existing instance
      ],
      child: App(
        showOnboarding: showOnboarding, 
      )
    )
  );

  makeAppTransparent();
}

void makeAppTransparent() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class App extends StatelessWidget {
  final bool showOnboarding;

  const App({
    super.key, 
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    
    final useSystemTheme = Provider.of<ThemeProvider>(context).useSystemTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showOnboarding ? OnboardingPage() : HomePage(),

      // Don't use "listen: false" here because widget is rebuilt 
      // ThemeProvider must be created in the main function. Why? because it must be ready BEFORE the App Widget is built.
      
      theme: useSystemTheme ? lightMode : Provider.of<ThemeProvider>(context).themeData,
      darkTheme: useSystemTheme ? darkMode : null,
      themeMode: ThemeMode.system,
    );
  }
}