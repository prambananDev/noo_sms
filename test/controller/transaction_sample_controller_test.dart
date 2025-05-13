import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noo_sms/models/id_valaue.dart';

import 'test_transaction_sample_controller.dart';

@GenerateMocks([http.Client, SharedPreferences])
import 'transaction_sample_controller_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTransactionSampleController controller;
  late MockClient mockClient;
  late MockSharedPreferences mockPreferences;

  setUp(() {
    Get.testMode = true;

    mockClient = MockClient();
    mockPreferences = MockSharedPreferences();

    when(mockPreferences.getString("username")).thenReturn("testuser");
    when(mockPreferences.getString("token")).thenReturn("test-token");
    when(mockPreferences.getString("scs_idEmp")).thenReturn("123");

    controller = TestTransactionSampleController();
  });

  tearDown(() {
    Get.reset();
  });

  group('TransactionSampleController - Initialization', () {
    test('controller initializes with empty promotionProgramInputState', () {
      expect(
          controller
              .promotionProgramInputStateRx.value.promotionProgramInputState,
          isEmpty);
    });

    test('controller initializes with empty text controllers', () {
      expect(controller.purposeDescTextEditingControllerRx.value.text, isEmpty);
      expect(controller.custNameTextEditingControllerRx.value.text, isEmpty);
      expect(controller.custPicTextEditingControllerRx.value.text, isEmpty);
      expect(controller.custPhoneTextEditingControllerRx.value.text, isEmpty);
      expect(controller.custAddressTextEditingControllerRx.value.text, isEmpty);
    });

    test('isProspectValid is initially false', () {
      expect(controller.isProspectValid.value, isFalse);
    });
  });

  group('TransactionSampleController - validateProspectFields', () {
    test('validates when all prospect fields are filled', () {
      controller.custNameTextEditingControllerRx.value.text = "Test Customer";
      controller.custPicTextEditingControllerRx.value.text = "Test PIC";
      controller.custPhoneTextEditingControllerRx.value.text = "123456789";
      controller.custAddressTextEditingControllerRx.value.text = "Test Address";

      controller.validateProspectFields();

      expect(controller.isProspectValid.value, isTrue);
    });

    test('invalidates when any prospect field is empty', () {
      controller.custNameTextEditingControllerRx.value.text = "Test Customer";
      controller.custPicTextEditingControllerRx.value.text = "Test PIC";
      controller.custPhoneTextEditingControllerRx.value.text = "123456789";
      controller.custAddressTextEditingControllerRx.value.text = "";

      controller.validateProspectFields();

      expect(controller.isProspectValid.value, isFalse);
    });
  });

  group('TransactionSampleController - Sample Type Management', () {
    test('changes sample type and updates state', () {
      final sampleType = IdAndValue<String>(id: "0", value: "Commercial");

      expect(controller.typesList.value.selectedChoice, isNull);

      controller.changeSampleType(sampleType);

      expect(controller.typesList.value.selectedChoice, equals(sampleType));
      expect(controller.typesList.value.selectedChoice?.id, equals("0"));
      expect(controller.typesList.value.selectedChoice?.value,
          equals("Commercial"));
    });
  });

  group('TransactionSampleController - Product Line Management', () {
    test('adds a product line item', () {
      expect(
          controller
              .promotionProgramInputStateRx.value.promotionProgramInputState,
          isEmpty);

      controller.addItem();

      expect(
          controller.promotionProgramInputStateRx.value
              .promotionProgramInputState.length,
          equals(1));

      final item = controller
          .promotionProgramInputStateRx.value.promotionProgramInputState[0];
      expect(item.qtyTransaction?.text, equals("1"));
      expect(
          item.productTransactionPageDropdownState?.selectedChoiceWrapper
              ?.value,
          isNull);
    });

    test('removes a product line item', () {
      controller.addItem();
      controller.addItem();
      expect(
          controller.promotionProgramInputStateRx.value
              .promotionProgramInputState.length,
          equals(2));

      controller.removeItem(0);

      expect(
          controller.promotionProgramInputStateRx.value
              .promotionProgramInputState.length,
          equals(1));
    });

    test('updates quantity for a product line', () {
      controller.addItem();

      controller.changeQty(0, "5");

      expect(
          controller.promotionProgramInputStateRx.value
              .promotionProgramInputState[0].qtyTransaction?.text,
          equals("5"));
    });
  });

  group('TransactionSampleController - Customer Selection', () {
    test('updates customer selection', () {
      final customer = IdAndValue<String>(id: "1", value: "Customer 1");

      expect(
          controller.customerNameInputPageDropdownStateRx.value.selectedChoice,
          isNull);

      controller.changeSelectCustomer(customer);

      expect(
          controller.customerNameInputPageDropdownStateRx.value.selectedChoice,
          equals(customer));
    });

    test('handles prospect customer selection and validation', () {
      final prospect = IdAndValue<String>(id: "prospect", value: "Prospect");

      expect(
          controller.customerNameInputPageDropdownStateRx.value.selectedChoice,
          isNull);

      controller.changeSelectCustomer(prospect);

      expect(
          controller.customerNameInputPageDropdownStateRx.value.selectedChoice,
          equals(prospect));

      expect(controller.isProspectValid.value, isFalse);

      controller.custNameTextEditingControllerRx.value.text = "Test Prospect";
      controller.custPicTextEditingControllerRx.value.text = "Test PIC";
      controller.custPhoneTextEditingControllerRx.value.text = "123456789";
      controller.custAddressTextEditingControllerRx.value.text = "Test Address";

      controller.updateProspectField("");

      expect(controller.isProspectValid.value, isTrue);
    });
  });

  group('TransactionSampleController - Form Validation', () {
    test('validateSubmission fails with missing required fields', () {
      final result = controller.validateSubmission();
      expect(result, isFalse);

      expect(controller.validationMessages.isNotEmpty, isTrue);
      expect(controller.validationMessages.first, contains('Sample Type'));
    });

    test('validateSubmission validates sample type selection', () {
      controller.typesList.value.selectedChoice =
          IdAndValue<String>(id: "0", value: "Commercial");

      controller.validationMessages.clear();

      final result = controller.validateSubmission();
      expect(result, isFalse);

      expect(controller.validationMessages.first, contains('Purpose'));
    });
  });

  group('TransactionSampleController - Product and Unit Management', () {
    test('changes product selection', () {
      controller.addItem();

      final product = IdAndValue<String>(id: "1", value: "Test Product");

      controller.changeProduct(0, product);

      expect(
          controller
              .promotionProgramInputStateRx
              .value
              .promotionProgramInputState[0]
              .productTransactionPageDropdownState
              ?.selectedChoiceWrapper
              ?.value,
          equals(product));
    });

    test('changes unit selection', () {
      controller.addItem();

      controller.changeUnit(0, "KG");

      expect(
          controller
              .promotionProgramInputStateRx
              .value
              .promotionProgramInputState[0]
              .unitPageDropdownState
              ?.selectedChoice,
          equals("KG"));
    });
  });

  group('TransactionSampleController - Reset Functionality', () {
    test('resets all controllers to initial state', () {
      controller.purposeDescTextEditingControllerRx.value.text =
          "Test description";
      controller.custNameTextEditingControllerRx.value.text = "Test customer";
      controller.typesList.value.selectedChoice =
          IdAndValue<String>(id: "0", value: "Commercial");
      controller.addItem();

      expect(
          controller.purposeDescTextEditingControllerRx.value.text, isNotEmpty);
      expect(controller.custNameTextEditingControllerRx.value.text, isNotEmpty);
      expect(controller.typesList.value.selectedChoice, isNotNull);
      expect(
          controller.promotionProgramInputStateRx.value
              .promotionProgramInputState.length,
          equals(1));

      controller.resetAllControllers();

      expect(controller.purposeDescTextEditingControllerRx.value.text, isEmpty);
      expect(controller.custNameTextEditingControllerRx.value.text, isEmpty);
      expect(controller.typesList.value.selectedChoice, isNull);
      expect(
          controller
              .promotionProgramInputStateRx.value.promotionProgramInputState,
          isEmpty);
    });
  });
}
