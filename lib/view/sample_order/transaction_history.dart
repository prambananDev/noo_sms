import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/button_widget.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/sample_order/transaction_history_controller.dart';
import 'package:noo_sms/models/transaction_history_sample.dart';
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
                        borderRadius: BorderRadius.circular(20.rr(context)),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              children:
                                  inputPagePresenter.listDetail.map((detail) {
                                return ListTile(
                                  title: Text(
                                    'Product: ${detail["Product"]}',
                                    style: TextStyle(fontSize: 16.rt(context)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unit: ${detail["Unit"]}',
                                        style:
                                            TextStyle(fontSize: 14.rt(context)),
                                      ),
                                      Text(
                                        'Qty: ${detail["Qty"]}',
                                        style:
                                            TextStyle(fontSize: 14.rt(context)),
                                      ),
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
                                  minimumSize: Size(0, 45.rs(context)),
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.rr(context)),
                                  ),
                                ),
                                child: Text(
                                  'Close',
                                  style: TextStyle(fontSize: 16.rt(context)),
                                ),
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
                margin: EdgeInsets.symmetric(
                    horizontal: 16.rp(context), vertical: 8.rp(context)),
                padding: EdgeInsets.all(16.rp(context)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          transaction.salesId ?? "N/A",
                          style: TextStyle(
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.bold,
                              color: colorBlack),
                        ),
                      ],
                    ),
                    Text(
                      'Order Date : ${DateFormat("dd-MM-yyyy hh:mm").format(DateTime.parse(transaction.date!))}',
                      style: TextStyle(
                          fontSize: 16.rt(context),
                          fontWeight: FontWeight.w300),
                    ),
                    Text(
                      'Customer Name : ${transaction.customer ?? "N/A"}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Segment : ${transaction.segment}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Address : ${transaction.address}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'PIC : ${transaction.pic}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Phone Number: ${transaction.phone}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Purpose Type : ${transaction.purposeType}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Purpose : ${transaction.purpose}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Purpose Description : ${transaction.desc}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Sales Office : ${transaction.salesoffice}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Business Unit : ${transaction.businessUnit}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Departement : ${transaction.dept}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Claim : ${transaction.isClaimed}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Principal : ${transaction.principal}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Feedback : ${transaction.feedback}',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    Text(
                      'Feedback Note : ${transaction.notes ?? "N/A"}',
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
                          statusText,
                          style: TextStyle(
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.w300,
                              color: statusColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Attachment : ",
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await inputPagePresenter.downloadFile(
                                salesId: transaction.id!, context: context);
                          },
                          child: Text(
                            "Download File",
                            style: TextStyle(
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.w300,
                              color: colorAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonOrderSample(
                            size: MediaQuery.of(context).size,
                            onTapAction: () async {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 24.rs(context),
                                            height: 24.rs(context),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                          SizedBox(height: 16.rs(context)),
                                          Text(
                                            'Loading approval information...',
                                            style: TextStyle(
                                                fontSize: 16.rt(context)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                final List<ApprovalInfo> approvalInfo =
                                    await inputPagePresenter
                                        .fetchApprovalInfo(transaction.id ?? 0);

                                Navigator.pop(context);

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Approval Information",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.rt(context),
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: approvalInfo.map((info) {
                                            final statusColor =
                                                info.status == 'Approved'
                                                    ? Colors.green
                                                    : info.status == 'Pending'
                                                        ? Colors.orange
                                                        : Colors.red;

                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.rp(context)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Level ${info.level} - ${info.name}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.rt(context),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Status: ',
                                                        style: TextStyle(
                                                            fontSize:
                                                                14.rt(context)),
                                                      ),
                                                      Text(
                                                        info.status,
                                                        style: TextStyle(
                                                          fontSize:
                                                              14.rt(context),
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (info.message != null) ...[
                                                    Text(
                                                      'Message: ${info.message}',
                                                      style: TextStyle(
                                                          fontSize:
                                                              14.rt(context)),
                                                    ),
                                                  ],
                                                  if (info.time != null) ...[
                                                    Text(
                                                      'Time: ${DateFormat("dd-MM-yyyy HH:mm").format(info.time!)}',
                                                      style: TextStyle(
                                                          fontSize:
                                                              14.rt(context)),
                                                    ),
                                                  ],
                                                  const Divider(),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Close',
                                            style: TextStyle(
                                                fontSize: 16.rt(context)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } catch (e) {
                                Navigator.pop(context);

                                Get.snackbar(
                                  'Error',
                                  'Failed to load approval information',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            colorIcon: Colors.white,
                            nameButton: "Info",
                          ),
                          ButtonOrderSample(
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
                                            title: Text(
                                              "Feedback",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.rt(context),
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
                                                    style: TextStyle(
                                                        fontSize:
                                                            16.rt(context),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                8.rp(context)),
                                                    child: Text(
                                                      "Notes : ${inputPagePresenter.feedbackDetail.value.notes!}",
                                                      style: TextStyle(
                                                          fontSize:
                                                              16.rt(context)),
                                                    ),
                                                  ),
                                                  fetchedData != null
                                                      ? Image.memory(
                                                          fetchedData,
                                                          fit: BoxFit.fitWidth)
                                                      : SizedBox(
                                                          height:
                                                              200.rs(context),
                                                          child: Center(
                                                            child: Text(
                                                              "No Image Loaded",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 16.rt(
                                                                    context),
                                                              ),
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
                                                child: Text(
                                                  'Close',
                                                  style: TextStyle(
                                                      fontSize: 16.rt(context)),
                                                ),
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
                                            title: Text(
                                              "Upload POD",
                                              style: TextStyle(
                                                  fontSize: 18.rt(context)),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    handleUploadsPOD(salesId,
                                                        ImageSource.camera);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(
                                                        double.infinity,
                                                        45.rs(context)),
                                                  ),
                                                  child: Text(
                                                    "Camera",
                                                    style: TextStyle(
                                                        fontSize:
                                                            16.rt(context)),
                                                  ),
                                                ),
                                                SizedBox(height: 8.rs(context)),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    handleUploadsPOD(salesId,
                                                        ImageSource.gallery);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(
                                                        double.infinity,
                                                        45.rs(context)),
                                                  ),
                                                  child: Text(
                                                    "Gallery",
                                                    style: TextStyle(
                                                        fontSize:
                                                            16.rt(context)),
                                                  ),
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
                                          title: Text(
                                            "POD Image",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.rt(context),
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
                                                : Center(
                                                    child: Text(
                                                      "No Image Loaded",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            16.rt(context),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'Close',
                                                style: TextStyle(
                                                    fontSize: 16.rt(context)),
                                              ),
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
