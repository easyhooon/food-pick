import 'package:flutter/material.dart';

class ElevatedButtonCustom extends StatelessWidget {
  String text;
  Color backgroundColor;
  Color textColor;
  Function onPressed;

  ElevatedButtonCustom({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed.call(), // 클릭 함수 콜백 구현,
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
