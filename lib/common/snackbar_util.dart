import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO 대괄호의 의미 파악
void showSnackBar(BuildContext context, String text, [int duration = 2]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    ),
  );
}
