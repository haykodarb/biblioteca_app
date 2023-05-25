import 'package:biblioteca/backend/login_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/login_form.dart';
import 'package:biblioteca/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class LoginController extends GetxController {
  final Rx<LoginForm> form = LoginForm(
    email: 'hayko1',
    password: 'ea29hd',
  ).obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString errorMessage = ''.obs;

  final RxBool loading = false.obs;

  void onEmailChange(String value) {
    form.update((val) {
      val!.email = value;
    });
  }

  void onPasswordChange(String value) {
    form.update((val) {
      val!.password = value;
    });
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (!value.isEmail) {
      return 'Input must be a valid email.';
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (!isAscii(value)) {
      return 'Password should only include ASCII characters';
    }

    return null;
  }

  Future<void> loginButtonCallback() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendReponse response = await LoginBackend.login(form: form.value);

      loading.value = false;

      if (response.success) {
        errorMessage.value = '';
        Get.offAllNamed(RouteNames.myBooksPage);
      } else {
        errorMessage.value = response.payload;
      }
    }
  }
}
