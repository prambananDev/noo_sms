import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
        borderRadius: BorderRadius.circular(16.rr(context)),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Add Follow-up Comment',
            style: TextStyle(
              fontSize: 18.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.rs(context)),
          TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 5,
            style: TextStyle(fontSize: 16.rt(context)),
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              hintStyle: TextStyle(fontSize: 16.rt(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.rr(context)),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.rp(context),
                vertical: 12.rp(context),
              ),
            ),
          ),
          SizedBox(height: 16.rs(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
              SizedBox(width: 8.rs(context)),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.rp(context),
                    vertical: 12.rp(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.rr(context)),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: 20.rs(context),
                        height: 20.rs(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.rs(context),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16.rt(context),
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
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.rp(context)),
            child: Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 16.rt(context),
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
            margin: EdgeInsets.only(
              top: 4.rp(context),
              bottom: 12.rp(context),
              left: 4.rp(context),
              right: 4.rp(context),
            ),
            padding: EdgeInsets.all(8.rp(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.rr(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8.rs(context),
                  spreadRadius: 1.rs(context),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.ri(context),
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.rs(context)),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.rt(context),
                      ),
                    ),
                    if (canDelete && !isVisitClosed)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18.ri(context),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.rr(context)),
                                ),
                                title: Text(
                                  'Delete Comment',
                                  style: TextStyle(fontSize: 18.rt(context)),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this comment?',
                                  style: TextStyle(fontSize: 16.rt(context)),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style:
                                          TextStyle(fontSize: 16.rt(context)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16.rt(context),
                                      ),
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
                SizedBox(height: 8.rs(context)),
                Text(
                  comment.comment ?? '',
                  style: TextStyle(fontSize: 14.rt(context)),
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
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20.rr(context))),
            ),
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16.rp(context)),
                  child: Column(
                    children: [
                      Container(
                        width: 40.rs(context),
                        height: 5.rs(context),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.rr(context)),
                        ),
                        margin: EdgeInsets.only(bottom: 20.rp(context)),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.rp(context),
                                  vertical: 12.rp(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8.rr(context)),
                                ),
                              ),
                              child: Text(
                                'Close Visit',
                                style: TextStyle(fontSize: 16.rt(context)),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(
                                Icons.add,
                                size: 18.ri(context),
                              ),
                              label: Text(
                                'Add Followup Result',
                                style: TextStyle(fontSize: 16.rt(context)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorAccent,
                                foregroundColor: colorNetral,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.rp(context),
                                  vertical: 12.rp(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8.rr(context)),
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
                      SizedBox(height: 16.rs(context)),
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
            borderRadius: BorderRadius.circular(12.rr(context)),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 16.rp(context), vertical: 8.rp(context)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.comment,
                color: Colors.white,
                size: 18.ri(context),
              ),
              SizedBox(width: 6.rs(context)),
              Text(
                "Follow-up",
                style: TextStyle(
                  color: colorNetral,
                  fontSize: 16.rt(context),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
