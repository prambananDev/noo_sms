import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/controllers/noo/draft_controller.dart';
import 'package:noo_sms/models/draft_model.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form_coba.dart';

class DraftPage extends GetView<DraftController> {
  const DraftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: colorAccent,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "NOO Draft",
          style: TextStyle(
            color: colorNetral,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display the list of drafts
        return ListView.builder(
          itemCount: controller.drafts.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final draft = controller.drafts[index];
            return _buildDraftCard(draft);
          },
        );
      }),
    );
  }

  Widget _buildDraftCard(DraftModel draft) {
    return Container(
      padding: const EdgeInsets.all(7),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Customer Name", draft.custName),
              _buildInfoRow("Brand Name", draft.brandName),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    final customerFormController =
                        Get.put(CustomerFormController());

                    customerFormController.loadFromDraft(draft);

                    Get.to(() => CustomerForm(
                          isFromDraft: true,
                          controller: customerFormController,
                        ));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Text(
                        "Details",
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16,
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label : ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:noo_sms/controllers/noo/draft_controller.dart';
// import 'package:noo_sms/models/draft_model.dart';

// class DraftPage extends GetView<DraftController> {
//   const DraftPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         backgroundColor: Colors.white60,
//         title: const Text(
//           "NOO Draft Form",
//           style: TextStyle(
//             color: Colors.blue,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           itemCount: controller.drafts.length,
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             final draft = controller.drafts[index];
//             return _buildDraftCard(draft);
//           },
//         );
//       }),
//     );
//   }

//   Widget _buildDraftCard(DraftModel draft) {
//     return Container(
//       padding: const EdgeInsets.all(7),
//       child: Card(
//         elevation: 3,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildInfoRow("CustName", draft.custName),
//             _buildInfoRow("BrandName", draft.brandName),
//             const Center(
//               child: SizedBox(
//                 height: 5,
//                 child: Divider(
//                   thickness: 1,
//                   color: Colors.orange,
//                   indent: 5,
//                   endIndent: 5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 5),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildVerticalDivider(),
//                 TextButton(
//                   onPressed: () => _navigateToDetail(draft),
//                   child: const Text(
//                     "DETAILS",
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//                 _buildVerticalDivider(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       alignment: Alignment.centerLeft,
//       child: Text(
//         "$label : $value",
//         textAlign: TextAlign.left,
//         style: const TextStyle(
//           color: Colors.blue,
//           fontSize: 15,
//         ),
//       ),
//     );
//   }

//   Widget _buildVerticalDivider() {
//     return const SizedBox(
//       height: 60,
//       child: VerticalDivider(
//         thickness: 2,
//         color: Colors.orange,
//         endIndent: 20,
//         indent: 5,
//       ),
//     );
//   }

//   void _navigateToDetail(DraftModel draft) {
//     // Get.to(
//     //   () => DraftDetailView(
//     //     imageKtpPath: draft.fotoKTP,
//     //     imageNpwpPath: draft.fotoNPWP,
//     //     imageNibPath: draft.fotoSIUP,
//     //     imageSppkpPath: draft.fotoGedung3,
//     //     imageFrontViewPath: draft.fotoGedung1,
//     //     imageInsideViewPath: draft.fotoGedung2,
//     //     customerName: draft.custName,
//     //     brandName: draft.brandName,
//     //     salesOffice: draft.salesOffice,
//     //     businessUnit: draft.businessUnit,
//     //     category1: draft.category1,
//     //     category2: draft.category,
//     //     axRegional: draft.regional,
//     //     distributionChannel: draft.segment,
//     //     channelSegmentation: draft.subSegment,
//     //     classNOO: draft.classField,
//     //     companyStatus: draft.companyStatus,
//     //     currency: draft.currency,
//     //     priceGroup: draft.priceGroup,
//     //     paymentMode: draft.paymMode,
//     //     contactPerson: draft.contactPerson,
//     //     ktp: draft.ktp,
//     //     ktpAddress: draft.ktpAddress,
//     //     npwp: draft.npwp,
//     //     phone: draft.phoneNo,
//     //     fax: draft.faxNo,
//     //     emailAddress: draft.emailAddress,
//     //     webSite: draft.website,
//     //     nameCompany: draft.companyAddresses?['Name'],
//     //     streetnameCompany: draft.companyAddresses?['StreetName'],
//     //     wardCompany: draft.companyAddresses?['Kelurahan'],
//     //     districtsCompany: draft.companyAddresses?['Kecamatan'],
//     //     cityCompany: draft.companyAddresses?['City'],
//     //     countryCompany: draft.companyAddresses?['Country'],
//     //     provinceCompany: draft.companyAddresses?['State'],
//     //     zipcodeCompany: draft.companyAddresses?['ZipCode'],
//     //     nameTax: draft.taxAddresses?['Name'],
//     //     streetNameTax: draft.taxAddresses?['StreetName'],
//     //     nameDelivery: draft.deliveryAddresses?[0]['Name'],
//     //     streetNameDelivery: draft.deliveryAddresses?[0]['StreetName'],
//     //     wardDelivery: draft.deliveryAddresses?[0]['Kelurahan'],
//     //     districtsDelivery: draft.deliveryAddresses?[0]['Kecamatan'],
//     //     cityDelivery: draft.deliveryAddresses?[0]['City'],
//     //     countryDelivery: draft.deliveryAddresses?[0]['Country'],
//     //     provinceDelivery: draft.deliveryAddresses?[0]['State'],
//     //     zipcodeDelivery: draft.deliveryAddresses?[0]['ZipCode'],
//     //     longitudeData: draft.longitude,
//     //     latitudeData: draft.latitude,
//     //   ),
//     // );
//   }
// }
