import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
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

  void _closeKeyboard() {
    _principalNameFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (presenter.approvalList.isEmpty) {
        return const Center(
          child: Text(
            'Data Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }
      return ListView.builder(
        itemCount: presenter.approvalList.length,
        itemBuilder: (context, index) {
          final approval = presenter.approvalList[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(10),
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
            child: ListTile(
              leading: Icon(
                Icons.description,
                color: colorAccent,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Order Number : ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        approval.salesOrder ?? "N/A",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorBlack),
                      ),
                    ],
                  ),
                  Text(
                    'Order Date : ${approval.getFormattedDate()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Customer Name : ${approval.customer ?? "N/A"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (approval.desc != null)
                    Text('Purpose Description : ${approval.desc}',
                        style: const TextStyle(fontSize: 16)),
                  Text('Purpose : ${approval.purpose}',
                      style: const TextStyle(fontSize: 16)),
                  Text('Purpose Type : ${approval.purposeType}',
                      style: const TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      const Text(
                        "Status : ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        approval.status,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorBlack),
                      ),
                    ],
                  ),
                  Text('Is Claim ? : ${approval.isClaimed == 1 ? 'Yes' : 'No'}',
                      style: const TextStyle(fontSize: 16)),
                  Text('Principal : ${approval.principal ?? ' '} ',
                      style: const TextStyle(fontSize: 16)),
                  Text('New Principal : ${approval.newPrincipal ?? ' '}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              isThreeLine: true,
              onTap: () => presenter.showApprovalDetail(
                  context, approval.id, showApprovalDialog),
            ),
          );
        },
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: GetBuilder<TransactionPendingController>(
                init: presenter,
                builder: (controller) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      contentPadding: const EdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      ),
                      title: Center(
                        child: Text(
                          'Preview Details',
                          style: TextStyle(
                            color: colorAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                      title: Text(detail.product),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('QTY : '),
                                              Container(
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
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
                                                    Text(qtyControllers[index]
                                                        .text),
                                                    IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
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
                                          Text('Unit: ${detail.unit}'),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),

                              Obx(() => CheckboxListTile(
                                    title: const Text('Claim to Principal'),
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
                                    hint: const Text("Select Principal"),
                                    isExpanded: true,
                                    value: presenter
                                        .principalList.value.selectedChoice,
                                    items: principalList?.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item.value),
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
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    controller: presenter
                                        .principalNameTextEditingControllerRx
                                        .value,
                                    decoration: InputDecoration(
                                      labelText: 'New Principal Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              // Message Input
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextField(
                                  controller: messageController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Message (Optional)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Update details with current qty
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

                                        // Send rejection
                                        presenter.sendApproval(id, false,
                                            messageController.text, details);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('REJECT'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Update details with current qty
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
                                      child: const Text('APPROVE'),
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
