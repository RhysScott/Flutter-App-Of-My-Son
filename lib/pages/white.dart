import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class WhitePage extends StatefulWidget {
  const WhitePage({super.key});
  @override
  State<WhitePage> createState() => _WhitePageState();
}

class _WhitePageState extends State<WhitePage> {
  Widget _buildBody() {
    return FTimePicker(
      control: FTimePickerControl.managed(
        initial: FTime.now(),
        onChange: (time) {},
      ),
      hour24: false,
      hourInterval: 1,
      minuteInterval: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}
