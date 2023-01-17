import 'package:flutter/widgets.dart';

class HomeItem {
  HomeItem({
    this.navigateScreen,
    this.imagePath = '',
  });

  Widget? navigateScreen;
  String imagePath;

  static List<HomeItem> homeItems = [
    HomeItem(
      imagePath: 'assets/introduction_animation/introduction_animation.png',
      // navigateScreen: IntroductionAnimationScreen(),
    ),
    HomeItem(
      imagePath: 'assets/hotel/hotel_booking.png',
      // navigateScreen: HotelHomeScreen(),
    ),
    HomeItem(
      imagePath: 'assets/fitness_app/fitness_app.png',
      // navigateScreen: FitnessAppHomeScreen(),
    ),
    HomeItem(
      imagePath: 'assets/design_course/design_course.png',
      // navigateScreen: DesignCourseHomeScreen(),
    ),
  ];
}
