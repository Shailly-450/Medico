import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/onboarding_item.dart';

class OnboardingViewModel extends BaseViewModel {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Find Trusted Doctors',
      description: 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature.',
      image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      isNetworkImage: true,
    ),
    OnboardingItem(
      title: 'Choose Best Doctors',
      description: 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature.',
      image: 'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      title: 'Easy Appointments',
      description: 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature.',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  void onPageChanged(int page) {
    currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (currentPage < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
} 