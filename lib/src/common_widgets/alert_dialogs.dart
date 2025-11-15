import 'package:flutter/material.dart';

/// Shows a dialog with a title and content.
Future<void> showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  String? cancelActionText,
  String defaultActionText = 'OK',
}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (cancelActionText != null)
          TextButton(
            child: Text(cancelActionText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        TextButton(
          child: Text(defaultActionText),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}

/// Shows an exception alert dialog.
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  required String title,
  required dynamic exception,
}) => showAlertDialog(
  context: context,
  title: title,
  content: exception.toString(),
  defaultActionText: 'OK',
);
