import 'package:dr_on_call/app/modules/news2_core/views/mini_widgets/news2_tiles.dart';
import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/news2_core_controller.dart';

import '../../../../../config/AppText.dart';

class News2List extends StatelessWidget {
  const News2List({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<News2CoreController>();

    return Column(
      children: [
        News2Tiles(
          symptoms: const [
            AppText.respiratoryRate,
            AppText.oxygenSaturation,
            AppText.temperature,
            AppText.systolicBloodPressure,
            AppText.heartRate,
            AppText.levelOfConsciousness,
            AppText.oxygenRequirement,
          ],
          onSelectionChanged: (selectedSymptoms) {
            // Handle selection changes if needed
          },
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 10,
          ),
          spacing: 22.0,
          onSymptomTap: (symptom) {
            // Handle symptom tap if needed for navigation
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 15.0,
            left: 15.0,
          ),
          child: GestureDetector(
            onTap: () {
              // Validate and calculate NEWS2 score
              if (controller.calculateNews2Score()) {
                _showNews2ScoreDialog(context, controller);
              }
            },
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.baseColor,
              ),
              child: Center(
                child: Text('Calculate',
                    style: AppTextStyles.bold
                        .copyWith(color: AppColors.txtBlackColor)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showNews2ScoreDialog(
      BuildContext context, News2CoreController controller) {
    final calculator = controller.calculationResult.value;
    if (calculator == null) {
      return;
    }

    final totalScore = calculator.calculateTotalScore();
    final riskLevel = calculator.interpretScore();
    final actionRecommendation = calculator.getActionRecommendation();

    // Determine risk color
    Color getRiskColor() {
      if (totalScore == 0) return Colors.green;
      if (totalScore >= 1 && totalScore <= 4) return Colors.yellow;
      if (totalScore >= 5 && totalScore <= 6) return Colors.orange;
      return Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on outside tap
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF00132B),
          contentPadding: EdgeInsets.zero, // Remove default padding
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.txtOrangeColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          content: Stack(
            children: [
              // Cross Button
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                ),
              ),

              // Main Content with padding
              Padding(
                padding: const EdgeInsets.all(20.0).copyWith(top: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        AppText.news2Score2,
                        style: AppTextStyles.bold.copyWith(fontSize: 25),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total NEWS2 Score',
                            style: AppTextStyles.medium.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 18)),
                        Text('$totalScore',
                            style: AppTextStyles.medium.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: getRiskColor())),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Risk Level',
                            style: AppTextStyles.medium.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(riskLevel,
                            style: AppTextStyles.medium.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: getRiskColor())),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Action',
                        style: AppTextStyles.medium.copyWith(
                            color: getRiskColor(),
                            fontWeight: FontWeight.w500,
                            fontSize: 18)),
                    const SizedBox(height: 5),
                    Text(actionRecommendation, style: AppTextStyles.regular),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEC643),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text('Close',
                            style: AppTextStyles.bold
                                .copyWith(color: AppColors.txtBlackColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
