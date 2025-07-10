import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class PPDateRangePicker extends StatelessWidget {
  final Rx<TextEditingController> fromController;
  final Rx<TextEditingController> toController;
  final PPDimensions dimensions;

  const PPDateRangePicker({
    Key? key,
    required this.fromController,
    required this.toController,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = dimensions.isSmallScreen(context);

    return isSmallScreen
        ? _buildVerticalLayout(context)
        : _buildHorizontalLayout(context);
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFromDateField(),
        SizedBox(height: dimensions.getSpacing(context) / 2),
        _buildToDateField(),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150,
          child: _buildFromDateField(),
        ),
        SizedBox(
          width: 150,
          child: _buildToDateField(),
        ),
      ],
    );
  }

  Widget _buildFromDateField() {
    return Obx(() => CustomDatePickerField(
          controller: fromController.value,
          labelText: 'From Date',
          initialValue: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 180)),
        ));
  }

  Widget _buildToDateField() {
    return Obx(() => CustomDatePickerField(
          controller: toController.value,
          labelText: 'To Date',
          initialValue: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 180)),
        ));
  }
}
