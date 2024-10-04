import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:search_choices/search_choices.dart';

Widget customCard(
  int index,
  InputPageController inputPagePresenter,
) {
  PromotionProgramInputState promotionProgramInputState = inputPagePresenter
      .promotionProgramInputStateRx.value.promotionProgramInputState[index];

  return Container(
    margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
    child: Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      semanticContainer: true,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Add Lines"),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    inputPagePresenter.addItem();
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    // Remove the line
                    inputPagePresenter.removeItem(index);
                    inputPagePresenter.onTap.value = false;
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SearchChoices.single(
              isExpanded: true,
              value: promotionProgramInputState
                  .itemGroupInputPageDropdownState?.selectedChoice,
              hint: const Text(
                "Item/Item Group",
                style: TextStyle(fontSize: 12),
              ),
              items: promotionProgramInputState
                  .itemGroupInputPageDropdownState?.choiceList
                  ?.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.fade,
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  inputPagePresenter.changeItemGroup(index, value),
            ),

            const SizedBox(height: 8),
            _buildSearchChoices<IdAndValue<String>>(
              "Item Product",
              promotionProgramInputState
                  .selectProductPageDropdownState?.selectedChoice,
              promotionProgramInputState
                  .selectProductPageDropdownState?.choiceList,
              (value) => inputPagePresenter.changeProduct(index, value),
            ),
            const SizedBox(height: 8),
            _buildSearchChoices<IdAndValue<String>>(
              "Warehouse",
              promotionProgramInputState
                  .wareHousePageDropdownState?.selectedChoiceWrapper?.value,
              promotionProgramInputState
                  .wareHousePageDropdownState?.choiceListWrapper?.value,
              (value) => inputPagePresenter.changeWarehouse(index, value),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: promotionProgramInputState.qtyFrom,
                  labelText: "Qty From",
                ),
                const SizedBox(width: 30),
                _buildTextField(
                  controller: promotionProgramInputState.qtyTo,
                  labelText: "Qty To",
                ),
              ],
            ),
            // Add other UI elements similar to this
          ],
        ),
      ),
    ),
  );
}

Widget _buildSearchChoices<T extends IdAndValue<String>>(
    String label, T? selectedValue, List<T>? items, Function(T) onChanged) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ),
      SearchChoices.single(
        isExpanded: true,
        value: selectedValue,
        items: items?.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.value, style: const TextStyle(fontSize: 12)),
          );
        }).toList(),
        onChanged: (value) => onChanged(value as T),
        hint: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

Widget _buildTextField({
  required TextEditingController? controller,
  required String labelText,
}) {
  return SizedBox(
    width: 50,
    child: TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
            color: Colors.black87, fontSize: 12, fontFamily: 'AvenirLight'),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      style: const TextStyle(
          color: Colors.black87, fontSize: 17, fontFamily: 'AvenirLight'),
    ),
  );
}
