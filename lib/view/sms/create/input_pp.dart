import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_header_card.dart';
import 'package:noo_sms/view/sms/create/pp_line_item_card.dart';

class InputPagePP extends StatefulWidget {
  final bool isEdit;
  final String? programNumber;

  const InputPagePP({
    Key? key,
    this.isEdit = false,
    this.programNumber,
  }) : super(key: key);

  @override
  State<InputPagePP> createState() => _InputPagePPState();
}

class _InputPagePPState extends State<InputPagePP> {
  final InputPageController _controller = Get.put(InputPageController());
  final ScrollController _scrollController = ScrollController();
  final FocusNode _noteFocusNode = FocusNode();

  late final PPDimensions _dimensions;
  bool _isNoteTapped = false;
  final double _noteFieldHeight = 10.0;

  @override
  void initState() {
    super.initState();
    _dimensions = PPDimensions();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (widget.isEdit && widget.programNumber != null) {
      await _controller.loadProgramData(widget.programNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(_dimensions.getPadding(context)),
      child: Column(
        children: [
          PPHeaderCard(
            controller: _controller,
            dimensions: _dimensions,
            noteFocusNode: _noteFocusNode,
            isNoteTapped: _isNoteTapped,
            onNoteTapChanged: (value) => setState(() => _isNoteTapped = value),
          ),
          SizedBox(height: _dimensions.getSpacing(context) / 2),
          _buildLineItems(),
          SizedBox(height: _noteFieldHeight),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    return Obx(() {
      final state = _controller.promotionProgramInputStateRx.value;

      if (state.promotionProgramInputState.isEmpty) {
        return _buildAddLineButton(state.isAddItem);
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.promotionProgramInputState.length,
        itemBuilder: (context, index) => PPLineItemCard(
          index: index,
          controller: _controller,
          dimensions: _dimensions,
          onAddItem: () => _onAddItem(),
          onDeleteItem: (index) => _onDeleteItem(index),
          isLastItem: index == state.promotionProgramInputState.length - 1,
        ),
      );
    });
  }

  Widget _buildAddLineButton(bool isEnabled) {
    return Container(
      margin: EdgeInsets.only(bottom: _dimensions.getSpacing(context) * 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: colorAccent),
        onPressed: isEnabled ? () => _controller.addItem() : null,
        child: Text(
          "Add Lines",
          style: TextStyle(
            color: colorNetral,
            fontSize: _dimensions.getTextSize(context),
          ),
        ),
      ),
    );
  }

  void _onAddItem() {
    _controller.addItem();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onDeleteItem(int index) {
    _controller.removeItem(index);
    _controller.onTap.value = false;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - 500,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
