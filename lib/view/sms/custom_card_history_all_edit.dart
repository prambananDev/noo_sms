import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

Widget customCard(
  int index,
  InputPageController inputPagePresenter,
  BuildContext context,
) {
  return Obx(() {
    PromotionProgramInputState promotionProgramInputState = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    final basePadding = ResponsiveUtil.scaleSize(context, 12.0);
    final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);
    final sectionSpacing = ResponsiveUtil.scaleSize(context, 24.0);
    final cardMargin = EdgeInsets.only(
      top: ResponsiveUtil.scaleSize(context, 16.0),
      left: ResponsiveUtil.scaleSize(context, 16.0),
      right: ResponsiveUtil.scaleSize(context, 16.0),
      bottom: ResponsiveUtil.scaleSize(context, 4.0),
    );

    return Container(
      margin: cardMargin,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Add Lines",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.scaleSize(context, 16.0),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      inputPagePresenter.addItem();
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Add Item",
                    padding:
                        EdgeInsets.all(ResponsiveUtil.scaleSize(context, 8.0)),
                  ),
                  IconButton(
                    onPressed: () {
                      inputPagePresenter.removeItem(index);
                      inputPagePresenter.onTap.value = false;
                    },
                    icon: const Icon(Icons.delete),
                    tooltip: "Remove Item",
                    padding:
                        EdgeInsets.all(ResponsiveUtil.scaleSize(context, 8.0)),
                  ),
                ],
              ),
              SizedBox(height: itemSpacing),
              _buildResponsiveSearchChoices(
                context,
                null,
                "Item/Item Group",
                promotionProgramInputState
                    .itemGroupInputPageDropdownState?.selectedChoice,
                promotionProgramInputState
                    .itemGroupInputPageDropdownState?.choiceList
                    ?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                          fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                (value) => inputPagePresenter.changeItemGroup(index, value),
              ),
              SizedBox(height: itemSpacing),
              _buildSearchChoices<IdAndValue<String>>(
                context,
                "Item Product",
                promotionProgramInputState
                    .selectProductPageDropdownState?.selectedChoice,
                promotionProgramInputState
                    .selectProductPageDropdownState?.choiceList,
                (value) => inputPagePresenter.changeProduct(index, value),
              ),
              SizedBox(height: itemSpacing),
              _buildSearchChoices<IdAndValue<String>>(
                context,
                "Warehouse",
                promotionProgramInputState
                    .wareHousePageDropdownState?.selectedChoiceWrapper?.value,
                promotionProgramInputState
                    .wareHousePageDropdownState?.choiceListWrapper?.value,
                (value) => inputPagePresenter.changeWarehouse(index, value),
              ),
              SizedBox(height: itemSpacing),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      controller: promotionProgramInputState.qtyFrom,
                      labelText: "Qty From",
                    ),
                  ),
                  SizedBox(width: itemSpacing),
                  Expanded(
                    child: _buildTextField(
                      context,
                      controller: promotionProgramInputState.qtyTo,
                      labelText: "Qty To",
                    ),
                  ),
                ],
              ),
              SizedBox(height: itemSpacing),
              _buildResponsiveSearchChoices(
                context,
                null,
                "Unit",
                promotionProgramInputState
                    .unitPageDropdownState?.selectedChoice,
                promotionProgramInputState.unitPageDropdownState?.choiceList
                    ?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                          fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
                    ),
                  );
                }).toList(),
                (value) => inputPagePresenter.changeUnit(index, value),
              ),
              SizedBox(height: itemSpacing),
              if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                      .selectedChoice?.value !=
                  "Bonus") ...[
                _buildDiscountTypeSection(context, index,
                    promotionProgramInputState, inputPagePresenter),
              ],
              if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                      .selectedChoice?.value ==
                  "Bonus") ...[
                _buildBonusItemSection(context, index,
                    promotionProgramInputState, inputPagePresenter),
              ],
            ],
          ),
        ),
      ),
    );
  });
}

