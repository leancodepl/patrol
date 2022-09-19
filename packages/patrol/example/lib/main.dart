import 'package:example/loading_screen.dart';
import 'package:example/location_screen.dart';
import 'package:example/notifications_screen.dart';
import 'package:example/overlay_screen.dart';
import 'package:example/permissions_screen.dart';
import 'package:example/scrolling_screen.dart';
import 'package:example/webview_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        key: const Key('listViewKey'),
        children: [
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            key: const Key('counterText'),
            style: Theme.of(context).textTheme.headline4,
          ),
          Container(
            key: const Key('box1'),
            color: Colors.grey,
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
            color: Colors.grey,
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
                builder: (_) => const LocationScreen(),
              ),
            ),
            child: const Text('Open location screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
            child: const Text('Open notifications screen'),
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
                builder: (_) => const PermissionsScreen(),
              ),
            ),
            child: const Text('Open permissions screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScrollingScreen(),
              ),
            ),
            child: const Text('Open scrolling screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WebViewScreen(),
              ),
            ),
            child: const Text('Open webview screen'),
          ),
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
