import 'package:flutter/material.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget neoCortexTitleWidget() {
  return Row(
    children: [
      Image.asset("assets/images/logoSmall.png", width: 40),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          AppConfig.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}

Widget appBarIndicatorWidget(int count, PageController pageController) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: SmoothPageIndicator(
      controller: pageController,
      count: count,
      effect: const ExpandingDotsEffect(
        dotColor: Colors.grey,
        activeDotColor: Colors.white,
        dotHeight: 10,
        dotWidth: 10,
        // strokeWidth: 5,
      ),
    ),
  );
}
