import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/approval_pending_line_controller.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/view/promotion_program/approval/history_so.dart';
import 'package:search_choices/search_choices.dart';

class CardLinesAdapter extends StatefulWidget {
  final String? namePP;
  final int? idEmp;
  final Promotion? promotion;
  final int? index;
  final bool? startApp;
  final bool? valueSelectAll;
  final bool? statusDisable;
  final bool? showSalesHistory;
  final List<TextEditingController>? qtyFromController;
  final List<TextEditingController>? qtyToController;
  final List<TextEditingController>? disc1Controller;
  final List<TextEditingController>? disc2Controller;
  final List<TextEditingController>? disc3Controller;
  final List<TextEditingController>? disc4Controller;
  final List<TextEditingController>? value1Controller;
  final List<TextEditingController>? value2Controller;
  final List<dynamic>? unitController;
  final List<String>? suppItemController;
  final List<String>? suppUnitController;
  final List<dynamic>? warehouseController;
  final List<Map<String, dynamic>>? addToLines;
  final List<dynamic>? dataUnit;
  final List<dynamic>? dataSupplyUnit;
  final List<dynamic>? dataWarehouse;
  final List<dynamic>? dataSupplyItem;
  final Function(String itemId)? getUnit;
  Function(String itemId)? getSupplyUnit;
  Function(String itemId)? getWarehouse;

  CardLinesAdapter({
    Key? key,
    this.namePP,
    this.idEmp,
    this.promotion,
    this.index,
    this.startApp,
    this.valueSelectAll,
    this.statusDisable,
    this.showSalesHistory,
    this.qtyFromController,
    this.qtyToController,
    this.disc1Controller,
    this.disc2Controller,
    this.disc3Controller,
    this.disc4Controller,
    this.value1Controller,
    this.value2Controller,
    this.unitController,
    this.suppItemController,
    this.suppUnitController,
    this.warehouseController,
    this.addToLines,
    this.dataUnit,
    this.dataSupplyUnit,
    this.dataWarehouse,
    this.dataSupplyItem,
    this.getUnit,
    this.getSupplyUnit,
    this.getWarehouse,
  }) : super(key: key);

  @override
  CardLinesAdapterState createState() => CardLinesAdapterState();
}

class CardLinesAdapterState extends State<CardLinesAdapter> {
  late TextEditingController qtyFromcontroller;
  late TextEditingController qtyTocontroller;
  late TextEditingController disc1Controller;
  late TextEditingController disc2Controller;
  late TextEditingController disc3Controller;
  late TextEditingController disc4Controller;
  late HistoryLinesPendingController controller;

  @override
  void initState() {
    super.initState();
    qtyFromcontroller =
        TextEditingController(text: widget.promotion!.qty.toString());
    qtyTocontroller =
        TextEditingController(text: widget.promotion!.qtyTo.toString());
    disc1Controller =
        TextEditingController(text: widget.promotion!.disc1.toString());
    disc2Controller =
        TextEditingController(text: widget.promotion!.disc2.toString());
    disc3Controller =
        TextEditingController(text: widget.promotion!.disc3.toString());
    disc4Controller =
        TextEditingController(text: widget.promotion!.disc4.toString());
  }

