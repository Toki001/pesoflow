import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo_workspace/application/demo_workspace_providers.dart';

enum OnboardingStep { overview, plans, demo }

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingStep>(
      OnboardingController.new,
    );

/// Session-only introduction state, never an authentication or consent record.
class OnboardingController extends Notifier<OnboardingStep> {
  @override
  OnboardingStep build() => OnboardingStep.overview;

  void next() {
    if (state != OnboardingStep.demo) {
      state = OnboardingStep.values[state.index + 1];
    }
  }

  void back() {
    if (state != OnboardingStep.overview) {
      state = OnboardingStep.values[state.index - 1];
    }
  }

  void skipToDemo() => state = OnboardingStep.demo;
}

/// Remembers explicit demo entry only; step navigation remains session-only.
class DemoIntroductionCompleted extends Notifier<bool> {
  @override
  bool build() =>
      ref
          .watch(initialDemoWorkspaceProvider)
          ?.preferences
          .introductionCompleted ??
      false;
  void complete() => state = true;
}

final demoIntroductionCompletedProvider =
    NotifierProvider<DemoIntroductionCompleted, bool>(
      DemoIntroductionCompleted.new,
    );
