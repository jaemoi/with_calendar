import 'package:flutter/material.dart';

class TermsCheckTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final bool required;

  const TermsCheckTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFF6E91),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        "${required ? "(필수) " : "(선택) "}$text",
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          height: 20 / 18,
        ),
      ),
    );
  }
}
