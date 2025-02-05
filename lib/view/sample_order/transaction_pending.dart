import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/sample_order/transaction_pending_controller.dart';
import 'package:noo_sms/models/approval.dart';

class TransactionPendingPage extends StatefulWidget {
  const TransactionPendingPage({super.key});

  @override
  TransactionPendingPageState createState() => TransactionPendingPageState();
}

class TransactionPendingPageState extends State<TransactionPendingPage> {
  final TransactionPendingController presenter =
      Get.put(TransactionPendingController());

  @override
  void initState() {
    super.initState();
    presenter.fetchApprovals();
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
              leading: Icon(Icons.description, color: colorAccent),
              title: Text(
                approval.salesOrder,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer : ${approval.customer}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Date : ${approval.getFormattedDate()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text('Status : ${approval.status}',
                      style: const TextStyle(fontSize: 16)),
                  if (approval.desc != null)
                    Text('Description : ${approval.desc}',
                        style: const TextStyle(fontSize: 16)),
                  Text('Purpose : ${approval.purpose}',
                      style: const TextStyle(fontSize: 16)),
                  Text('Purpose Type : ${approval.purposeType}',
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
    List<TextEditingController> qtyControllers = details
        .map((detail) => TextEditingController(text: detail.qty.toString()))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight -
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        ...details.asMap().entries.map((entry) {
                          int index = entry.key;
                          ApprovalDetail detail = entry.value;
                          return Column(
                            children: [
                              ListTile(
                                title: Text(detail.product),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('QTY : '),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              width: 0.5,
                                              color: const Color.fromARGB(
                                                  167, 37, 37, 37),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _addQuantity(index, false,
                                                      qtyControllers);
                                                },
                                                icon: const Icon(
                                                  Icons.remove,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                child: TextField(
                                                  autofocus: false,
                                                  textAlign: TextAlign.center,
                                                  controller:
                                                      qtyControllers[index],
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                    decimal: false,
                                                    signed: true,
                                                  ),
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                  ],
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  _addQuantity(index, true,
                                                      qtyControllers);
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Unit: ${detail.unit}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            controller: messageController,
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
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  for (int i = 0; i < details.length; i++) {
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
                                child: const Text('REJECT'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorAccent,
                                  minimumSize: const Size(0, 45),
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  for (int i = 0; i < details.length; i++) {
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
              );
            },
          ),
        );
      },
    );
  }

  void _addQuantity(
      int index, bool isIncrement, List<TextEditingController> qtyControllers) {
    int currentQty = int.tryParse(qtyControllers[index].text) ?? 0;
    if (isIncrement) {
      qtyControllers[index].text = (currentQty + 1).toString();
    } else {
      if (currentQty > 1) {
        qtyControllers[index].text = (currentQty - 1).toString();
      }
    }
  }
}
