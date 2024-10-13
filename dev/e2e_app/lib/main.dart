import 'package:app_links/app_links.dart';
import 'package:e2e_app/applink_screen.dart';
import 'package:e2e_app/loading_screen.dart';
import 'package:e2e_app/location_screen.dart';
import 'package:e2e_app/notifications_screen.dart';
import 'package:e2e_app/overlay_screen.dart';
import 'package:e2e_app/permissions_screen.dart';
import 'package:e2e_app/scrolling_screen.dart';
import 'package:e2e_app/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpTimezone();

  runApp(const ExampleApp());
}

Future<void> setUpTimezone() async {
  tz_data.initializeTimeZones();
  final timezone = await FlutterTimezone.getLocalTimezone();
  final location = tz.getLocation(timezone);
  tz.setLocalLocation(location);
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
  final _appLinks = AppLinks();
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
    _appLinks.uriLinkStream.listen((uri) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ApplinkScreen(
            uri: uri,
          ),
        ),
      );
    });

    return Scaffold(
      key: const Key('scaffold'),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        key: const Key('listViewKey'),
        children: [
          const Text('FIRST_KEY: ${const String.fromEnvironment('FIRST_KEY')}'),
          const Text(
            'SECOND_KEY: ${const String.fromEnvironment('SECOND_KEY')}',
          ),
          const Text('THIRD_KEY: ${const String.fromEnvironment('THIRD_KEY')}'),
          const Text('FIFTH_KEY: ${const String.fromEnvironment('FIFTH_KEY')}'),
          const Text(
            'BOOL_DEFINED: ${const String.fromEnvironment('BOOL_DEFINED')}',
          ),
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            semanticsLabel: 'Counter: $_counter',
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
            color: Theme.of(context).colorScheme.surface,
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
                    icon: const Icon(
                      Icons.add,
                      key: Key('icon1'),
                      semanticLabel: 'Increment counter',
                    ),
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
            color: Theme.of(context).colorScheme.surface,
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
                builder: (_) => const ScrollingScreen(),
              ),
            ),
            child: const Text('Open scrolling screen'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WebViewScreen(
                  title: 'WebView (LeanCode)',
                  url: 'https://leancode.co',
                ),
              ),
            ),
            child: const Text('Open webview (LeanCode)'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WebViewScreen(
                  title: 'WebView (Hacker News)',
                  url: 'https://news.ycombinator.com',
                ),
              ),
            ),
            child: const Text('Open webview (Hacker News)'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WebViewScreen(
                  title: 'WebView (StackOverflow)',
                  url: 'https://stackoverflow.com',
                ),
              ),
            ),
            child: const Text('Open webview (StackOverflow)'),
          ),
          TextButton(
            onPressed: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PermissionsScreen(),
              ),
            ),
            child: const Text('Open permissions screen'),
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
