import 'package:flutter/material.dart';

class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // Page Transitions
  static Widget slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static Widget slideFromLeft(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static Widget fadeIn(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  static Widget scaleIn(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }

  // Custom Page Route Builder
  static PageRouteBuilder<T> createSlideRoute<T extends Object?>(
    Widget page, {
    Offset begin = const Offset(1.0, 0.0),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  // Staggered Animation for Form Fields
  static List<Animation<Offset>> createStaggeredSlideAnimations(
    Animation<double> parent,
    int itemCount,
  ) {
    final List<Animation<Offset>> animations = [];
    
    for (int i = 0; i < itemCount; i++) {
      animations.add(
        Tween<Offset>(
          begin: Offset(0, 0.3 + (i * 0.1)),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: parent,
            curve: Interval(
              i / itemCount,
              1.0,
              curve: Curves.easeOutBack,
            ),
          ),
        ),
      );
    }
    
    return animations;
  }

  // Pulse Animation
  static AnimationController createPulseController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
  }

  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Bounce Animation
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }

  static Animation<double> createBounceAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  // Shake Animation for Error States
  static AnimationController createShakeController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
  }

  static Animation<Offset> createShakeAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticIn,
      ),
    );
  }

  // Loading Animation
  static Widget createLoadingAnimation({
    double size = 24.0,
    Color color = Colors.orange,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  // Success Check Animation
  static Widget createSuccessAnimation({
    double size = 24.0,
    Color color = Colors.green,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 16.0,
      ),
    );
  }
}
