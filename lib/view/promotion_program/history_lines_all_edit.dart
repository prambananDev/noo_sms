import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/activity_edit.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/promotion_program/custom_card_history_all_edit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesAllEdit extends StatefulWidget {
  final String? numberPP;
  final int? idEmp;

  const HistoryLinesAllEdit({Key? key, this.numberPP, this.idEmp})
      : super(key: key);

  @override
  State<HistoryLinesAllEdit> createState() => _HistoryLinesAllEditState();
}

class _HistoryLinesAllEditState extends State<HistoryLinesAllEdit> {
  late User _user;
  late int code;
  late List _listHistorySO;
  bool startApp = false;
  final inputPagePresenter = Get.put(InputPageController());
  ActivityEdit activityEditModel = ActivityEdit();
  List idLines = [];

  @override
  void initState() {
    super.initState();
    getSharedPreference();
    getDataActivity();
    initData();
  }

  void getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _user = listUser[0];
      code = pref.getInt("code")!;
    });
  }

  initData() {
    Future.delayed(const Duration(seconds: 2), () {
      startApp = true;

      // Safely assigning values to the text fields
      inputPagePresenter.programNoteTextEditingControllerRx.value.text =
          activityEditModel.note ??
              ''; // Provide a default empty string if null
      inputPagePresenter.programNameTextEditingControllerRx.value.text =
          activityEditModel.number ??
              ''; // Provide a default empty string if null

      IdAndValue<String> type = IdAndValue<String>(
        id: activityEditModel.type ?? '1', // Provide default '1' if null
        value: activityEditModel.type == "1"
            ? "Discount"
            : activityEditModel.type == "2"
                ? "Bonus"
                : "Discount & Bonus",
      );

      inputPagePresenter
          .promotionTypeInputPageDropdownStateRx.value.selectedChoice = type;
      inputPagePresenter.customerGroupInputPageDropdownState.value
          .selectedChoice = "Customer";
      inputPagePresenter.changeCustomerGroupHeader(inputPagePresenter
          .customerGroupInputPageDropdownState.value.selectedChoice!);

      IdAndValue<String> custHeader = IdAndValue<String>(
          id: activityEditModel.customerId ?? '',
          value: activityEditModel.customerId ?? '');

      inputPagePresenter
          .custNameHeaderValueDropdownStateRx.value.selectedChoice = custHeader;

      // Safely handling fromDate and toDate
      if (activityEditModel.fromDate != null) {
        inputPagePresenter.programFromDateTextEditingControllerRx.value.text =
            DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(activityEditModel.fromDate));
      }

      if (activityEditModel.toDate != null) {
        inputPagePresenter.programToDateTextEditingControllerRx.value.text =
            DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(activityEditModel.toDate));
      }

      // Handle vendor
      if (activityEditModel.vendor != null) {
        final index = inputPagePresenter.listDataPrincipal
            .indexOf(activityEditModel.vendor);
        if (index >= 0) {
          inputPagePresenter.selectedDataPrincipal.add(index);
        }
      }

      for (int i = 0; i < activityEditModel.activityLinesEdit!.length; i++) {
        inputPagePresenter.addItem();
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {});
        });

        IdAndValue<String> percent =
            IdAndValue<String>(id: "1", value: "Percent");

        PromotionProgramInputState promotionProgramInputState =
            inputPagePresenter.promotionProgramInputStateRx.value
                .promotionProgramInputState[i];

        IdAndValue<String> itemProduct = IdAndValue<String>(
          id: activityEditModel.activityLinesEdit![i].item ?? '',
          value: activityEditModel.activityLinesEdit![i].item ?? '',
        );

        IdAndValue<String> suppItemProduct = IdAndValue<String>(
          id: activityEditModel.activityLinesEdit![i].suppItemId ?? '',
          value: activityEditModel.activityLinesEdit![i].suppItemId ?? '',
        );

        promotionProgramInputState
            .itemGroupInputPageDropdownState!.selectedChoice = 'Item';
        inputPagePresenter.changeItemGroup(
            i,
            promotionProgramInputState
                .itemGroupInputPageDropdownState!.selectedChoice!);

        promotionProgramInputState
            .selectProductPageDropdownState!.selectedChoice = itemProduct;
        promotionProgramInputState.supplyItem!.selectedChoice = suppItemProduct;

        inputPagePresenter.changeProduct(
            i,
            promotionProgramInputState
                .selectProductPageDropdownState!.selectedChoice!);
        inputPagePresenter.changeSupplyItem(
            i, promotionProgramInputState.supplyItem!.selectedChoice!);

        promotionProgramInputState.qtyFrom!.text = activityEditModel
                .activityLinesEdit![i].qtyFrom
                ?.toString()
                .split(".")[0] ??
            '';
        promotionProgramInputState.qtyTo!.text = activityEditModel
                .activityLinesEdit![i].qtyTo
                ?.toString()
                .split(".")[0] ??
            '';

        promotionProgramInputState.unitSupplyItem?.selectedChoice =
            activityEditModel.activityLinesEdit![i].supplementaryUnitId ?? '';
        promotionProgramInputState.salesPrice!.text = activityEditModel
                .activityLinesEdit![i].salesPrice
                ?.toString()
                .replaceAll("Rp", '') ??
            '';

        promotionProgramInputState
            .percentValueInputPageDropdownState?.selectedChoice = percent;
        promotionProgramInputState.qtyItem!.text = activityEditModel
                .activityLinesEdit![i].suppItemQty
                ?.toString()
                .split(".")[0] ??
            '';
        promotionProgramInputState.percent1!.text = activityEditModel
                .activityLinesEdit![i].percent1
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);

        promotionProgramInputState.percent2!.text = activityEditModel
                .activityLinesEdit![i].percent2
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);

        promotionProgramInputState.percent3!.text = activityEditModel
                .activityLinesEdit![i].percent3
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);

        promotionProgramInputState.percent4!.text = activityEditModel
                .activityLinesEdit![i].percent4
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);

        promotionProgramInputState.value1!.text = activityEditModel
                .activityLinesEdit![i].value1
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);

        promotionProgramInputState.value2!.text = activityEditModel
                .activityLinesEdit![i].value2
                ?.toString()
                .split(".")[0] ??
            '';
        inputPagePresenter.getPriceToCustomer(i);
      }

      idLines = activityEditModel.activityLinesEdit!.map((e) => e.id).toList();
    });
  }

  Future<void> getDataActivity() async {
    final url = '$apiCons/api/activity/${widget.numberPP}';
    print("Fetching activity data from: $url");

    try {
      final response = await get(Uri.parse(url));
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          setState(() {
            activityEditModel = ActivityEdit.fromJson(decodedData);

            // Now safely set the fields, check if they are not null
            inputPagePresenter.programNoteTextEditingControllerRx.value.text =
                activityEditModel.note ?? '';
            inputPagePresenter.programNameTextEditingControllerRx.value.text =
                activityEditModel.number ?? '';

            IdAndValue<String> type = IdAndValue<String>(
              id: activityEditModel.type ?? '',
              value: activityEditModel.type == "1"
                  ? "Discount"
                  : activityEditModel.type == "2"
                      ? "Bonus"
                      : "Discount & Bonus",
            );
            inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                .selectedChoice = type;

            inputPagePresenter.customerGroupInputPageDropdownState.value
                .selectedChoice = "Customer";
            inputPagePresenter.changeCustomerGroupHeader(inputPagePresenter
                .customerGroupInputPageDropdownState.value.selectedChoice!);

            IdAndValue<String> custHeader = IdAndValue<String>(
                id: activityEditModel.customerId ?? '',
                value: activityEditModel.customerId ?? '');
            inputPagePresenter.custNameHeaderValueDropdownStateRx.value
                .selectedChoice = custHeader;

            // Handle the date fields safely
            if (activityEditModel.fromDate != null) {
              inputPagePresenter
                      .programFromDateTextEditingControllerRx.value.text =
                  DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(activityEditModel.fromDate!));
            }

            if (activityEditModel.toDate != null) {
              inputPagePresenter
                      .programToDateTextEditingControllerRx.value.text =
                  DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(activityEditModel.toDate!));
            }

            // Further handling of vendor or other fields
            if (activityEditModel.vendor != null) {
              final index = inputPagePresenter.listDataPrincipal
                  .indexOf(activityEditModel.vendor);
              if (index >= 0) {
                inputPagePresenter.selectedDataPrincipal.add(index);
              }
            }

            // Handle activity lines safely
            for (int i = 0;
                i < activityEditModel.activityLinesEdit!.length;
                i++) {
              inputPagePresenter.addItem();
              // Populate data for each item here
            }
          });
        }
      } else {
        print(
            "Failed to load activity data, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching activity data: $e");
    }
  }

  Future<bool> onBackPressLines() {
    Navigator.of(context).pop();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressLines,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Edit",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colorNetral,
              )),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: colorNetral,
              size: 35,
            ),
            onPressed: () => onBackPressLines(),
          ),
        ),
        body: startApp == false
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMainForm(),
                    _buildListView(),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _buildMainForm() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create"),
              const SizedBox(height: 10),
              _buildTextFormField("Program Name",
                  inputPagePresenter.programNameTextEditingControllerRx.value),
              const SizedBox(height: 10),
              _buildDropdown(),
              // Add any other widgets here...
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDropdown() {
    return Obx(
      () => DropdownButtonFormField<IdAndValue<String>>(
        value: inputPagePresenter
            .promotionTypeInputPageDropdownStateRx.value.selectedChoice,
        items: inputPagePresenter
            .promotionTypeInputPageDropdownStateRx.value.choiceList!
            .map((item) {
          return DropdownMenuItem<IdAndValue<String>>(
            value: item,
            child: Text(item.value),
          );
        }).toList(),
        onChanged: (value) => inputPagePresenter.changePromotionType(value),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      InputPageWrapper inputPageWrapper =
          inputPagePresenter.promotionProgramInputStateRx.value;
      List<PromotionProgramInputState>? promotionProgramInputStateList =
          inputPageWrapper.promotionProgramInputState;
      bool? isAddItem = inputPageWrapper.isAddItem;
      if (promotionProgramInputStateList.isEmpty) {
        return ElevatedButton(
          onPressed: isAddItem ? () => inputPagePresenter.addItem() : null,
          child: const Text("Add Lines"),
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: promotionProgramInputStateList.length,
          itemBuilder: (context, index) {
            return customCard(
                index, inputPagePresenter); // Using the custom card
          },
        );
      }
    });
  }
}
