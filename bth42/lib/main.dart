import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BalanceGameWeb(),
  ));
}

class BalanceGameWeb extends StatefulWidget {
  const BalanceGameWeb({super.key});

  @override
  State<BalanceGameWeb> createState() => _BalanceGameWebState();
}

class _BalanceGameWebState extends State<BalanceGameWeb> {
  // 📍 vị trí của bi
  double ballX = 150;
  double ballY = 400;

  // 📍 vị trí của đích
  double targetX = 200;
  double targetY = 200;

  // kích thước
  final double ballSize = 50;
  final double targetSize = 60;

  // lưu kích thước màn hình
  double screenW = 0;
  double screenH = 0;

  // tốc độ di chuyển
  double speed = 10;

  // Hàm di chuyển bằng bàn phím
  void _moveBall(String direction) {
    setState(() {
      if (direction == 'left') ballX -= speed;
      if (direction == 'right') ballX += speed;
      if (direction == 'up') ballY -= speed;
      if (direction == 'down') ballY += speed;

      // Giới hạn trong màn hình
      ballX = ballX.clamp(0, screenW - ballSize);
      ballY = ballY.clamp(0, screenH - ballSize);

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    final ballCenterX = ballX + ballSize / 2;
    final ballCenterY = ballY + ballSize / 2;
    final targetCenterX = targetX + targetSize / 2;
    final targetCenterY = targetY + targetSize / 2;

    final distance = sqrt(pow(ballCenterX - targetCenterX, 2) +
        pow(ballCenterY - targetCenterY, 2));

    if (distance < targetSize / 2) {
      _showWin();
      final random = Random();
      targetX = random.nextDouble() * (screenW - targetSize);
      targetY = random.nextDouble() * (screenH - targetSize);
    }
  }

  void _showWin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 Bạn đã chạm đích! Đích mới đã xuất hiện!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Game Lăn Bi (Phiên bản Web/PC)'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
          // 🎯 Đích
          Positioned(
          left: targetX,
          top: targetY,
          child: Container(
            width: targetSize,
            height: targetSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 4),
            ),
          ),
        ),
        // 🔵 Quả bi
        Positioned(
            left: ballX,
            top: ballY,
            child: Container(
                width: ballSize,
                height: ballSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
            ),
        ),

            // 🎮 Nút điều khiển (phím ảo)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _moveBall('left'),
                      icon: const Icon(Icons.arrow_left, size: 48),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _moveBall('up'),
                          icon: const Icon(Icons.arrow_drop_up, size: 48),
                        ),
                        const SizedBox(height: 10),
                        IconButton(
                          onPressed: () => _moveBall('down'),
                          icon: const Icon(Icons.arrow_drop_down, size: 48),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _moveBall('right'),
                      icon: const Icon(Icons.arrow_right, size: 48),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}