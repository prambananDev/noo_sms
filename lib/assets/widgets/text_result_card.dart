import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';

class TextResultCard extends StatelessWidget {
  final String title;
  final String value;

  const TextResultCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(
              4), // Replaced ScreenUtil with constant padding
          width: MediaQuery.of(context).size.width /
              4, // Responsive width based on screen size
          child: Text(
            title,
            style: TextStyle(
              color: colorBlack,
              fontSize: 15, // Fixed font size
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
                right: 4), // Replaced ScreenUtil with constant padding
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15, // Fixed font size
              ),
            ),
          ),
        ),
      ],
    );
  }
}
