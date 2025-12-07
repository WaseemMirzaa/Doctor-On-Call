import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/subscription_manager_service.dart';

class HomeController extends GetxController {
  final selectedBottomNavIndex = 0.obs;
  final isPremiumUser = false.obs;
  final currentPlan = 'Free Trial'.obs;
  final subscriptionStatusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSubscription();
  }

  @override
  void onReady() {
    super.onReady();
    _loadSubscriptionStatus();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize subscription (trial start date, etc.)
  Future<void> _initializeSubscription() async {
    await SubscriptionManagerService.initializeTrialIfNeeded();
  }

  /// Load subscription status from local storage
  Future<void> _loadSubscriptionStatus() async {
    try {
      isPremiumUser.value = await SubscriptionManagerService.isPremiumUser();
      currentPlan.value = await SubscriptionManagerService.getCurrentPlan();
      subscriptionStatusMessage.value =
          await SubscriptionManagerService.getAccessStatusMessage();

      // Get view count and trial status
      final viewCount = await SubscriptionManagerService.getContentViewCount();
      final isInTrial = await SubscriptionManagerService.isInFreeTrial();
      final remainingViews =
          await SubscriptionManagerService.getRemainingFreeViews();

      print(
          '📱 Home: Premium=${isPremiumUser.value}, Plan=${currentPlan.value}');
      print(
          '👁️ View Count: $viewCount | InTrial: $isInTrial | Remaining: $remainingViews');
    } catch (e) {
      print('❌ Error loading subscription status: $e');
    }
  }

  /// Refresh subscription status (call this when returning to home)
  Future<void> refreshSubscriptionStatus() async {
    await _loadSubscriptionStatus();
  }

  void changeBottomNavIndex(int index) {
    selectedBottomNavIndex.value = index;
    // Add navigation logic here
    switch (index) {
      case 0:
        Get.toNamed(Routes.SEARCH);
        break;
      case 1:
        Get.toNamed(Routes.FAVOURITES);
        break;
      case 2:
        Get.toNamed(Routes.RECENT);
        break;
    }
  }

  void onClinicalPresentationsTap() {
    // TODO: Navigate to Clinical Presentations
    Get.toNamed(Routes.CLINICAL_PRESENTATIONS);
  }

  void onBiochemicalEmergenciesTap() {
    // TODO: Navigate to Biochemical Emergencies
    Get.toNamed(Routes.BIO_CHEMICAL_DIAGNOSIS);
  }

  void onClinicalDiagnosisTap() {
    // TODO: Navigate to Clinical Diagnosis
    Get.toNamed(Routes.CLINICAL_DIAGNOSIS);
  }

  void onNews2ScoreTap() {
    // TODO: Navigate to NEWS2 Score
    Get.toNamed(Routes.NEWS2_CORE);
  }

  void onAboutTap() {
    // TODO: Navigate to About
    Get.toNamed(Routes.ABOUT_VIEW);
  }
}
