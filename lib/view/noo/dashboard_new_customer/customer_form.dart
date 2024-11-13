import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/customer_dropdownfield_noo.dart';
import 'package:noo_sms/assets/widgets/customer_textfield_noo.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({super.key});

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController ktpController = TextEditingController();
  final TextEditingController ktpAddressController = TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  String? selectedSalesOffice;
  String? selectedBusinessUnit;
  String? selectedCategory1;
  String? selectedCategory2;
  String? selectedAXRegional;

  final CustomerFormController controller = Get.put(CustomerFormController());

  @override
  void initState() {
    super.initState();
    controller.fetchAXRegionals();
    controller.fetchSalesOffices();
    controller.loadSharedPreferences();
  }

  final List<Map<String, dynamic>> businessUnitItems = [
    {'name': 'Business Unit 1'},
    {'name': 'Business Unit 2'},
  ];

  final List<Map<String, dynamic>> categoryItems = [
    {'name': 'Category 1'},
    {'name': 'Category 2'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomTextField(
            label: "Customer Name",
            controller: customerNameController,
            validationText: "Please enter Customer Name",
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Brand Name",
            controller: brandNameController,
            validationText: "Please enter Brand Name",
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          CustomDropdownField(
            label: "Sales Office",
            value: controller.selectedSalesOffice,
            validationText: "Please select a Sales Office",
            items:
                controller.salesOffices.map((so) => {'name': so.name}).toList(),
            onChanged: (value) =>
                setState(() => controller.selectedSalesOffice = value),
          ),
          const SizedBox(height: 10),
          CustomDropdownField(
            label: "Business Unit",
            value: selectedBusinessUnit,
            validationText: "Please select Business Unit",
            items: businessUnitItems,
            onChanged: (value) {
              setState(() {
                selectedBusinessUnit = value;
              });
            },
          ),
          const SizedBox(height: 10),
          CustomDropdownField(
            label: "Category 1",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Category 2",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "AX Regional",
            value: controller.selectedAXRegional,
            validationText: "Please select a regional option",
            items: controller.axRegionals.map((item) {
              return {'name': item.regional};
            }).toList(),
            onChanged: (value) {
              setState(() {
                controller.selectedAXRegional = value;
              });
            },
          ),
          const SizedBox(height: 10),
          CustomDropdownField(
            label: "Distribution Channel",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Channel Segmentation",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Class",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Company Status",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Currency",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Price Group",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          CustomDropdownField(
            label: "Payment Mode",
            value: selectedCategory1,
            validationText: "Please select Category 1",
            items: categoryItems,
            onChanged: (value) {
              setState(() {
                selectedCategory1 = value;
              });
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Contact Person",
            controller: contactPersonController,
            validationText: "Please enter Contact Person",
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "KTP",
            controller: ktpController,
            validationText: "Please enter KTP",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "KTP Address",
            controller: ktpAddressController,
            validationText: "Please enter KTP Address",
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "NPWP",
            controller: npwpController,
            validationText: "Please enter NPWP",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Phone",
            controller: phoneController,
            validationText: "Please enter Phone Number",
            inputType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Email Address",
            controller: emailAddressController,
            validationText: "Please enter Email Address",
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Website",
            controller: websiteController,
            inputType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}