Widget _buildDiscountTypeSection(
  BuildContext context,
  int index,
  PromotionProgramInputState state,
  InputPageController inputPagePresenter,
) {
  final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownButtonFormField<IdAndValue<String>>(
        value: state.percentValueInputPageDropdownState?.selectedChoice,
        hint: Text(
          "Disc Type (percent/value)",
          style: TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: ResponsiveUtil.scaleSize(context, 8.0),
            horizontal: ResponsiveUtil.scaleSize(context, 12.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items:
            state.percentValueInputPageDropdownState?.choiceList?.map((item) {
          return DropdownMenuItem<IdAndValue<String>>(
            value: item,
            child: Text(
              item.value,
              style:
                  TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
            ),
          );
        }).toList(),
        onChanged: (value) {
          inputPagePresenter.changePercentValue(index, value!);
        },
      ),
      SizedBox(height: itemSpacing),
      if (state.percentValueInputPageDropdownState?.selectedChoice ==
          state.percentValueInputPageDropdownState?.choiceList![1])
        _buildValueDiscountUI(context, state, index, inputPagePresenter)
      else
        _buildPercentDiscountUI(context, state, index, inputPagePresenter),
    ],
  );
}

Widget _buildValueDiscountUI(
  BuildContext context,
  PromotionProgramInputState state,
  int index,
  InputPageController inputPagePresenter,
) {
  final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);

  return Column(
    children: [
      _buildPriceRow(context, state),
      SizedBox(height: itemSpacing),
      Row(
        children: [
          Expanded(
            child: _buildMoneyTextField(
              context,
              controller: state.value1,
              labelText: 'Value (PRB)',
              prefix: null,
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
          SizedBox(width: itemSpacing),
          Expanded(
            child: _buildMoneyTextField(
              context,
              controller: state.value2,
              labelText: 'Value (Principal)',
              prefix: null,
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildPercentDiscountUI(
  BuildContext context,
  PromotionProgramInputState state,
  int index,
  InputPageController inputPagePresenter,
) {
  final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);

  return Column(
    children: [
      _buildPriceRow(context, state),
      SizedBox(height: itemSpacing),
      Row(
        children: [
          Expanded(
            child: _buildPercentTextField(
              context,
              controller: state.percent1,
              labelText: 'Disc-1 (%) Prb',
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
          SizedBox(width: itemSpacing),
          Expanded(
            child: _buildPercentTextField(
              context,
              controller: state.percent2,
              labelText: 'Disc-2 (%) COD',
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
        ],
      ),
      SizedBox(height: itemSpacing),
      Row(
        children: [
          Expanded(
            child: _buildPercentTextField(
              context,
              controller: state.percent3,
              labelText: 'Disc-3 (%) Principal',
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
          SizedBox(width: itemSpacing),
          Expanded(
            child: _buildPercentTextField(
              context,
              controller: state.percent4,
              labelText: 'Disc-4 (%) Principal',
              onChanged: (value) =>
                  inputPagePresenter.getPriceToCustomer(index),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildPriceRow(BuildContext context, PromotionProgramInputState state) {
  final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);

  return Row(
    children: [
      Expanded(
        child: _buildMoneyTextField(
          context,
          controller: state.salesPrice,
          labelText: 'Sales Price',
          prefix: "Rp",
        ),
      ),
      SizedBox(width: itemSpacing),
      Expanded(
        child: _buildMoneyTextField(
          context,
          controller: state.priceToCustomer,
          labelText: 'Price to Customer',
          prefix: "Rp",
          readOnly: true,
        ),
      ),
    ],
  );
}

Widget _buildBonusItemSection(
  BuildContext context,
  int index,
  PromotionProgramInputState state,
  InputPageController inputPagePresenter,
) {
  final itemSpacing = ResponsiveUtil.scaleSize(context, 16.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildResponsiveSearchChoices(
        context,
        null,
        "Bonus Item",
        state.supplyItem?.selectedChoice,
        state.supplyItem?.choiceList?.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item.value,
              style:
                  TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        (value) => inputPagePresenter.changeSupplyItem(index, value),
      ),
      SizedBox(height: itemSpacing),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaleSize(context, 100.0),
            child: _buildTextField(
              context,
              controller: state.qtyItem,
              labelText: 'Qty Item',
            ),
          ),
          SizedBox(width: itemSpacing),
          Expanded(
            child: _buildResponsiveSearchChoices(
              context,
              null,
              "Unit Bonus Item",
              state.unitSupplyItem?.selectedChoice,
              state.unitSupplyItem?.choiceList?.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
                  ),
                );
              }).toList(),
              (value) => inputPagePresenter.changeUnitSupplyItem(index, value),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildSearchChoices<T extends IdAndValue<String>>(
  BuildContext context,
  String label,
  T? selectedValue,
  List<T>? items,
  Function(T) onChanged,
) {
  return _buildResponsiveSearchChoices(
    context,
    label,
    label,
    selectedValue,
    items?.map((item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(
          item.value,
          style: TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
    (value) => onChanged(value),
  );
}

Widget _buildResponsiveSearchChoices<T>(
  BuildContext context,
  String? floatingLabel,
  String hintText,
  T? selectedValue,
  List<DropdownMenuItem<T>>? items,
  Function(T) onChanged,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: ResponsiveUtil.scaleSize(context, 8.0),
      vertical: ResponsiveUtil.scaleSize(context, 4.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (floatingLabel != null)
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveUtil.scaleSize(context, 4.0),
              top: ResponsiveUtil.scaleSize(context, 4.0),
            ),
            child: Text(
              floatingLabel,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 12.0),
                color: Colors.grey.shade600,
              ),
            ),
          ),
        SearchChoices.single(
          isExpanded: true,
          value: selectedValue,
          items: items,
          onChanged: onChanged,
          hint: Text(
            hintText,
            style: TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 14.0)),
          ),
          searchHint: "Search $hintText",
          underline: Container(),
          displayClearIcon: true,
          dialogBox: true,
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );
}

Widget _buildTextField(
  BuildContext context, {
  required TextEditingController? controller,
  required String labelText,
  bool readOnly = false,
  ValueChanged<String>? onChanged,
}) {
  return TextFormField(
    keyboardType: TextInputType.number,
    controller: controller,
    readOnly: readOnly,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: ResponsiveUtil.scaleSize(context, 14.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.scaleSize(context, 8.0),
        horizontal: ResponsiveUtil.scaleSize(context, 12.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    ),
    style: TextStyle(
      color: Colors.black87,
      fontSize: ResponsiveUtil.scaleSize(context, 14.0),
    ),
  );
}

Widget _buildPercentTextField(
  BuildContext context, {
  required TextEditingController? controller,
  required String labelText,
  ValueChanged<String>? onChanged,
}) {
  return TextFormField(
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: labelText,
      suffixText: "%",
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: ResponsiveUtil.scaleSize(context, 14.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.scaleSize(context, 8.0),
        horizontal: ResponsiveUtil.scaleSize(context, 12.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    ),
    style: TextStyle(
      color: Colors.black87,
      fontSize: ResponsiveUtil.scaleSize(context, 14.0),
    ),
  );
}

Widget _buildMoneyTextField(
  BuildContext context, {
  required TextEditingController? controller,
  required String labelText,
  String? prefix,
  bool readOnly = false,
  ValueChanged<String>? onChanged,
}) {
  return TextFormField(
    keyboardType: TextInputType.number,
    controller: controller,
    readOnly: readOnly,
    onChanged: onChanged,
    inputFormatters: [
      CustomMoneyInputFormatter(
        thousandSeparator: ".",
        decimalSeparator: ",",
      ),
    ],
    decoration: InputDecoration(
      labelText: labelText,
      prefixText: prefix,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: ResponsiveUtil.scaleSize(context, 14.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.scaleSize(context, 8.0),
        horizontal: ResponsiveUtil.scaleSize(context, 12.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    ),
    style: TextStyle(
      color: Colors.black87,
      fontSize: ResponsiveUtil.scaleSize(context, 14.0),
    ),
  );
}
