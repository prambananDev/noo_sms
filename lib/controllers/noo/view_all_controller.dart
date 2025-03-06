import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewAllController extends GetxController {
  var data = <NOOModel>[].obs;
  var isLoading = false.obs;
  var page = 1.obs;
  var userId = ''.obs;
  var hasMoreData = true.obs;
  var itemsPerPage = 10.obs;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    // setupScrollController();
  }

  // void setupScrollController() {
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels ==
  //         scrollController.position.maxScrollExtent) {
  //       if (hasMoreData.value) {
  //         loadMoreData();
  //       }
  //     }
  //   });
  // }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await fetchData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchData({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      isLoading.value = true;
    }

    try {
      final response = await http.get(
        Uri.parse('${apiNOO}ViewAllCust?page=${page.value}'),
        headers: {
          'authorization': 'Basic ${base64Encode(utf8.encode('test:test456'))}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final newData = jsonData
            .map((item) {
              try {
                return NOOModel.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .whereType<NOOModel>()
            .toList();

        if (isLoadMore) {
          data.addAll(newData);
        } else {
          data.value = newData;
        }

        hasMoreData.value = newData.isNotEmpty;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      hasMoreData.value = false;
      Get.snackbar(
        'Data has been finished loaded',
        'No more data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreData() async {
    if (!isLoading.value) {
      page.value++;

      await fetchData(isLoadMore: true);
    }
  }

  Future<void> refreshData() async {
    page.value = 1;
    hasMoreData.value = true;
    await fetchData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
