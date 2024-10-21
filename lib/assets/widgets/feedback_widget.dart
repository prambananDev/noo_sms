// import 'package:flutter/material.dart';
// import 'package:flutter_scs/mobile_sms/lib/models/IdAndValue.dart';
// import 'package:flutter_scs/mobile_sms/lib/view/transaction/transaction_history_presenter2.dart';
// import 'package:get/get.dart';

// class FeedbackWidget extends StatelessWidget {
//   final int index;
//   final TransactionHistoryPresenter2 feedbackController =
//       Get.put(TransactionHistoryPresenter2());

//   FeedbackWidget({required this.index});

//   @override
//   Widget build(BuildContext context) {
//     // Load feedback data when the widget is built
//     feedbackController.loadFeedback(index);

//     return AlertDialog(
//       title: Text(
//         "Feedback",
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: Container(
//         height: MediaQuery.of(context).size.height * 0.6,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           children: [
//             Obx(() {
//               // Observe changes to feedbackList
//               var state = feedbackController.promotionProgramInputStateRx.value
//                   .promotionProgramInputState![index].feedbackDropdownState;
//               if (state?.choiceListWrapper?.value?.isEmpty ?? true) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return DropdownButton<IdAndValue<String>>(
//                 value: state?.selectedChoiceWrapper?.value,
//                 onChanged: (IdAndValue<String>? newValue) {
//                   if (newValue != null) {
//                     state?.selectedChoiceWrapper?.value = newValue;
//                   }
//                 },
//                 items: state?.choiceListWrapper?.value
//                     ?.map((IdAndValue<String> choice) {
//                   return DropdownMenuItem<IdAndValue<String>>(
//                     value: choice,
//                     child: Text(choice.value),
//                   );
//                 }).toList(),
//               );
//             }),
//             Container(
//               alignment: Alignment.center,
//               padding: EdgeInsets.all(8),
//               child: TextField(
//                 maxLines: 4,
//                 decoration: new InputDecoration(
//                   hintText: 'Submit feedback here',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide(width: 1, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {},
//           child: const Text('Submit'),
//         ),
//       ],
//     );
//   }
// }
