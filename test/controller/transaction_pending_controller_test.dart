import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/approval.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noo_sms/controllers/sample_order/transaction_pending_controller.dart';

// Generate mocks
@GenerateMocks([http.Client, SharedPreferences])
import 'transaction_pending_controller_test.mocks.dart';

void main() {
  late TransactionPendingController controller;
  late MockClient mockClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockClient = MockClient();
    mockPrefs = MockSharedPreferences();
    controller = TransactionPendingController();
  });

  tearDown(() {
    reset(mockClient);
    reset(mockPrefs);
  });

  group('Initialization', () {
    test('onInit calls _initializeData', () async {
      // Arrange
      when(mockPrefs.getString(any)).thenReturn('valid_token');
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('[]', 200));

      // Act

      controller.onInit();

      // Assert
      expect(controller.isLoading.value, true);
      await untilCalled(mockClient.get(any));
      verify(mockClient.get(any)).called(any);
    });

    test('onClose disposes controller', () {
      // Act
      controller.onClose();

      // Assert
      expect(controller.principalNameTextEditingControllerRx.value.text, '');
    });
  });

  group('Principal Loading', () {
    test('loads principals successfully', () async {
      // Arrange
      const jsonResponse = '[{"Value": "1", "Text": "Principal 1"}]';
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      // Act
      await controller.loadPrincipal();

      // Assert
      expect(controller.principalList.value.choiceList?.length,
          2); // +1 for 'New Principal'
      expect(controller.errorMessage.value, '');
    });

    test('handles principal loading error', () async {
      // Arrange
      when(mockClient.get(any)).thenThrow(Exception('Failed to load'));

      // Act
      await controller.loadPrincipal();

      // Assert
      expect(controller.principalList.value.choiceList?.length,
          1); // Only 'New Principal'
      expect(controller.errorMessage.value, 'Failed to load principals');
    });
  });

  group('Approval Fetching', () {
    test('fetches approvals successfully', () async {
      // Arrange
      const jsonResponse = '[{"id": 1, "salesOrder": "SO123"}]';
      when(mockPrefs.getString('token')).thenReturn('valid_token');
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      // Act
      await controller.fetchApprovals();

      // Assert
      expect(controller.approvalList.length, 1);
      expect(controller.approvalList[0].salesOrder, 'SO123');
      expect(controller.errorMessage.value, '');
    });

    test('handles empty token', () async {
      // Arrange
      when(mockPrefs.getString('token')).thenReturn(null);

      // Act
      await controller.fetchApprovals();

      // Assert
      expect(controller.approvalList.length, 0);
      expect(controller.errorMessage.value, 'Failed to fetch approvals');
    });

    test('handles API error', () async {
      // Arrange
      when(mockPrefs.getString('token')).thenReturn('valid_token');
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 500));

      // Act
      await controller.fetchApprovals();

      // Assert
      expect(controller.approvalList.length, 0);
      expect(controller.errorMessage.value, 'Failed to fetch approvals');
    });
  });

  group('Approval Details', () {
    test('shows approval detail successfully', () async {
      // Arrange
      const jsonResponse = '{"Lines": [{"productId": 1, "product": "Test"}]}';
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      // Act
      await controller.showApprovalDetail(1, (id, details) {});

      // Assert
      verify(mockClient.get(any)).called(1);
    });

    test('handles approval detail error', () async {
      // Arrange
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 500));

      // Act
      await controller.showApprovalDetail(1, (id, details) {});

      // Assert
      verify(mockClient.get(any)).called(1);
    });
  });

  group('Approval Submission', () {
    test('submits approval successfully', () async {
      // Arrange
      final details = [
        ApprovalDetail(productId: '1', product: 'Test', qty: 1, unit: 'pc')
      ];
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Success', 200));

      // Act
      await controller.sendApproval(1, true, 'Message', details);

      // Assert
      verify(mockClient.post(any)).called(1);
    });

    test('submits rejection successfully', () async {
      // Arrange
      final details = [
        ApprovalDetail(productId: '1', product: 'Test', qty: 1, unit: 'pc')
      ];
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Success', 200));

      // Act
      await controller.sendApproval(1, false, 'Message', details);

      // Assert
      verify(mockClient.post(any)).called(1);
    });

    test('submits with claim to principal', () async {
      // Arrange
      final details = [
        ApprovalDetail(productId: '1', product: 'Test', qty: 1, unit: 'pc')
      ];
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Success', 200));
      controller.isClaim.value = true;
      controller.principalList.value = InputPageDropdownState(
        choiceList: [IdAndValue(id: '1', value: 'Principal')],
        selectedChoice: IdAndValue(id: '1', value: 'Principal'),
      );

      // Act
      await controller.sendApproval(1, true, 'Message', details);

      // Assert
      verify(mockClient.post(any)).called(1);
    });

    test('handles submission error', () async {
      // Arrange
      final details = [
        ApprovalDetail(productId: '1', product: 'Test', qty: 1, unit: 'pc')
      ];
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Failed'));

      // Act
      await controller.sendApproval(1, true, 'Message', details);

      // Assert
      verify(mockClient.post(any)).called(1);
    });
  });

  group('Utility Methods', () {
    test('changePrincipal updates selection', () {
      // Arrange
      final newValue = IdAndValue<String>(id: '2', value: 'Principal 2');

      // Act
      controller.changePrincipal(newValue);

      // Assert
      expect(controller.principalList.value.selectedChoice, newValue);
    });

    test('refreshData reloads data', () async {
      // Arrange
      when(mockPrefs.getString('token')).thenReturn('valid_token');
      when(mockPrefs.getString('scs_idEmp')).thenReturn('123');
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('[]', 200));

      // Act
      await controller.refreshData();

      // Assert
      verify(mockClient.get(any)).called(any);
    });
  });
}
