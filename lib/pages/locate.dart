import 'package:flutter/material.dart';

// GPS地图页面
class GpsMapPage extends StatelessWidget {
  const GpsMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE8F4F8),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Color(0xFF4299E1)),
                  SizedBox(height: 20),
                  Text(
                    "实时GPS定位地图",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "当前位置：北京市朝阳区XX路XX号",
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "定位精度：5米 | 卫星信号：强",
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
