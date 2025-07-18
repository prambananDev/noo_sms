import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_dialog.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/controllers/noo/draft_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/widget/widget_all.dart';
import 'package:noo_sms/view/noo/draft/draft_page.dart';

class CustomerForm extends StatefulWidget {
  final NOOModel? editData;
  final bool isFromDraft;
  final CustomerFormController controller;

  const CustomerForm({
    Key? key,
    this.editData,
    this.isFromDraft = false,
    required this.controller,
  }) : super(key: key);

  @override
  CustomerFormState createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm>
    with SingleTickerProviderStateMixin {
  late CustomerFormController controller;
  bool _showButtons = false;
  bool _isLoading = true;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    _initializeController().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.index != _currentIndex) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  Future<void> _initializeController() async {
    controller = widget.controller;

    if (!controller.isInitialized) {
      await controller.requestPermissions();
    }

    if (!controller.isInitialized) {
      await controller.initializeData();
    }

    if (widget.editData != null && !controller.isEditMode.value) {
      controller.isEditMode.value = true;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void handleBack() {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Form'),
        content: const Text(
            'Are you sure you want to leave this form? All unsaved data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _clearAndExit();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _clearAndExit() {
    controller.clearForm();
    controller.isEditMode.value = false;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerFormController>(
      builder: (controller) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor: colorNetral,
            body: const Center(
              child: LoadingIndicator(message: 'Loading form data...'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorNetral,
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                _buildHeaderSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      BasicInfoSection(controller: controller),
                      CompanyAndTaxSection(controller: controller),
                      DeliveryAddressSection(controller: controller),
                      DocumentsSection(controller: controller),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return GestureDetector(
                        onTap: () {
                          _tabController.animateTo(index);
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: _currentIndex == index ? 24.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4.0),
                            color: _currentIndex == index
                                ? colorAccent
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                FormActionButtons(
                  controller: controller,
                  onSubmit: () => controller.handleSubmit(),
                  onPreview: () {
                    if (controller.validateRequiredDocuments()) {
                      final previewController =
                          Get.isRegistered<PreviewController>()
                              ? Get.find<PreviewController>()
                              : Get.put(PreviewController());
                      Get.dialog(PreviewDialog(controller: previewController));
                    }
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButtons(),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16,
        top: widget.isFromDraft || controller.isEditMode.value ? 48 : 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isFromDraft || widget.editData != null)
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 35.rt(context),
              ),
              onPressed: handleBack,
            ),
          Text(
            widget.isFromDraft
                ? 'Edit Draft'
                : controller.isEditMode.value
                    ? 'Edit Customer'
                    : 'New Customer',
            style: TextStyle(
              fontSize: 24.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Stack(
      children: [
        Positioned(
          bottom: 60,
          right: 10,
          child: FloatingActionButton(
            backgroundColor: colorAccent,
            onPressed: () {
              setState(() {
                _showButtons = !_showButtons;
              });
            },
            child: Icon(
              _showButtons ? Icons.close : Icons.menu,
              color: colorNetral,
            ),
          ),
        ),
        if (_showButtons)
          Positioned(
            bottom: 120,
            right: 20,
            child: AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final draftController =
                          Get.isRegistered<DraftController>()
                              ? Get.find<DraftController>()
                              : Get.put(DraftController());

                      await draftController.saveDraft(controller);
                      controller.clearForm();
                      Get.to(() => const DraftPage());
                    },
                    child: Text(
                      'Save Draft',
                      style: TextStyle(
                        color: colorAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (!widget.isFromDraft)
                    OutlinedButton(
                      onPressed: () async {
                        Get.isRegistered<DraftController>()
                            ? Get.find<DraftController>()
                            : Get.put(DraftController());
                        Get.to(() => const DraftPage());
                      },
                      child: Text(
                        'Draft List',
                        style: TextStyle(
                          color: colorAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({Key? key, this.message = 'Loading...'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
