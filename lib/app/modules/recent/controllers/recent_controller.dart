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

  Future<void> fetchRecents() async {
    isLoading.value = true;
    try {
      final activities = await RecentsService.getRecentActivities();
      recentActivities.assignAll(activities);
      recentSymptoms.assignAll(
          activities.map((e) => e['title'] as String).toSet().toList());
    } catch (e) {
      print("⚠️ Error fetching recent symptoms: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearRecents() async {
    await RecentsService.clearRecentActivities();
    await fetchRecents();
  }
}
