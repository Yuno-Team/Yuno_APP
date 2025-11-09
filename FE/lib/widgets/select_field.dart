import 'package:flutter/material.dart';

class SelectField extends StatelessWidget {
  final String? hintText;
  final String? value;
  final List<String>? options;
  final Function(String?)? onChanged;
  final bool enabled;

  const SelectField({
    Key? key,
    this.hintText,
    this.value,
    this.options,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? Color(0xFF252931) : Color(0xFF252931),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Color(0xFF252931),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hintText ?? '선택해주세요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A7180),
              letterSpacing: -0.8,
              height: 24/16,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF949CAD),
            size: 16,
          ),
          dropdownColor: Color(0xFF252931),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFF6F8FA),
            letterSpacing: -0.8,
            height: 24/16,
          ),
          isExpanded: true,
          onChanged: enabled ? onChanged : null,
          items: options?.map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList() ?? [],
        ),
      ),
    );
  }
}
