import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ZoomController extends GetxController {
  final ImagePicker picker = ImagePicker();
  RxString imagePath = ''.obs;
  RxString imageName = ''.obs;
  RxBool cameraLodaing = false.obs;
  RxBool isVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> pickImage(ImageSource source) async {
    if (!await Permission.camera.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission was not granted.',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final XFile? img = await picker.pickImage(source: source);
    if (img != null && img.path.isNotEmpty) {
      imagePath.value = img.path;
      cameraLodaing.value = false;

      imageName.value = path.basename(img.path);
    }
  }

  /// store zoom link here
  String zoomLink = '';

  void setZoomLink(String link) {
    zoomLink = link;
    update();
  }
}
