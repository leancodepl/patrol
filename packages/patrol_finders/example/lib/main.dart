import 'package:flutter/material.dart';
import 'package:patrol_finders_example/loading_screen.dart';
import 'package:patrol_finders_example/overlay_screen.dart';
import 'package:patrol_finders_example/scrolling_screen.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const ExampleHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key, required this.title});

  final String title;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  var _counter = 0;

  void _incrementCounter([int value = 1]) {
    final newValue = _counter + value;
    setState(() {
      _counter = newValue;
    });
  }

  void _decrementCounter([int value = 1]) {
    final newValue = _counter - value;
    setState(() {
      _counter = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('scaffold'),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        key: const Key('listViewKey'),
        children: [
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            key: const Key('counterText'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const TextField(
            key: Key('textField'),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'You have entered this text',
            ),
          ),
          SizedBox(height: 8),
          Container(
            key: const Key('box1'),
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('box 1'),
                ListTile(
                  onTap: () => _incrementCounter(10),
                  key: const Key('tile1'),
                  title: const Text('Add'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, key: Key('icon1')),
                    onPressed: _incrementCounter,
                  ),
                ),
                ListTile(
                  onTap: () => _decrementCounter(10),
                  key: const Key('tile2'),
                  title: const Text('Subtract'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove, key: Key('icon2')),
                    onPressed: _decrementCounter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            key: const Key('box2'),
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('box 2'),
                ListTile(
                  onTap: () => _incrementCounter(10),
                  key: const Key('tile1'),
                  title: const Text('Add'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, key: Key('icon1')),
                    onPressed: _incrementCounter,
                  ),
                ),
                ListTile(
                  onTap: () => _decrementCounter(10),
                  key: const Key('tile2'),
                  title: const Text('Subtract'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove, key: Key('icon2')),
                    onPressed: _decrementCounter,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LoadingScreen(),
              ),
            ),
            child: const Text('Open loading screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OverlayScreen(),
              ),
            ),
            child: const Text('Open overlay screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScrollingScreen(),
              ),
            ),
            child: const Text('Open scrolling screen'),
          ),
          Text('EXAMPLE_KEY: ${const String.fromEnvironment('EXAMPLE_KEY')}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
