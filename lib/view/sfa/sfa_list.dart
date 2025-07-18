import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';
import 'package:noo_sms/models/sfa_model.dart';
import 'package:noo_sms/view/sfa/sfa_create_visit.dart';
import 'package:noo_sms/view/sfa/sfa_detail.dart';
import 'package:noo_sms/view/sfa/sfa_followup_comment.dart';

class SfaListView extends StatefulWidget {
  const SfaListView({Key? key}) : super(key: key);

  @override
  State<SfaListView> createState() => _SfaListViewState();
}

class _SfaListViewState extends State<SfaListView> {
  late final SfaController controller = Get.put(SfaController());

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await controller.getUserData();
    await controller.fetchSfaRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Container(
        color: colorNetral,
        child: RefreshIndicator(
          onRefresh: controller.fetchSfaRecords,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.sfaRecords.isEmpty) {
              return Center(
                child: Text(
                  'No SFA records found',
                  style: TextStyle(
                    fontSize: 16.rt(context),
                    color: colorBlack,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: controller.sfaRecords.length,
              itemBuilder: (context, index) {
                return _buildSfaCard(controller.sfaRecords[index], context);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSfaCard(SfaRecord record, BuildContext context) {
    String formattedDate = 'Unknown';
    if (record.createdDate != null) {
      formattedDate =
          DateFormat("dd/MM/yyyy").format(DateTime.parse(record.createdDate!));
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.rp(context),
        vertical: 8.rp(context),
      ),
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.rp(context)),
                child: Text(
                  'Transaction ID - ${record.id}',
                  style: TextStyle(
                    fontSize: 24.rt(context),
                    fontWeight: FontWeight.bold,
                    color: colorBlack,
                  ),
                ),
              ),
              _buildInfoRow(
                context,
                'Date : ',
                formattedDate,
              ),
              _buildInfoRow(
                context,
                'Customer : ',
                record.customerName ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Contact Person : ',
                record.contactPerson ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Purpose : ',
                record.purpose ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Purpose Description : ',
                record.purposeDesc ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Sales Name : ',
                record.fullName ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Status : ',
                record.statusName ?? 'N/A',
              ),
              SizedBox(
                height:
                    60.rs(context), // More predictable than percentage-based
              ),
            ],
          ),
          Positioned(
            bottom: 10.rp(context),
            right: 10.rp(context),
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  "Edit",
                  () => Get.to(() => SfaCreate(record: record)),
                ),
                SizedBox(width: 8.rp(context)),
                _buildActionButton(
                  context,
                  "Detail",
                  () {
                    if (record.id != null) {
                      Get.to(() => SfaDetail(
                            recordId: record.id!,
                            status: record.statusName!,
                          ));
                    }
                  },
                ),
                SizedBox(width: 8.rp(context)),
                FollowUpButton(
                  recordId: record.id!,
                  controller: controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.rp(context)),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16.rt(context),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 16.rt(context),
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(12.rr(context)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.rp(context),
          vertical: 8.rp(context),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorNetral,
            fontSize: 16.rt(context),
          ),
        ),
      ),
    );
  }
}
