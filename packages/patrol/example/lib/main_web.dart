import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:example/pages/quiz/question_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/text_field.dart';
import 'package:example/ui/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebAutomatorShowcaseApp());
}

class WebAutomatorShowcaseApp extends StatelessWidget {
  const WebAutomatorShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebAutomator Showcase',
      debugShowCheckedModeBanner: false,
      theme: _buildUglyLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const WebShowcaseHomePage(),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      appBarTheme: const AppBarTheme(backgroundColor: PTColors.lcYellow),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
      primaryColor: PTColors.lcBlack,
      canvasColor: PTColors.textDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: PTColors.lcYellow.withValues(alpha: 0.5),
        cursorColor: PTColors.textWhite,
        selectionHandleColor: PTColors.lcYellow,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: PTColors.lcYellow),
        ),
      ),
    );
  }

  /// Ugly light theme
  ThemeData _buildUglyLightTheme() {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFF69B4), // Hot pink
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF32CD32), // Lime green
        foregroundColor: Color(0xFFFFFF00), // Yellow
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00FFFF), // Cyan
        secondary: Color(0xFFFF00FF), // Magenta
      ),
    );
  }
}

class WebShowcaseHomePage extends StatelessWidget {
  const WebShowcaseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'WEB TESTING TOOL CHALLENGE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: PTColors.lcYellow,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                "Complete all the challenges to prove you're a great testing tool.",
                style: TextStyle(fontSize: 16, color: PTColors.textWhite),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PTElevatedButton(
                caption: 'Start the test',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Test1Screen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Test1Screen extends StatelessWidget {
  const Test1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 1')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: switch (Theme.of(context).brightness) {
            Brightness.light => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Change the theme to dark',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Before we start, please change the theme to dark.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
            ),
            Brightness.dark => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "That's better!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'We can now continue without being distracted by the ugly theme.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                PTElevatedButton(
                  caption: 'Continue to next test',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Test2Screen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}

/// Intent to reveal the hidden button
class RevealButtonIntent extends Intent {
  const RevealButtonIntent();
}

class Test2Screen extends StatefulWidget {
  const Test2Screen({super.key});

  @override
  State<Test2Screen> createState() => _Test2ScreenState();
}

class _Test2ScreenState extends State<Test2Screen> {
  var _buttonVisible = false;

  void _revealButton() {
    if (!_buttonVisible) {
      setState(() {
        _buttonVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyL,
          LogicalKeyboardKey.keyC,
        ): const RevealButtonIntent(),
      },
      child: Actions(
        actions: {
          RevealButtonIntent: CallbackAction<RevealButtonIntent>(
            onInvoke: (_) => _revealButton(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(title: const Text('Test 2')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Secret Key Combination',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Press Ctrl + L + C to reveal the hidden button.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    if (_buttonVisible)
                      PTElevatedButton(
                        caption: 'Continue to next test',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const Test3Screen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Test3Screen extends StatelessWidget {
  const Test3Screen({super.key});

  static const double compactBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 3')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < compactBreakpoint;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Responsive Layout',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isCompact) ...[
                    const Text(
                      'You are in compact view.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    PTElevatedButton(
                      caption: 'Continue to next test',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Test4Screen(),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    const Text(
                      'You are in expanded view.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The button to continue is only revealed in compact view. '
                      'Please resize the window to make it narrower.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Test4Screen extends StatefulWidget {
  const Test4Screen({super.key});

  @override
  State<Test4Screen> createState() => _Test4ScreenState();
}

class _Test4ScreenState extends State<Test4Screen> {
  late final String _secretCode;
  final _controller = TextEditingController();
  var _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _secretCode = _generateUuid();
    _setCookie('secret_code', _secretCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generateUuid() => const Uuid().v4();

  void _setCookie(String name, String value) {
    web.document.cookie = '$name=$value; path=/';
  }

  void _onTextChanged(String value) {
    setState(() {
      _isCorrect = value == _secretCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 4')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cookie Challenge',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'A secret code has been stored in a cookie. '
                'Find it and enter it below to continue.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hint: Check the cookie named "secret_code"',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 400,
                child: PTTextField(
                  controller: _controller,
                  label: 'Enter the secret code',
                  onChanged: _onTextChanged,
                ),
              ),
              const SizedBox(height: 48),
              if (_isCorrect)
                PTElevatedButton(
                  caption: 'Continue to next test',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Test5Screen(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Test5Screen extends StatefulWidget {
  const Test5Screen({super.key});

  @override
  State<Test5Screen> createState() => _Test5ScreenState();
}

class _Test5ScreenState extends State<Test5Screen> {
  static const _viewType = 'iframe-challenge';
  static var _registered = false;
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
    _listenForMessages();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _registerViewFactory() {
    if (_registered) {
      return;
    }
    _registered = true;

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement
            ..src = 'iframe_challenge.html'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
      return iframe;
    });
  }

  void _listenForMessages() {
    _messageSubscription = web.window.onMessage.listen((event) {
      final data = event.data;
      if (data == null) {
        return;
      }

      // Handle the message from iframe
      try {
        final jsData = data as JSObject;
        final type = jsData.getProperty<JSString?>('type'.toJS)?.toDart;

        if (type == 'PASSWORD_CORRECT') {
          _navigateToNextScreen();
        }
      } catch (_) {
        // Ignore malformed messages
      }
    });
  }

  void _navigateToNextScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const Test6Screen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 5')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'IFrame Challenge',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Interact with the iframe below. Scroll down inside it, '
                  'find the password field, and enter the correct password.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: const HtmlElementView(viewType: _viewType),
            ),
          ),
        ],
      ),
    );
  }
}

class Test6Screen extends StatefulWidget {
  const Test6Screen({super.key});

  @override
  State<Test6Screen> createState() => _Test6ScreenState();
}

class _Test6ScreenState extends State<Test6Screen> {
  static const _secretPassword = 'ClipboardSecret2024!';
  final _controller = TextEditingController();
  var _isCorrect = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyPasswordToClipboard() async {
    await Clipboard.setData(const ClipboardData(text: _secretPassword));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTextChanged(String value) {
    final correct = value == _secretPassword;
    if (correct != _isCorrect) {
      setState(() {
        _isCorrect = correct;
      });
    }

    if (_isCorrect) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const Test7Screen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 6')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Clipboard Challenge',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Click the button below to copy a secret password to your clipboard. '
                'Then paste it into the text field to continue.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PTElevatedButton(
                caption: 'Copy password to clipboard',
                onPressed: _copyPasswordToClipboard,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 400,
                child: PTTextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  label: 'Paste the password here',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Test7Screen extends StatelessWidget {
  const Test7Screen({super.key});

  void _showDialogAndNavigate(BuildContext context) {
    final confirmed = web.window.confirm('Press accept to go to the next page');
    if (confirmed) {
      if (context.mounted) {
        Navigator.of(context).push(webQuestionRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 7')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Dialog Challenge',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Click the button below to show a browser dialog. '
                'Accept the dialog to continue to the next test.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PTElevatedButton(
                caption: 'Show dialog',
                onPressed: () => _showDialogAndNavigate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Test8Screen extends StatelessWidget {
  const Test8Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test 8')),
      body: const Center(child: Text('Test 8 - Coming soon')),
    );
  }
}
