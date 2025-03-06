import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noo_sms/assets/global.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String svgPath;
  final bool hasNotification;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.title,
    required this.svgPath,
    this.hasNotification = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(16),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.05),
          //       blurRadius: 10,
          //       spreadRadius: 1,
          //     ),
          //   ],
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 50,
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
