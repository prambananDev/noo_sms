import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _customerPICFocusNode = FocusNode();
  final FocusNode _customerPhoneFocusNode = FocusNode();
  final FocusNode _customerAddressFocusNode = FocusNode();

  final FocusNode _invoiceIdFocusNode = FocusNode();
  final FocusNode _salesIdFocusNode = FocusNode();

  void _closeKeyboard() {
    _qtyAddFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    _customerNameFocusNode.unfocus();
    _customerPICFocusNode.unfocus();
    _customerPhoneFocusNode.unfocus();
    _customerAddressFocusNode.unfocus();
    _invoiceIdFocusNode.unfocus();
    _salesIdFocusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
    inputPagePresenter.requestPermissions();
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
  }

  @override
  void dispose() {
    for (var controller in valuesControllers) {
      controller.dispose();
    }
    for (var focusNode in qtyFocusNodes) {
      focusNode.dispose();
    }

    inputPagePresenter.custNameTextEditingControllerRx.value
        .removeListener(_updateProspectValidity);
    inputPagePresenter.custPicTextEditingControllerRx.value
        .removeListener(_updateProspectValidity);
    inputPagePresenter.custPhoneTextEditingControllerRx.value
        .removeListener(_updateProspectValidity);
    inputPagePresenter.custAddressTextEditingControllerRx.value
        .removeListener(_updateProspectValidity);

    _descriptionFocusNode.dispose();
    _customerNameFocusNode.dispose();
    _customerPICFocusNode.dispose();
    _customerPhoneFocusNode.dispose();
    _customerAddressFocusNode.dispose();
    _invoiceIdFocusNode.dispose();
    _salesIdFocusNode.dispose();
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

  bool _isAddItemEnabled() {
    bool isPurposeDescriptionFilled = inputPagePresenter
        .purposeDescTextEditingControllerRx.value.text.isNotEmpty;

    String? sampleType =
        inputPagePresenter.typesList.value.selectedChoice?.value;

    if (sampleType == null) {
      return false;
    }

    if (sampleType == 'Commercial') {
      return isPurposeDescriptionFilled;
    } else if (sampleType == 'Non Commercial') {
      bool isDepartmentSelected =
          inputPagePresenter.deptList.value.selectedChoice != null;

      bool isPurposeSelected =
          inputPagePresenter.purposeList.value.selectedChoice != null;

      return isPurposeDescriptionFilled &&
          isDepartmentSelected &&
          isPurposeSelected;
    }

    return false;
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
      margin: EdgeInsets.symmetric(
          horizontal: 16.rp(context), vertical: 8.rp(context)),
      padding: EdgeInsets.all(
          ResponsiveUtil.isIPad(context) ? 20.rp(context) : 16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
            offset: Offset(0, 2.rs(context)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Add Lines",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.rt(context)),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addItem,
                icon: Icon(Icons.add, size: 24.ri(context)),
                padding: EdgeInsets.all(8.rp(context)),
              ),
              IconButton(
                onPressed: () {
                  _removeItem(index);
                },
                icon:
                    Icon(Icons.delete, color: Colors.red, size: 24.ri(context)),
                padding: EdgeInsets.all(8.rp(context)),
              ),
            ],
          ),
          SearchChoices.single(
            isExpanded: true,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.rt(context),
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
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item.value,
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              );
            }).toList(),
            hint: Text(
              "Select Product",
              style: TextStyle(
                fontSize: 16.rt(context),
              ),
            ),
            onChanged: (value) {
              inputPagePresenter.changeProduct(index, value);
            },
          ),
          SizedBox(height: 16.rs(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'QTY',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.rt(context)),
                  ),
                  Container(
                    width: ResponsiveUtil.isIPad(context)
                        ? MediaQuery.of(context).size.width * 0.35
                        : MediaQuery.of(context).size.width * 0.4,
                    height: ResponsiveUtil.isIPad(context)
                        ? 55.rs(context)
                        : MediaQuery.of(context).size.height * 0.06,
                    margin: EdgeInsets.only(bottom: 8.rp(context)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.rr(context)),
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
                          icon: Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 24.ri(context),
                          ),
                          padding: EdgeInsets.all(4.rp(context)),
                        ),
                        SizedBox(
                          width: ResponsiveUtil.isIPad(context)
                              ? 50.rs(context)
                              : MediaQuery.of(context).size.width * 0.1,
                          child: TextField(
                            focusNode: qtyFocusNodes[index],
                            autofocus: false,
                            textAlign: TextAlign.center,
                            controller: values,
                            style: TextStyle(fontSize: 16.rt(context)),
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
                          icon: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 24.ri(context),
                          ),
                          padding: EdgeInsets.all(4.rp(context)),
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
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 16.rt(context)),
                        ),
                      );
                    }).toList() ??
                    [],
                style: TextStyle(fontSize: 16.rt(context), color: Colors.black),
                hint: Text(
                  promotionProgramInputState.productTransactionPageDropdownState
                              ?.selectedChoiceWrapper?.value ==
                          null
                      ? "Unit"
                      : "Select Unit",
                  style: TextStyle(fontSize: 16.rt(context)),
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
      margin: EdgeInsets.symmetric(
          horizontal: 16.rp(context), vertical: 8.rp(context)),
      padding: EdgeInsets.all(
          ResponsiveUtil.isIPad(context) ? 20.rp(context) : 16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
            offset: Offset(0, 2.rs(context)),
          ),
        ],
      ),
      child: Obx(
        () {
          final isCommercial =
              inputPagePresenter.typesList.value.selectedChoice?.value ==
                  'Commercial';

          final isBonus =
              inputPagePresenter.purposeList.value.selectedChoice?.value ==
                  'Bonus';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New Sample Order",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.rt(context)),
              ),
              SizedBox(height: 16.rs(context)),
              SearchChoices.single(
                isExpanded: true,
                value: inputPagePresenter.typesList.value.selectedChoice,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.rt(context),
                ),
                menuBackgroundColor: Colors.white,
                underline: Container(
                  height: 1,
                  color: Colors.grey,
                ),
                hint: Text(
                  "Sample Types",
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
                items:
                    inputPagePresenter.typesList.value.choiceList?.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.value,
                        style: TextStyle(fontSize: 16.rt(context))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _closeKeyboard();
                    inputPagePresenter.changeSampleType(value);
                  });
                },
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
              ),
              SizedBox(height: 16.rs(context)),
              Obx(
                () => SearchChoices.single(
                  isExpanded: true,
                  value: inputPagePresenter.purposeList.value.selectedChoice,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.rt(context),
                  ),
                  menuBackgroundColor: Colors.white,
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  hint: Text(
                    "Select Purpose",
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
                  items: inputPagePresenter.purposeList.value.choiceList
                      ?.map((purpose) {
                    return DropdownMenuItem<IdAndValue<String>>(
                      value: purpose,
                      child: Text(
                        purpose.value,
                        style: TextStyle(fontSize: 16.rt(context)),
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
              Padding(
                padding: EdgeInsets.only(top: 16.rp(context)),
                child: Text(
                  "Purpose Description",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.rt(context),
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
                  padding: EdgeInsets.only(
                      top: 8.rp(context), bottom: 16.rp(context)),
                  child: TextField(
                    focusNode: _descriptionFocusNode,
                    controller: inputPagePresenter
                        .purposeDescTextEditingControllerRx.value,
                    maxLines: null,
                    style: TextStyle(fontSize: 16.rt(context)),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Submit description here',
                      hintStyle: TextStyle(fontSize: 16.rt(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.rr(context)),
                        borderSide: BorderSide(
                            width: 1.rs(context), color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.all(12.rp(context)),
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
                        clearSearchIcon:
                            Icon(Icons.clear_all, size: 20.ri(context)),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.rt(context),
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
                        hint: Text(
                          "Customer Name",
                          style: TextStyle(fontSize: 16.rt(context)),
                        ),
                        items: inputPagePresenter
                            .customerNameInputPageDropdownStateRx
                            .value
                            .choiceList
                            ?.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.value,
                                style: TextStyle(fontSize: 16.rt(context))),
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
                        Padding(
                          padding: EdgeInsets.only(top: 16.rp(context)),
                          child: Text(
                            "Customer Name/Alias",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: TextField(
                            focusNode: _customerNameFocusNode,
                            controller: inputPagePresenter
                                .custNameTextEditingControllerRx.value,
                            maxLines: null,
                            style: TextStyle(fontSize: 16.rt(context)),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.rr(context)),
                                borderSide: BorderSide(
                                    width: 1.rs(context), color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(12.rp(context)),
                            ),
                          ),
                        ),
                        Text(
                          "Customer PIC",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: TextField(
                            focusNode: _customerPICFocusNode,
                            controller: inputPagePresenter
                                .custPicTextEditingControllerRx.value,
                            maxLines: 1,
                            style: TextStyle(fontSize: 16.rt(context)),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.rr(context)),
                                borderSide: BorderSide(
                                    width: 1.rs(context), color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(12.rp(context)),
                            ),
                          ),
                        ),
                        Text(
                          "Customer Phone",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: TextField(
                            focusNode: _customerPhoneFocusNode,
                            controller: inputPagePresenter
                                .custPhoneTextEditingControllerRx.value,
                            maxLines: 1,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(fontSize: 16.rt(context)),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.rr(context)),
                                borderSide: BorderSide(
                                    width: 1.rs(context), color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(12.rp(context)),
                            ),
                          ),
                        ),
                        Text(
                          "Customer Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: ResponsiveUtil.isIPad(context)
                                  ? 350.rs(context)
                                  : 300.rs(context),
                            ),
                            child: TextField(
                              focusNode: _customerAddressFocusNode,
                              keyboardType: TextInputType.streetAddress,
                              controller: inputPagePresenter
                                  .custAddressTextEditingControllerRx.value,
                              maxLines: null,
                              style: TextStyle(fontSize: 16.rt(context)),
                              decoration: InputDecoration(
                                hintText: 'Customer Address',
                                hintStyle: TextStyle(fontSize: 16.rt(context)),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10.rr(context)),
                                  borderSide: BorderSide(
                                      width: 1.rs(context), color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.all(12.rp(context)),
                              ),
                            ),
                          ),
                        ),
                        SearchChoices.single(
                          isExpanded: true,
                          value: inputPagePresenter
                              .distributionChannelList.value.selectedChoice,
                          hint: Text(
                            "Distribution Channel",
                            style: TextStyle(fontSize: 16.rt(context)),
                          ),
                          items: inputPagePresenter
                              .distributionChannelList.value.choiceList
                              ?.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item.value,
                                  style: TextStyle(fontSize: 16.rt(context))),
                            );
                          }).toList(),
                          onChanged: (IdAndValue<String>? value) {
                            inputPagePresenter.changeDistributionChannel(value);
                          },
                        ),
                      ],
                      if (isBonus) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 16.rp(context)),
                          child: Text(
                            "Sales ID AX",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            focusNode: _salesIdFocusNode,
                            controller: inputPagePresenter
                                .salesIdTextEditingControllerRx.value,
                            maxLines: null,
                            style: TextStyle(fontSize: 16.rt(context)),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.rr(context)),
                                borderSide: BorderSide(
                                    width: 1.rs(context), color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(12.rp(context)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.rp(context)),
                          child: Text(
                            "Invoice ID AX",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 8.rp(context), bottom: 16.rp(context)),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            focusNode: _invoiceIdFocusNode,
                            controller: inputPagePresenter
                                .invoiceIdTextEditingControllerRx.value,
                            maxLines: null,
                            style: TextStyle(fontSize: 16.rt(context)),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.rr(context)),
                                borderSide: BorderSide(
                                    width: 1.rs(context), color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(12.rp(context)),
                            ),
                          ),
                        ),
                        Obx(() => GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16.rr(context)),
                                        ),
                                        title: Text(
                                          "Attach Document",
                                          style: TextStyle(
                                              fontSize: 18.rt(context)),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                inputPagePresenter
                                                    .pickAndUploadFile();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(colorAccent),
                                                foregroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(Colors.white),
                                                elevation: WidgetStateProperty
                                                    .all<double>(4.rs(context)),
                                                padding: WidgetStateProperty
                                                    .all<EdgeInsets>(
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                20.rp(context),
                                                            vertical: 12
                                                                .rp(context))),
                                                shape: WidgetStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.rr(context)),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                "Choose File",
                                                style: TextStyle(
                                                  fontSize: 16.rt(context),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: inputPagePresenter
                                      .uploadedFileName.value.isEmpty
                                  ? Container(
                                      width: ResponsiveUtil.isIPad(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.4
                                          : MediaQuery.of(context).size.width *
                                              0.5,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.rp(context),
                                          vertical: 10.rp(context)),
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(
                                            10.rr(context)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Attach Document",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.rt(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      inputPagePresenter.uploadedFileName.value,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.rt(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),
                      ],
                    ],
                  );
                }),
              ],
              if (inputPagePresenter.typesList.value.selectedChoice?.value ==
                  'Non Commercial') ...[
                SizedBox(height: 16.rs(context)),
                Obx(
                  () {
                    final deptState = inputPagePresenter.deptList.value;
                    return DropdownButtonHideUnderline(
                      child: SearchChoices.single(
                        isExpanded: true,
                        hint: Text(
                          "Select Department",
                          style: TextStyle(fontSize: 16.rt(context)),
                        ),
                        value: deptState.selectedChoice,
                        items: deptState.choiceList?.map((dept) {
                          return DropdownMenuItem<IdAndValue<String>>(
                            value: dept,
                            child: Text(
                              dept.value,
                              style: TextStyle(fontSize: 16.rt(context)),
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
                  },
                ),
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.isIPad(context) ? 24.rp(context) : 0,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.rp(context)),
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
                          padding:
                              EdgeInsets.symmetric(vertical: 16.rp(context)),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.rp(context),
                                vertical: 16.rp(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.rr(context)),
                              ),
                            ),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 16.rt(context),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
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
                      padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.rr(context)),
                          ),
                          backgroundColor: colorAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.rp(context),
                            vertical: 16.rp(context),
                          ),
                        ),
                        onPressed: isAddItemEnabled
                            ? () {
                                _addItem();
                              }
                            : null,
                        child: Text(
                          "Add New Data",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            }),
            SizedBox(height: 16.rs(context)),
          ],
        ),
      ),
    );
  }
}
