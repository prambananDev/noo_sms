import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';
import 'dart:math' as math;

class InputPagePP extends StatefulWidget {
  final bool isEdit;
  final String? programNumber;

  const InputPagePP({
    Key? key,
    this.isEdit = false,
    this.programNumber,
  }) : super(key: key);

  @override
  State<InputPagePP> createState() => _InputPagePPState();
}

class _InputPagePPState extends State<InputPagePP> {
  final InputPageController inputPagePresenter = Get.put(InputPageController());
  final ScrollController _scrollController = ScrollController();
  final FocusNode noteFocusNode = FocusNode();
  bool isNoteTapped = false;
  double noteFieldHeight = 10.0;

  final double _baseLabelSize = 16.0;
  final double _baseTextSize = 16.0;
  final double _baseHeadingSize = 18.0;
  final double _baseIconSize = 24.0;
  final double _basePadding = 16.0;
  final double _baseSpacing = 20.0;
  final double _baseBorderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadEditData();
    }
  }

  void _scrollToFocusedField(BuildContext? fieldContext) {
    if (fieldContext == null) return;

    final RenderObject? renderObject = fieldContext.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderObject);
    final RevealedOffset offset = viewport.getOffsetToReveal(renderObject, 0.0);

    final keyboardHeight = MediaQuery.of(fieldContext).viewInsets.bottom;
    final targetOffset = offset.offset -
        _scrollController.position.viewportDimension / 2 +
        renderObject.paintBounds.height +
        keyboardHeight * 0.5;

    if (targetOffset > _scrollController.position.pixels ||
        targetOffset <
            _scrollController.position.pixels -
                renderObject.paintBounds.height) {
      _scrollController.animateTo(
        math.max(0, targetOffset),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
  }

  Future<void> _loadEditData() async {
    if (widget.programNumber != null) {
      await inputPagePresenter.loadProgramData(widget.programNumber!);
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - 500,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  double get scaledLabelSize =>
      ResponsiveUtil.scaleSize(context, _baseLabelSize);
  double get scaledTextSize => ResponsiveUtil.scaleSize(context, _baseTextSize);
  double get scaledHeadingSize =>
      ResponsiveUtil.scaleSize(context, _baseHeadingSize);
  double get scaledIconSize => ResponsiveUtil.scaleSize(context, _baseIconSize);
  double get scaledPadding => ResponsiveUtil.scaleSize(context, _basePadding);
  double get scaledSpacing => ResponsiveUtil.scaleSize(context, _baseSpacing);
  double get scaledBorderRadius =>
      ResponsiveUtil.scaleSize(context, _baseBorderRadius);

  bool get isSmallScreen =>
      MediaQuery.of(context).size.width < ResponsiveUtil.tabletBreakpoint;
  bool get isMobileScreen =>
      MediaQuery.of(context).size.width < ResponsiveUtil.mobileBreakpoint;

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(scaledPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaledBorderRadius),
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
          Text(
            "Create",
            style: TextStyle(
                fontSize: scaledHeadingSize, fontWeight: FontWeight.bold),
          ),
          Text(
            "Setup a trade agreement",
            style: TextStyle(fontSize: scaledTextSize, color: Colors.black54),
          ),
          SizedBox(height: scaledSpacing),
          _buildProgramNameField(),
          _buildPromotionTypeDropdown(),
          _buildCustomerGroupDropdown(),
          _buildPrincipalSelection(),
          _buildDateFields(),
          _buildNoteField(),
        ],
      ),
    );
  }

  Widget _buildProgramNameField() {
    return Obx(() => TextFormField(
          controller:
              inputPagePresenter.programNameTextEditingControllerRx.value,
          onChanged: (value) => inputPagePresenter.checkAddItemStatus(),
          decoration: InputDecoration(
            labelText: 'Program Name',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: scaledLabelSize,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorAccent),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: scaledTextSize,
          ),
        ));
  }

  Widget _buildPromotionTypeDropdown() {
    return Obx(() => DropdownButtonFormField<IdAndValue<String>>(
          value: inputPagePresenter
              .promotionTypeInputPageDropdownStateRx.value.selectedChoice,
          hint: Text("Type", style: TextStyle(fontSize: scaledTextSize)),
          items: inputPagePresenter
              .promotionTypeInputPageDropdownStateRx.value.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value,
                        style: TextStyle(fontSize: scaledTextSize)),
                  ))
              .toList(),
          onChanged: (value) => inputPagePresenter.changePromotionType(value!),
        ));
  }

  Widget _buildCustomerGroupDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          isExpanded: true,
          isDense: true,
          value: inputPagePresenter
              .customerGroupInputPageDropdownState.value.selectedChoice,
          hint: Text(
            "Customer/Cust Group",
            style: TextStyle(fontSize: scaledTextSize),
          ),
          items: inputPagePresenter
              .customerGroupInputPageDropdownState.value.choiceList
              ?.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: scaledTextSize),
                      overflow: TextOverflow.fade,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              inputPagePresenter.changeCustomerGroupHeader(value!);
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {});
              });
            });
          },
        ));
  }

  Widget _buildPrincipalSelection() {
    return Obx(
      () => SearchChoices.single(
        clearSearchIcon: Icon(Icons.clear_all, size: scaledIconSize),
        padding: EdgeInsets.only(top: scaledPadding / 2),
        isExpanded: true,
        value: inputPagePresenter.selectedDataPrincipal.isNotEmpty
            ? inputPagePresenter
                .listDataPrincipal[inputPagePresenter.selectedDataPrincipal[0]]
            : null,
        hint: Text(
          "Select Principal",
          style: TextStyle(fontSize: scaledTextSize),
        ),
        items: inputPagePresenter.listDataPrincipal.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item.toString(),
                style: TextStyle(fontSize: scaledTextSize)),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            final index = inputPagePresenter.listDataPrincipal.indexOf(value);
            inputPagePresenter.selectedDataPrincipal.clear();
            if (index >= 0) {
              inputPagePresenter.selectedDataPrincipal.add(index);
            }
          }
        },
      ),
    );
  }

  Widget _buildDateFields() {
    return isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDatePickerField(
                controller: inputPagePresenter
                    .programFromDateTextEditingControllerRx.value,
                labelText: 'From Date',
                initialValue: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 180)),
              ),
              SizedBox(height: scaledSpacing / 2),
              CustomDatePickerField(
                controller: inputPagePresenter
                    .programToDateTextEditingControllerRx.value,
                labelText: 'To Date',
                initialValue: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 180)),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: CustomDatePickerField(
                  controller: inputPagePresenter
                      .programFromDateTextEditingControllerRx.value,
                  labelText: 'From Date',
                  initialValue: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                ),
              ),
              SizedBox(
                width: 150,
                child: CustomDatePickerField(
                  controller: inputPagePresenter
                      .programToDateTextEditingControllerRx.value,
                  labelText: 'To Date',
                  initialValue: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                ),
              ),
            ],
          );
  }

  Widget _buildNoteField() {
    return Obx(() => TextFormField(
          maxLines: isNoteTapped ? 5 : 1,
          controller:
              inputPagePresenter.programNoteTextEditingControllerRx.value,
          onTapOutside: (_) {
            noteFocusNode.unfocus();
            setState(() {
              isNoteTapped = false;
              noteFieldHeight = 10.0;
            });
          },
          onChanged: (value) {},
          decoration: InputDecoration(
            labelText: 'Note',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: scaledTextSize,
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: scaledTextSize,
          ),
        ));
  }

  Widget _buildCustomerFields(PromotionProgramInputState state, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          isDense: true,
          value: state.customerGroupInputPageDropdownState!.selectedChoice,
          hint: Text(
            "Customer/Cust Group",
            style: TextStyle(fontSize: scaledTextSize),
          ),
          items: state.customerGroupInputPageDropdownState!.choiceList!
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: scaledTextSize),
                      overflow: TextOverflow.fade,
                    ),
                  ))
              .toList(),
          onChanged: (value) =>
              inputPagePresenter.changeCustomerGroup(index, value),
        ),
        SizedBox(height: scaledSpacing),
        Obx(
          () => SearchChoices.single(
            isExpanded: true,
            padding: EdgeInsets.only(top: scaledPadding / 2),
            value: inputPagePresenter
                .custNameHeaderValueDropdownStateRx.value.selectedChoice,
            items: inputPagePresenter
                .custNameHeaderValueDropdownStateRx.value.choiceList
                ?.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.value,
                          style: TextStyle(fontSize: scaledTextSize)),
                    ))
                .toList(),
            hint: Text(
              "Select Customer",
              style: TextStyle(fontSize: scaledTextSize),
            ),
            onChanged: (value) {
              setState(() {
                inputPagePresenter
                    .changeCustomerNameOrDiscountGroupHeader(value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemFields(PromotionProgramInputState state, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          hint: Text(
            "Select Item Group",
            style: TextStyle(fontSize: scaledTextSize),
          ),
          isExpanded: true,
          value: state.itemGroupInputPageDropdownState?.selectedChoice,
          items: state.itemGroupInputPageDropdownState!.choiceList!
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: scaledTextSize)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              inputPagePresenter.changeItemGroup(index, newValue!);
            });
          },
        ),
        SizedBox(height: scaledSpacing / 2),
        SearchChoices.single(
          isExpanded: true,
          value: state.supplyItem?.selectedChoice,
          items: state.supplyItem?.choiceList?.map((item) {
            return DropdownMenuItem(
                value: item,
                child: Text(item.value,
                    style: TextStyle(fontSize: scaledTextSize)));
          }).toList(),
          hint: Text(
            "Select Product",
            style: TextStyle(fontSize: scaledTextSize),
          ),
          onChanged: (value) {
            inputPagePresenter.changeSupplyItem(index, value);
          },
        ),
        SearchChoices.single(
          isExpanded: true,
          value:
              state.wareHousePageDropdownState?.selectedChoiceWrapper?.value ??
                  "WHS - Tunas - Buffer",
          hint: Text(
            "WHS - Tunas - Buffer",
            style: TextStyle(
                fontSize: scaledTextSize, fontWeight: FontWeight.w500),
          ),
          items: state.wareHousePageDropdownState?.choiceListWrapper?.value
              ?.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.value,
                style: TextStyle(fontSize: scaledTextSize),
                overflow: TextOverflow.fade,
              ),
            );
          }).toList(),
          onChanged: (value) =>
              inputPagePresenter.changeWarehouse(index, value),
        ),
      ],
    );
  }

  Widget _buildQuantityFields(PromotionProgramInputState state, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: state.qtyFrom,
                decoration: InputDecoration(
                  labelText: 'Qty From',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: scaledLabelSize,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: scaledPadding),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: scaledTextSize,
                ),
              ),
            ),
            SizedBox(width: scaledSpacing),
            Expanded(
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: state.qtyTo,
                decoration: InputDecoration(
                  labelText: 'Qty To',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: scaledLabelSize,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: scaledPadding),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: scaledTextSize,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SearchChoices.single(
                underline: Container(),
                isExpanded: true,
                value: state.unitSupplyItem?.selectedChoice,
                hint: Text(
                  "Unit",
                  style: TextStyle(fontSize: scaledTextSize),
                ),
                items: state.unitSupplyItem?.choiceList?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child:
                        Text(item, style: TextStyle(fontSize: scaledTextSize)),
                  );
                }).toList(),
                onChanged: (value) =>
                    inputPagePresenter.changeUnitSupplyItem(index, value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineItemCard(int index) {
    final state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Container(
      margin: EdgeInsets.only(top: scaledSpacing / 2),
      padding: EdgeInsets.all(scaledPadding),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(scaledBorderRadius),
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
          _buildLineItemHeader(index),
          SizedBox(height: scaledSpacing),
          _buildCustomerFields(state, index),
          SizedBox(height: scaledSpacing),
          _buildItemFields(state, index),
          _buildQuantityFields(state, index),
          SizedBox(height: scaledSpacing),
          if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                  .selectedChoice?.value !=
              "Bonus")
            _buildDiscountFields(state, index),
          SizedBox(height: scaledSpacing),
          if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                  .selectedChoice?.value !=
              "Discount")
            _buildBonusFields(state, index),
        ],
      ),
    );
  }

  Widget _buildLineItemHeader(int index) {
    return Row(
      children: [
        Text(
          "Add Lines",
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: scaledTextSize),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            inputPagePresenter.addItem();
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          },
          icon: Icon(Icons.add, size: scaledIconSize),
        ),
        IconButton(
          onPressed: () {
            inputPagePresenter.removeItem(index);
            inputPagePresenter.onTap.value = false;
          },
          icon: Icon(Icons.delete, size: scaledIconSize),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    List<PromotionProgramInputState> promotionProgramInputStateList,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtil.scaleSize(context, 500)),
      child: Obx(
        () => inputPagePresenter.onTap.value
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  minimumSize: Size(
                      double.infinity, ResponsiveUtil.scaleSize(context, 50)),
                ),
                onPressed: () =>
                    inputPagePresenter.submitPromotionProgram(context),
                child: Text(
                  "Submit",
                  style:
                      TextStyle(color: colorNetral, fontSize: scaledTextSize),
                ),
              ),
      ),
    );
  }

  Widget _buildLineItem(
    int index,
    List<PromotionProgramInputState> promotionProgramInputStateList,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildLineItemCard(index),
          SizedBox(height: scaledSpacing / 2),
          if (index == promotionProgramInputStateList.length - 1)
            _buildSubmitButton(promotionProgramInputStateList),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    return Obx(() {
      final inputPageWrapper =
          inputPagePresenter.promotionProgramInputStateRx.value;
      final promotionProgramInputStateList =
          inputPageWrapper.promotionProgramInputState;
      final isAddItem = inputPageWrapper.isAddItem;

      if (promotionProgramInputStateList.isEmpty) {
        return Container(
          margin: EdgeInsets.only(bottom: scaledSpacing * 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorAccent),
            onPressed: isAddItem
                ? () {
                    inputPagePresenter.addItem();
                  }
                : null,
            child: Text(
              "Add Lines",
              style: TextStyle(color: colorNetral, fontSize: scaledTextSize),
            ),
          ),
        );
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: promotionProgramInputStateList.length,
        itemBuilder: (context, index) => _buildLineItem(
          index,
          promotionProgramInputStateList,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(scaledPadding),
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeaderCard(),
                SizedBox(height: scaledSpacing / 2),
                _buildLineItems(),
                SizedBox(height: noteFieldHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBonusFields(PromotionProgramInputState state, int index) {
    if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
            .selectedChoice?.value ==
        "Discount") {
      return const SizedBox();
    }

    return Column(
      children: [
        SearchChoices.single(
          isExpanded: true,
          value: state.supplyItem?.selectedChoice,
          hint: Text(
            "Bonus Item",
            style: TextStyle(fontSize: scaledTextSize),
          ),
          items: state.supplyItem?.choiceList?.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.value,
                style: TextStyle(fontSize: scaledTextSize),
                overflow: TextOverflow.fade,
              ),
            );
          }).toList(),
          onChanged: (value) =>
              inputPagePresenter.changeSupplyItem(index, value),
        ),
        isMobileScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.qtyItem,
                    decoration: InputDecoration(
                      labelText: 'Qty Item',
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing / 2),
                  SearchChoices.single(
                    isExpanded: true,
                    value: state.unitSupplyItem?.selectedChoice,
                    hint: Text(
                      "Unit Bonus Item",
                      style: TextStyle(fontSize: scaledTextSize),
                    ),
                    items: state.unitSupplyItem?.choiceList?.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: TextStyle(fontSize: scaledTextSize)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        inputPagePresenter.changeUnitSupplyItem(index, value),
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: ResponsiveUtil.scaleSize(context, 50),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.qtyItem,
                      decoration: InputDecoration(
                        labelText: 'Qty Item',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: ResponsiveUtil.scaleSize(context, 120),
                    child: SearchChoices.single(
                      isExpanded: true,
                      value: state.unitSupplyItem?.selectedChoice,
                      hint: Text(
                        "Unit Bonus Item",
                        style: TextStyle(fontSize: scaledTextSize),
                      ),
                      items: state.unitSupplyItem?.choiceList?.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item,
                              style: TextStyle(fontSize: scaledTextSize)),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          inputPagePresenter.changeUnitSupplyItem(index, value),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildDiscountFields(PromotionProgramInputState state, int index) {
    if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
            .selectedChoice?.value ==
        "Bonus") {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<IdAndValue<String>>(
                value: state.percentValueInputPageDropdownState?.selectedChoice,
                hint: Text(
                  "Disc Type (percent/value)",
                  style: TextStyle(fontSize: scaledTextSize),
                ),
                items: state.percentValueInputPageDropdownState?.choiceList
                    ?.map((item) {
                  return DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(
                      item.value,
                      style: TextStyle(fontSize: scaledTextSize),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  inputPagePresenter.changePercentValue(index, value!);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: scaledSpacing),
        if (state.percentValueInputPageDropdownState?.selectedChoice ==
            state.percentValueInputPageDropdownState?.choiceList![1])
          _buildValueBasedDiscount(state, index)
        else
          _buildPercentageBasedDiscount(state, index),
        SizedBox(height: scaledSpacing),
      ],
    );
  }

  Widget _buildValueBasedDiscount(PromotionProgramInputState state, int index) {
    return Column(
      children: [
        isMobileScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.salesPrice,
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Sales Price',
                      prefixText: "Rp",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.priceToCustomer,
                    readOnly: true,
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Price to Customer',
                      prefixText: "Rp",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.salesPrice,
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Sales Price',
                        prefixText: "Rp",
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                  SizedBox(width: scaledSpacing),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.priceToCustomer,
                      readOnly: true,
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Price to Customer',
                        prefixText: "Rp",
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                ],
              ),
        isMobileScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.value1,
                    onChanged: (_) =>
                        inputPagePresenter.getPriceToCustomer(index),
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Value(PRB)',
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing / 2),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.value2,
                    onChanged: (_) =>
                        inputPagePresenter.getPriceToCustomer(index),
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Value(Principal)',
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.value1,
                      onChanged: (_) =>
                          inputPagePresenter.getPriceToCustomer(index),
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Value(PRB)',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                  SizedBox(width: scaledSpacing),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.value2,
                      onChanged: (_) =>
                          inputPagePresenter.getPriceToCustomer(index),
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Value(Principal)',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildPercentageBasedDiscount(
      PromotionProgramInputState state, int index) {
    return Column(
      children: [
        isMobileScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.salesPrice,
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Sales Price',
                      prefixText: "Rp",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing / 2),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.priceToCustomer,
                    readOnly: true,
                    inputFormatters: [
                      CustomMoneyInputFormatter(
                        thousandSeparator: ".",
                        decimalSeparator: ",",
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Price to Customer',
                      prefixText: "Rp",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.salesPrice,
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Sales Price',
                        prefixText: "Rp",
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                  SizedBox(width: scaledSpacing),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: state.priceToCustomer,
                      readOnly: true,
                      inputFormatters: [
                        CustomMoneyInputFormatter(
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Price to Customer',
                        prefixText: "Rp",
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: scaledLabelSize,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledTextSize,
                      ),
                    ),
                  ),
                ],
              ),
        isMobileScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.percent1,
                    onChanged: (_) => setState(() {
                      inputPagePresenter.getPriceToCustomer(index);
                    }),
                    decoration: InputDecoration(
                      suffixText: "%",
                      labelText: 'Disc-1 (%) Prb',
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.percent2,
                    onChanged: (_) => setState(() {
                      inputPagePresenter.getPriceToCustomer(index);
                    }),
                    decoration: InputDecoration(
                      labelText: 'Disc-2 (%) COD',
                      suffixText: "%",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing / 2),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.percent3,
                    onChanged: (_) => setState(() {
                      inputPagePresenter.getPriceToCustomer(index);
                    }),
                    decoration: InputDecoration(
                      labelText: 'Disc-3 (%) Principal',
                      suffixText: "%",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                  SizedBox(height: scaledSpacing / 2),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: state.percent4,
                    onChanged: (_) => setState(() {
                      inputPagePresenter.getPriceToCustomer(index);
                    }),
                    decoration: InputDecoration(
                      labelText: 'Disc-4 (%) Principal',
                      suffixText: "%",
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: scaledLabelSize,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaledTextSize,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: state.percent1,
                          onChanged: (_) => setState(() {
                            inputPagePresenter.getPriceToCustomer(index);
                          }),
                          decoration: InputDecoration(
                            suffixText: "%",
                            labelText: 'Disc-1 (%) Prb',
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: scaledLabelSize,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: scaledTextSize,
                          ),
                        ),
                      ),
                      SizedBox(width: scaledSpacing),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: state.percent2,
                          onChanged: (_) => setState(() {
                            inputPagePresenter.getPriceToCustomer(index);
                          }),
                          decoration: InputDecoration(
                            labelText: 'Disc-2 (%) COD',
                            suffixText: "%",
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: scaledLabelSize,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: scaledTextSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: state.percent3,
                          onChanged: (_) => setState(() {
                            inputPagePresenter.getPriceToCustomer(index);
                          }),
                          decoration: InputDecoration(
                            labelText: 'Disc-3 (%) Principal',
                            suffixText: "%",
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: scaledLabelSize,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: scaledTextSize,
                          ),
                        ),
                      ),
                      SizedBox(width: scaledSpacing),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: state.percent4,
                          onChanged: (_) => setState(() {
                            inputPagePresenter.getPriceToCustomer(index);
                          }),
                          decoration: InputDecoration(
                            labelText: 'Disc-4 (%) Principal',
                            suffixText: "%",
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: scaledLabelSize,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: scaledTextSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
