import 'package:apply_roster/core/constants/app_constants.dart';
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:apply_roster/features/applications/repositories/application_repository.dart';
import 'package:apply_roster/features/notifications/controllers/notification_controller.dart';
import 'package:apply_roster/features/notifications/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationController extends GetxController {
  final ApplicationRepository _repository = Get.find<ApplicationRepository>();

  // Observable States
  final RxList<ApplicationModel> applications = <ApplicationModel>[].obs;
final RxInt applicationsResetTrigger = 0.obs;
  final RxMap<String, int> dashboardCounts = <String, int>{}.obs;

  final RxBool isLoading = false.obs;
  final RxInt selectedNavigationIndex = 0.obs;

  final RxString selectedStatus = 'All'.obs;

  final RxString searchQuery = ''.obs;

  final RxString errorMessage = ''.obs;

  // Filtered Applications
  List<ApplicationModel> get filteredApplications {
    final query = searchQuery.value.toLowerCase().trim();

    return applications.where((application) {
      final matchesStatus =
          selectedStatus.value == 'All' ||
          application.status == selectedStatus.value;

      final matchesSearch =
          query.isEmpty ||
          application.companyName.toLowerCase().contains(query) ||
          application.jobTitle.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  // Load Applications
  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getAllApplications();
      applications.assignAll(result);

      await loadDashboardCounts();
    } catch (e, stackTrace) {
      debugPrint('LOAD APPLICATIONS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load applications.';
    } finally {
      isLoading.value = false;
    }
  }

  // Load Dashboard Counts
  Future<void> loadDashboardCounts() async {
    try {
      final counts = await _repository.getDashboardCounts();
      dashboardCounts.assignAll(counts);
    } catch (e, stackTrace) {
      debugPrint('LOAD DASHBOARD COUNTS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load dashboard statistics.';
    }
  }

  // Add Application
 Future<bool> addApplication(ApplicationModel application) async {
  errorMessage.value = '';

  try {
    final applicationId = await _repository.addApplication(application);

    if (applicationId <= 0) {
      throw Exception('Application could not be saved.');
    }

    await loadApplications();

    return true;
  } catch (e, stackTrace) {
    debugPrint('ADD APPLICATION ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    errorMessage.value = 'Failed to add application.';

    AppSnackbar.error('Error', errorMessage.value);

    return false;
  }
}
  // Update Application
  Future<bool> updateApplication(ApplicationModel application) async {
    errorMessage.value = '';

    try {
      final rowsUpdated = await _repository.updateApplication(application);

      if (rowsUpdated == 0) {
        throw Exception('Application record was not updated.');
      }

      await loadApplications();

      AppSnackbar.success(
        'Application Updated!',
        'Your application has been updated successfully.',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('UPDATE APPLICATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to update application.';

      AppSnackbar.error('Error', errorMessage.value);

      return false;
    }
  }

  // Update Application Status + Create Inbox Notification
  Future<bool> updateStatus(int id, String newStatus) async {
    errorMessage.value = '';

    try {
      final existingApplication = await _repository.getApplicationById(id);

      if (existingApplication == null) {
        errorMessage.value = 'Application not found.';
        return false;
      }

      final oldStatus = existingApplication.status;

      if (oldStatus == newStatus) {
        return true;
      }

      await _repository.updateApplicationStatus(id, newStatus);

      // Inbox notification is a supporting operation.
      try {
        final notificationController = Get.find<NotificationController>();

        String notificationTitle = 'Application Status Updated';

        if (newStatus == AppConstants.statusInterview) {
          notificationTitle = 'Interview Update';
        } else if (newStatus == AppConstants.statusOffer) {
          notificationTitle = 'Congratulations! Job Offer Received';
        }

        await notificationController.addNotification(
          NotificationModel(
            title: notificationTitle,
            message:
                '${existingApplication.companyName} - '
                '${existingApplication.jobTitle}: '
                '$oldStatus → $newStatus',
            type: 'status',
            relatedId: id,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('STATUS NOTIFICATION ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      await loadApplications();

      AppSnackbar.success('Status Updated!', 'Application status updated.');

      return true;
    } catch (e, stackTrace) {
      debugPrint('UPDATE STATUS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to update application status.';

      AppSnackbar.error('Error', errorMessage.value);

      return false;
    }
  }

  // Delete Application
  Future<bool> deleteApplication(int id) async {
    errorMessage.value = '';

    try {
      final rowsDeleted = await _repository.deleteApplication(id);

      if (rowsDeleted == 0) {
        throw Exception('Application record was not deleted.');
      }

      await loadApplications();

      return true;
    } catch (e, stackTrace) {
      debugPrint('DELETE APPLICATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to delete application.';

      AppSnackbar.error('Error', errorMessage.value);

      return false;
    }
  }

  // Search Applications
  void searchApplications(String query) {
    searchQuery.value = query;
  }

  // Filter Applications
  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  // Reset Filters
  void resetFilters() {
    selectedStatus.value = 'All';
    searchQuery.value = '';
  }

  // Get Application By ID
  Future<ApplicationModel?> getApplicationById(int id) async {
    try {
      return await _repository.getApplicationById(id);
    } catch (e, stackTrace) {
      debugPrint('GET APPLICATION BY ID ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load application details.';
      return null;
    }
  }

  // Get Status History
  Future<List<Map<String, dynamic>>> getStatusHistory(int applicationId) async {
    try {
      return await _repository.getStatusHistory(applicationId);
    } catch (e, stackTrace) {
      debugPrint('GET STATUS HISTORY ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load status history.';
      return [];
    }
  }

  // Dashboard Status Labels
  List<String> get statusFilters => [
    'All',
    AppConstants.statusApplied,
    AppConstants.statusInterview,
    AppConstants.statusOffer,
    AppConstants.statusRejected,
  ];
}
