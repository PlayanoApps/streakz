import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            alignment: Alignment(0, 0.75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // dot indicator
                SmoothPageIndicator(
                  controller: _controller, 
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.white.withOpacity(0.5),
                    activeDotColor: Theme.of(context).colorScheme.tertiary,         
                    dotHeight: 20, 
                    dotWidth: 25
                  )
                ),
                // Next Button
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact(); 
                    // Go to Homescreen
                    if (onLastPage) {
                      // Local storage with SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('showOnboarding', false);

                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => HomePage(showThemes: true)));
                    }
                    else
                      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    
                    margin: EdgeInsets.only(top: 35),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: (onLastPage) ? Colors.white : Colors.grey[100],
                    ),
                    child: Icon(
                      (onLastPage) ? Icons.done : Icons.arrow_forward, 
                      color: Colors.grey[400]
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

  Widget introPage_1() {
    return Container(
      color: Color.fromARGB(255, 230, 230, 230),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 300),
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
                color: Colors.grey[800]          
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
    return Container(
      color: Color.fromARGB(255, 230, 230, 230),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 300),
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
                color: Colors.grey[800],
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
    return Container(
      color: Color.fromARGB(255, 230, 230, 230),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 300),
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
                color: Colors.grey[800]          
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