import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key, this.from = 10});

  final int from;

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionA = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('A: StreamBuilder')),
              ButtonSegment(value: false, label: Text('B: listen')),
            ],
            selected: {_versionA},
            onSelectionChanged: (s) => setState(() => _versionA = s.first),
          ),
          Expanded(
            child: _versionA
                ? CountdownA(from: widget.from)
                : CountdownB(from: widget.from),
          ),
        ],
      ),
    );
  }
}

/// Version A: StreamBuilder cancels the subscription for you.
class CountdownA extends StatefulWidget {
  const CountdownA({super.key, required this.from});

  final int from;

  @override
  State<CountdownA> createState() => _CountdownAState();
}

class _CountdownAState extends State<CountdownA> {
  late final Stream<int> _stream = countdown(widget.from);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<int>(
        stream: _stream,
        builder: (context, snapshot) {
          return Text(
            '${snapshot.data ?? widget.from}',
            style: Theme.of(context).textTheme.displayLarge,
          );
        },
      ),
    );
  }
}

/// Version B: manual listen, so we must cancel in dispose.
class CountdownB extends StatefulWidget {
  const CountdownB({super.key, required this.from});

  final int from;

  @override
  State<CountdownB> createState() => _CountdownBState();
}

class _CountdownBState extends State<CountdownB> {
  late int _left = widget.from;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(widget.from).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
