import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/pages/auth/auth_gate.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      body: Stack(
        children: [
          // page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              introPage_1(), 
              introPage_2(),
              introPage_3()
            ],
          ),

          // Navigation
          Container(
            alignment: Alignment(0, 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // dot indicator
                dotIndicator(darkMode),
                
                SizedBox(height: 10),

                // Next Button
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact(); 

                    if (onLastPage) {
                      // Now in home
                      /* final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('showOnboarding', false); */

                      Navigator.pushAndRemoveUntil(context, 
                        CupertinoPageRoute(builder: (context) => AuthPage()),
                        (route) => false
                      );
                    }
                    else
                      _controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeOut);
                  },
                  child: Container(
                    width: 70,
                    height: 48,
                    margin: EdgeInsets.only(top: 35),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: (!darkMode) ? (onLastPage) ? Colors.white : Colors.grey[100]
                                        : (onLastPage) ? Colors.grey[700] : Colors.grey[800],
                    ),
                    child: Icon(
                      (onLastPage) ? Icons.done : Icons.arrow_forward, 
                      color: darkMode ? Colors.grey[400] : Colors.grey[400]
                    ),
                    
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }

  Widget dotIndicator(darkMode) {
    return SmoothPageIndicator(
      controller: _controller, 
      count: 3,
      effect: ExpandingDotsEffect(
        dotColor: darkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
        activeDotColor: darkMode ? Colors.white.withOpacity(0.4) : Colors.white,      
        dotHeight: 19, 
        dotWidth: 26
      )
    );
  }

  Widget introPage_1() {
    final isDarkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      //color: Color.fromARGB(255, 230, 230, 230),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 320),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Lottie
            Lottie.asset(
              "assets/calendar.json",
              fit: BoxFit.contain,
              width: 600
            ),
            Text(
              "Welcome",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48,
                color: !isDarkMode ? Colors.grey[800] : Colors.grey[300]
              ),
            ),
            SizedBox(height: 4),
            Text(
              "to Streakz",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 25,
                color: Theme.of(context).colorScheme.primary            
              ),
            )
          ]
          
        ),
      )
    );
  }

  Widget introPage_2() {
    final isDarkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      //color: Color.fromARGB(255, 230, 230, 230),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 320),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Lottie
            Lottie.asset(
              "assets/completed.json",
              fit: BoxFit.contain,
              width: 200,
              repeat: false
            ),
            SizedBox(height: 15),
            Text(
              "Powerful",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 49,
                color: !isDarkMode ? Colors.grey[800] : Colors.grey[300],
                //letterSpacing: -0.5    
              ),
            ),
            SizedBox(height: 4),
            Text(
              "habit tracking",//"choices, every day",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 25,
                color: Theme.of(context).colorScheme.primary            
              ),
            )
          ]      
        ),
      )
    );
  }

  Widget introPage_3() {
    final isDarkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      //color: Color.fromARGB(255, 230, 230, 230),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 320),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Lottie
            Lottie.asset(
              "assets/time.json",
              fit: BoxFit.contain,
              width: 250,
              repeat: true
            ),
            Text(
              "Everyday",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                color: !isDarkMode ? Colors.grey[800] : Colors.grey[300]      
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Starting today!",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
                color: Theme.of(context).colorScheme.primary            
              ),
            )
          ]      
        ),
      )
    );
  }
}