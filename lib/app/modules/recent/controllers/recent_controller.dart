import 'package:get/get.dart';
import '../../../services/recents_service.dart';

class RecentController extends GetxController {
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;
  final RxList<String> recentSymptoms = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecents();
  }

  // Future<void> fetchRecents() async {
  //   if (isLoading.value) return;
  //
  //   isLoading.value = true;
  //
  //   try {
  //     final activities = await RecentsService.getRecentActivities();
  //     recentActivities.assignAll(activities);
  //
  //     // Format: type (category - title)
  //     recentSymptoms.assignAll(
  //       activities.map((e) {
  //         final type = e['type'] ?? '';
  //         final category = e['category'] ?? '';
  //         final title = e['title'] ?? '';
  //         return '$type ($category - $title)';
  //       }).toList(),
  //     );
  //   } catch (e) {
  //     print("⚠️ Error fetching recent symptoms: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchRecents() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final activities = await RecentsService.getRecentActivities();
      recentActivities.assignAll(activities);

      recentSymptoms.assignAll(
        activities.map((e) => e['title'] as String).toList(),
      );
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearRecents() async {
    await RecentsService.clearRecentActivities();
    await fetchRecents();
  }

  Future<void> updateRecentTimestamp(String title, String type) async {
    try {
      await RecentsService.updateActivityTimestamp(title, type);
      fetchRecents();
    } catch (e) {}
  }
}
