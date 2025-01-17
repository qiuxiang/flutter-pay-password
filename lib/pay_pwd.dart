import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pin_put/pin_put.dart';

Future<void> pay({
  required BuildContext context,
  required FutureOr<String?> Function(String password) onSubmit,
  String title = '',
  String hintText = '',
  String amount = '',
  String currency = '\$',
  Widget? content,
}) async {
  final input = TextEditingController();
  final state = _PayState();
  Get.put(state);
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      final decoration = BoxDecoration(
        color: context.theme.dividerColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
      return AlertDialog(
        title: Row(children: [
          Expanded(child: Text(title)),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: Navigator.of(context).pop,
              splashRadius: 24,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close),
            ),
          ),
        ]),
        content: SizedBox(
          width: 240,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Visibility(visible: hintText.isNotEmpty, child: Text(hintText)),
            Visibility(
              visible: amount.isNotEmpty,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  currency,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ),
            content ?? const SizedBox(),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, box) {
              final width = (box.maxWidth - 6 * 5) / 6;
              return Obx(() {
                return PinPut(
                  fieldsCount: 6,
                  obscureText: '•',
                  controller: input,
                  autofocus: true,
                  enabled: state.loading.isFalse,
                  eachFieldConstraints:
                      BoxConstraints(minHeight: width, minWidth: width),
                  submittedFieldDecoration: decoration,
                  selectedFieldDecoration: decoration,
                  followingFieldDecoration: decoration,
                  disabledDecoration: decoration,
                  onSubmit: (password) async {
                    state.loading.value = true;
                    final error = await onSubmit(password);
                    if (error == null || error.isEmpty) {
                      Navigator.of(context).pop();
                    } else {
                      state.error.value = error;
                      state.loading.value = false;
                      input.clear();
                    }
                  },
                );
              });
            }),
            Obx(() {
              if (state.loading.isTrue) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              if (state.error.isNotEmpty) {
                return Container(
                  height: 24,
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    state.error.value,
                    style: TextStyle(color: context.theme.errorColor),
                  ),
                );
              }

              return const SizedBox();
            }),
          ]),
        ),
      );
    },
  );
}

class _PayState extends GetxController {
  final loading = false.obs;
  final error = ''.obs;
}

class PayPasswordException {
  final String error;

  const PayPasswordException(this.error);
}
