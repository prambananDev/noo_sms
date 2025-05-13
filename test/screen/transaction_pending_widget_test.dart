import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/sample_order/transaction_pending_controller.dart';
import 'package:noo_sms/view/sample_order/transaction_pending.dart';

void main() {
  testWidgets('Displays loading indicator', (WidgetTester tester) async {
    final controller = TransactionPendingController();
    controller.isLoading.value = true;

    await tester.pumpWidget(
      MaterialApp(
        home: GetBuilder<TransactionPendingController>(
          init: controller,
          builder: (_) => const TransactionPendingPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays error message', (WidgetTester tester) async {
    final controller = TransactionPendingController();
    Get.put(controller); // Important for GetX to work in tests
    controller.errorMessage.value = 'Test error';

    await tester.pumpWidget(
      const MaterialApp(
        home: GetMaterialApp(
          // Need GetMaterialApp for GetX to work
          home: TransactionPendingPage(),
        ),
      ),
    );

    await tester.pump(); // Need to pump to update the UI

    expect(find.text('Test error'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('Displays empty state', (WidgetTester tester) async {
    final controller = TransactionPendingController();
    Get.put(controller);
    controller.approvalList.clear();
    controller.isLoading.value = false; // Ensure loading is false

    await tester.pumpWidget(
      const MaterialApp(
        home: GetMaterialApp(
          home: TransactionPendingPage(),
        ),
      ),
    );

    await tester.pump(); // Need to pump to update the UI

    expect(find.text('No Data Found'), findsOneWidget);
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
  });
}
