import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';

class FollowUpCommentDialog extends StatefulWidget {
  final int recordId;
  final SfaController controller;

  const FollowUpCommentDialog({
    Key? key,
    required this.recordId,
    required this.controller,
  }) : super(key: key);

  @override
  State<FollowUpCommentDialog> createState() => _FollowUpCommentDialogState();
}

class _FollowUpCommentDialogState extends State<FollowUpCommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Add Follow-up Comment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (_commentController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter a comment',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[900],
                          );
                          return;
                        }

                        setState(() {
                          isSubmitting = true;
                        });

                        final success = await widget.controller.addComment(
                            widget.recordId, _commentController.text.trim());

                        if (success) {
                          Navigator.of(context).pop(true);
                        }

                        setState(() {
                          isSubmitting = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          color: colorNetral,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FollowUpCommentsList extends StatelessWidget {
  final int recordId;
  final SfaController controller;
  final bool canDelete;

  const FollowUpCommentsList({
    Key? key,
    required this.recordId,
    required this.controller,
    this.canDelete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingComments.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.sfaComments.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }

      final bool isVisitClosed = controller.isVisitClosed(recordId);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.sfaComments.length,
        itemBuilder: (context, index) {
          final comment = controller.sfaComments[index];
          String formattedDate = 'Unknown date';

          if (comment.createdDate != null && comment.createdDate!.isNotEmpty) {
            formattedDate = comment.createdDate!;
          }

          return Container(
            margin: const EdgeInsets.only(
              top: 4,
              bottom: 12,
              left: 4,
              right: 4,
            ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (canDelete && !isVisitClosed)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Comment'),
                                content: const Text(
                                    'Are you sure you want to delete this comment?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true && comment.id != null) {
                            await controller.deleteComment(comment.id!);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.comment ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class FollowUpButton extends StatelessWidget {
  final int recordId;
  final SfaController controller;

  const FollowUpButton({
    Key? key,
    required this.recordId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVisitClosed = controller.isVisitClosed(recordId);

      return GestureDetector(
        onTap: () async {
          await controller.fetchComments(recordId);
          showModalBottomSheet(
            backgroundColor: colorNetral,
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isVisitClosed) ...[
                            ElevatedButton(
                              onPressed: () async {
                                final success =
                                    await controller.closeVisit(recordId);
                                if (success) {
                                  Navigator.of(context).pop();
                                  Get.snackbar(
                                    'Success',
                                    'Visit closed successfully',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green[100],
                                    colorText: Colors.green[900],
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Close Visit'),
                            ),
                            ElevatedButton.icon(
                              label: const Text('Add Followup Result'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorAccent,
                                foregroundColor: colorNetral,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FollowUpCommentDialog(
                                      recordId: recordId,
                                      controller: controller,
                                    );
                                  },
                                );
                                if (result == true) {
                                  await controller.fetchComments(recordId);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: FollowUpCommentsList(
                            recordId: recordId,
                            controller: controller,
                            canDelete: !isVisitClosed,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.comment,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "Follow-up",
                style: TextStyle(
                  color: colorNetral,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
