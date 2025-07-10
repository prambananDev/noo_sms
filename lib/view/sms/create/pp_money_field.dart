import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class PPMoneyField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final PPDimensions dimensions;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final String currencyPrefix;
  final TextAlign textAlign;

  const PPMoneyField({
    Key? key,
    required this.controller,
    required this.label,
    required this.dimensions,
    this.readOnly = false,
    this.onChanged,
    this.currencyPrefix = "Rp",
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      readOnly: readOnly,
      onChanged: onChanged,
      textAlign: textAlign,
      inputFormatters: [
        CustomMoneyInputFormatter(
          thousandSeparator: ".",
          decimalSeparator: ",",
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixText: currencyPrefix,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: dimensions.getLabelSize(context),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      style: TextStyle(
        color: readOnly ? Colors.black54 : Colors.black87,
        fontSize: dimensions.getTextSize(context),
      ),
    );
  }
}

class PPResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final PPDimensions dimensions;
  final double spacing;
  final bool forceVertical;
  final CrossAxisAlignment crossAxisAlignment;

  const PPResponsiveRow({
    Key? key,
    required this.children,
    required this.dimensions,
    this.spacing = 0,
    this.forceVertical = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = dimensions.isMobileScreen(context) || forceVertical;

    if (isMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildrenWithSpacing(vertical: true),
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithSpacing(vertical: false),
    );
  }

  List<Widget> _buildChildrenWithSpacing({required bool vertical}) {
    final List<Widget> spacedChildren = [];

    for (int i = 0; i < children.length; i++) {
      if (vertical) {
        spacedChildren.add(children[i]);
      } else {
        spacedChildren.add(Expanded(child: children[i]));
      }

      if (i < children.length - 1 && spacing > 0) {
        spacedChildren.add(SizedBox(
          width: vertical ? 0 : spacing,
          height: vertical ? spacing : 0,
        ));
      }
    }

    return spacedChildren;
  }
}

class PPPercentField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final PPDimensions dimensions;
  final ValueChanged<String>? onChanged;

  const PPPercentField({
    Key? key,
    required this.controller,
    required this.label,
    required this.dimensions,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: "%",
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: dimensions.getLabelSize(context),
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
    );
  }
}
