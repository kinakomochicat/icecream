import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: KakigoriApp(),
      ),
    );

class KakigoriApp extends StatefulWidget {
  const KakigoriApp({super.key});

  @override
  State<KakigoriApp> createState() => _KakigoriAppState();
}

class _KakigoriAppState extends State<KakigoriApp> {
  final prices = <int, int>{
    1: 450,
    2: 400,
    3: 300,
    4: 300,
    5: 300,
  };

  final syrupColors = <String, Color>{
    'いちご': Colors.pink,
    'レモン': Colors.yellow,
    'メロン': Colors.green,
    'ブルーハワイ': Colors.lightBlue,
    'ぶどう': Colors.purple,
  };

  int flavorCount = 1;
  final selectedSyrups = <String>[];
  bool spoon = false;
  bool napkin = false;
  int order = 0;
  String receipt = '';

  @override
  Widget build(BuildContext context) {
    final subtotal = prices[flavorCount]!;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final canOrder = selectedSyrups.length == flavorCount;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('🍧 かき氷 屋台注文アプリ'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CustomPaint(
                  size: const Size(240, 220),
                  painter: KakigoriPainter(
                    colors: [
                      for (final name in selectedSyrups)
                        syrupColors[name]!,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('シロップの種類数を選ぶ'),
              Wrap(
                spacing: 6,
                children: [
                  for (final count in prices.keys)
                    ChoiceChip(
                      label: Text('$count種類 ${prices[count]}円'),
                      selected: flavorCount == count,
                      onSelected: (_) {
                        setState(() {
                          flavorCount = count;

                          if (selectedSyrups.length > count) {
                            selectedSyrups.removeRange(
                              count,
                              selectedSyrups.length,
                            );
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'シロップを選ぶ'
                '（${selectedSyrups.length} / $flavorCount種類）',
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final name in syrupColors.keys)
                    FilterChip(
                      avatar: CircleAvatar(
                        backgroundColor: syrupColors[name],
                        radius: 8,
                      ),
                      label: Text(name),
                      selected: selectedSyrups.contains(name),
                      onSelected: (selected) {
                        setState(() {
                          if (!selected) {
                            selectedSyrups.remove(name);
                          } else if (selectedSyrups.length < flavorCount) {
                            selectedSyrups.add(name);
                          } else {
                            selectedSyrups.removeLast();
                            selectedSyrups.add(name);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('無料サービス'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('🥄 スプーン'),
                value: spoon,
                onChanged: (value) {
                  setState(() => spoon = value ?? false);
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('🧻 紙ナプキン'),
                value: napkin,
                onChanged: (value) {
                  setState(() => napkin = value ?? false);
                },
              ),
              const Divider(),
              Center(
                child: Text('税抜 $subtotal 円 / 消費税 $tax 円'),
              ),
              Center(
                child: Text(
                  '合計 $total 円',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: FilledButton(
                  onPressed: canOrder
                      ? () {
                          setState(() {
                            order = Random().nextInt(999) + 1;
                            receipt = 'かき氷：$flavorCount種類\n'
                                'シロップ：${selectedSyrups.join('・')}\n'
                                '🥄 スプーン：${spoon ? 'あり' : 'なし'}\n'
                                '🧻 紙ナプキン：${napkin ? 'あり' : 'なし'}\n'
                                '税抜：$subtotal 円\n'
                                '消費税（10%）：$tax 円\n'
                                '合計：$total 円';
                          });
                        }
                      : null,
                  child: const Text('注文する'),
                ),
              ),
              if (!canOrder)
                Center(
                  child: Text(
                    'シロップをあと'
                    '${flavorCount - selectedSyrups.length}種類選んでください',
                  ),
                ),
              if (order != 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '注文番号 #$order',
                          style: const TextStyle(fontSize: 26),
                        ),
                        Text(receipt),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class KakigoriPainter extends CustomPainter {
  KakigoriPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final ice = Path()
      ..moveTo(20, 145)
      ..quadraticBezierTo(25, 105, 50, 90)
      ..quadraticBezierTo(55, 55, 85, 55)
      ..quadraticBezierTo(120, 5, 155, 55)
      ..quadraticBezierTo(190, 55, 195, 90)
      ..quadraticBezierTo(220, 110, 220, 145)
      ..close();

    canvas.drawPath(
      ice,
      Paint()..color = const Color(0xFFF0F8FF),
    );

    if (colors.isNotEmpty) {
      canvas.save();
      canvas.clipPath(ice);

      final stripeWidth = 200 / colors.length;

      for (var i = 0; i < colors.length; i++) {
        final rect = Rect.fromLTWH(
          20 + stripeWidth * i,
          20,
          stripeWidth,
          125,
        );

        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors[i],
                Color.lerp(colors[i], Colors.white, 0.75)!,
              ],
            ).createShader(rect),
        );
      }

      canvas.restore();
    }

    canvas.drawPath(
      ice,
      Paint()
        ..color = const Color(0xFFB0BEC5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final bowl = Path()
      ..moveTo(15, 145)
      ..lineTo(225, 145)
      ..quadraticBezierTo(210, 205, 120, 205)
      ..quadraticBezierTo(30, 205, 15, 145)
      ..close();

    canvas.drawPath(
      bowl,
      Paint()..color = const Color(0xFF81D4FA),
    );

    canvas.drawLine(
      const Offset(15, 145),
      const Offset(225, 145),
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant KakigoriPainter oldDelegate) {
    return true;
  }
}