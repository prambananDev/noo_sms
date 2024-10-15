import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart'; // Assuming TextResultCard is a custom widget
import 'package:noo_sms/view/promotion_program/approval/history_so.dart';
import 'package:provider/provider.dart';
import 'package:noo_sms/controllers/provider/lines_provider.dart';
import 'package:search_choices/search_choices.dart';

class CardLinesAdapter extends StatefulWidget {
  final String namePP;
  final int idEmp;
  final Promotion promotion;
  final int index;
  final bool startApp;
  final bool valueSelectAll;
  final bool statusDisable;
  final bool showSalesHistory;
  List<TextEditingController>? disc1Controller;
  final List<TextEditingController> disc2Controller;
  final List<TextEditingController> disc3Controller;
  final List<TextEditingController> disc4Controller;
  // List<TextEditingController> value1Controller;
  // List<TextEditingController> value2Controller;
  final List<dynamic> unitController;
  // List<String> suppItemController;
  // List<String> suppUnitController;
  // List<dynamic> warehouseController;
  // List<Map<String, dynamic>> addToLines;
  final List<dynamic> dataUnit;
  // List<dynamic> dataSupplyUnit;
  // List<dynamic> dataWarehouse;
  // List<dynamic> dataSupplyItem;
  final Function(String itemId) getUnit;
  // Function(String itemId) getSupplyUnit;
  // Function(String itemId) getWarehouse;

  CardLinesAdapter({
    Key? key,
    required this.namePP,
    required this.idEmp,
    required this.promotion,
    required this.index,
    required this.startApp,
    required this.valueSelectAll,
    required this.statusDisable,
    required this.showSalesHistory,
    // required this.qtyFromController,
    // required this.qtyToController,
    this.disc1Controller,
    required this.disc2Controller,
    required this.disc3Controller,
    required this.disc4Controller,
    // required this.value1Controller,
    // required this.value2Controller,
    required this.unitController,
    // required this.suppItemController,
    // required this.suppUnitController,
    // required this.warehouseController,
    // required this.addToLines,
    required this.dataUnit,
    // required this.dataSupplyUnit,
    // required this.dataWarehouse,
    // required this.dataSupplyItem,
    required this.getUnit,
    // required this.getSupplyUnit,
    // required this.getWarehouse,
  }) : super(key: key);

  @override
  _CardLinesAdapterState createState() => _CardLinesAdapterState();
}

class _CardLinesAdapterState extends State<CardLinesAdapter> {
  late TextEditingController qtyFromcontroller;
  late TextEditingController qtyTocontroller;

