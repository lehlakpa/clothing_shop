import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';

// Model representing each banner slide
class BannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;
  final Color tagColor;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final VoidCallback? onTap;

  BannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientColors,
    this.tagColor = AppColors.gold,
    this.buttonBgColor = AppColors.gold,
    this.buttonTextColor = AppColors.forestDark,
    this.onTap,
  });
}

class BannerSlider extends StatefulWidget {
  final List<BannerItem> banners;
  final Duration autoSlideInterval;

  const BannerSlider({
    super.key,
    required this.banners,
    this.autoSlideInterval = const Duration(seconds: 4),
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final PageController _pageController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _bannerTimer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (_pageController.hasClients && widget.banners.isNotEmpty) {
        int nextIndex = (_currentBannerIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: banner.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.tag,
                      style: TextStyle(
                        color: banner.tagColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      banner.title,
                      style: const TextStyle(
                        color: AppColors.paper,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'serif',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFD9D2C2),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: banner.onTap ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: banner.buttonBgColor,
                        foregroundColor: banner.buttonTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        banner.buttonText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.forest
                    : AppColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
