import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

class InputPagePP extends StatefulWidget {
  const InputPagePP({Key? key}) : super(key: key);

  @override
  State<InputPagePP> createState() => _InputPageNewState();
}

class _InputPageNewState extends State<InputPagePP> {
  Widget customCard(int index, InputPageController inputPagePresenter) {
    PromotionProgramInputState promotionProgramInputState = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];
    // promotionProgramInputState.qtyFrom.text = 1.toString();
    // promotionProgramInputState.qtyTo.text = 1.toString();
    // promotionProgramInputState.fromDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // promotionProgramInputState.toDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
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
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _scrollToBottom());
                      },
                      icon: const Icon(Icons.add)),
                  IconButton(
                      onPressed: () {
                        inputPagePresenter.removeItem(index);
                        inputPagePresenter.onTap.value = false;
                      },
                      icon: const Icon(
                        Icons.delete,
                      )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // DropdownButtonFormField<String>(
              //   isExpanded: true,
              //   isDense: true,
              //   value: promotionProgramInputState.customerGroupInputPageDropdownState.selectedChoice,
              //   hint: Text(
              //     "Customer/Cust Group",
              //     style: TextStyle(fontSize: 12),
              //   ),
              //   items: promotionProgramInputState.customerGroupInputPageDropdownState.choiceList.map((item) {
              //     return DropdownMenuItem(
              //       child: Text(
              //         item,
              //         style: TextStyle(fontSize: 12),
              //         overflow: TextOverflow.fade,
              //       ),
              //       value: item,
              //     );
              //   }).toList(),
              //   onChanged: (value) => inputPagePresenter.changeCustomerGroup(index, value)
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // SearchChoices.single(
              //   items: promotionProgramInputState.customerNameOrDiscountGroupInputPageDropdownState.choiceList.map((item) {
              //     return DropdownMenuItem(
              //       child: Text(
              //         item.value,
              //         style: TextStyle(fontSize: 12),
              //         overflow: TextOverflow.fade,
              //       ),
              //       value: item,
              //     );
              //   }).toList(),
              //   value: promotionProgramInputState.customerNameOrDiscountGroupInputPageDropdownState.selectedChoice,
              //   hint: Builder(
              //     builder: (context) {
              //       String text = (promotionProgramInputState.customerGroupInputPageDropdownState.selectedChoice ?? "").toLowerCase() == "Customer"
              //           ? "Customer Name" : "Discount Group Name";
              //       return Text(
              //         promotionProgramInputState.customerGroupInputPageDropdownState.selectedChoice=="Customer"?"Select Customer": "Select Discount Group",
              //         style: TextStyle(fontSize: 12),
              //       );
              //     }
              //   ),
              //   onChanged: (value) => inputPagePresenter.changeCustomerNameOrDiscountGroup(index, value),
              //   isExpanded: true,
              // ),
              // SizedBox(height: 10,),
              //ite, group
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Item/Item Group",
                        style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                  SearchChoices.single(
                    isExpanded: true,
                    value: promotionProgramInputState
                        .itemGroupInputPageDropdownState?.selectedChoice,
                    hint: const Text(
                      "Item/Item Group",
                      style: TextStyle(fontSize: 12),
                    ),
                    items: promotionProgramInputState
                        .itemGroupInputPageDropdownState?.choiceList
                        ?.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.fade,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        inputPagePresenter.changeItemGroup(index, value),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Item Product",
                        style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: promotionProgramInputState
                                  .selectProductPageDropdownState
                                  ?.selectedChoice !=
                              null
                          ? 10
                          : 0,
                    ),
                    child: SearchChoices.single(
                        isExpanded: true,
                        value: promotionProgramInputState
                            .selectProductPageDropdownState?.selectedChoice,
                        items: promotionProgramInputState
                            .selectProductPageDropdownState?.choiceList
                            ?.map((item) {
                          return DropdownMenuItem(
                              value: item, child: Text(item.value));
                        }).toList(),
                        hint: Text(
                          promotionProgramInputState
                                      .itemGroupInputPageDropdownState
                                      ?.selectedChoice ==
                                  "Item"
                              ? "Select Product"
                              : "Select Product",
                          style: const TextStyle(fontSize: 12),
                        ),
                        onChanged: (value) =>
                            inputPagePresenter.changeProduct(index, value)
                        // isExpanded: true,
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              //warehouse qyt
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Warehouse",
                        style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                  Container(
                    child: SearchChoices.single(
                      isExpanded: true,
                      value: promotionProgramInputState
                              .wareHousePageDropdownState
                              ?.selectedChoiceWrapper
                              ?.value ??
                          "WHS - Tunas - Buffer",
                      hint: const Text(
                        "WHS - Tunas - Buffer",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      items: promotionProgramInputState
                          .wareHousePageDropdownState?.choiceListWrapper?.value
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
                  ),
                ],
              ),

              //unit multiply
              // Stack(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(left: 10),
              //       child: Text("Unit",style: TextStyle(fontSize: 10,color: Colors.black54)),
              //     ),
              //     Row(
              //       children: [
              //         //unit
              //         Expanded(
              //           child: SearchChoices.single(
              //             isExpanded: true,
              //             value: promotionProgramInputState.unitPageDropdownState.selectedChoice,
              //             hint: Text(
              //               "Unit",
              //               style: TextStyle(fontSize: 12),
              //             ),
              //             items: promotionProgramInputState.unitPageDropdownState.choiceList.map((item) {
              //               return DropdownMenuItem(
              //                 child: Text(item),
              //                 value: item,
              //               );
              //             }).toList(),
              //             onChanged: (value) => inputPagePresenter.changeUnit(index, value),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: promotionProgramInputState.qtyFrom,
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
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontFamily: 'AvenirLight'),
                      //  controller: _passwordController,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: promotionProgramInputState.qtyTo,
                      decoration: const InputDecoration(
                          labelText: 'Qty To',
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontFamily: 'AvenirLight'),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0)),
                          contentPadding: EdgeInsets.only(bottom: 20)),
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontFamily: 'AvenirLight'),
                      //  controller: _passwordController,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 140,
                    height: 68,
                    child: SearchChoices.single(
                      isExpanded: true,
                      value: promotionProgramInputState
                          .unitPageDropdownState?.selectedChoice,
                      hint: const Text(
                        "Unit",
                        style: TextStyle(fontSize: 12),
                      ),
                      items: promotionProgramInputState
                          .unitPageDropdownState?.choiceList
                          ?.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          inputPagePresenter.changeUnit(index, value),
                    ),
                  ),
                ],
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
                              style: TextStyle(fontSize: 12),
                            ),
                            items: promotionProgramInputState
                                .percentValueInputPageDropdownState?.choiceList
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
                  : promotionProgramInputState
                              .percentValueInputPageDropdownState
                              ?.selectedChoice ==
                          promotionProgramInputState
                              .percentValueInputPageDropdownState
                              ?.choiceList![1]
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //sales price
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
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
                                    //  controller: _passwordController,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                //value 1
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      CustomMoneyInputFormatter(
                                        thousandSeparator: ".",
                                        decimalSeparator: ",",
                                      ),
                                    ],
                                    controller:
                                        promotionProgramInputState.value1,
                                    onChanged: (value) {
                                      inputPagePresenter
                                          .getPriceToCustomer(index);
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Value(PRB)',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
                                    //  controller: _passwordController,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                //value 2
                                Expanded(
                                  child: TextFormField(
                                    inputFormatters: [
                                      CustomMoneyInputFormatter(
                                        thousandSeparator: ".",
                                        decimalSeparator: ",",
                                      ),
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller:
                                        promotionProgramInputState.value2,
                                    onChanged: (value) {
                                      inputPagePresenter
                                          .getPriceToCustomer(index);
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Value(Principal)',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                //sales price
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
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                      setState(() {
                                        inputPagePresenter
                                            .getPriceToCustomer(index);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      suffixText: "%",
                                      labelText: 'Disc-1 (%) Prb',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                      setState(() {
                                        inputPagePresenter
                                            .getPriceToCustomer(index);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Disc-2 (%) COD',
                                      suffixText: "%",
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                      setState(() {
                                        inputPagePresenter
                                            .getPriceToCustomer(index);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Disc-3 (%) Principal',
                                      suffixText: "%",
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                                      setState(() {
                                        inputPagePresenter
                                            .getPriceToCustomer(index);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Disc-4 (%) Principal',
                                      suffixText: "%",
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontFamily: 'AvenirLight'),
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
                                        fontFamily: 'AvenirLight'),
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
                        style: TextStyle(fontSize: 12),
                      ),
                      items: promotionProgramInputState.supplyItem?.choiceList
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
                          inputPagePresenter.changeSupplyItem(index, value)),

              //unit multiply
              inputPagePresenter.promotionTypeInputPageDropdownStateRx.value
                          .selectedChoice?.value ==
                      "Discount"
                  ? const SizedBox()
                  : Row(
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
                                  fontSize: 12,
                                  fontFamily: 'AvenirLight'),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0)),
                            ),
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontFamily: 'AvenirLight'),
                            //  controller: _passwordController,
                          ),
                        ),
                        const Spacer(),
                        //unit supply item
                        SizedBox(
                          width: 120,
                          child: SearchChoices.single(
                            isExpanded: true,
                            value: promotionProgramInputState
                                .unitSupplyItem?.selectedChoice,
                            hint: const Text(
                              "Unit Bonus Item",
                              style: TextStyle(fontSize: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  final noteFocusNode = FocusNode();

  final _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - 500,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool isNoteTapped = false;
  double noteFieldHeight = 10.0;

  @override
  Widget build(BuildContext context) {
    final inputPagePresenter = Get.put(InputPageController());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                borderOnForeground: true,
                semanticContainer: true,
                child: Container(
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
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => TextFormField(
                                  controller: inputPagePresenter
                                      .programNameTextEditingControllerRx.value,
                                  onChanged: (value) =>
                                      inputPagePresenter.checkAddItemStatus(),
                                  decoration: const InputDecoration(
                                    labelText: 'Program Name',
                                    labelStyle: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontFamily: 'AvenirLight'),
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
                                      fontFamily: 'AvenirLight'),
                                  //  controller: _passwordController,
                                  // obscureText: true,
                                )),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            // width: 150,
                            child: Obx(() =>
                                DropdownButtonFormField<IdAndValue<String>>(
                                  value: inputPagePresenter
                                      .promotionTypeInputPageDropdownStateRx
                                      .value
                                      .selectedChoice,
                                  hint: const Text(
                                    "Type",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  items: inputPagePresenter
                                      .promotionTypeInputPageDropdownStateRx
                                      .value
                                      .choiceList
                                      ?.map((item) {
                                    return DropdownMenuItem<IdAndValue<String>>(
                                      value: item,
                                      child: Text(item.value),
                                    );
                                  }).toList(),
                                  onChanged: (value) => inputPagePresenter
                                      .changePromotionType(value!),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: Get.width,
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                                isExpanded: true,
                                isDense: true,
                                value: inputPagePresenter
                                    .customerGroupInputPageDropdownState
                                    .value
                                    .selectedChoice,
                                hint: const Text(
                                  "Customer/Cust Group",
                                  style: TextStyle(fontSize: 12),
                                ),
                                items: inputPagePresenter
                                    .customerGroupInputPageDropdownState
                                    .value
                                    .choiceList
                                    ?.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.fade,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    inputPagePresenter
                                        .changeCustomerGroupHeader(value!);
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      setState(() {});
                                    });
                                  });
                                }),
                          )),
                      SizedBox(
                        width: Get.width,
                        child: Obx(
                          () => SearchChoices.single(
                            items: inputPagePresenter
                                .custNameHeaderValueDropdownStateRx
                                .value
                                .choiceList
                                ?.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item.value,
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            value: inputPagePresenter
                                .custNameHeaderValueDropdownStateRx
                                .value
                                .selectedChoice,
                            hint: Text(
                              inputPagePresenter
                                          .customerGroupInputPageDropdownState
                                          .value
                                          .selectedChoice ==
                                      "Customer"
                                  ? "Select Customer"
                                  : "Select Customer",
                              style: const TextStyle(fontSize: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                inputPagePresenter
                                    .changeCustomerNameOrDiscountGroupHeader(
                                        value);
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => SearchChoices.single(
                                // Assuming listDataPrincipal is a List of non-null items
                                value: inputPagePresenter
                                        .selectedDataPrincipal.isNotEmpty
                                    ? inputPagePresenter.listDataPrincipal[
                                        inputPagePresenter
                                            .selectedDataPrincipal[0]]
                                    : null,
                                hint: const Text(
                                  "Select Principal",
                                  style: TextStyle(fontSize: 12),
                                ),
                                items: inputPagePresenter.listDataPrincipal
                                    .map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.toString(),
                                    child: Text(item.toString()),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  // onChanged should expect a nullable String
                                  if (value != null) {
                                    print("value: $value");
                                    final index = inputPagePresenter
                                        .listDataPrincipal
                                        .indexOf(value);
                                    inputPagePresenter.selectedDataPrincipal
                                        .clear();
                                    if (index >= 0) {
                                      inputPagePresenter.selectedDataPrincipal
                                          .add(index);
                                    }
                                    final selectedItems = inputPagePresenter
                                        .selectedDataPrincipal
                                        .map((index) => inputPagePresenter
                                            .listDataPrincipal[index])
                                        .toList();
                                    print("Selected Principal: $selectedItems");
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // From Date
                          SizedBox(
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDatePickerField(
                                    controller: inputPagePresenter
                                        .programFromDateTextEditingControllerRx
                                        .value,
                                    labelText: 'From Date',
                                    initialValue: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 180)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDatePickerField(
                                    controller: inputPagePresenter
                                        .programFromDateTextEditingControllerRx
                                        .value,
                                    labelText: 'From Date',
                                    initialValue: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 180)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => TextFormField(
                                  maxLines: 1,
                                  controller: inputPagePresenter
                                      .programNoteTextEditingControllerRx.value,
                                  onTapOutside: (_) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      // isNoteTapped = false;
                                      // noteFieldHeight = 10.0;
                                    });
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
                                        fontFamily: 'AvenirLight'),
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
                                      fontFamily: 'AvenirLight'),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(() {
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
                            backgroundColor: Colors.green,
                          ),
                          onPressed: isAddItem
                              ? () {
                                  inputPagePresenter.addItem();
                                }
                              : null,
                          child: const Text("Add Lines")),
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
                                customCard(index, inputPagePresenter),
                                const SizedBox(
                                  height: 10,
                                ),
                                index ==
                                        promotionProgramInputStateList.length -
                                            1
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 500),
                                        child: Column(
                                          children: [
                                            Visibility(
                                              visible: !inputPagePresenter
                                                  .onTap.value,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                  child: const Text("Submit"),
                                                  onPressed: () {
                                                    setState(() {
                                                      bool isInvalid = false;
                                                      for (int i = 0;
                                                          i <
                                                              promotionProgramInputStateList
                                                                  .length;
                                                          i++) {
                                                        PromotionProgramInputState
                                                            element =
                                                            promotionProgramInputStateList[
                                                                i];
                                                        if (element.selectProductPageDropdownState
                                                                    ?.selectedChoice ==
                                                                null ||
                                                            element.qtyFrom!
                                                                .text.isEmpty ||
                                                            /*element.qtyTo.text.isEmpty ||*/
                                                            element.unitPageDropdownState
                                                                    ?.selectedChoice ==
                                                                null) {
                                                          isInvalid = true;
                                                          break;
                                                        }
                                                      }

                                                      if (isInvalid) {
                                                        // Handle empty fields in promotionProgramInputList
                                                        inputPagePresenter.onTap
                                                            .value = false;
                                                        Get.snackbar("Error",
                                                            "Found empty fields in Lines",
                                                            backgroundColor:
                                                                Colors.red,
                                                            icon: const Icon(
                                                                Icons.error));
                                                      } else {
                                                        inputPagePresenter
                                                            .onTap.value = true;
                                                        inputPagePresenter
                                                            .submitPromotionProgram();
                                                      }
                                                      // inputPagePresenter.submitPromotionProgram();
                                                    });
                                                  }),
                                            ),
                                            Visibility(
                                              visible: inputPagePresenter
                                                      .onTap.value ==
                                                  true,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ));
            }),
            SizedBox(
              height: noteFieldHeight,
            ),
          ],
        ),
      )),
    );
  }
}
