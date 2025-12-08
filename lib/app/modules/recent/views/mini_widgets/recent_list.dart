import 'package:dr_on_call/app/modules/clinical_presentations/controllers/clinical_presentations_controller.dart';
import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:dr_on_call/app/helpers/subscription_access_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/symptom_selection_widget.dart';
import '../../../bio_chemical_diagnosis/controllers/bio_chemical_diagnosis_controller.dart';
import '../../../clinical_diagnosis/controllers/clinical_diagnosis_controller.dart';
import '../../controllers/recent_controller.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    final recentController = Get.put(RecentController());
    final bioController = Get.put(BioChemicalDiagnosisController());
    final clinicalController = Get.put(ClinicalDiagnosisController());
    final presentationController = Get.put(ClinicalPresentationsController());

    return Obx(() {
      // ✅ Now the entire widget is wrapped in one Obx, but correctly uses observables
      if (recentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SymptomSelectionWidget(
          symptoms: recentController.recentSymptoms,
          onSelectionChanged: (selected) {},
          showRecentIcon: true,
          padding: const EdgeInsets.all(16.0),
          spacing: 8.0,

          // onSymptomTap: (label) async {
          //   // label = "biochemical (Standalone - Acute Severe Anemia)"
          //   final typeSplit = label.split(' (');
          //   if (typeSplit.length < 2) {
          //     Get.snackbar("Error", "Invalid recent format");
          //     return;
          //   }
          //
          //   final type = typeSplit[0];
          //   final inner = typeSplit[1].replaceAll(')', '');
          //   final innerSplit = inner.split(' - ');
          //
          //   if (innerSplit.length < 2) {
          //     Get.snackbar("Error", "Invalid recent format");
          //     return;
          //   }
          //
          //   final category = innerSplit[0];
          //   final title =
          //       innerSplit.sublist(1).join(' - '); // in case title has -
          //
          //   final index = recentController.recentSymptoms.indexOf(label);
          //   if (index == -1) {
          //     Get.snackbar("Error", "Recent item not found");
          //     return;
          //   }
          //
          //   // 🔄 Update timestamp in background
          //   recentController.updateRecentTimestamp(title, type);
          //
          //   print(
          //       '🟡 Tapped recent: $title | Category: $category | Type: $type');
          //
          //   if (type == 'biochemical') {
          //     await bioController.loadEmergencyByTitle(title);
          //     if (bioController.emergencies.isNotEmpty) {
          //       Get.toNamed(
          //         Routes.BIO_CHEMICAL_DETAIL_PAGE,
          //         arguments: {
          //           'title': title,
          //           'category': category,
          //           'emergencies': bioController.emergencies.toList(),
          //         },
          //       );
          //     } else {
          //       Get.snackbar("No Data", "No emergency found for '$title'");
          //     }
          //   } else if (type == 'clinical') {
          //     await clinicalController.loadDiagnosisByTitle(title);
          //     if (clinicalController.diagnoses.isNotEmpty) {
          //       Get.toNamed(
          //         Routes.CLINICAL_DETAILS,
          //         arguments: {
          //           'title': title,
          //           'category': category,
          //           'diagnoses': clinicalController.diagnoses.toList(),
          //         },
          //       );
          //     } else {
          //       Get.snackbar("No Data", "No diagnosis found for '$title'");
          //     }
          //   } else {
          //     Get.snackbar("Unknown Type", "Type '$type' not supported.");
          //   }
          // });

          onSymptomTap: (title) async {
            final index = recentController.recentSymptoms.indexOf(title);
            if (index == -1) {
              Get.snackbar("Error", "Recent item not found");
              return;
            }

            final recent = recentController.recentActivities[index];
            final category = recent['category'] ?? '';
            final type = recent['type'] ?? 'biochemical';

            // ✅ Update Firestore timestamp
            recentController.updateRecentTimestamp(title, type);

            if (type == 'biochemical') {
              await bioController.loadEmergencyByTitle(title);
              if (bioController.emergencies.isNotEmpty) {
                await SubscriptionAccessHelper.checkAccessAndNavigate(
                  routeName: Routes.BIO_CHEMICAL_DETAIL_PAGE,
                  arguments: {
                    'title': title,
                    'category': category,
                    'emergencies': bioController.emergencies.toList(),
                  },
                  contentType: 'biochemical',
                );
              } else {
                Get.snackbar("No Data", "No emergency found for '$title'");
              }
            } else if (type == 'clinical') {
              await clinicalController.loadDiagnosisByTitle(title);
              if (clinicalController.diagnoses.isNotEmpty) {
                await SubscriptionAccessHelper.checkAccessAndNavigate(
                  routeName: Routes.CLINICAL_DETAILS,
                  arguments: {
                    'title': title,
                    'category': category,
                    'diagnoses': clinicalController.diagnoses.toList(),
                  },
                  contentType: 'clinical',
                );
              } else {
                Get.snackbar("No Data", "No diagnosis found for '$title'");
              }
            } else if (type == "clinical_presentation") {
              await presentationController.loadPresentationByTitle(title);
              if (presentationController.presentations.isNotEmpty) {
                await SubscriptionAccessHelper.checkAccessAndNavigate(
                  routeName: Routes.CLINICAL_PRESENTATION_DETAIL,
                  arguments: presentationController.currentPresentation.value,
                  contentType: 'clinical_presentation',
                );
              } else {
                Get.snackbar("Unknown Type", "Type '$type' not supported.");
              }
            }
          });
    });
  }
}
