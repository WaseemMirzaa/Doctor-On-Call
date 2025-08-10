import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../widgets/symptom_selection_widget.dart';
import '../../controllers/favourites_controller.dart';

class FavoritesList extends StatelessWidget {
  const FavoritesList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavouritesController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.favorites.isEmpty) {
        return _buildEmptyState();
      }

      // Create favorite states map for all items (all should be true since they're favorites)
      final favoriteStatesMap = <String, bool>{};
      for (final item in controller.favorites) {
        favoriteStatesMap[item.title] = true;
      }

      return Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0), // Add bottom padding for scroll
        child: SymptomSelectionWidget(
          symptoms: controller.favorites.map((item) => item.title).toList(),
          onSelectionChanged: (selectedItems) {
            // This is called when heart icons are toggled internally
            // We don't need this for external favorite management
          },
          favoriteStates: favoriteStatesMap,
          onFavoriteToggle: (itemTitle) {
            // Handle favorites removal
            final favoriteItem = controller.favorites.firstWhere(
              (item) => item.title == itemTitle,
            );
            controller.removeFromFavorites(favoriteItem.itemId);
          },
          showHeartIcon: true,
          padding: const EdgeInsets.all(16.0),
          spacing: 8.0,
          onSymptomTap: (itemTitle) {
            final favoriteItem = controller.favorites.firstWhere(
              (item) => item.title == itemTitle,
            );
            controller.navigateToItemDetails(favoriteItem);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: AppTextStyles.medium.copyWith(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to favorites to see them here',
            style: AppTextStyles.regular.copyWith(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
