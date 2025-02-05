import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/history_lines_all_controller.dart';
import 'package:noo_sms/models/promotion.dart';

class HistoryLinesAll extends StatefulWidget {
  final String numberPP;
  final int idEmp;

  const HistoryLinesAll({
    Key? key,
    required this.numberPP,
    required this.idEmp,
  }) : super(key: key);

  @override
  HistoryLinesAllState createState() => HistoryLinesAllState();
}

class HistoryLinesAllState extends State<HistoryLinesAll> {
  final HistoryLinesController _controller = Get.put(HistoryLinesController());
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();

    _initializeDates();
  }

  void _initializeDates() async {
    final promotions = await Promotion.getListLines(widget.numberPP);
    if (promotions.isNotEmpty) {
      setState(() {
        dateFrom =
            DateTime.tryParse(promotions[0].fromDate ?? '') ?? DateTime.now();
        dateTo =
            DateTime.tryParse(promotions[0].toDate ?? '') ?? DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: colorAccent,
      title: Text(
        'Lines Detail',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: colorNetral,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: colorNetral,
          size: 35,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        await Future.delayed(Duration.zero);
        setState(() {});
      },
      child: FutureBuilder<List<Promotion>>(
        future: Promotion.getListLines(widget.numberPP),
        builder: _buildFutureContent,
      ),
    );
  }

  Widget _buildFutureContent(
      BuildContext context, AsyncSnapshot<List<Promotion>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final firstItem = snapshot.data![0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderInfo(firstItem),
          _buildDateRangeInfo(firstItem),
          _buildLinesList(snapshot.data!),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(Promotion item) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextResultCard(title: "No. PP", value: item.nomorPP ?? ""),
          TextResultCard(title: "PP. Type", value: item.ppType ?? ""),
          TextResultCard(title: "Customer", value: item.customer ?? ""),
          TextResultCard(title: "Note", value: item.note ?? ""),
        ],
      ),
    );
  }

  Widget _buildDateRangeInfo(Promotion item) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            readOnly: true,
            initialValue: item.fromDate?.split(" ")[0],
            decoration: const InputDecoration(
              labelText: 'From Date',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            initialValue: item.toDate?.split(" ")[0],
            decoration: const InputDecoration(
              labelText: 'To Date',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesList(List<Promotion> items) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildLineCard(items[index], index),
    );
  }

  Widget _buildLineCard(Promotion promotion, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
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
        children: [
          _buildBasicInfo(promotion, index),
          if (promotion.ppType != "Bonus") _buildDiscountInfo(promotion),
          _buildBonusInfo(promotion),
          TextResultCard(
            title: "Total",
            value: _calculateTotalPrice(promotion),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(Promotion promotion, int index) {
    return Column(
      children: [
        TextResultCard(
          title: "Product",
          value: promotion.product ?? "",
        ),
        TextResultCard(
          title: "Qty From",
          value: promotion.qty.toString(),
        ),
        TextResultCard(
          title: "Qty To",
          value: promotion.qtyTo.toString(),
        ),
        TextResultCard(
          title: 'Unit',
          value: promotion.unitId ?? "",
        ),
        TextResultCard(
          title: "Price",
          value: promotion.price ?? "",
        ),
      ],
    );
  }

  Widget _buildDiscountInfo(Promotion promotion) {
    if (promotion.ppType == "Bonus") return const SizedBox();

    return Column(
      children: [
        // Disc1 and Disc2 row
        _buildDiscountRow(
          promotion,
          "Disc1(%) PRB",
          promotion.disc1,
          "Disc2(%) COD",
          promotion.disc2,
        ),

        _buildDiscountRow(
          promotion,
          "Disc3(%) Principal1",
          promotion.disc3,
          "Disc4(%) Principal2",
          promotion.disc4,
        ),

        _buildDiscountValueRow(
          promotion,
          "Disc Value1",
          promotion.value1,
          "Disc Value2",
          promotion.value2,
        ),
      ],
    );
  }

  Widget _buildDiscountRow(Promotion promotion, String label1, String? value1,
      String label2, String? value2) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 5,
          child: Text(
            label1,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            keyboardType: TextInputType.text,
            initialValue: value1?.split(".").first ?? "",
            onFieldSubmitted: (value) {
              _controller.setBundleLines(
                  promotion.id, double.parse(value), dateFrom!, dateTo!);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 5,
          child: Text(
            label2,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            keyboardType: TextInputType.text,
            initialValue: value2?.split(".").first ?? "",
            onFieldSubmitted: (value) {
              _controller.setBundleLines(
                  promotion.id, double.parse(value), dateFrom!, dateTo!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountValueRow(Promotion promotion, String label1,
      String? value1, String label2, String? value2) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 5,
          child: Text(
            label1,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            keyboardType: TextInputType.text,
            initialValue:
                MoneyFormatter(amount: double.tryParse(value1 ?? '0') ?? 0)
                    .output
                    .withoutFractionDigits,
            onFieldSubmitted: (value) {
              _controller.setBundleLines(
                  promotion.id, double.parse(value), dateFrom!, dateTo!);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 5,
          child: Text(
            label2,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            keyboardType: TextInputType.text,
            initialValue:
                MoneyFormatter(amount: double.tryParse(value2 ?? '0') ?? 0)
                    .output
                    .withoutFractionDigits,
            onFieldSubmitted: (value) {
              _controller.setBundleLines(
                  promotion.id, double.parse(value), dateFrom!, dateTo!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBonusInfo(Promotion promotion) {
    if (promotion.ppType == "Diskon") return const SizedBox();

    return Column(
      children: [
        TextResultCard(
          title: 'Bonus Item',
          value: promotion.suppItem ?? "",
        ),
        TextResultCard(
          title: 'Bonus Qty',
          value: promotion.suppQty ?? "",
        ),
        TextResultCard(
          title: 'Bonus Unit',
          value: promotion.suppUnit ?? "",
        ),
      ],
    );
  }

  String _calculateTotalPrice(Promotion promotion) {
    try {
      if (promotion.price == null || promotion.price!.isEmpty) {
        return '0';
      }

      double price = 0;
      try {
        price = double.parse(
            promotion.price!.replaceAll(RegExp("Rp"), "").replaceAll(".", ""));
      } catch (e) {
        return '0';
      }

      double disc1 = double.tryParse(promotion.disc1 ?? '0') ?? 0;
      double disc2 = double.tryParse(promotion.disc2 ?? '0') ?? 0;
      double disc3 = double.tryParse(promotion.disc3 ?? '0') ?? 0;
      double disc4 = double.tryParse(promotion.disc4 ?? '0') ?? 0;
      double discValue1 = double.tryParse(promotion.value1 ?? '0') ?? 0;
      double discValue2 = double.tryParse(promotion.value2 ?? '0') ?? 0;

      double totalPriceDiscOnly =
          price - (price * ((disc1 + disc2 + disc3 + disc4) / 100));
      double totalPriceDiscValue = price - (discValue1 + discValue2);

      bool isAllDiscsZero =
          (promotion.disc1 == null || promotion.disc1 == "0.00") &&
              (promotion.disc2 == null || promotion.disc2 == "0.00") &&
              (promotion.disc3 == null || promotion.disc3 == "0.00") &&
              (promotion.disc4 == null || promotion.disc4 == "0.00");

      double finalAmount =
          isAllDiscsZero ? totalPriceDiscValue : totalPriceDiscOnly;

      return 'Rp${MoneyFormatter(amount: finalAmount).output.withoutFractionDigits.replaceAll(",", ".")}';
    } catch (e) {
      return 'Rp0';
    }
  }
}
