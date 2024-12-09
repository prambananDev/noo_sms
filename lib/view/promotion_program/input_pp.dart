import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadEditData();
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

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create"),
              const SizedBox(height: 5),
              const Text(
                "Setup a trade agreement",
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              _buildProgramNameField(),
              _buildPromotionTypeDropdown(),
              _buildCustomerGroupDropdown(),
              _buildPrincipalSelection(),
              _buildDateFields(),
              _buildNoteField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramNameField() {
    return Obx(() => TextFormField(
          controller:
              inputPagePresenter.programNameTextEditingControllerRx.value,
          onChanged: (value) => inputPagePresenter.checkAddItemStatus(),
          decoration: const InputDecoration(
            labelText: 'Program Name',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontFamily: 'AvenirLight',
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontFamily: 'AvenirLight',
          ),
        ));
  }

  Widget _buildPromotionTypeDropdown() {
    return Obx(() => DropdownButtonFormField<IdAndValue<String>>(
          value: inputPagePresenter
              .promotionTypeInputPageDropdownStateRx.value.selectedChoice,
          hint: const Text("Type", style: TextStyle(fontSize: 12)),
          items: inputPagePresenter
              .promotionTypeInputPageDropdownStateRx.value.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(item.value),
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
          hint: const Text(
            "Customer/Cust Group",
            style: TextStyle(fontSize: 12),
          ),
          items: inputPagePresenter
              .customerGroupInputPageDropdownState.value.choiceList
              ?.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12),
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
    return Obx(() => SearchChoices.single(
          clearSearchIcon: const Icon(Icons.clear_all),
          padding: const EdgeInsets.only(top: 8),
          isExpanded: true,
          value: inputPagePresenter.selectedDataPrincipal.isNotEmpty
              ? inputPagePresenter.listDataPrincipal[
                  inputPagePresenter.selectedDataPrincipal[0]]
              : null,
          hint: const Text(
            "Select Principal",
            style: TextStyle(fontSize: 12),
          ),
          items: inputPagePresenter.listDataPrincipal.map((item) {
            return DropdownMenuItem<String>(
              value: item.toString(),
              child: Text(item.toString()),
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
        ));
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomDatePickerField(
              controller: inputPagePresenter
                  .programFromDateTextEditingControllerRx.value,
              labelText: 'From Date',
              initialValue: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 180)),
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomDatePickerField(
              controller:
                  inputPagePresenter.programToDateTextEditingControllerRx.value,
              labelText: 'To Date',
              initialValue: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 180)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Obx(() => TextFormField(
          maxLines: 1,
          controller:
              inputPagePresenter.programNoteTextEditingControllerRx.value,
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            setState(() {
              isNoteTapped = true;
              noteFieldHeight = 200.0;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Note',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontFamily: 'AvenirLight',
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontFamily: 'AvenirLight',
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
          hint: const Text(
            "Customer/Cust Group",
            style: TextStyle(fontSize: 12),
          ),
          items: state.customerGroupInputPageDropdownState!.choiceList!
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.fade,
                    ),
                  ))
              .toList(),
          onChanged: (value) =>
              inputPagePresenter.changeCustomerGroup(index, value),
        ),
        const SizedBox(height: 20),
        Obx(
          () => SearchChoices.single(
            isExpanded: true,
            padding: const EdgeInsets.only(top: 8),
            value: inputPagePresenter
                .custNameHeaderValueDropdownStateRx.value.selectedChoice,
            items: inputPagePresenter
                .custNameHeaderValueDropdownStateRx.value.choiceList
                ?.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.value,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            hint: const Text(
              "Select Customer",
              style: TextStyle(fontSize: 12),
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
          hint: const Text(
            "Select Item Group",
            style: TextStyle(fontSize: 12),
          ),
          isExpanded: true,
          value: state.itemGroupInputPageDropdownState?.selectedChoice,
          items: state.itemGroupInputPageDropdownState!.choiceList!
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              inputPagePresenter.changeItemGroup(index, newValue!);
            });
          },
        ),
        const SizedBox(height: 8),
        const Text(
          "Item Product",
          style: TextStyle(fontSize: 10, color: Colors.black54),
        ),
        SearchChoices.single(
          isExpanded: true,
          value: state.selectProductPageDropdownState?.selectedChoice,
          items: state.selectProductPageDropdownState?.choiceList?.map((item) {
            return DropdownMenuItem(value: item, child: Text(item.value));
          }).toList(),
          hint: const Text(
            "Select Product",
            style: TextStyle(fontSize: 12),
          ),
          onChanged: (value) {
            inputPagePresenter.changeProduct(index, value);
          },
        ),
        const Text(
          "Warehouse",
          style: TextStyle(fontSize: 10, color: Colors.black54),
        ),
        SearchChoices.single(
          isExpanded: true,
          value:
              state.wareHousePageDropdownState?.selectedChoiceWrapper?.value ??
                  "WHS - Tunas - Buffer",
          hint: const Text(
            "WHS - Tunas - Buffer",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          items: state.wareHousePageDropdownState?.choiceListWrapper?.value
              ?.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.value,
                style: const TextStyle(fontSize: 12),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: state.qtyFrom,
            decoration: const InputDecoration(
              labelText: 'Qty From',
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontFamily: 'AvenirLight',
              ),
              contentPadding: EdgeInsets.only(bottom: 20),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontFamily: 'AvenirLight',
            ),
          ),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 50,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: state.qtyTo,
            decoration: const InputDecoration(
              labelText: 'Qty To',
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontFamily: 'AvenirLight',
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 20),
            ),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontFamily: 'AvenirLight',
            ),
          ),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 140,
          height: 68,
          child: SearchChoices.single(
            isExpanded: true,
            value: state.unitPageDropdownState?.selectedChoice,
            hint: const Text(
              "Unit",
              style: TextStyle(fontSize: 12),
            ),
            items: state.unitPageDropdownState?.choiceList?.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) => inputPagePresenter.changeUnit(index, value),
          ),
        ),
      ],
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
          hint: const Text(
            "Bonus Item",
            style: TextStyle(fontSize: 12),
          ),
          items: state.supplyItem?.choiceList?.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.value,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.fade,
              ),
            );
          }).toList(),
          onChanged: (value) =>
              inputPagePresenter.changeSupplyItem(index, value),
        ),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: state.qtyItem,
                decoration: const InputDecoration(
                  labelText: 'Qty Item',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: SearchChoices.single(
                isExpanded: true,
                value: state.unitSupplyItem?.selectedChoice,
                hint: const Text(
                  "Unit Bonus Item",
                  style: TextStyle(fontSize: 12),
                ),
                items: state.unitSupplyItem?.choiceList?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
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
                hint: const Text(
                  "Disc Type (percent/value)",
                  style: TextStyle(fontSize: 12),
                ),
                items: state.percentValueInputPageDropdownState?.choiceList
                    ?.map((item) {
                  return DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(
                      item.value,
                      style: const TextStyle(fontSize: 12),
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
        if (state.percentValueInputPageDropdownState?.selectedChoice ==
            state.percentValueInputPageDropdownState?.choiceList![1])
          _buildValueBasedDiscount(state, index)
        else
          _buildPercentageBasedDiscount(state, index),
      ],
    );
  }

  Widget _buildValueBasedDiscount(PromotionProgramInputState state, int index) {
    return Column(
      children: [
        Row(
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
                decoration: const InputDecoration(
                  labelText: 'Sales Price',
                  prefixText: "Rp",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const SizedBox(width: 20),
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
                decoration: const InputDecoration(
                  labelText: 'Price to Customer',
                  prefixText: "Rp",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: state.value1,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                inputFormatters: [
                  CustomMoneyInputFormatter(
                    thousandSeparator: ".",
                    decimalSeparator: ",",
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'Value(PRB)',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: state.value2,
                onChanged: (_) => inputPagePresenter.getPriceToCustomer(index),
                inputFormatters: [
                  CustomMoneyInputFormatter(
                    thousandSeparator: ".",
                    decimalSeparator: ",",
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'Value(Principal)',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
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
        Row(
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
                decoration: const InputDecoration(
                  labelText: 'Sales Price',
                  prefixText: "Rp",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const SizedBox(width: 20),
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
                decoration: const InputDecoration(
                  labelText: 'Price to Customer',
                  prefixText: "Rp",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
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
                controller: state.percent1,
                onChanged: (_) => setState(() {
                  inputPagePresenter.getPriceToCustomer(index);
                }),
                decoration: const InputDecoration(
                  suffixText: "%",
                  labelText: 'Disc-1 (%) Prb',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: state.percent2,
                onChanged: (_) => setState(() {
                  inputPagePresenter.getPriceToCustomer(index);
                }),
                decoration: const InputDecoration(
                  labelText: 'Disc-2 (%) COD',
                  suffixText: "%",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
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
                decoration: const InputDecoration(
                  labelText: 'Disc-3 (%) Principal',
                  suffixText: "%",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: state.percent4,
                onChanged: (_) => setState(() {
                  inputPagePresenter.getPriceToCustomer(index);
                }),
                decoration: const InputDecoration(
                  labelText: 'Disc-4 (%) Principal',
                  suffixText: "%",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontFamily: 'AvenirLight',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight',
                ),
              ),
            ),
          ],
        ),
      ],
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
          const SizedBox(height: 10),
          if (index == promotionProgramInputStateList.length - 1)
            _buildSubmitButton(promotionProgramInputStateList),
        ],
      ),
    );
  }

  Widget _buildLineItemCard(int index) {
    final state = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLineItemHeader(index),
              const SizedBox(height: 20),
              _buildCustomerFields(state, index),
              _buildItemFields(state, index),
              _buildQuantityFields(state, index),
              if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                      .selectedChoice?.value !=
                  "Bonus")
                _buildDiscountFields(state, index),
              if (inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                      .selectedChoice?.value !=
                  "Discount")
                _buildBonusFields(state, index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItemHeader(int index) {
    return Row(
      children: [
        const Text("Add Lines"),
        const Spacer(),
        IconButton(
          onPressed: () {
            inputPagePresenter.addItem();
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            inputPagePresenter.removeItem(index);
            inputPagePresenter.onTap.value = false;
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    List<PromotionProgramInputState> promotionProgramInputStateList,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 500),
      child: Column(
        children: [
          Visibility(
            visible: !inputPagePresenter.onTap.value,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colorAccent),
              onPressed: () {
                setState(() {
                  bool isInvalid = false;
                  for (var element in promotionProgramInputStateList) {
                    if (element.selectProductPageDropdownState
                                ?.selectedChoice ==
                            null ||
                        element.qtyFrom!.text.isEmpty ||
                        element.unitPageDropdownState?.selectedChoice == null) {
                      isInvalid = true;
                      break;
                    }
                  }

                  if (isInvalid) {
                    inputPagePresenter.onTap.value = false;
                    Get.snackbar(
                      "Error",
                      "Found empty fields in Lines",
                      backgroundColor: Colors.red,
                      icon: const Icon(Icons.error),
                    );
                  } else {
                    inputPagePresenter.onTap.value = true;
                    inputPagePresenter.submitPromotionProgram();
                  }
                });
              },
              child: Text(
                "Submit",
                style: TextStyle(color: colorNetral, fontSize: 12),
              ),
            ),
          ),
          Visibility(
            visible: inputPagePresenter.onTap.value,
            child: const Center(child: CircularProgressIndicator()),
          ),
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
          margin: const EdgeInsets.only(bottom: 100),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorAccent),
            onPressed: isAddItem
                ? () {
                    inputPagePresenter.addItem();
                  }
                : null,
            child: Text(
              "Add Lines",
              style: TextStyle(color: colorNetral, fontSize: 12),
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
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 10),
              _buildLineItems(),
              SizedBox(height: noteFieldHeight),
            ],
          ),
        ),
      ),
    );
  }
}
