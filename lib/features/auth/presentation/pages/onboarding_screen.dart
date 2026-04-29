import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';

const List<_OnboardingSlide> _slides = <_OnboardingSlide>[
  _OnboardingSlide(
    titlePartA: 'Doctor Appointments',
    titlePartB: ' Made Easy',
    highlightPartA: false,
    description:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt',
  ),
  _OnboardingSlide(
    titlePartA: 'Bookmark ',
    titlePartB: 'Your Preferred Doctors & Hospitals',
    highlightPartA: true,
    description:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt',
  ),
  _OnboardingSlide(
    titlePartA: 'Find Nearby ',
    titlePartB: 'Doctors and Hospitals Using Map View',
    highlightPartA: true,
    description:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex == _slides.length - 1) {
      context.go(AppPaths.createAccount);
      return;
    }

    _pageController.animateToPage(
      _currentIndex + 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentIndex == 0) return;

    _pageController.animateToPage(
      _currentIndex - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopSkipButton(onSkip: () => context.go(AppPaths.createAccount)),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
            Flexible(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double maxH = constraints.maxHeight;
                        final double phoneHeight = (maxH * 0.57).clamp(220.0, 420.0);
                        final double gap1 = (maxH * 0.02).clamp(10.0, 18.0);
                        final double gap2 = (maxH * 0.015).clamp(8.0, 14.0);
                        final textTheme = Theme.of(context).textTheme;

                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: maxH),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _PhoneFrame(
                                  height: phoneHeight,
                                  slideIndex: index,
                                ),
                                SizedBox(height: gap1),
                                _OnboardingTitle(slide: slide),
                                SizedBox(height: gap2),
                                Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            _BottomArea(
              currentIndex: _currentIndex,
              onBack: _goBack,
              onNext: _goNext,
              slideCount: _slides.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.titlePartA,
    required this.titlePartB,
    required this.highlightPartA,
    required this.description,
  });

  final String titlePartA;
  final String titlePartB;
  final bool highlightPartA;
  final String description;
}

class _TopSkipButton extends StatelessWidget {
  const _TopSkipButton({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: onSkip,
        child: Text(
          'Skip',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.currentIndex,
    required this.onBack,
    required this.onNext,
    required this.slideCount,
  });

  final int currentIndex;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final int slideCount;

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = (MediaQuery.sizeOf(context).height * 0.02).clamp(12.0, 22.0);
    final double dotsToButtonsGap = (MediaQuery.sizeOf(context).height * 0.018).clamp(12.0, 18.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DotsRow(
            currentIndex: currentIndex,
            slideCount: slideCount,
          ),
          SizedBox(height: dotsToButtonsGap),
          Row(
            children: [
              if (currentIndex > 0)
                _OutlinedCircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: onBack,
                  iconColor: AppColors.primary,
                ),
              if (currentIndex > 0) const SizedBox(width: 12),
              const Spacer(),
              _FilledCircleIconButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: onNext,
                background: AppColors.primary,
                iconColor: AppColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow({
    required this.currentIndex,
    required this.slideCount,
  });

  final int currentIndex;
  final int slideCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slideCount, (index) {
        final bool isActive = index == currentIndex;
        final double size = isActive ? 12 : 8;
        final Color color = isActive ? AppColors.yellow : AppColors.neutral200;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _OutlinedCircleIconButton extends StatelessWidget {
  const _OutlinedCircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _FilledCircleIconButton extends StatelessWidget {
  const _FilledCircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w800,
          height: 1.2,
        );
    final highlightStyle = baseStyle?.copyWith(color: AppColors.primary);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: slide.titlePartA,
            style: slide.highlightPartA ? highlightStyle : baseStyle,
          ),
          TextSpan(
            text: slide.titlePartB,
            style: slide.highlightPartA ? baseStyle : highlightStyle,
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.height,
    required this.slideIndex,
  });

  final double height;
  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    final double width = height * 0.5;

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              // Keeps content inside the display cutout and bezels.
              padding: EdgeInsets.fromLTRB(width * 0.082, height * 0.062, width * 0.082, height * 0.064),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  color: AppColors.neutral100,
                  child: Image.network(
                    'https://via.placeholder.com/400x600',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _PhonePlaceholder(slideIndex: slideIndex);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _PhonePlaceholder(slideIndex: slideIndex);
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/phone.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePlaceholder extends StatelessWidget {
  const _PhonePlaceholder({required this.slideIndex});

  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.white,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.primary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
