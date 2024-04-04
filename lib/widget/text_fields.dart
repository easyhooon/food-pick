import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatefulWidget {
  String? defaultText;
  String? hintText;
  bool isPasswordField = false;
  bool? isEnabled;
  int? maxLines;
  bool isReadOnly;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FormFieldValidator validator;
  TextEditingController controller;
  Function(String value)? onFieldSubmitted;
  Function()? onTap;

  TextFormFieldCustom({
    this.defaultText,
    this.hintText,
    required this.isPasswordField,
    this.isEnabled,
    this.maxLines,
    required this.isReadOnly,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.controller,
    this.onFieldSubmitted,
    this.onTap,
    super.key,
  });

  @override
  State<TextFormFieldCustom> createState() => _TextFormFieldCustomState();
}

class _TextFormFieldCustomState extends State<TextFormFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.defaultText,
      validator: (value) => widget.validator(value),
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      onTap: widget.isReadOnly ? widget.onTap : null,
      maxLines: widget.maxLines,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.redAccent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        hintText: widget.hintText,
      ),
      obscureText: widget.isPasswordField,
    );
  }
}
