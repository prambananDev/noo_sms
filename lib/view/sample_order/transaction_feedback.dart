import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/button_widget.dart';
import 'package:noo_sms/assets/widgets/upload_photo_feedback.dart';
import 'package:noo_sms/controllers/sample_order/transaction_history_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';

class FeedbackPage extends StatefulWidget {
  final int index;
  final TransactionHistorySampleController inputPagePresenter;
  final String salesId;

  const FeedbackPage({
    super.key,
    required this.index,
    required this.inputPagePresenter,
    required this.salesId,
  });

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  final ImagePicker imagePicker = ImagePicker();
  File? _selectedImage;
  Uint8List? _uploadedImage;
  late TextEditingController _textController;
  IdAndValue<String>? _selectedFeed;
  bool isImagePickerActive = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initializeFeedback();
  }

  void _initializeFeedback() {
    final feedbackDetail = widget.inputPagePresenter.feedbackDetail.value;
    _textController.text = feedbackDetail.notes ?? "";
    if (feedbackDetail.feedbackName != null &&
        feedbackDetail.feedbackName!.isNotEmpty) {
      _selectedFeed = widget.inputPagePresenter.feedList.value.choiceList
          ?.firstWhere((feed) => feed.value == feedbackDetail.feedbackName);
    }
  }

  Future<void> handleUploadsFeed(String salesId, ImageSource source) async {
    if (isImagePickerActive) return;
    setState(() {
      isImagePickerActive = true;
    });

    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      final pickedFile = await imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImage =
              null; // Reset uploaded image when a new image is picked
        });
      }
    } finally {
      setState(() {
        isImagePickerActive = false;
      });
    }
  }

  Future<void> uploadImageIfNeeded(String salesId) async {
    if (_selectedImage != null && _uploadedImage == null) {
      setState(() {
        isUploading = true;
      });
      try {
        await widget.inputPagePresenter
            .uploadsFeedImage(salesId, _selectedImage!);
        Uint8List? uploadedImage =
            await widget.inputPagePresenter.fetchImageFeed(salesId);
        setState(() {
          _uploadedImage = uploadedImage;
        });
      } catch (e) {
        rethrow;
      } finally {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> submitFeedback() async {
    try {
      if (_selectedImage != null && _uploadedImage == null) {
        await uploadImageIfNeeded(widget.salesId);
      }

      widget.inputPagePresenter.feedList.value.selectedChoice = _selectedFeed;
      widget.inputPagePresenter.feedbackTextEditingControllerRx.value.text =
          _textController.text;
      await widget.inputPagePresenter.submitFeedback(widget.index);

      // DashboardOrderSampleState.tabController.animateTo(3);

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit feedback: $e",
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        title: const Text("Submit Feedback"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<IdAndValue<String>>(
                      hint: const Text(
                        "Select Feedback",
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _selectedFeed,
                      items: widget.inputPagePresenter.feedList.value.choiceList
                          ?.map((feed) {
                        return DropdownMenuItem<IdAndValue<String>>(
                          value: feed,
                          child: Text(feed.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFeed = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: null,
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Submit notes here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.fitWidth)
                      : _uploadedImage != null
                          ? Image.memory(_uploadedImage!, fit: BoxFit.fitWidth)
                          : const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "No Image Loaded",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                  if (_selectedImage == null && _uploadedImage == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ButtonOrderSample(
                          size: MediaQuery.of(context).size,
                          onTapAction: () {
                            Get.bottomSheet(
                              DynamicBottomFeedback(
                                salesId: widget.salesId,
                                onCameraTap: (salesId, source) =>
                                    handleUploadsFeed(salesId, source),
                                onGalleryTap: (salesId, source) =>
                                    handleUploadsFeed(salesId, source),
                              ),
                            );
                          },
                          colorIcon: Colors.white,
                          nameButton: "Upload",
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isUploading ? null : submitFeedback,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
          if (isUploading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
