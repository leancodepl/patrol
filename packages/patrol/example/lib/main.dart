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
  List<Widget> items = [
    ListTile(
      onTap: () => () {},
      key: const Key('tile1'),
      title: const Text('Add'),
      trailing: IconButton(
        icon: const Icon(Icons.add, key: Key('icon1')),
        onPressed: () {},
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), addItemToList);
  }

  void addItemToList() {
    setState(() {
      items.add(
        ListTile(
          onTap: () => () {},
          key: const Key('tile2'),
          title: const Text('Add'),
          trailing: IconButton(
            icon: const Icon(Icons.add, key: Key('icon2')),
            onPressed: () {},
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('scaffold'),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }
}
