import 'package:clothing_shop/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class BannerModel {
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;
  final Color tagColor;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final VoidCallback? onTap;

  BannerModel({
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
