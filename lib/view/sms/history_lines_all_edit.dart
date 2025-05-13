import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/activity_edit.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

class HistoryLinesAllEdit extends StatefulWidget {
  final String? numberPP;
  final int? idEmp;

  const HistoryLinesAllEdit({Key? key, this.numberPP, this.idEmp})
      : super(key: key);

  @override
  State<HistoryLinesAllEdit> createState() => _HistoryLinesAllEditState();
}

class _HistoryLinesAllEditState extends State<HistoryLinesAllEdit> {
  bool isLoading = true;
  List<int> idLines = [];
  final inputPagePresenter = Get.put(InputPageController());
  ActivityEdit activityEditModel = ActivityEdit();

  @override
  void initState() {
    super.initState();
    _resetController();
    getDataActivity();
  }

  void _resetController() {
    inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState
        .clear();
    inputPagePresenter.onTap.value = false;
  }

  Future<void> getDataActivity() async {
    final url = '$apiSMS/activity/${widget.numberPP}';

    try {
      final response = await get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          activityEditModel = ActivityEdit.fromJson(jsonDecode(response.body));
          _initializeData();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackbar('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _initializeData() {
    _populateFormFields();
    _initializeActivityLines();
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

    idLines =
        activityEditModel.activityLinesEdit!.map((e) => e.id ?? -1).toList();
  }

  void _initializeActivityLines() {
    if (activityEditModel.activityLinesEdit != null) {
      for (int i = 0; i < activityEditModel.activityLinesEdit!.length; i++) {
        inputPagePresenter.addItem();
        _initializeSingleLine(i);
      }
    }
  }

  void _initializeSingleLine(int i) {
    if (i >= activityEditModel.activityLinesEdit!.length) return;

    IdAndValue<String> percent = IdAndValue<String>(id: "1", value: "Percent");
    PromotionProgramInputState promotionProgramInputState = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[i];

    _setItemProduct(i, promotionProgramInputState);
    _setSupplyItem(i, promotionProgramInputState);
    _setQuantities(i, promotionProgramInputState);
    _setSupplementaryUnit(i, promotionProgramInputState);
    _setSalesPrice(i, promotionProgramInputState);
    _setDiscountValues(i, promotionProgramInputState, percent);
    inputPagePresenter.getPriceToCustomer(i);
  }

  void _setItemProduct(int i, PromotionProgramInputState state) {
    String itemId = activityEditModel.activityLinesEdit![i].item ?? 'Default';
    IdAndValue<String> itemProduct =
        IdAndValue<String>(id: itemId, value: itemId);

    state.itemGroupInputPageDropdownState!.selectedChoice = 'Item';
    inputPagePresenter.changeItemGroup(
        i, state.itemGroupInputPageDropdownState!.selectedChoice!);
    state.selectProductPageDropdownState!.selectedChoice = itemProduct;
    inputPagePresenter.changeProduct(
        i, state.selectProductPageDropdownState!.selectedChoice!);
  }

  void _setSupplyItem(int i, PromotionProgramInputState state) {
    if (activityEditModel.activityLinesEdit![i].suppItemId == null) return;

    IdAndValue<String> suppItemProduct = IdAndValue<String>(
      id: activityEditModel.activityLinesEdit![i].suppItemId!,
      value: activityEditModel.activityLinesEdit![i].suppItemId!,
    );
    state.supplyItem!.selectedChoice = suppItemProduct;
    inputPagePresenter.changeSupplyItem(i, state.supplyItem!.selectedChoice!);
  }

  void _setQuantities(int i, PromotionProgramInputState state) {
    state.qtyFrom!.text = activityEditModel.activityLinesEdit![i].qtyFrom
        .toString()
        .split(".")[0];
    state.qtyTo!.text =
        activityEditModel.activityLinesEdit![i].qtyTo.toString().split(".")[0];
  }

  void _setSupplementaryUnit(int i, PromotionProgramInputState state) {
    if (activityEditModel.activityLinesEdit![i].supplementaryUnitId != null) {
      state.unitSupplyItem?.selectedChoice =
          activityEditModel.activityLinesEdit![i].supplementaryUnitId;
    }
  }

  void _setSalesPrice(int i, PromotionProgramInputState state) {
    state.salesPrice!.text = activityEditModel.activityLinesEdit![i].salesPrice
        .toString()
        .replaceAll("Rp", "");
  }

  void _setDiscountValues(
      int i, PromotionProgramInputState state, IdAndValue<String> percent) {
    state.percentValueInputPageDropdownState?.selectedChoice = percent;
    state.qtyItem!.text = activityEditModel.activityLinesEdit![i].suppItemQty
        .toString()
        .split(".")[0];
    state.percent1!.text = activityEditModel.activityLinesEdit![i].percent1
        .toString()
        .split(".")[0];
    state.percent2!.text = activityEditModel.activityLinesEdit![i].percent2
        .toString()
        .split(".")[0];
    state.percent3!.text = activityEditModel.activityLinesEdit![i].percent3
        .toString()
        .split(".")[0];
    state.percent4!.text = activityEditModel.activityLinesEdit![i].percent4
        .toString()
        .split(".")[0];
    state.value1!.text =
        activityEditModel.activityLinesEdit![i].value1.toString().split(".")[0];
    state.value2!.text =
        activityEditModel.activityLinesEdit![i].value2.toString().split(".")[0];
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

  Future<bool> _onBackPress() {
    Navigator.pop(context);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        title: Text("Edit Lines",
            style: TextStyle(fontWeight: FontWeight.w800, color: colorNetral)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colorNetral, size: 35),
          onPressed: _onBackPress,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    _buildDateRangeCard(),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextResultCard(
            title: "Program Name",
            value: activityEditModel.number ?? "",
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<IdAndValue<String>>(
            value: inputPagePresenter
                .promotionTypeInputPageDropdownStateRx.value.selectedChoice,
            decoration: const InputDecoration(
              labelText: "Promotion Type",
              border: OutlineInputBorder(),
            ),
            items: inputPagePresenter
                .promotionTypeInputPageDropdownStateRx.value.choiceList!
                .map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item, child: Text(item.value)))
                .toList(),
            onChanged: inputPagePresenter.changePromotionType,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller:
                inputPagePresenter.programNoteTextEditingControllerRx.value,
            decoration: const InputDecoration(
              labelText: "Note",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomDatePickerField(
              controller: inputPagePresenter
                  .programFromDateTextEditingControllerRx.value,
              labelText: "From Date",
              initialValue:
                  DateTime.tryParse(activityEditModel.fromDate ?? '') ??
                      DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 180)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomDatePickerField(
              controller:
                  inputPagePresenter.programToDateTextEditingControllerRx.value,
              labelText: "To Date",
              initialValue: DateTime.tryParse(activityEditModel.toDate ?? '') ??
                  DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 180)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      InputPageWrapper inputPageWrapper =
          inputPagePresenter.promotionProgramInputStateRx.value;
      List<PromotionProgramInputState> promotionProgramInputStateList =
          inputPageWrapper.promotionProgramInputState;
      bool isAddItem = inputPageWrapper.isAddItem ?? false;

      if (promotionProgramInputStateList.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(bottom: 100),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isAddItem ? () => inputPagePresenter.addItem() : null,
            child: Text("Add Lines", style: TextStyle(color: colorNetral)),
          ),
        );
      }

      return Column(
        children: [
          ...List.generate(
            promotionProgramInputStateList.length,
            (index) => _buildLineCard(index, promotionProgramInputStateList),
          ),
          const SizedBox(height: 20),
          _buildActionButtons(isAddItem, promotionProgramInputStateList),
          const SizedBox(height: 40),
        ],
      );
    });
  }

