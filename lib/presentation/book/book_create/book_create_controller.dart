import 'dart:typed_data';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class BookCreateController extends GetxController {
  final Rx<Book> bookForm = Book.empty().obs;

  final RxBool allowReview = false.obs;
  final RxBool addingReview = false.obs;

  final RxBool loading = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final BookListController bookListController = Get.find();

  Future<void> scanBook() async {
    /*
    var result = await BarcodeScanner.scan();

    if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
      getOpenLibraryImage(result.rawContent);

      final BackendResponse response = await OpenLibraryBackend.getBookByISBN(result.rawContent);

      if (response.success) {
        final OpenLibraryBook book = response.payload;

        if (book.title != null) {
          bookForm.value.title = book.title!;
          titleController.text = book.title!;
        }

        if (book.author != null) {
          bookForm.value.author = book.author!;
          authorController.text = book.author!;
        }

        bookForm.refresh();
      }
    }
*/
  }

  Future<void> takePicture(ImageSource source, BuildContext context) async {
    try {
      XFile? pickedImage = await imagePicker.pickImage(
        source: source,
        imageQuality: 100,
        maxHeight: 1280,
        maxWidth: 960,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedImage == null) return;
      final Uint8List pickedBytes = await pickedImage.readAsBytes();

      if (!context.mounted) return;

      final Uint8List? croppedBytes = await showDialog<Uint8List?>(
        context: context,
        builder: (context) => CommonImageCropper(
          image: Image.memory(pickedBytes),
          aspectRatio: 3 / 4,
        ),
      );

      if (croppedBytes == null || croppedBytes.isEmpty) return;

      selectedBytes.value = croppedBytes;
    } catch (e) {
      if (!context.mounted) return;
      CommonAlertDialog(title: e.toString()).open(context);
    }
  }

  void onAddReviewChange(int? index) {
    if (index == 0) {
      addingReview.value = true;
    } else {
      addingReview.value = false;

      bookForm.update(
        (Book? val) {
          val!.review = null;
        },
      );
    }
  }

  void onReviewTextChange(String? value) {
    bookForm.update(
      (Book? val) {
        val!.review = value;
      },
    );
  }

  void onPublicChange() {
    bookForm.update(
      (Book? val) {
        val!.public = !val.public;
      },
    );
  }

  void onTitleChange(String value) {
    bookForm.update(
      (Book? val) {
        val!.title = value;
      },
    );
  }

  void onAuthorChange(String value) {
    bookForm.update(
      (Book? val) {
        val!.author = value;
      },
    );
  }

  String? stringValidator({required String? value, required int length, required bool optional}) {
    if (optional) {
      if (value == null || value.isEmpty) return null;
    } else {
      if (value == null || value.isEmpty) {
        return 'Please enter something.';
      }
    }

    if (value.length < length) {
      return 'Must be at least $length characters long.';
    }

    return null;
  }

  Future<void> onSubmitButton(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      if (selectedBytes.value == null) {
        showDialog(
          context: context,
          builder: (context) => const CommonAlertDialog(
            title: 'Please add a book cover image.',
          ),
        );
        loading.value = false;
        return;
      }

      final BackendResponse response = await BooksBackend.addBook(
        bookForm.value,
        selectedBytes.value!,
      );
      if (!context.mounted) return;

      if (response.success) {
        bookListController.listViewController.itemList.insert(0, response.payload);
        bookListController.listViewController.itemList.refresh();
        bookListController.listViewController.pageKey++;
        context.pop(response.payload);
      } else {
        showDialog(
          context: context,
          builder: (context) => CommonAlertDialog(
            title: response.payload,
          ),
        );
        loading.value = false;
      }
    }
  }
}
