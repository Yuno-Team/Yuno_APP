import 'package:flutter/material.dart';

class SwitchField extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;
  final bool enabled;

  const SwitchField({
    Key? key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: Color(0xFF165DFB),
      activeTrackColor: Color(0xFF165DFB).withOpacity(0.3),
      inactiveThumbColor: Color(0xFF949CAD),
      inactiveTrackColor: Color(0xFF949CAD).withOpacity(0.3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