  @override
  void initState() {
    super.initState();
    qtyFromcontroller =
        TextEditingController(text: widget.promotion.qty.toString());
    qtyTocontroller =
        TextEditingController(text: widget.promotion.qtyTo.toString());
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    qtyFromcontroller.dispose();
    qtyTocontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double price = double.parse(widget.promotion.price
            ?.replaceAll(RegExp("Rp"), "")
            .replaceAll(".", "") ??
        "0");
    double disc1 = double.parse(widget.promotion.disc1 ?? "0");
    double disc2 = double.parse(widget.promotion.disc2 ?? "0");
    double disc3 = double.parse(widget.promotion.disc3 ?? "0");
    double disc4 = double.parse(widget.promotion.disc4 ?? "0");
    double discValue1 = double.parse(widget.promotion.value1 ?? "0");
    double discValue2 = double.parse(widget.promotion.value2 ?? "0");
    double totalPriceDiscOnly =
        price - (price * ((disc1 + disc2 + disc3 + disc4) / 100));
    double totalPriceDiscValue = price - (discValue1 + discValue2);

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: CheckboxListTile(
              value: widget.valueSelectAll
                  ? widget.valueSelectAll
                  : widget.promotion.status,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.promotion.status = value;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
            ),
          ),
          TextResultCard(
            title: "Product",
            value: widget.promotion.product!,
          ),
          buildQtyRow(context, qtyFromcontroller, qtyTocontroller),
          // buildUnitField(context, widget.index),
          TextResultCard(
            title: "Unit",
            value: widget.promotion.unitId.toString(),
          ),
          TextResultCard(
            title: "Price",
            value: widget.promotion.price!,
          ),
          // if (widget.promotion.ppType != "Bonus")
          //   buildDiscountFields(context, totalPriceDiscOnly),
          // if (widget.promotion.ppType != "Diskon") buildBonusFields(context),
          // buildNetPriceField(context, totalPriceDiscOnly, totalPriceDiscValue),
          // if (widget.showSalesHistory)
          //   buildSalesHistoryButton(
          //       context), // Conditionally display the button
        ],
      ),
    );
  }

  // Helper method to build Qty fields
  Widget buildQtyRow(
      BuildContext context,
      TextEditingController qtyFromController,
      TextEditingController qtyToController) {
    return Row(
      children: [
        buildQtyField(context, "Qty From", qtyFromController),
        buildQtyField(context, "Qty To", qtyToController),
      ],
    );
  }

  Widget buildQtyField(
      BuildContext context, String title, TextEditingController controller) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
            decimal: true), // Allows decimal input
      ),
    );
  }

  Widget buildUnitField(BuildContext context, int index) {
    if (index >= widget.unitController.length) {
      return const Text("No Unit Available");
    }
    return InkWell(
      onTap: () {
        //xx
        String? itemId = widget.promotion.idProduct
            ?.split("-")
            .first
            .toString()
            .split(" ")
            .first;
        print("tol $itemId");
        setState(() {
          widget.getUnit(itemId!);
        });
        Future.delayed(const Duration(seconds: 1), () {
          Get.defaultDialog(
              title: "",
              barrierDismissible: false,
              content: SearchChoices.single(
                isExpanded: true,
                value: widget.unitController[index],
                items: widget.dataUnit.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    widget.unitController[index] = value;
                  });
                },
              ),
              onConfirm: () {
                Get.back();
              });
        });
      },
      child: TextResultCard(
        title: 'Unit',
        value: widget.unitController[index] ?? "Empty",
      ),
    );
    //   return InkWell(
    //     onTap: () {
    //       String? itemId = widget.promotion.idProduct?.split("-").first;
    //       if (itemId != null) {
    //         widget.getUnit(itemId);
    //         Future.delayed(const Duration(seconds: 1), () {
    //           Get.defaultDialog(
    //             title: "",
    //             barrierDismissible: false,
    //             content: SearchChoices.single(
    //               isExpanded: true,
    //               value: widget.unitController,
    //               items: widget.dataUnit.map((item) {
    //                 return DropdownMenuItem(
    //                   value: item,
    //                   child: Text(item),
    //                 );
    //               }).toList(),
    //               onChanged: (value) {
    //                 setState(() {
    //                   widget.unitController[widget.index] = value;
    //                 });
    //               },
    //             ),
    //             onConfirm: () {
    //               Get.back();
    //             },
    //           );
    //         });
    //       }
    //     },
    //     child: TextResultCard(
    //       title: 'Unit',
    //       value: widget.unitController[widget.index] ?? "Empty",
    //     ),
    //   );
  }

  // // Helper method to build discount fields
  Widget buildDiscountFields(BuildContext context, double totalPriceDiscOnly) {
    return Column(
      children: <Widget>[
        buildDiscountRow(context, "Disc1(%) PRB", widget.disc1Controller!),
        buildDiscountRow(context, "Disc2(%) COD", widget.disc2Controller),
        buildDiscountRow(
            context, "Disc3(%) Principal1", widget.disc3Controller),
        buildDiscountRow(
            context, "Disc4(%) Principal2", widget.disc4Controller),
      ],
    );
  }

  Widget buildDiscountRow(BuildContext context, String title,
      List<TextEditingController> controller) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 5,
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Consumer<LinesProvider>(
            builder: (context, linesProv, _) => TextFormField(
              keyboardType: TextInputType.number,
              readOnly: widget.statusDisable,
              controller: controller[widget.index],
              onChanged: (value) {
                // Update discount logic
              },
            ),
          ),
        ),
      ],
    );
  }

  // // Helper method to build bonus fields
  // Widget buildBonusFields(BuildContext context) {
  //   return Column(
  //     children: <Widget>[
  //       TextResultCard(
  //         title: 'Bonus Item',
  //         value: widget.promotion.suppItem!,
  //       ),
  //       TextResultCard(
  //         title: 'Bonus Qty',
  //         value: widget.promotion.suppQty!,
  //       ),
  //       TextResultCard(
  //         title: 'Bonus Unit',
  //         value: widget.promotion.suppUnit!,
  //       ),
  //     ],
  //   );
  // }

  Widget buildNetPriceField(BuildContext context, double totalPriceDiscOnly,
      double totalPriceDiscValue) {
    return TextResultCard(
      title: "Net Price",
      value:
          "Rp${(widget.promotion.disc1 == "0.00" && widget.promotion.disc2 == "0.00" && widget.promotion.disc3 == "0.00" && widget.promotion.disc4 == "0.00" ? totalPriceDiscValue : totalPriceDiscOnly).toString()}",
    );
  }

  // Conditionally show or hide the "VIEW SALES HISTORY" button
  Widget buildSalesHistoryButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HistorySO(
            namePP: widget.namePP,
            idCustomer: widget.promotion.idCustomer!,
            idProduct: widget.promotion.idProduct!,
            idEmp: widget.idEmp,
          );
        }));
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(7),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(7),
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            "VIEW SALES HISTORY",
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
