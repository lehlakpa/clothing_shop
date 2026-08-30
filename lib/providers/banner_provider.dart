import 'package:clothing_shop/models/banner_model.dart';
import 'package:clothing_shop/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class BannerProvider extends ChangeNotifier {
  List<BannerModel> banners = [
    BannerModel(
      tag: 'AUTUMN STUDIO SALE',
      title: 'Fired, woven & carved this week',
      subtitle: '15% off new arrivals from 12 small studios.',
      buttonText: 'Browse the sale',
      gradientColors: [AppColors.forest, AppColors.forestDark],
      tagColor: AppColors.gold,
      buttonBgColor: AppColors.gold,
      buttonTextColor: AppColors.forestDark,
    ),
    BannerModel(
      tag: 'HANDMADE TEXTILES',
      title: 'Artisan rugs & throw blankets',
      subtitle: 'Sustainably sourced wool crafted by local weavers.',
      buttonText: 'Explore Collection',
      gradientColors: const [Color(0xFF8C533E), Color(0xFF593122)],
      tagColor: const Color(0xFFF2C94C),
      buttonBgColor: const Color(0xFFF2C94C),
      buttonTextColor: const Color(0xFF331D15),
    ),
    BannerModel(
      tag: 'FEATURED MAKER',
      title: 'Minimalist Glassware Series',
      subtitle: 'Hand-blown glass pieces designed for everyday elegance.',
      buttonText: 'Meet the Maker',
      gradientColors: const [Color(0xFF2C4C5E), Color(0xFF162B37)],
      tagColor: const Color(0xFF81D4FA),
      buttonBgColor: const Color(0xFF81D4FA),
      buttonTextColor: const Color(0xFF0D1B2A),
    ),
  ];
}
