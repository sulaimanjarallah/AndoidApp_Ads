import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../ads/banner_slot.dart';
import '../game/progress.dart';
import '../game/puzzle.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _p = Progress.instance;
  late int _level = widget.level;
  late Puzzle _puzzle;
  final List<Puzzle> _history = [];
  int? _selected;
  int _undos = Progress.freeUndos;
  bool _extraTubeUsed = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _puzzle = generateLevel(_level);
    _history.clear();
    _selected = null;
    _undos = Progress.freeUndos;
    _extraTubeUsed = false;
    _moves = 0;
  }

  void _tap(int i) {
    if (_puzzle.solved) return;
    setState(() {
      if (_selected == null) {
        if (_puzzle.tubes[i].isNotEmpty) _selected = i;
        return;
      }
      final from = _selected!;
      _selected = null;
      if (from == i || !_puzzle.canPour(from, i)) {
        if (from != i && _puzzle.tubes[i].isNotEmpty) _selected = i;
        return;
      }
      _history.add(_puzzle.copy());
      _puzzle.pour(from, i);
      _moves++;
    });
    if (_puzzle.solved) _win();
  }

  Future<void> _undo() async {
    if (_history.isEmpty) return;
    if (_undos == 0) {
      if (!await payOrWatch(context, Progress.undoPackCost, '٥ تراجعات إضافية')) {
        return;
      }
      _undos = Progress.freeUndos;
    }
    setState(() {
      _puzzle = _history.removeLast();
      _selected = null;
      _undos--;
    });
  }

  Future<void> _addTube() async {
    if (!await payOrWatch(context, Progress.extraTubeCost, 'أنبوب إضافي')) {
      return;
    }
    setState(() {
      _puzzle.tubes.add(<int>[]);
      _extraTubeUsed = true;
    });
  }

  void _restart() => setState(_load);

  Future<void> _win() async {
    _p.completeLevel(_level);
    _p.addCoins(Progress.levelReward);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final next = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('أحسنت! 🎉', textAlign: TextAlign.center),
        content: Text(
            'خلصت المرحلة $_level في $_moves حركة\n+${Progress.levelReward} 🪙',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('الرئيسية')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('المرحلة التالية')),
        ],
      ),
    );
    if (!mounted) return;
    AdManager.instance.onRoundFinished(() {
      if (!mounted) return;
      if (next == true) {
        setState(() {
          _level++;
          _load();
        });
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _tube(int i, double width) {
    final tube = _puzzle.tubes[i];
    final selected = _selected == i;
    final unit = width * 1.05;
    final done = tube.length == capacity && tube.every((c) => c == tube.first);
    return GestureDetector(
      onTap: () => _tap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(
            bottom: selected ? 24 : 0, top: selected ? 0 : 24, left: 6, right: 6),
        width: width,
        height: unit * capacity + 10,
        padding: const EdgeInsets.fromLTRB(3, 3, 3, 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: done
                  ? Colors.greenAccent
                  : selected
                      ? Colors.white
                      : Colors.white54,
              width: 2),
          borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(width / 2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var k = tube.length - 1; k >= 0; k--)
              Container(
                height: unit - 2,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: palette[tube[k]],
                  borderRadius: k == 0
                      ? BorderRadius.vertical(
                          bottom: Radius.circular(width / 2))
                      : BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _puzzle.tubes.length;
    final perRow = count <= 7 ? count : (count / 2).ceil();
    final screen = MediaQuery.sizeOf(context).width;
    final width = ((screen - 32) / perRow - 12).clamp(26.0, 52.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('المرحلة $_level'),
        actions: [
          IconButton(
              onPressed: _restart,
              tooltip: 'إعادة',
              icon: const Icon(Icons.refresh)),
          const CoinBadge(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 24,
                  children: [for (var i = 0; i < count; i++) _tube(i, width)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _history.isEmpty ? null : _undo,
                      icon: const Icon(Icons.undo),
                      label: Text(_undos > 0
                          ? 'تراجع ($_undos)'
                          : 'تراجع ${Progress.undoPackCost}🪙'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _extraTubeUsed ? null : _addTube,
                      icon: const Icon(Icons.add),
                      label: Text('أنبوب ${Progress.extraTubeCost}🪙'),
                    ),
                  ),
                ],
              ),
            ),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
