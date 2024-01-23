import 'dart:io';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/tool/tool_edit/tool_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:unicons/unicons.dart';

class ToolEditPage extends StatelessWidget {
  const ToolEditPage({super.key});

  Widget _availableForLoansPrompt(ToolEditController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available for loans?',
              style: TextStyle(fontSize: 14),
            ),
            const Divider(),
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: controller.inheritedTool.available ? 0 : 1,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [UniconsLine.check, UniconsLine.multiply],
              radiusStyle: true,
              onToggle: controller.onAvailableChange,
            ),
          ],
        );
      },
    );
  }

  Widget _descriptionTextInput(ToolEditController controller) {
    return CommonTextField(
      callback: controller.onDescriptionChange,
      initialValue: controller.inheritedTool.description,
      label: 'Description',
      validator: (String? value) => controller.stringValidator(value, 10),
      maxLength: 100,
      maxLines: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ToolEditController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit tool',
            ),
            actions: [
              Obx(
                () => controller.loading.value
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      )
                    : IconButton(
                        onPressed: controller.onSubmitButton,
                        icon: const Icon(UniconsLine.check),
                      ),
              ),
              const VerticalDivider(),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Obx(
                                () {
                                  if (controller.selectedFile.value != null) {
                                    return Image.file(
                                      File(controller.selectedFile.value!.path),
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return FutureBuilder(
                                      future: ToolsBackend.getToolImage(controller.inheritedTool),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CommonLoadingImage();
                                        }

                                        if (snapshot.data!.isEmpty) {
                                          return Container(
                                            color: Theme.of(context).colorScheme.primary,
                                            child: Icon(
                                              UniconsLine.users_alt,
                                              color: Theme.of(context).colorScheme.background,
                                              size: 150,
                                            ),
                                          );
                                        }

                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: double.maxFinite,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              width: double.maxFinite,
                              height: 75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => controller.takePicture(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => controller.takePicture(ImageSource.gallery),
                                    icon: const Icon(
                                      Icons.image,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 30),
                    CommonTextField(
                      callback: controller.onNameChange,
                      initialValue: controller.inheritedTool.name,
                      label: 'Name',
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    const Divider(),
                    _availableForLoansPrompt(controller),
                    const Divider(),
                    _descriptionTextInput(controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
