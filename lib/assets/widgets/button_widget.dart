import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:noo_sms/assets/global.dart';

class ButtonOrderSample extends StatelessWidget {
  final Uint8List? imageData;
  final Function? onTapAction;
  final Size size;
  final String nameButton;
  final IconData? iconButton;
  final Color colorIcon;

  const ButtonOrderSample({
    Key? key,
    this.imageData,
    required this.onTapAction,
    required this.size,
    required this.nameButton,
    this.iconButton,
    required this.colorIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapAction != null ? () => onTapAction!() : null,
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: onTapAction != null ? colorAccent : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          nameButton,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
