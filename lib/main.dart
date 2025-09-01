import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:habit_tracker/firebase_options.dart";
import "package:habit_tracker/habit_database.dart";
import "package:habit_tracker/pages/onboarding_page.dart";
import "package:habit_tracker/auth/auth_gate.dart";
import "package:habit_tracker/services/noti_service.dart";
import "package:habit_tracker/theme/theme_provider.dart";
import "package:habit_tracker/theme/themes.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:showcaseview/showcaseview.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize database (await to not block the UI stream)
  // These are asynchronous function that can run in parallel
  await HabitDatabase.initialize();
  await HabitDatabase.saveFirstLaunchSettings();

  // Init notifications
  await NotiService().initNotification();

  // Onboarding screen
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool("showOnboarding") ?? true;

  /* Load data in main instead of home */
  final themeProvider = ThemeProvider(prefs);  // Open instance here instead of in runApp
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitDatabase()),
        ChangeNotifierProvider(create: (context) => themeProvider),     // pass existing instance
        ChangeNotifierProvider(create: (context) => NotiServiceProvider())
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

    return ShowCaseWidget(
      //enableShowcase: false,

      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        //home: showOnboarding ? OnboardingPage() : HomePage(),
        home: showOnboarding ? OnboardingPage() : AuthPage(),
      
      
        // Don't use "listen: false" here because widget is rebuilt 
        // ThemeProvider must be created in the main function. Why? because it must be ready BEFORE the App Widget is built.
        
        theme: useSystemTheme ? lightMode : Provider.of<ThemeProvider>(context).themeData,
        darkTheme: useSystemTheme ? darkMode : null,
        themeMode: ThemeMode.system,
      ),
    );
  }
}