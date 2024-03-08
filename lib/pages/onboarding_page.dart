import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listinha/utils/app_routes.dart';
import 'package:listinha/utils/static_texts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.only(bottom: 60),
        child: PageView(
          onPageChanged: (index) => setState(() => isLastPage = index == 1),
          controller: controller,
          children: [
            for (int i = 0; i < onboardingTexts.length; i++)
              GenerateOnboardingPage(i, onboardingTexts[i])
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(),
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFB7B7B7),
                minimumSize: Size.fromHeight(60),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('showHome', true);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: SystemUiOverlay.values);
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.LOGIN_OR_MENU);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vamos lá',
                    style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'ITC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ))
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Color(0xFFB7B7B7),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 2,
                    effect: WormEffect(
                        spacing: 16,
                        dotColor: Colors.white,
                        activeDotColor:
                            Theme.of(context).colorScheme.primaryContainer),
                    onDotClicked: (i) => controller.animateToPage(i,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeIn),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget GenerateOnboardingPage(int imgSource, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Column(
        children: [
          LottieBuilder.asset(
            "lib/images/onboarding${imgSource}.json",
            alignment: Alignment.center,
            fit: BoxFit.cover,
            height: 128,
            width: 128,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ITC',
                  fontSize: 22,
                )),
          )
        ],
      ),
    ],
  );
}
