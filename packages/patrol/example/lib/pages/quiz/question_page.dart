import 'package:example/handlers/notification_handler.dart';
import 'package:example/pages/quiz/error_page.dart';
import 'package:example/pages/quiz/success_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/button/text_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:example/ui/widgets/top_bar.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Route<void> get questionRoute =>
    MaterialPageRoute(builder: (_) => _QuestionsPage());

class _QuestionsPage extends StatefulWidget {
  @override
  State<_QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<_QuestionsPage> {
  var _taskIndex = 0;
  late final List<Widget> _answers;
  final List<String> _tasks = [
    "Click on elevated button with centered 'Fluttercon' text",
    'Click on an elevated button, which is placed in a list tile with a dash icon',
    'Click on the third button that is enabled',
  ];

  @override
  void initState() {
    super.initState();

    _answers = [
      _Answers(answers: firstTaskAnswers),
      _Answers(answers: secondTaskAnswers),
      _Answers(answers: thirdTaskTaskAnswers),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      bodyKey: ValueKey(_taskIndex),
      top: const TopBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Question ${_taskIndex + 1}/3',
            style: PTTextStyles.h3,
          ).horizontallyPadded24,
          const SizedBox(height: 32),
          Text(_tasks[_taskIndex]).horizontallyPadded24,
          const SizedBox(height: 32),
          Flexible(child: _answers[_taskIndex]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showError() => Navigator.of(context).push(errorRoute);

  void _showNextQuestion() => setState(() => _taskIndex++);

  Future<void> _showNotification() async {
    final notificationHandler = context.read<NotificationHandler>();
    await notificationHandler.triggerLocalNotification(
      onPressed: () => Navigator.of(context).push(successRoute),
      onError: _showError,
    );
  }

  List<Widget> get firstTaskAnswers {
    return [
      PTTextButton(
        onPressed: _showError,
        text: 'Fluttercon',
      ),
      PTElevatedButton(
        onPressed: _showError,
        caption: '',
        trailing: const Text('Fluttercon'),
      ),
      PTElevatedButton(
        onPressed: _showNextQuestion,
        caption: 'Fluttercon',
      ),
    ]..shuffle();
  }

  List<Widget> get secondTaskAnswers {
    return [
      _Tile(
        leading: _EnabledButton(onPressed: _showNextQuestion),
        trailing: const _Dash(color: PTColors.lcWhite),
      ),
      _Tile(leading: _EnabledButton(onPressed: _showError)),
      Center(
        child: SizedBox(
          width: 128,
          child: _EnabledButton(
            onPressed: _showError,
            showTrailing: true,
          ),
        ),
      ),
    ]..shuffle();
  }

  List<Widget> get thirdTaskTaskAnswers {
    final firstPart = List.generate(
      10,
      (index) => index % 6 == 0
          ? _EnabledButton(onPressed: _showError)
          : const _DisabledButton(),
    )..shuffle();
    final secondPart = List.generate(
      5,
      (index) => index == 0
          ? _EnabledButton(onPressed: _showNotification)
          : const _DisabledButton(),
    )..shuffle();
    final thirdPart = List.generate(
      5,
      (index) => index == 0
          ? _EnabledButton(onPressed: _showError)
          : const _DisabledButton(),
    )..shuffle();

    return [...firstPart, ...secondPart, ...thirdPart];
  }
}

class _Answers extends StatelessWidget {
  const _Answers({
    required this.answers,
  });

  final List<Widget> answers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 16),
        child: Column(
          children: List.generate(
            answers.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _Answer(
                letter: _getAlphabetLetter(index),
                answer: answers[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAlphabetLetter(int index) => String.fromCharCode(index + 65);
}

class _Answer extends StatelessWidget {
  const _Answer({
    required this.letter,
    required this.answer,
  });

  final String letter;
  final Widget answer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 19,
          child: Text(
            letter,
            style: PTTextStyles.bodyBold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: answer),
      ],
    );
  }
}

class _EnabledButton extends StatelessWidget {
  const _EnabledButton({
    required this.onPressed,
    this.showTrailing = false,
  });

  final VoidCallback onPressed;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return PTElevatedButton(
      caption: 'click',
      trailing: showTrailing ? const _Dash(color: PTColors.lcBlack) : null,
      onPressed: onPressed,
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton();

  @override
  Widget build(BuildContext context) {
    return const PTElevatedButton(
      caption: 'click',
      onPressed: null,
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.flutter_dash,
      color: color,
      size: 24,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.leading,
    this.trailing,
  });

  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: PTColors.borderGrey),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: PTColors.backgroundGrey,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        leading: SizedBox(
          width: 128,
          child: leading,
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: trailing,
        ),
        tileColor: PTColors.backgroundGrey,
      ),
    );
  }
}
