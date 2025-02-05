import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';

import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/controllers/sample_order/transaction_sample_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

class TransactionSample extends StatefulWidget {
  const TransactionSample({Key? key}) : super(key: key);

  @override
  State<TransactionSample> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionSample> {
  final TransactionSampleController inputPagePresenter =
      Get.put(TransactionSampleController());
  List<TextEditingController> valuesControllers = [];
  String? sampleType;
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> qtyFocusNodes = [];

  final FocusNode _qtyAddFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _customerPICFocusNode = FocusNode();
  final FocusNode _customerPhoneFocusNode = FocusNode();
  final FocusNode _customerAddressFocusNode = FocusNode();
  final FocusNode _principalNameFocusNode = FocusNode();

  void _closeKeyboard() {
    _qtyAddFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    _customerPICFocusNode.unfocus();
    _customerPhoneFocusNode.unfocus();
    _customerAddressFocusNode.unfocus();
    _principalNameFocusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    inputPagePresenter.custNameTextEditingControllerRx.value
        .addListener(_updateProspectValidity);
    inputPagePresenter.custPicTextEditingControllerRx.value
        .addListener(_updateProspectValidity);
    inputPagePresenter.custPhoneTextEditingControllerRx.value
        .addListener(_updateProspectValidity);
    inputPagePresenter.custAddressTextEditingControllerRx.value
        .addListener(_updateProspectValidity);
    inputPagePresenter.purposeDescTextEditingControllerRx.value
        .addListener(_updateButtonValidity);
    inputPagePresenter.principalNameTextEditingControllerRx.value
        .addListener(_updateButtonValidity);
  }

  @override
  void dispose() {
    for (var controller in valuesControllers) {
      controller.dispose();
    }
    for (var focusNode in qtyFocusNodes) {
      focusNode.dispose();
    }
    _descriptionFocusNode.dispose();
    _customerPICFocusNode.dispose();
    _customerPhoneFocusNode.dispose();
    _customerAddressFocusNode.dispose();
    _principalNameFocusNode.dispose();
    super.dispose();
  }

  void _updateProspectValidity() {
    bool isValid = inputPagePresenter
            .custNameTextEditingControllerRx.value.text.isNotEmpty &&
        inputPagePresenter
            .custPicTextEditingControllerRx.value.text.isNotEmpty &&
        inputPagePresenter
            .custPhoneTextEditingControllerRx.value.text.isNotEmpty &&
        inputPagePresenter
            .custAddressTextEditingControllerRx.value.text.isNotEmpty;
    inputPagePresenter.isProspectValid.value = isValid;
  }

  void _updateButtonValidity() {
    setState(() {});
  }

  bool _isAddItemEnabled() {
    bool isPurposeDescriptionFilled = inputPagePresenter
        .purposeDescTextEditingControllerRx.value.text.isNotEmpty;
    bool isPrincipalNameFilled = !inputPagePresenter.isClaim.value ||
        (inputPagePresenter.isClaim.value &&
            inputPagePresenter.principalList.value.selectedChoice?.id != '0') ||
        (inputPagePresenter
            .principalNameTextEditingControllerRx.value.text.isNotEmpty);

    bool isCommercial =
        inputPagePresenter.typesList.value.selectedChoice?.value ==
            'Commercial';

    return isPurposeDescriptionFilled &&
        (isCommercial ? isPrincipalNameFilled : true);
  }

  void _addItem() {
    setState(() {
      FocusScope.of(context).unfocus();
      inputPagePresenter.addItem();

      var newController = TextEditingController(text: "1");
      valuesControllers.add(newController);

      var newFocusNode = FocusNode();
      qtyFocusNodes.add(newFocusNode);

      inputPagePresenter.changeQty(valuesControllers.length - 1, "1");

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      inputPagePresenter.removeItem(index);

      if (index < valuesControllers.length) {
        valuesControllers[index].dispose();
        valuesControllers.removeAt(index);
      }

      if (index < qtyFocusNodes.length) {
        qtyFocusNodes[index].dispose();
        qtyFocusNodes.removeAt(index);
      }
    });
  }

  void _addQuantity(int index, bool isAddition) {
    int counter = int.parse(valuesControllers[index].text);
    if (!isAddition) {
      if (counter > 1) {
        counter = counter - 1;
      }
    } else {
      counter = counter + 1;
    }
    setState(() {
      valuesControllers[index].text = counter.toString();
      inputPagePresenter.changeQty(index, valuesControllers[index].text);
    });
  }

  void _synchronizeValues() {
    for (int i = 0; i < valuesControllers.length; i++) {
      inputPagePresenter.changeQty(i, valuesControllers[i].text);
    }
  }

  Widget customCard(int index, TransactionSampleController inputPagePresenter) {
    PromotionProgramInputState promotionProgramInputState = inputPagePresenter
        .promotionProgramInputStateRx.value.promotionProgramInputState[index];

    while (valuesControllers.length <= index) {
      valuesControllers.add(TextEditingController(text: "1"));
      qtyFocusNodes.add(FocusNode());
    }

    TextEditingController values = valuesControllers[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Add Lines",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
              IconButton(
                onPressed: () {
                  _removeItem(index);
                },
                icon: const Icon(Icons.delete, color: Colors.black),
              ),
            ],
          ),
          SearchChoices.single(
            isExpanded: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            menuBackgroundColor: Colors.white,
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            value: promotionProgramInputState
                .productTransactionPageDropdownState!
                .selectedChoiceWrapper
                ?.value,
            items: promotionProgramInputState
                .productTransactionPageDropdownState?.choiceListWrapper?.value
                ?.map((item) {
              return DropdownMenuItem(value: item, child: Text(item.value));
            }).toList(),
            hint: const Text(
              "Select Product",
              style: TextStyle(fontSize: 16),
            ),
            onChanged: (value) {
              inputPagePresenter.changeProduct(index, value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'QTY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.06,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1.5,
                        color: const Color.fromARGB(167, 37, 37, 37),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            _addQuantity(index, false);
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: TextField(
                            focusNode: qtyFocusNodes[index],
                            autofocus: false,
                            textAlign: TextAlign.center,
                            controller: values,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                              signed: true,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              inputPagePresenter.changeQty(index, value);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _addQuantity(index, true);
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: promotionProgramInputState
                    .unitPageDropdownState?.selectedChoice,
                items: promotionProgramInputState
                        .unitPageDropdownState?.choiceList
                        ?.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList() ??
                    [],
                style: const TextStyle(fontSize: 16, color: Colors.black),
                hint: Text(
                  promotionProgramInputState.productTransactionPageDropdownState
                              ?.selectedChoiceWrapper?.value ==
                          null
                      ? "Unit"
                      : "Select Unit",
                  style: const TextStyle(fontSize: 16),
                ),
                onChanged: promotionProgramInputState
                            .productTransactionPageDropdownState
                            ?.selectedChoiceWrapper
                            ?.value !=
                        null
                    ? (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          inputPagePresenter.changeUnit(index, value);
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addOrder(TransactionSampleController inputPagePresenter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Obx(
        () {
          final isCommercial =
              inputPagePresenter.typesList.value.selectedChoice?.value ==
                  'Commercial';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Sample Order",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SearchChoices.single(
                isExpanded: true,
                value: inputPagePresenter.typesList.value.selectedChoice,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                menuBackgroundColor: Colors.white,
                underline: Container(
                  height: 1,
                  color: Colors.grey,
                ),
                hint: const Text(
                  "Sample Types",
                  style: TextStyle(fontSize: 16),
                ),
                items:
                    inputPagePresenter.typesList.value.choiceList?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child:
                        Text(item.value, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) {
                  _closeKeyboard();
                  inputPagePresenter.changeSampleType(value);
                },
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
              ),
              Obx(
                () => SearchChoices.single(
                  isExpanded: true,
                  value: inputPagePresenter.purposeList.value.selectedChoice,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  menuBackgroundColor: Colors.white,
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  hint: const Text(
                    "Select Purpose",
                    style: TextStyle(fontSize: 16),
                  ),
                  items: inputPagePresenter.purposeList.value.choiceList
                      ?.map((purpose) {
                    return DropdownMenuItem<IdAndValue<String>>(
                      value: purpose,
                      child: Text(
                        purpose.value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (IdAndValue<String>? newValue) {
                    _closeKeyboard();
                    setState(() {
                      inputPagePresenter.changePurpose(newValue);
                    });
                  },
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Purpose Description",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                  child: TextField(
                    focusNode: _descriptionFocusNode,
                    controller: inputPagePresenter
                        .purposeDescTextEditingControllerRx.value,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Submit description here',
                      hintStyle: const TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              if (isCommercial) ...[
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchChoices.single(
                        clearSearchIcon: const Icon(Icons.clear_all),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        menuBackgroundColor: Colors.white,
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        isExpanded: true,
                        value: inputPagePresenter
                            .customerNameInputPageDropdownStateRx
                            .value
                            .selectedChoice,
                        hint: const Text(
                          "Customer Name",
                          style: TextStyle(fontSize: 16),
                        ),
                        items: inputPagePresenter
                            .customerNameInputPageDropdownStateRx
                            .value
                            .choiceList
                            ?.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.value,
                                style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (IdAndValue<String> newValue) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            inputPagePresenter.changeSelectCustomer(newValue);
                          });
                        },
                      ),
                      if (inputPagePresenter
                              .customerNameInputPageDropdownStateRx
                              .value
                              .selectedChoice
                              ?.id ==
                          'prospect') ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Customer Name/Alias",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4, bottom: 16.0),
                          child: TextField(
                            focusNode: _customerPICFocusNode,
                            controller: inputPagePresenter
                                .custNameTextEditingControllerRx.value,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "Customer PIC",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4, bottom: 16.0),
                          child: TextField(
                            focusNode: _customerPhoneFocusNode,
                            controller: inputPagePresenter
                                .custPicTextEditingControllerRx.value,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "Customer Phone",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4, bottom: 16.0),
                          child: TextField(
                            focusNode: _customerAddressFocusNode,
                            controller: inputPagePresenter
                                .custPhoneTextEditingControllerRx.value,
                            maxLines: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "Customer Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4, bottom: 16.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 300.0,
                            ),
                            child: TextField(
                              focusNode: _customerAddressFocusNode,
                              keyboardType: TextInputType.streetAddress,
                              controller: inputPagePresenter
                                  .custAddressTextEditingControllerRx.value,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Customer Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SearchChoices.single(
                          isExpanded: true,
                          value: inputPagePresenter
                              .distributionChannelList.value.selectedChoice,
                          hint: const Text(
                            "Distribution Channel",
                            style: TextStyle(fontSize: 16),
                          ),
                          items: inputPagePresenter
                              .distributionChannelList.value.choiceList
                              ?.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item.value,
                                  style: const TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (IdAndValue<String>? value) {
                            inputPagePresenter.changeDistributionChannel(value);
                          },
                        ),
                      ],
                    ],
                  );
                }),
                Obx(
                  () => CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text(
                      "Claim to principal ?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: inputPagePresenter.isClaim.value,
                    onChanged: (bool? value) {
                      setState(() {
                        inputPagePresenter.isClaim.value = value ?? false;
                        _updateButtonValidity();
                      });
                    },
                  ),
                ),
                if (inputPagePresenter.isClaim.value) ...[
                  Obx(
                    () => SearchChoices.single(
                      clearSearchIcon: const Icon(Icons.clear_all),
                      padding: const EdgeInsets.only(top: 8),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      menuBackgroundColor: Colors.white,
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      isExpanded: true,
                      value:
                          inputPagePresenter.principalList.value.selectedChoice,
                      hint: const Text(
                        "Select Principal",
                        style: TextStyle(fontSize: 16),
                      ),
                      items: inputPagePresenter.principalList.value.choiceList
                          ?.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.value,
                              style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (IdAndValue<String>? newValue) {
                        _closeKeyboard();
                        inputPagePresenter.changePrincipal(newValue);
                        _updateButtonValidity();
                      },
                    ),
                  ),
                  if (inputPagePresenter
                          .principalList.value.selectedChoice?.id ==
                      '0') ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Principal Name",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 4, bottom: 16.0),
                      child: TextField(
                        controller: inputPagePresenter
                            .principalNameTextEditingControllerRx.value,
                        maxLines: 1,
                        focusNode: _principalNameFocusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ] else ...[
                Obx(() {
                  final deptState = inputPagePresenter.deptList.value;
                  return DropdownButtonHideUnderline(
                    child: SearchChoices.single(
                      isExpanded: true,
                      hint: const Text(
                        "Select Department",
                        style: TextStyle(fontSize: 16),
                      ),
                      value: deptState.selectedChoice,
                      items: deptState.choiceList?.map((dept) {
                        return DropdownMenuItem<IdAndValue<String>>(
                          value: dept,
                          child: Text(
                            dept.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (IdAndValue<String>? newValue) {
                        _closeKeyboard();
                        setState(() {
                          inputPagePresenter.changeDept(newValue);
                        });
                      },
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: addOrder(inputPagePresenter),
            ),
            Obx(() {
              InputPageWrapper inputPageWrapper =
                  inputPagePresenter.promotionProgramInputStateRx.value;
              List<PromotionProgramInputState>? promotionProgramInputStateList =
                  inputPageWrapper.promotionProgramInputState;

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: promotionProgramInputStateList.length,
                itemBuilder: (BuildContext context, index) {
                  if (index >= valuesControllers.length) {
                    valuesControllers.add(TextEditingController(text: "1"));
                  }
                  return Column(
                    children: [
                      customCard(index, inputPagePresenter),
                      if (index ==
                          promotionProgramInputStateList.length - 1) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorAccent,
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              _synchronizeValues();
                              inputPagePresenter.submitPromotionProgram();
                            },
                          ),
                        )
                      ],
                    ],
                  );
                },
              );
            }),
            Obx(() {
              bool isAddItemEnabled = inputPagePresenter
                          .customerNameInputPageDropdownStateRx
                          .value
                          .selectedChoice
                          ?.id ==
                      'prospect'
                  ? inputPagePresenter.isProspectValid.value &&
                      _isAddItemEnabled()
                  : _isAddItemEnabled();

              bool showAddNewDataButton = inputPagePresenter
                  .promotionProgramInputStateRx
                  .value
                  .promotionProgramInputState
                  .isEmpty;

              return showAddNewDataButton
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: colorAccent,
                        ),
                        onPressed: isAddItemEnabled
                            ? () {
                                _addItem();
                              }
                            : null,
                        child: const Text(
                          "Add New Data",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}
