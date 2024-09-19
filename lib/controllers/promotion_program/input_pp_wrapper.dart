import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';

class InputPageWrapper {
  List<PromotionProgramInputState> promotionProgramInputState;
  List<String> originalPrice = [];
  bool isAddItem;

  InputPageWrapper(
      {required this.promotionProgramInputState, required this.isAddItem});
  InputPageWrapper copy(
      {List<PromotionProgramInputState>? promotionProgramInputState,
      bool? isAddItem}) {
    return InputPageWrapper(
        promotionProgramInputState:
            promotionProgramInputState ?? this.promotionProgramInputState,
        isAddItem: isAddItem ?? this.isAddItem);
  }
}
