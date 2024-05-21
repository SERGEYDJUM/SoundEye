// import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SoundEye extends StatefulWidget {
  const SoundEye({super.key, required this.title});

  final String title;

  @override
  State<SoundEye> createState() => _SoundEyeState();
}

class _SoundEyeState extends State<SoundEye> {
  int _counter = 0;

  // static const platform = MethodChannel('samples.flutter.dev/audioprocessing');

  // Future<void> _getSquare() async {
  //   int counter = _counter;

  //   try {
  //     final result = await platform.invokeMethod<int>('square', {'number': counter});
  //     counter = result as int;
  //   } on PlatformException {
  //     counter = 0;
  //   }

  //   setState(() {
  //     _counter = counter;
  //   });
  // }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}