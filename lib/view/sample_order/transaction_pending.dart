import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/sample_order/transaction_pending_controller.dart';
import 'package:noo_sms/models/approval.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:search_choices/search_choices.dart';

class TransactionPendingPage extends StatefulWidget {
  const TransactionPendingPage({super.key});

  @override
  TransactionPendingPageState createState() => TransactionPendingPageState();
}

class TransactionPendingPageState extends State<TransactionPendingPage> {
  final TransactionPendingController presenter =
      Get.put(TransactionPendingController());
  final FocusNode _principalNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    presenter.fetchApprovals();
  }

  @override
  void dispose() {
    _principalNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (presenter.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.rs(context)),
              Text(
                'Loading data...',
                style: TextStyle(fontSize: 16.rt(context)),
              ),
            ],
          ),
        );
      }

      if (presenter.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.ri(context),
                color: Colors.red[300],
              ),
              SizedBox(height: 16.rs(context)),
              Text(
                presenter.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.rt(context),
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 24.rs(context)),
              ElevatedButton.icon(
                onPressed: () => presenter.refreshData(),
                icon: Icon(
                  Icons.refresh,
                  size: 20.ri(context),
                ),
                label: Text(
                  'Retry',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.rp(context),
                    vertical: 12.rp(context),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (presenter.approvalList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64.ri(context),
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.rs(context)),
              Text(
                'No Data Found',
                style: TextStyle(
                  fontSize: 18.rt(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.rs(context)),
              Text(
                'Pull down to refresh',
                style: TextStyle(
                  fontSize: 14.rt(context),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.rs(context)),
              ElevatedButton.icon(
                onPressed: () => presenter.refreshData(),
                icon: Icon(
                  Icons.refresh,
                  size: 20.ri(context),
                ),
                label: Text(
                  'Refresh',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.rp(context),
                    vertical: 12.rp(context),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => presenter.refreshData(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: presenter.approvalList.length,
          itemBuilder: (context, index) {
            final approval = presenter.approvalList[index];
            return Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 16.rp(context), vertical: 8.rp(context)),
              padding: EdgeInsets.all(10.rp(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.rr(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8.rs(context),
                    spreadRadius: 1.rs(context),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.description,
                  color: colorAccent,
                  size: 24.ri(context),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Order Number : ",
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          approval.salesOrder ?? "N/A",
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                            color: colorBlack,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Order Date : ${approval.getFormattedDate()}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Customer Name : ${approval.customer ?? "N/A"}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    if (approval.desc != null)
                      Text(
                        'Purpose Description : ${approval.desc}',
                        style: TextStyle(fontSize: 16.rt(context)),
                      ),
                    Text(
                      'Purpose : ${approval.purpose}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Purpose Type : ${approval.purposeType}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Row(
                      children: [
                        Text(
                          "Status : ",
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          approval.status,
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                            color: colorBlack,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Is Claim ? : ${approval.isClaimed == 1 ? 'Yes' : 'No'}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Principal : ${approval.principal ?? ' '} ',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'New Principal : ${approval.newPrincipal ?? ' '}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () => presenter.showApprovalDetail(
                  approval.id,
                  showApprovalDialog,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void showApprovalDialog(int id, List<ApprovalDetail> details) {
    TextEditingController messageController = TextEditingController();
    List<TextEditingController> qtyControllers = [];

    for (var detail in details) {
      var controller = TextEditingController(text: detail.qty.toString());
      qtyControllers.add(controller);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      presenter.isClaim.value = false;
      presenter.principalList.value =
          InputPageDropdownState<IdAndValue<String>>(
        choiceList: presenter.principalList.value.choiceList,
        selectedChoice:
            presenter.principalList.value.choiceList?.isNotEmpty == true
                ? presenter.principalList.value.choiceList![0]
                : null,
        loadingState: 2,
      );
      presenter.principalNameTextEditingControllerRx.value.clear();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16.rp(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.rr(context)),
              ),
              child: GetBuilder<TransactionPendingController>(
                init: presenter,
                builder: (controller) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: AlertDialog(
                      insetPadding: EdgeInsets.all(8.rp(context)),
                      contentPadding: EdgeInsets.all(4.rp(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.rr(context)),
                        side: BorderSide.none,
                      ),
                      title: Center(
                        child: Text(
                          'Preview Details',
                          style: TextStyle(
                            color: colorAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.rt(context),
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.rp(context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...details.asMap().entries.map((entry) {
                                int index = entry.key;
                                ApprovalDetail detail = entry.value;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        detail.product,
                                        style:
                                            TextStyle(fontSize: 16.rt(context)),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'QTY : ',
                                                style: TextStyle(
                                                    fontSize: 14.rt(context)),
                                              ),
                                              Container(
                                                width: 150.rs(context),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.rr(context)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove,
                                                        size: 20.ri(context),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          int currentQty = int.tryParse(
                                                                  qtyControllers[
                                                                          index]
                                                                      .text) ??
                                                              0;
                                                          if (currentQty > 1) {
                                                            qtyControllers[
                                                                        index]
                                                                    .text =
                                                                (currentQty - 1)
                                                                    .toString();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      qtyControllers[index]
                                                          .text,
                                                      style: TextStyle(
                                                          fontSize:
                                                              14.rt(context)),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.add,
                                                        size: 20.ri(context),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          int currentQty = int.tryParse(
                                                                  qtyControllers[
                                                                          index]
                                                                      .text) ??
                                                              0;
                                                          qtyControllers[index]
                                                                  .text =
                                                              (currentQty + 1)
                                                                  .toString();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Unit: ${detail.unit}',
                                            style: TextStyle(
                                                fontSize: 14.rt(context)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                              Obx(() => CheckboxListTile(
                                    title: Text(
                                      'Claim to Principal',
                                      style:
                                          TextStyle(fontSize: 16.rt(context)),
                                    ),
                                    value: presenter.isClaim.value,
                                    onChanged: (bool? value) {
                                      presenter.isClaim.value = value ?? false;
                                      controller.update();
                                    },
                                  )),
                              if (presenter.isClaim.value)
                                Obx(() {
                                  final principalList =
                                      presenter.principalList.value.choiceList;
                                  return SearchChoices.single(
                                    hint: Text(
                                      "Select Principal",
                                      style:
                                          TextStyle(fontSize: 16.rt(context)),
                                    ),
                                    isExpanded: true,
                                    value: presenter
                                        .principalList.value.selectedChoice,
                                    items: principalList?.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item.value,
                                          style: TextStyle(
                                              fontSize: 16.rt(context)),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (IdAndValue<String>? newValue) {
                                      setState(() {
                                        presenter.changePrincipal(newValue);
                                      });
                                    },
                                  );
                                }),
                              if (presenter.isClaim.value &&
                                  presenter.principalList.value.selectedChoice
                                          ?.id ==
                                      '0')
                                Padding(
                                  padding: EdgeInsets.only(top: 8.rp(context)),
                                  child: TextField(
                                    controller: presenter
                                        .principalNameTextEditingControllerRx
                                        .value,
                                    style: TextStyle(fontSize: 16.rt(context)),
                                    decoration: InputDecoration(
                                      labelText: 'New Principal Name',
                                      labelStyle:
                                          TextStyle(fontSize: 14.rt(context)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.rr(context)),
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.rp(context)),
                                child: TextField(
                                  controller: messageController,
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 16.rt(context)),
                                  decoration: InputDecoration(
                                    labelText: 'Message (Optional)',
                                    labelStyle:
                                        TextStyle(fontSize: 14.rt(context)),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.rr(context)),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.rp(context)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.rr(context)),
                                        ),
                                      ),
                                      onPressed: () {
                                        for (int i = 0;
                                            i < details.length;
                                            i++) {
                                          details[i] = ApprovalDetail(
                                            productId: details[i].productId,
                                            product: details[i].product,
                                            qty: int.tryParse(
                                                    qtyControllers[i].text) ??
                                                details[i].qty,
                                            unit: details[i].unit,
                                          );
                                        }

                                        presenter.sendApproval(id, false,
                                            messageController.text, details);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'REJECT',
                                        style:
                                            TextStyle(fontSize: 16.rt(context)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.rs(context)),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.rp(context)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.rr(context)),
                                        ),
                                      ),
                                      onPressed: () {
                                        for (int i = 0;
                                            i < details.length;
                                            i++) {
                                          details[i] = ApprovalDetail(
                                            productId: details[i].productId,
                                            product: details[i].product,
                                            qty: int.tryParse(
                                                    qtyControllers[i].text) ??
                                                details[i].qty,
                                            unit: details[i].unit,
                                          );
                                        }

                                        presenter.sendApproval(id, true,
                                            messageController.text, details);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'APPROVE',
                                        style:
                                            TextStyle(fontSize: 16.rt(context)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _addQuantity(
      int index, bool isIncrement, List<TextEditingController> qtyControllers) {
    int currentQty = int.tryParse(qtyControllers[index].text) ?? 0;
    if (isIncrement) {
      currentQty += 1;
    } else if (currentQty > 1) {
      currentQty -= 1;
    }
    qtyControllers[index].text = currentQty.toString();
  }
}
