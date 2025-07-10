import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class PPNoteField extends StatelessWidget {
  final Rx<TextEditingController> controller;
  final FocusNode focusNode;
  final bool isExpanded;
  final ValueChanged<bool> onTapChanged;
  final PPDimensions dimensions;

  const PPNoteField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isExpanded,
    required this.onTapChanged,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.value,
          focusNode: focusNode,
          maxLines: isExpanded ? 5 : 1,
          onTap: () => onTapChanged(true),
          onTapOutside: (_) {
            focusNode.unfocus();
            onTapChanged(false);
          },
          decoration: InputDecoration(
            labelText: 'Note',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: dimensions.getTextSize(context),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: dimensions.getTextSize(context),
          ),
        ));
  }
}
