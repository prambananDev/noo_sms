import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/button_widget.dart';
import 'package:noo_sms/controllers/sample_order/transaction_history_controller.dart';
import 'package:noo_sms/view/sample_order/transaction_feedback.dart';

class TransactionHistorySampleView extends StatefulWidget {
  const TransactionHistorySampleView({Key? key}) : super(key: key);

  @override
  State<TransactionHistorySampleView> createState() =>
      _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistorySampleView> {
  final TransactionHistorySampleController inputPagePresenter =
      Get.put(TransactionHistorySampleController());
  final ImagePicker imagePicker = ImagePicker();
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    inputPagePresenter.getTransactionHistory();
  }

  void handleUploadsPOD(String salesId, ImageSource source) async {
    await inputPagePresenter.uploadsPOD(salesId, source);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: inputPagePresenter.transactionHistory.length,
          itemBuilder: (context, int index) {
            final transaction = inputPagePresenter.transactionHistory[index];
            bool isPODButtonActive = false;
            bool isFeedbackButtonActive = false;
            bool isFeedbackEditable = true;
            String statusText = "Pending";
            Color statusColor = Colors.grey;

            if (transaction.status == 'Pending') {
              statusText = "Pending";
              statusColor = Colors.grey;
            } else if (transaction.status == 'Approved') {
              if (transaction.docStatus == 0) {
                statusText = "Approved";
                statusColor = Colors.orange;
                isPODButtonActive = false;
                isFeedbackButtonActive = false;
              } else if (transaction.docStatus == 1) {
                statusText = "Delivered";
                statusColor = Colors.blue;
                isPODButtonActive = true;
                isFeedbackButtonActive = false;
              } else if (transaction.docStatus == 2) {
                statusText = "Received";
                statusColor = Colors.green;
                isPODButtonActive = true;
                isFeedbackButtonActive = true;
              } else if (transaction.docStatus == 3) {
                statusText = "Closed";
                statusColor = Colors.red;
                isPODButtonActive = true;
                isFeedbackButtonActive = true;
                isFeedbackEditable = false;
              }
            }

            return InkWell(
              onTap: () async {
                String? idTransaction = transaction.salesId;

                await inputPagePresenter
                    .getTransactionHistoryDetail(idTransaction!);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              children:
                                  inputPagePresenter.listDetail.map((detail) {
                                return ListTile(
                                  title: Text('Product: ${detail["Product"]}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Unit: ${detail["Unit"]}'),
                                      Text('Qty: ${detail["Qty"]}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorAccent,
                                  minimumSize: const Size(0, 45),
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
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
                  title: Text(
                    transaction.salesId ?? "N/A",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Customer : ${transaction.customer}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Cust.Reff : ${transaction.custReff}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Date: ${DateFormat("dd-MM-yyyy hh:mm").format(DateTime.parse(transaction.date!))}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
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
                            statusText,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: statusColor),
                          ),
                        ],
                      ),
                      Text(
                        'Description : ${transaction.desc}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Address : ${transaction.address}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'PIC : ${transaction.pic}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Phone : ${transaction.phone}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Principal : ${transaction.principal}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Segment : ${transaction.segment}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Notes : ${transaction.notes}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Sales Office : ${transaction.salesoffice}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Business Unit : ${transaction.businessUnit}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Dept : ${transaction.dept}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Claim : ${transaction.isClaimed}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Feedback : ${transaction.feedback}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Purpose : ${transaction.purpose}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Purpose Type : ${transaction.purposeType}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: ButtonOrderSample(
                              size: MediaQuery.of(context).size,
                              onTapAction: isFeedbackButtonActive
                                  ? () async {
                                      if (transaction.docStatus == 2) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FeedbackPage(
                                                      index: index,
                                                      inputPagePresenter:
                                                          inputPagePresenter,
                                                      salesId:
                                                          transaction.salesId!,
                                                    )));
                                      } else if (transaction.docStatus == 3) {
                                        Uint8List? fetchedData =
                                            await inputPagePresenter
                                                .fetchImageFeed(
                                                    transaction.salesId!);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Feedback",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.9,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      " ${inputPagePresenter.feedbackDetail.value.feedbackName}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: Text(
                                                        "Notes : ${inputPagePresenter.feedbackDetail.value.notes!}",
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    fetchedData != null
                                                        ? Image.memory(
                                                            fetchedData,
                                                            fit:
                                                                BoxFit.fitWidth)
                                                        : const SizedBox(
                                                            height: 200,
                                                            child: Center(
                                                              child: Text(
                                                                "No Image Loaded",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null,
                              colorIcon: isFeedbackButtonActive
                                  ? Colors.white
                                  : Colors.grey,
                              nameButton: "Feedback",
                            ),
                          ),
                          ButtonOrderSample(
                            imageData: imageData,
                            size: MediaQuery.of(context).size,
                            onTapAction: isPODButtonActive
                                ? () async {
                                    String? salesId = transaction.salesId;

                                    Uint8List? fetchedData =
                                        await inputPagePresenter
                                            .fetchImagePOD(salesId!);

                                    if (transaction.docStatus == 1) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Upload POD"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    handleUploadsPOD(salesId,
                                                        ImageSource.camera);
                                                  },
                                                  child: const Text("Camera"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    handleUploadsPOD(salesId,
                                                        ImageSource.gallery);
                                                  },
                                                  child: const Text("Gallery"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    } else if (transaction.docStatus == 2 ||
                                        transaction.docStatus == 3) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text(
                                            "POD Image",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            child: fetchedData != null
                                                ? Image.memory(fetchedData,
                                                    fit: BoxFit.fitWidth)
                                                : const Center(
                                                    child: Text(
                                                        "No Image Loaded",
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            colorIcon:
                                isPODButtonActive ? Colors.white : Colors.grey,
                            nameButton: "POD",
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
