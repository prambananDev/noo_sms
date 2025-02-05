import 'package:flutter/material.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

Widget customCard(
  int index,
  InputPageController inputPagePresenter,
) {
  PromotionProgramInputState promotionProgramInputState = inputPagePresenter
      .promotionProgramInputStateRx.value.promotionProgramInputState[index];

  return Container(
    margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
    child: Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      semanticContainer: true,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Add Lines"),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    inputPagePresenter.addItem();
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
            ),
            const SizedBox(height: 20),
            SearchChoices.single(
              isExpanded: true,
              value: promotionProgramInputState
                  .itemGroupInputPageDropdownState?.selectedChoice,
              hint: const Text(
                "Item/Item Group",
                style: TextStyle(fontSize: 16),
              ),
              items: promotionProgramInputState
                  .itemGroupInputPageDropdownState?.choiceList
                  ?.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.fade,
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  inputPagePresenter.changeItemGroup(index, value),
            ),
            _buildSearchChoices<IdAndValue<String>>(
              "Item Product",
              promotionProgramInputState
                  .selectProductPageDropdownState?.selectedChoice,
              promotionProgramInputState
                  .selectProductPageDropdownState?.choiceList,
              (value) => inputPagePresenter.changeProduct(index, value),
            ),

            _buildSearchChoices<IdAndValue<String>>(
              "Warehouse",
              promotionProgramInputState
                  .wareHousePageDropdownState?.selectedChoiceWrapper?.value,
              promotionProgramInputState
                  .wareHousePageDropdownState?.choiceListWrapper?.value,
              (value) => inputPagePresenter.changeWarehouse(index, value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTextField(
                  controller: promotionProgramInputState.qtyFrom,
                  labelText: "Qty From",
                ),
                const SizedBox(width: 10),
                _buildTextField(
                  controller: promotionProgramInputState.qtyTo,
                  labelText: "Qty To",
                ),
                const SizedBox(width: 10),
              ],
            ),
            SearchChoices.single(
              isExpanded: true,
              value: promotionProgramInputState
                  .unitPageDropdownState?.selectedChoice,
              hint: const Text(
                "Unit",
                style: TextStyle(fontSize: 16),
              ),
              items: promotionProgramInputState
                  .unitPageDropdownState?.choiceList
                  ?.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) => inputPagePresenter.changeUnit(index, value),
            ),
            inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                        .selectedChoice?.value ==
                    "Bonus"
                ? const SizedBox()
                : Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<IdAndValue<String>>(
                          value: promotionProgramInputState
                              .percentValueInputPageDropdownState
                              ?.selectedChoice,
                          hint: const Text(
                            "Disc Type (percent/value)",
                            style: TextStyle(fontSize: 16),
                          ),
                          items: promotionProgramInputState
                              .percentValueInputPageDropdownState?.choiceList
                              ?.map((item) {
                            return DropdownMenuItem<IdAndValue<String>>(
                              value: item,
                              child: Text(
                                item.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            inputPagePresenter.changePercentValue(
                                index, value!);
                          },
                        ),
                      ),
                    ],
                  ),

            //percent
            inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                        .selectedChoice?.value ==
                    "Bonus"
                ? const SizedBox()
                : promotionProgramInputState.percentValueInputPageDropdownState
                            ?.selectedChoice ==
                        promotionProgramInputState
                            .percentValueInputPageDropdownState?.choiceList![1]
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      promotionProgramInputState.salesPrice,
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
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CustomMoneyInputFormatter(
                                      thousandSeparator: ".",
                                      decimalSeparator: ",",
                                    ),
                                  ],
                                  controller: promotionProgramInputState
                                      .priceToCustomer,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Price to Customer',
                                    prefixText: "Rp",
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CustomMoneyInputFormatter(
                                      thousandSeparator: ".",
                                      decimalSeparator: ",",
                                    ),
                                  ],
                                  controller: promotionProgramInputState.value1,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Value(PRB)',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextFormField(
                                  inputFormatters: [
                                    CustomMoneyInputFormatter(
                                      thousandSeparator: ".",
                                      decimalSeparator: ",",
                                    ),
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: promotionProgramInputState.value2,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Value(Principal)',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                            ],
                          )
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
                                  controller:
                                      promotionProgramInputState.salesPrice,
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
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              //price to customer
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CustomMoneyInputFormatter(
                                      thousandSeparator: ".",
                                      decimalSeparator: ",",
                                    ),
                                  ],
                                  controller: promotionProgramInputState
                                      .priceToCustomer,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Price to Customer',
                                    prefixText: "Rp",
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //percent1
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      promotionProgramInputState.percent1,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: "%",
                                    labelText: 'Disc-1 (%) Prb',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              //percent2
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      promotionProgramInputState.percent2,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Disc-2 (%) COD',
                                    suffixText: "%",
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //percent3
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      promotionProgramInputState.percent3,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Disc-3 (%) Principal',
                                    suffixText: "%",
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              //percent4
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      promotionProgramInputState.percent4,
                                  onChanged: (value) {
                                    inputPagePresenter
                                        .getPriceToCustomer(index);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Disc-4 (%) Principal',
                                    suffixText: "%",
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0)),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                  ),
                                  //  controller: _passwordController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

            inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                        .selectedChoice?.value ==
                    "Discount"
                ? const SizedBox()
                : SearchChoices.single(
                    isExpanded: true,
                    value:
                        promotionProgramInputState.supplyItem?.selectedChoice,
                    hint: const Text(
                      "Bonus Item",
                      style: TextStyle(fontSize: 16),
                    ),
                    items: promotionProgramInputState.supplyItem?.choiceList
                        ?.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.value,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.fade,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        inputPagePresenter.changeSupplyItem(index, value)),

            //unit multiply
            inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                        .selectedChoice?.value ==
                    "Discount"
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //unit
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: promotionProgramInputState.qtyItem,
                          decoration: const InputDecoration(
                            labelText: 'Qty Item',
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0)),
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                          ),
                          //  controller: _passwordController,
                        ),
                      ),

                      SizedBox(
                        width: 120,
                        child: SearchChoices.single(
                          isExpanded: true,
                          value: promotionProgramInputState
                              .unitSupplyItem?.selectedChoice,
                          hint: const Text(
                            "Unit Bonus Item",
                            style: TextStyle(fontSize: 16),
                          ),
                          items: promotionProgramInputState
                              .unitSupplyItem?.choiceList
                              ?.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) => inputPagePresenter
                              .changeUnitSupplyItem(index, value),
                        ),
                      ),
                    ],
                  ),

            // Add other UI elements similar to this
          ],
        ),
      ),
    ),
  );
}

Widget _buildSearchChoices<T extends IdAndValue<String>>(
    String label, T? selectedValue, List<T>? items, Function(T) onChanged) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ),
      SearchChoices.single(
        isExpanded: true,
        value: selectedValue,
        items: items?.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (value) => onChanged(value as T),
        hint: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}

Widget _buildTextField({
  required TextEditingController? controller,
  required String labelText,
}) {
  return SizedBox(
    width: 80,
    child: TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 17,
      ),
    ),
  );
}
