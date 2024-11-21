// // lib/features/dashboard/employee/views/dashboard_employee_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/dashboard_employee_controller.dart';

// class DashboardEmployeeView extends GetView<DashboardEmployeeController> {
//   const DashboardEmployeeView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Employee Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: controller.logout,
//           ),
//         ],
//       ),
//       body: Obx(() => controller.isLoading.value
//         ? const Center(child: CircularProgressIndicator())
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildUserInfo(),
//                 const SizedBox(height: 20),
//                 _buildDashboardContent(),
//               ],
//             ),
//           ),
//       ),
//     );
//   }

//   Widget _buildUserInfo() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome, ${controller.username}',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text('ID: ${controller.iduser}'),
//             Text('SO: ${controller.so}'),
//             Text('BU: ${controller.bu}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardContent() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       children: [
//         _buildMenuCard(
//           icon: Icons.assignment,
//           title: 'Tasks',
//           onTap: controller.navigateToTasks,
//         ),
//         _buildMenuCard(
//           icon: Icons.history,
//           title: 'History',
//           onTap: controller.navigateToHistory,
//         ),
//         _buildMenuCard(
//           icon: Icons.notifications,
//           title: 'Notifications',
//           onTap: controller.navigateToNotifications,
//         ),
//         _buildMenuCard(
//           icon: Icons.person,
//           title: 'Profile',
//           onTap: controller.navigateToProfile,
//         ),
//       ],
//     );
//   }

//   Widget _buildMenuCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 48),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // lib/features/dashboard/employee/controllers/dashboard_employee_controller.dart
// import 'package:get/get.dart';
// import '../../../../core/services/storage_service.dart';

// class DashboardEmployeeController extends GetxController {
//   final StorageService _storage = Get.find<StorageService>();
  
//   final RxBool isLoading = false.obs;
  
//   late String username;
//   late int iduser;
//   late String so;
//   late String bu;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     isLoading.value = true;
//     try {
//       final user = await _storage.getUser();
//       if (user != null) {
//         username = user.username ?? '';
//         iduser = user.id ?? 0;
//         so = user.so ?? '';
//         bu = user.bu ?? '';
//       } else {
//         throw Exception('User data not found');
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load user data',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void navigateToTasks() {
//     // Implement navigation to tasks
//     Get.toNamed('/tasks');
//   }

//   void navigateToHistory() {
//     // Implement navigation to history
//     Get.toNamed('/history');
//   }

//   void navigateToNotifications() {
//     // Implement navigation to notifications
//     Get.toNamed('/notifications');
//   }

//   void navigateToProfile() {
//     // Implement navigation to profile
//     Get.toNamed('/profile');
//   }

//   Future<void> logout() async {
//     try {
//       await _storage.clearUser();
//       await _storage.clearCredentials();
//       Get.offAllNamed('/login');
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to logout',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }

// // lib/features/dashboard/employee/bindings/dashboard_employee_binding.dart
// import 'package:get/get.dart';
// import '../controllers/dashboard_employee_controller.dart';

// class DashboardEmployeeBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<DashboardEmployeeController>(() => DashboardEmployeeController());
//   }
// }

// // lib/features/dashboard/manager/views/dashboard_manager_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/dashboard_manager_controller.dart';

// class DashboardManagerView extends GetView<DashboardManagerController> {
//   const DashboardManagerView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manager Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: controller.logout,
//           ),
//         ],
//       ),
//       body: Obx(() => controller.isLoading.value
//         ? const Center(child: CircularProgressIndicator())
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildUserInfo(),
//                 const SizedBox(height: 20),
//                 _buildDashboardContent(),
//               ],
//             ),
//           ),
//       ),
//     );
//   }

//   Widget _buildUserInfo() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome, ${controller.username}',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text('Role: ${controller.role == "1" ? "Manager" : "Super Manager"}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardContent() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       children: [
//         _buildMenuCard(
//           icon: Icons.people,
//           title: 'Team Management',
//           onTap: controller.navigateToTeamManagement,
//         ),
//         _buildMenuCard(
//           icon: Icons.assignment,
//           title: 'Approvals',
//           onTap: controller.navigateToApprovals,
//         ),
//         _buildMenuCard(
//           icon: Icons.bar_chart,
//           title: 'Reports',
//           onTap: controller.navigateToReports,
//         ),
//         _buildMenuCard(
//           icon: Icons.settings,
//           title: 'Settings',
//           onTap: controller.navigateToSettings,
//         ),
//       ],
//     );
//   }

//   Widget _buildMenuCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 48),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // lib/features/dashboard/manager/controllers/dashboard_manager_controller.dart
// import 'package:get/get.dart';
// import '../../../../core/services/storage_service.dart';

// class DashboardManagerController extends GetxController {
//   final StorageService _storage = Get.find<StorageService>();
  
//   final RxBool isLoading = false.obs;
  
//   late String username;
//   late String role;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     isLoading.value = true;
//     try {
//       final user = await _storage.getUser();
//       if (user != null) {
//         username = user.username ?? '';
//         role = user.role ?? '1';
//       } else {
//         throw Exception('User data not found');
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load user data',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void navigateToTeamManagement() {
//     // Implement navigation to team management
//     Get.toNamed('/team-management');
//   }

//   void navigateToApprovals() {
//     // Implement navigation to approvals
//     Get.toNamed('/approvals');
//   }

//   void navigateToReports() {
//     // Implement navigation to reports
//     Get.toNamed('/reports');
//   }

//   void navigateToSettings() {
//     // Implement navigation to settings
//     Get.toNamed('/settings');
//   }

//   Future<void> logout() async {
//     try {
//       await _storage.clearUser();
//       await _storage.clearCredentials();
//       Get.offAllNamed('/login');
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to logout',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }