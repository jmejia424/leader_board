import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/common_widgets/alert_dialogs.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error',
        exception: message,
      );
    }
  }
}