  @override
  void dispose() {
    qtyFromcontroller.dispose();
    qtyTocontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double price = double.parse(widget.promotion!.price
            ?.replaceAll(RegExp("Rp"), "")
            .replaceAll(".", "") ??
        "0");
    double disc1 = double.parse(widget.promotion!.disc1 ?? "0");
    double disc2 = double.parse(widget.promotion!.disc2 ?? "0");
    double disc3 = double.parse(widget.promotion!.disc3 ?? "0");
    double disc4 = double.parse(widget.promotion!.disc4 ?? "0");
    double discValue1 = double.parse(widget.promotion!.value1 ?? "0");
    double discValue2 = double.parse(widget.promotion!.value2 ?? "0");
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
              value: widget.valueSelectAll!
                  ? widget.valueSelectAll
                  : widget.promotion!.status,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.promotion!.status = value;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
            ),
          ),
          TextResultCard(
            title: "Product",
            value: widget.promotion!.product!,
          ),
          buildQtyRow(context, qtyFromcontroller, qtyTocontroller),
          // buildUnitField(context, widget.index!),

          TextResultCard(
            title: "Unit",
            value: widget.promotion!.unitId!,
          ),
          TextResultCard(
            title: "Price",
            value: widget.promotion!.price!,
          ),
          if (widget.promotion!.ppType != "Bonus")
            buildDiscountFields(
                context, totalPriceDiscOnly, totalPriceDiscValue, price),
          if (widget.promotion!.ppType != "Diskon") buildBonusFields(context),
          buildNetPriceField(context, totalPriceDiscOnly, totalPriceDiscValue),
          if (widget.showSalesHistory!) buildSalesHistoryButton(context),
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
      width: 150,
      child: TextResultCard(
        title: title,
        value: controller.text,
      ),

      // TextFormField(
      //   controller: controller,
      //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
      //   onChanged: (value) {},
      // ),
    );
  }

  Widget buildUnitField(BuildContext context, int index) {
    if (index >= widget.unitController!.length) {
      return const Text("No Unit Available");
    }
    return InkWell(
      onTap: () {
        //xx
        String? itemId = widget.promotion!.idProduct
            ?.split("-")
            .first
            .toString()
            .split(" ")
            .first;

        setState(() {
          widget.getUnit!(itemId!);
        });
        Future.delayed(const Duration(seconds: 1), () {
          Get.defaultDialog(
              title: "",
              barrierDismissible: false,
              content: SearchChoices.single(
                isExpanded: true,
                value: widget.unitController![index],
                items: widget.dataUnit!.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    widget.unitController![index] = value;
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
        value: widget.unitController![index] ?? "Empty",
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

  Widget buildDiscountFields(BuildContext context, double totalPriceDiscOnly,
      double totalPriceDiscValue, double price) {
    return Column(
      children: <Widget>[
        buildDiscountRow(context, "Disc1(%) PRB", disc1Controller,
            totalPriceDiscOnly, totalPriceDiscValue, price),
        buildDiscountRow(context, "Disc2(%) COD", disc2Controller,
            totalPriceDiscOnly, totalPriceDiscValue, price),
        buildDiscountRow(context, "Disc3(%) Principal1", disc3Controller,
            totalPriceDiscOnly, totalPriceDiscValue, price),
        buildDiscountRow(context, "Disc4(%) Principal2", disc4Controller,
            totalPriceDiscOnly, totalPriceDiscValue, price),
      ],
    );
  }

  Widget buildDiscountRow(
      BuildContext context,
      String title,
      TextEditingController controller,
      double totalPriceDiscOnly,
      double totalPriceDiscValue,
      double price) {
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
          child: TextFormField(
            keyboardType: TextInputType.number,
            readOnly: widget.statusDisable!,
            controller: controller,
            onChanged: (value) {
              if (value.isEmpty) {
                widget.promotion!.value1 = "0.0";
                double discValue1 = double.parse(widget.promotion!.value1!);
                double discValue2 = double.parse(widget.promotion!.value2!);
                setState(() {
                  totalPriceDiscValue = price - (discValue1 + discValue2);
                });
              } else {
                widget.promotion!.value1 = value.replaceAll(".", "");
                double discValue1 = double.parse(widget.promotion!.value1!);
                double discValue2 = double.parse(widget.promotion!.value2!);
                setState(() {
                  totalPriceDiscValue = price - (discValue1 + discValue2);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildBonusFields(BuildContext context) {
    return Column(
      children: <Widget>[
        TextResultCard(
          title: 'Bonus Item',
          value: widget.promotion!.suppItem!,
        ),
        TextResultCard(
          title: 'Bonus Qty',
          value: widget.promotion!.suppQty!,
        ),
        TextResultCard(
          title: 'Bonus Unit',
          value: widget.promotion!.suppUnit!,
        ),
      ],
    );
  }

  Widget buildNetPriceField(BuildContext context, double totalPriceDiscOnly,
      double totalPriceDiscValue) {
    return TextResultCard(
      title: "Net Price",
      value:
          "Rp${(widget.promotion!.disc1 == "0.00" && widget.promotion!.disc2 == "0.00" && widget.promotion!.disc3 == "0.00" && widget.promotion!.disc4 == "0.00" ? totalPriceDiscValue : totalPriceDiscOnly).toString()}",
    );
  }

  Widget buildSalesHistoryButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HistorySO(
            namePP: widget.namePP!,
            idCustomer: widget.promotion!.idCustomer!,
            idProduct: widget.promotion!.idProduct!,
            idEmp: widget.idEmp!,
          );
        }));
      },
      style: TextButton.styleFrom(
        backgroundColor: colorAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(7),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(7),
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            "View Sales History",
            style: TextStyle(
              color: colorNetral,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
