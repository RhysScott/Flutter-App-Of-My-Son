import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      placeholder: const Text('Password'),
      obscureText: obscure,
      leading: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(LucideIcons.lock),
      ),
      trailing: ShadButton(
        width: 24,
        height: 24,
        padding: EdgeInsetsGeometry.zero,
        child: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye),
        onPressed: () {
          setState(() => obscure = !obscure);
        },
      ),
    );
  }
}
