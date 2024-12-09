import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';

import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final InputPageController inputPagePresenter = Get.put(InputPageController());
  Widget customCard(int index, TransactionController inputPagePresenter) {
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
                      icon: const Icon(Icons.add)),
                  IconButton(
                      onPressed: () {
                        // Future.delayed(Duration(milliseconds: ),(){
                        inputPagePresenter.removeItem(index);
                        // });
                        // Future.delayed(Duration(milliseconds: 500),(){
                        //   setState(() {
                        //   });
                        // });
                      },
                      icon: const Icon(
                        Icons.delete,
                      )),
                ],
              ),
              SearchChoices.single(
                isExpanded: true,
                value: promotionProgramInputState
                    .productTransactionPageDropdownState!
                    .selectedChoiceWrapper
                    ?.value,
                items: promotionProgramInputState
                    .productTransactionPageDropdownState
                    ?.choiceListWrapper
                    ?.value
                    ?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.value),
                  );
                }).toList(),
                hint: const Text(
                  "Select Product",
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    inputPagePresenter.changeProduct(index, value);
                  });
                },
              ),
              SearchChoices.single(
                isExpanded: true,
                value: promotionProgramInputState
                    .unitPageDropdownState?.selectedChoice,
                items: promotionProgramInputState
                    .unitPageDropdownState?.choiceList
                    ?.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                hint: const Text(
                  "Select Unit",
                  style: TextStyle(fontSize: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    inputPagePresenter.changeUnit(index, value);
                  });
                },
              ),
              SizedBox(
                width: Get.width,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: promotionProgramInputState.qtyTransaction,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Qty',
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
                  onChanged: (value) {
                    inputPagePresenter.changeQty(index, value);
                  },
                ),
              ),
              SizedBox(
                width: Get.width,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: promotionProgramInputState.priceTransaction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    CustomMoneyInputFormatter(
                      thousandSeparator: ".",
                      decimalSeparator: ",",
                    ),
                  ],
                  decoration: const InputDecoration(
                    prefixText: "Rp ",
                    labelText: 'Price',
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
                  onChanged: (value) {
                    inputPagePresenter.changeQty(index, value);
                  },
                ),
              ),
              SizedBox(
                width: Get.width,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: promotionProgramInputState.discTransaction,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Disc',
                    suffixText: "(%)",
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
                  onChanged: (value) {
                    inputPagePresenter.changeDisc(index, value);
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "Total",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(promotionProgramInputState
                      .totalTransaction!.value.text.isEmpty
                  ? "0"
                  : "Rp ${MoneyFormatter(amount: double.parse(promotionProgramInputState.totalTransaction!.value.text.replaceAll(",", ""))).output.withoutFractionDigits}"),
              const Divider(
                thickness: 1,
                color: Colors.black54,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputPagePresenter = Get.put(TransactionController());
    return Scaffold(
      backgroundColor: colorNetral,
      body: SafeArea(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Card(
                elevation: 10,
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
                        "New Order Taking",
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Obx(
                          () => SearchChoices.single(
                            isExpanded: true,
                            value: inputPagePresenter
                                .customerNameInputPageDropdownStateRx
                                .value
                                .selectedChoice,
                            hint: const Text(
                              "Customer Name",
                              style: TextStyle(fontSize: 12),
                            ),
                            items: inputPagePresenter
                                .customerNameInputPageDropdownStateRx
                                .value
                                .choiceList
                                ?.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item.value,
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              inputPagePresenter.changeSelectCustomer2(value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Obx(() => TextFormField(
                              controller: inputPagePresenter
                                  .transactionNumberTextEditingControllerRx
                                  .value,
                              keyboardType: TextInputType.text,
                              onChanged: (value) =>
                                  inputPagePresenter.checkAddItemStatus(),
                              decoration: const InputDecoration(
                                labelText: 'Transaction Number',
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
                            )),
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Obx(() => TextFormField(
                              controller: inputPagePresenter
                                  .transactionDateTextEditingControllerRx.value
                                ..text = "${DateTime.now()}",
                              onChanged: (value) =>
                                  inputPagePresenter.checkAddItemStatus(),
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Transaction Date',
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
                              // obscureText: true,
                            )),
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
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed:
                          isAddItem ? () => inputPagePresenter.addItem() : null,
                      child: const Text("Add Data Transaction",
                          style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: promotionProgramInputStateList.length,
                      itemBuilder: (context, index) => Column(
                            children: [
                              customCard(index, inputPagePresenter),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorAccent,
                                  ),
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: colorNetral,
                                    ),
                                  ),
                                  onPressed: () {
                                    List<PromotionProgramInputState>?
                                        promotionProgramInputState =
                                        inputPagePresenter
                                            .promotionProgramInputStateRx
                                            .value
                                            .promotionProgramInputState
                                            .toList();
                                    // List disc = promotionProgramInputState
                                    //     .map((e) => e.discTransaction?.text)
                                    //     .toList();

                                    List<String?> price =
                                        promotionProgramInputState
                                            .map(
                                                (e) => e.priceTransaction?.text)
                                            .toList();

                                    inputPagePresenter.submitPromotionProgram();
                                    bool isEqual = listEquals(
                                        inputPagePresenter.originalPrice,
                                        price);
                                    inputPagePresenter.submitPromotionProgram();
                                    // if (isEqual) {
                                    //   inputPagePresenter
                                    //       .submitPromotionProgram();
                                    // } else {
                                    //   Future.delayed(
                                    //       const Duration(
                                    //           seconds: 1,
                                    //           milliseconds: 500), () {
                                    //     inputPagePresenter
                                    //         .submitPromotionProgram();
                                    //   });
                                    // Future.delayed(
                                    //     const Duration(
                                    //         seconds: 1,
                                    //         milliseconds: 500), () {
                                    //   inputPagePresenter
                                    //       .submitPromotionProgramAll();
                                    // });
                                    // }
                                    inputPagePresenter.submitPromotionProgram();
                                  })
                            ],
                          ));
            }),
          ],
        ),
      )),
    );
  }
}
