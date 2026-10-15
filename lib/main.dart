import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: IcecreamApp()));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final foods = {
    '1種類': 450,
    '2種類': 400,
    '3種類': 300,
    '4種類': 300,
    '5種類': 300,
  };
  late String food = foods.keys.first;
  int order = 0;
  bool spoon = false, napkin = false;
  String receipt = '';

    final syrupColors = <String, Color>{
    'いちご': Colors.pink,
    'レモン': Colors.yellow,
    'メロン': Colors.green,
    'ブルーハワイ': Colors.lightBlue,
    'ぶどう': Colors.purple,
  };

  final syrups = <String>[];

  Future<void> diagnoseColor() async {
    final names = syrupColors.keys.toList();

    final questions = [
      '今、行きたい場所は？',
      '今日はどんなふうに過ごしたい？',
      '今、惹かれる言葉は？',
    ];


    final options = [
      ['🌷 お花のカフェ', '🎡 遊園地', '🌿 森', '🌊 海', '🌌 星空の丘'],
      ['🎀 好きなもの探し', '☀️ ワイワイ楽しむ', '🍃 のんびりする',
      '🧭 新しいことに挑戦', '📖 自分の世界に浸る'],
      ['💕 ときめき', '✨ ワクワク', '🌱 安らぎ', '🕊️ 自由', '🔮 想像'],
    ];

    final titles = [
      'ときめきのピンク',
      'きらめくイエロー',
      'やすらぎのグリーン',
      '自由なブルー',
      '夢見るパープル',
    ];

    final messages = [
      '好きなものや、ときめく出会いを楽しみたいあなたへ！',
      '今日は思いっきり楽しみたい！そんなあなたへ。',
      'ひと息ついて、自分のペースで過ごしたいあなたへ。',
      'いつもと違う景色に出会いたいあなたへ！',
      '想像を広げて、自分だけの世界を楽しみたいあなたへ。',
    ];

    final scores = List<int>.filled(names.length, 0);
    int lastAnswer = 0;

    for (int i = 0; i < questions.length; i++) {
      final answer = await showDialog<int>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text('質問 ${i + 1}/3\n${questions[i]}'),
          children: [
            for (int j = 0; j < options[i].length; j++)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, j),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(options[i][j]),
                ),
              ),
          ],
        ),
      );

      if (!mounted || answer == null) return;

      scores[answer]++;
      lastAnswer = answer;
    }

    final ranking = List<int>.generate(names.length, (i) => i)
      ..sort((a, b) {
        final difference = scores[b].compareTo(scores[a]);
        if (difference != 0) return difference;
        if (a == b) return 0;
        if (a == lastAnswer) return -1;
        if (b == lastAnswer) return 1;
        return a.compareTo(b);
      });

    final winner = ranking.first;
    final count = int.parse(food.substring(0, 1));
    final recommended = ranking.take(count).map((i) => names[i]).toList();

    final apply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('あなたは「${titles[winner]}」！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop,
              color: syrupColors[names[winner]],
              size: 64,
            ),
            Text(messages[winner]),
            const SizedBox(height: 16),
            Text('おすすめ：${recommended.join(' × ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('この色のかき氷にする'),
          ),
        ],
      ),
    );

    if (!mounted || apply != true) return;

    setState(() {
      syrups
        ..clear()
        ..addAll(recommended);
    });
  }

  Widget choices(Iterable<String> items, String value,
      void Function(String) change) => Wrap(spacing: 6, children: [
        for (final s in items)
          ChoiceChip(label: Text(s), selected: value == s,
            onSelected: (_) => setState(() => change(s))),
      ]);

  @override
  Widget build(BuildContext context) {
    final subtotal = foods[food]!;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final photo = SizedBox(
      width: 190,
      height: 145,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(90),
                  bottom: Radius.circular(12),
                ),
                color: syrups.length < 2
                    ? (syrups.isEmpty
                        ? const Color(0xFFEAF6FF)
                        : syrupColors[syrups.first]!)
                    : null,
                gradient: syrups.length >= 2
                    ? LinearGradient(
                        colors: [
                          for (final s in syrups) syrupColors[s]!,
                        ],
                      )
                    : null,
              ),
            ),
            Container(
              width: 145,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final products = choices(foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) {
        food = s.substring(0, s.lastIndexOf('  '));
        final count = int.parse(food.substring(0, 1));
        if (syrups.length > count) {
          syrups.removeRange(count, syrups.length);
        }
      });
    Widget supply(String label, bool value, void Function(bool) change) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: value,
          onChanged: (v) => setState(() => change(v ?? false))),
        Text(label),
      ]);
    final supplies = Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supply('🥄 スプーン（無料）', spoon, (v) => spoon = v),
        supply('🧻 紙ナプキン（無料）', napkin, (v) => napkin = v),
      ]);
    final bill = Column(children: [
      Text('税抜 $subtotal 円 / 消費税 $tax 円'),
      Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
    ]);
    final submit = Center(child: FilledButton(
      onPressed: syrups.length != int.parse(food.substring(0, 1))
          ? null
          : () => setState(() {
      order = Random().nextInt(999) + 1;
      receipt = '$food ${foods[food]}円\n'
        'シロップ: ${syrups.join('・')}\n'
        '🥄 スプーン: ${spoon ? 'あり' : 'なし'}\n'
        '🧻 紙ナプキン: ${napkin ? 'あり' : 'なし'}\n'
        '税抜: $subtotal 円 / 消費税（10%）: $tax 円\n'
        '合計: $total 円';
    }), child: const Text('注文する')));
    final ticket = order == 0 ? const SizedBox.shrink() : Card(child: Padding(
      padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('注文番号 #$order', style: const TextStyle(fontSize: 26)),
          Text(receipt),
        ],
      ),
    ));


    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('🍦 Icecream 屋台注文アプリ')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: photo),
        const SizedBox(height: 12),
        const Text('シロップの種類数・料金を選ぶ'), products,
        Text('シロップを選ぶ（${syrups.length}/${food.substring(0, 1)}種類）'),
        Wrap(
          spacing: 6,
          children: [
            for (final s in syrupColors.keys)
              FilterChip(
                label: Text(s),
                avatar: CircleAvatar(
                  radius: 7,
                  backgroundColor: syrupColors[s],
                ),
                selected: syrups.contains(s),
                onSelected: (v) => setState(() {
                  if (!v) {
                    syrups.remove(s);
                  } else {
                    final count = int.parse(food.substring(0, 1));
                    if (syrups.length >= count) syrups.removeLast();
                    syrups.add(s);
                  }
                }),
              ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: diagnoseColor,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('今のあなたは何色？ かき氷カラー診断'),
        ),
        const SizedBox(height: 12),
        const Text('無料サービス'), supplies,
        const Divider(),
        bill,
        submit, ticket,
      ]))),
    );
  }
}