  Widget _buildLineCard(int index, List<PromotionProgramInputState> stateList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "Item ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add, color: colorAccent),
                  onPressed: () => inputPagePresenter.addItem(),
                  tooltip: "Add new line",
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    inputPagePresenter.removeItem(index);
                    inputPagePresenter.onTap.value = false;
                  },
                  tooltip: "Delete this line",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemSelectionSection(index),
                _buildQuantitySection(index),
                _buildPricingSection(index),
                if (inputPagePresenter.promotionTypeInputPageDropdownStateRx
                        .value.selectedChoice?.value !=
                    "Discount")
                  _buildBonusSection(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSelectionSection(int index) {
    PromotionProgramInputState state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButton<String>(
          isExpanded: true,
          value: state.itemGroupInputPageDropdownState?.selectedChoice,
          hint: const Text(
            "Item/Item Group",
            style: TextStyle(fontSize: 16),
          ),
          items: state.itemGroupInputPageDropdownState?.choiceList
              ?.map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              inputPagePresenter.changeItemGroup(index, value);
            }
          },
          icon: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.arrow_drop_down),
          ),
        ),
        SearchChoices.single(
          isExpanded: true,
          value: state.selectProductPageDropdownState?.selectedChoice,
          hint: const Text(
            "Item Product",
            style: TextStyle(fontSize: 16),
          ),
          items: state.selectProductPageDropdownState?.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value),
                  ))
              .toList(),
          onChanged: (value) {
            inputPagePresenter.changeProduct(
                index, value as IdAndValue<String>);
          },
          dialogBox: true,
          displayClearIcon: false,
        ),
        const SizedBox(height: 12),
        SearchChoices.single(
          isExpanded: true,
          value: state.wareHousePageDropdownState?.selectedChoiceWrapper?.value,
          hint: const Text(
            "Warehouse",
            style: TextStyle(fontSize: 16),
          ),
          items: state.wareHousePageDropdownState?.choiceListWrapper?.value
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value),
                  ))
              .toList(),
          onChanged: (value) => inputPagePresenter.changeWarehouse(
              index, value as IdAndValue<String>),
          dialogBox: true,
          displayClearIcon: false,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuantitySection(int index) {
    PromotionProgramInputState state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quantity Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: state.qtyFrom,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Qty From",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state.qtyTo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Qty To",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SearchChoices.single(
          isExpanded: true,
          value: state.unitPageDropdownState?.selectedChoice,
          hint: const Text(
            "Unit",
            style: TextStyle(fontSize: 16),
          ),
          items: state.unitPageDropdownState?.choiceList
              ?.map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (value) =>
              inputPagePresenter.changeUnit(index, value as String),
          dialogBox: false,
          menuConstraints: BoxConstraints.tight(const Size.fromHeight(350)),
          displayClearIcon: false,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPricingSection(int index) {
    if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
            .selectedChoice?.value ==
        "Bonus") {
      return const SizedBox();
    }

    PromotionProgramInputState state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pricing Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SearchChoices.single(
          isExpanded: true,
          value: state.percentValueInputPageDropdownState?.selectedChoice,
          hint: const Text(
            "Discount Type",
            style: TextStyle(fontSize: 16),
          ),
          items: state.percentValueInputPageDropdownState?.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value),
                  ))
              .toList(),
          onChanged: (value) => inputPagePresenter.changePercentValue(
              index, value as IdAndValue<String>),
          dialogBox: false,
          menuConstraints: BoxConstraints.tight(const Size.fromHeight(350)),
          displayClearIcon: false,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: state.salesPrice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Sales Price",
                  prefixText: "Rp",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state.priceToCustomer,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Price to Customer",
                  prefixText: "Rp",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.percentValueInputPageDropdownState?.selectedChoice ==
            state.percentValueInputPageDropdownState?.choiceList![0])
          _buildPercentDiscountFields(index, state)
        else
          _buildValueDiscountFields(index, state),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPercentDiscountFields(
      int index, PromotionProgramInputState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: state.percent1,
                keyboardType: TextInputType.number,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                decoration: const InputDecoration(
                  labelText: "Disc-1 (%) Prb",
                  suffixText: "%",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state.percent2,
                keyboardType: TextInputType.number,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                decoration: const InputDecoration(
                  labelText: "Disc-2 (%) COD",
                  suffixText: "%",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: state.percent3,
                keyboardType: TextInputType.number,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                decoration: const InputDecoration(
                  labelText: "Disc-3 (%) Principal",
                  suffixText: "%",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state.percent4,
                keyboardType: TextInputType.number,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                decoration: const InputDecoration(
                  labelText: "Disc-4 (%) Principal",
                  suffixText: "%",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValueDiscountFields(
      int index, PromotionProgramInputState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: state.value1,
            keyboardType: TextInputType.number,
            onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
            decoration: const InputDecoration(
              labelText: "Value (PRB)",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: state.value2,
            keyboardType: TextInputType.number,
            onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
            decoration: const InputDecoration(
              labelText: "Value (Principal)",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBonusSection(int index) {
    PromotionProgramInputState state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bonus Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SearchChoices.single(
          isExpanded: true,
          value: state.supplyItem?.selectedChoice,
          hint: const Text(
            "Bonus Item",
            style: TextStyle(fontSize: 16),
          ),
          items: state.supplyItem?.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value),
                  ))
              .toList(),
          onChanged: (value) => inputPagePresenter.changeSupplyItem(
              index, value as IdAndValue<String>),
          dialogBox: false,
          menuConstraints: BoxConstraints.tight(const Size.fromHeight(350)),
          displayClearIcon: false,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: state.qtyItem,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Qty Item",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SearchChoices.single(
                isExpanded: true,
                value: state.unitSupplyItem?.selectedChoice,
                hint: const Text(
                  "Unit Bonus Item",
                  style: TextStyle(fontSize: 16),
                ),
                items: state.unitSupplyItem?.choiceList
                    ?.map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) => inputPagePresenter.changeUnitSupplyItem(
                    index, value as String),
                dialogBox: false,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350)),
                displayClearIcon: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      bool isAddItem, List<PromotionProgramInputState> stateList) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New Line"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccent,
              foregroundColor: colorNetral,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isAddItem ? () => inputPagePresenter.addItem() : null,
          ),
        ),
        Visibility(
          visible: !inputPagePresenter.onTap.value,
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _validateAndSubmit(stateList),
            ),
          ),
        ),
        Visibility(
          visible: inputPagePresenter.onTap.value,
          child: const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text("Processing submission..."),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _validateAndSubmit(List<PromotionProgramInputState> stateList) {
    bool isInvalid = false;
    for (int i = 0; i < stateList.length; i++) {
      PromotionProgramInputState element = stateList[i];
      if (element.selectProductPageDropdownState?.selectedChoice == null ||
          element.qtyFrom!.text.isEmpty ||
          element.unitPageDropdownState?.selectedChoice == null) {
        isInvalid = true;
        break;
      }
    }

    if (isInvalid) {
      inputPagePresenter.onTap.value = false;
      _showErrorSnackbar("Found empty required fields in one or more lines");
    } else {
      setState(() {
        inputPagePresenter.onTap.value = true;
      });
      inputPagePresenter.submitPromotionProgram(context);
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<InputPageController>()) {
      inputPagePresenter
          .promotionProgramInputStateRx.value.promotionProgramInputState
          .clear();
      inputPagePresenter.onTap.value = false;
    }

    super.dispose();
  }
}
