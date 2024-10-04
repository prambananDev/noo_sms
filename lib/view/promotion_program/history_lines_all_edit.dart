import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/activity_edit.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/promotion_program/custom_card_history_all_edit.dart';
import 'package:noo_sms/view/promotion_program/input_pp.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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
  bool startApp = false;
  List idLines = [];
  final inputPagePresenter = Get.put(InputPageController());
  ActivityEdit activityEditModel = ActivityEdit();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getSharedPreference();
    await _getDataActivity();
    _populateFormFields();
  }

  Future<void> _getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _user = userBox.get(0);
      code = pref.getInt("code") ?? 0;
    });
  }

  Future<void> _getDataActivity() async {
    final url = '$apiCons/api/activity/${widget.numberPP}';
    try {
      final response = await get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          activityEditModel = ActivityEdit.fromJson(jsonDecode(response.body));
        });
      } else {
        print("Failed to load activity data");
      }
    } catch (e) {
      print("Error fetching activity data: $e");
    }
  }

  void _populateFormFields() {
    inputPagePresenter.programNoteTextEditingControllerRx.value.text =
        activityEditModel.note ?? '';
    inputPagePresenter.programNameTextEditingControllerRx.value.text =
        activityEditModel.number ?? '';

    IdAndValue<String> type = IdAndValue<String>(
      id: activityEditModel.type ?? '1',
      value: _getPromotionTypeLabel(activityEditModel.type),
    );
    inputPagePresenter
        .promotionTypeInputPageDropdownStateRx.value.selectedChoice = type;

    if (activityEditModel.fromDate != null) {
      inputPagePresenter.programFromDateTextEditingControllerRx.value.text =
          _formatDate(activityEditModel.fromDate!);
    }
    if (activityEditModel.toDate != null) {
      inputPagePresenter.programToDateTextEditingControllerRx.value.text =
          _formatDate(activityEditModel.toDate!);
    }

    idLines = activityEditModel.activityLinesEdit!.map((e) => e.id).toList();
    startApp = true;
    setState(() {});
  }

  String _getPromotionTypeLabel(String? type) {
    switch (type) {
      case '1':
        return 'Discount';
      case '2':
        return 'Bonus';
      default:
        return 'Discount & Bonus';
    }
  }

  String _formatDate(String date) {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  }

  Future<bool> _onBackPressLines() {
    Navigator.of(context).pop();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressLines,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorAccent,
          title: Text(
            "Edit",
            style: TextStyle(fontWeight: FontWeight.w800, color: colorNetral),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: colorNetral, size: 35),
            onPressed: _onBackPressLines,
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
                ),
              ),
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
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create"),
              const SizedBox(height: 10),
              _buildTextFormField("Program Name",
                  inputPagePresenter.programNameTextEditingControllerRx.value),
              const SizedBox(height: 10),
              _buildDropdown(),
              _buildCustomerGroupDropdown(),
              _buildPrincipalDropdown(),
              _buildDatePickers(),
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
            .map((item) => DropdownMenuItem<IdAndValue<String>>(
                value: item, child: Text(item.value)))
            .toList(),
        onChanged: inputPagePresenter.changePromotionType,
      ),
    );
  }

  Widget _buildCustomerGroupDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: inputPagePresenter
            .customerGroupInputPageDropdownState.value.selectedChoice,
        items: inputPagePresenter
            .customerGroupInputPageDropdownState.value.choiceList!
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 12))))
            .toList(),
        onChanged: (value) => setState(
            () => inputPagePresenter.changeCustomerGroupHeader(value!)),
        hint: const Text("Customer/Cust Group", style: TextStyle(fontSize: 12)),
        isExpanded: true,
        isDense: true,
      ),
    );
  }

  Widget _buildPrincipalDropdown() {
    return Obx(
      () => SearchChoices.single(
        items: inputPagePresenter.listDataPrincipal
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
            .toList(),
        value: inputPagePresenter.selectedDataPrincipal.isNotEmpty
            ? inputPagePresenter
                .listDataPrincipal[inputPagePresenter.selectedDataPrincipal[0]]
            : null,
        hint: const Text(
          "Select Principal",
          style: TextStyle(fontSize: 12),
        ),
        onChanged: (String? value) {
          if (value != null) {
            final index = inputPagePresenter.listDataPrincipal.indexOf(value);
            inputPagePresenter.selectedDataPrincipal.clear();
            if (index >= 0) {
              inputPagePresenter.selectedDataPrincipal.add(index);
            }
          }
        },
        isExpanded: true, // Ensures that the dropdown fills the available space
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: CustomDatePickerField(
            controller:
                inputPagePresenter.programFromDateTextEditingControllerRx.value,
            labelText: "From Date",
            initialValue: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 180)),
          ),
        ),
        Expanded(
          child: CustomDatePickerField(
            controller:
                inputPagePresenter.programToDateTextEditingControllerRx.value,
            labelText: "To Date",
            initialValue: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 180)),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Obx(() {
      InputPageWrapper inputPageWrapper =
          inputPagePresenter.promotionProgramInputStateRx.value;
      List<PromotionProgramInputState>? promotionProgramInputStateList =
          inputPageWrapper.promotionProgramInputState;
      bool? isAddItem = inputPageWrapper.isAddItem;

      return promotionProgramInputStateList.isEmpty
          ? Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                onPressed:
                    isAddItem ? () => inputPagePresenter.addItem() : null,
                child: Text(
                  "Add Lines",
                  style: TextStyle(color: colorNetral),
                ),
              ),
            )
          : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: promotionProgramInputStateList.length,
              itemBuilder: (context, index) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  children: [
                    // Call customCard here
                    customCard(index, inputPagePresenter),
                    const SizedBox(
                      height: 10,
                    ),

                    index == promotionProgramInputStateList.length - 1
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 500),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: !inputPagePresenter.onTap.value,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorAccent,
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: colorNetral,
                                        fontSize: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        bool isInvalid = false;
                                        for (int i = 0;
                                            i <
                                                promotionProgramInputStateList
                                                    .length;
                                            i++) {
                                          PromotionProgramInputState element =
                                              promotionProgramInputStateList[i];
                                          if (element.selectProductPageDropdownState
                                                      ?.selectedChoice ==
                                                  null ||
                                              element.qtyFrom!.text.isEmpty ||
                                              element.unitPageDropdownState
                                                      ?.selectedChoice ==
                                                  null) {
                                            isInvalid = true;
                                            break;
                                          }
                                        }

                                        // If fields are invalid, show an error message
                                        if (isInvalid) {
                                          inputPagePresenter.onTap.value =
                                              false;
                                          Get.snackbar("Error",
                                              "Found empty fields in Lines",
                                              backgroundColor: Colors.red,
                                              icon: const Icon(Icons.error));
                                        } else {
                                          inputPagePresenter.onTap.value = true;
                                          inputPagePresenter
                                              .submitPromotionProgram();
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      inputPagePresenter.onTap.value == true,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            );
    });
  }
}
