import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OnboardingStep { overview, plans, ready }

class OnboardingController extends Notifier<OnboardingStep> {
  @override
  OnboardingStep build() => OnboardingStep.overview;
  void next() {
    if (state != OnboardingStep.ready) {
      state = OnboardingStep.values[state.index + 1];
    }
  }

  void back() {
    if (state != OnboardingStep.overview) {
      state = OnboardingStep.values[state.index - 1];
    }
  }

  void skip() => state = OnboardingStep.ready;
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingStep>(
      OnboardingController.new,
    );
