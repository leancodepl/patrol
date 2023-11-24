import 'dart:math';

import 'package:example/pages/quiz/question_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/components/text_field.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:example/ui/widgets/top_bar.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Route<void> get formRoute =>
    MaterialPageRoute(builder: (_) => const _FormPage());

class _FormPage extends StatefulWidget {
  const _FormPage();

  static final _leanCodeColors = {
    PTColors.lcBlack,
    PTColors.lcYellow,
    PTColors.lcWhite,
  };
  static final _otherColors = {
    const Color(0xFF3AE35F),
    const Color(0xFF7521FF),
    const Color(0xFF215FFF),
    const Color(0xFFABFFB3),
    const Color(0xFF8DD6FF),
    const Color(0xFF739F51),
  };

  @override
  State<_FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<_FormPage> {
  var _submitted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: PTScaffold(
        bodyKey: ValueKey(_submitted),
        top: const TopBar(),
        body:
            _submitted ? const _CountdownTimer() : _Form(onSubmit: _showTimer),
      ),
    );
  }

  void _showTimer(bool valid) {
    if (valid) {
      setState(() => _submitted = true);
    }
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.onSubmit});

  final ValueChanged<bool> onSubmit;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _colorsToDisplay = [
    ..._FormPage._leanCodeColors,
    ..._FormPage._otherColors,
  ]..shuffle();
  final _textController = TextEditingController();
  final _selectedColors = <Color>{};
  var _showErrors = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Choose a nickname to sign up',
            style: PTTextStyles.h4,
          ),
          const SizedBox(height: 32),
          PTTextField(
            controller: _textController,
            label: 'Your nickname',
            errorText:
                _showErrors && !_nickValid ? 'Nick must not be empty' : null,
          ),
          const SizedBox(height: 32),
          _ColorPicker(
            selectedColors: _selectedColors,
            colorsToDisplay: _colorsToDisplay,
            onSelected: _onColorSelected,
            errorText:
                _showErrors && !_colorsValid ? 'Colors must be picked' : null,
          ),
          const SizedBox(height: 24),
          PTElevatedButton(
            caption: 'Ready!',
            onPressed: _onSubmit,
          ),
        ],
      ).horizontallyPadded24,
    );
  }

  void _onColorSelected(Color color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
      } else if (_selectedColors.length < 3) {
        _selectedColors.add(color);
      }
    });
  }

  bool get _nickValid => _textController.text.isNotEmpty;

  bool get _colorsValid =>
      setEquals(_FormPage._leanCodeColors, _selectedColors);

  bool get _allValid => _nickValid && _colorsValid;

  void _onSubmit() {
    if (_allValid) {
      widget.onSubmit(true);
    } else if (!_showErrors) {
      setState(() {
        _showErrors = true;
      });
    }
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 128,
          height: 120,
          width: 262,
          child: Text(
            'The quiz will start in',
            style: PTTextStyles.h1,
            textAlign: TextAlign.center,
          ),
        ),
        const _AnimatedTimer(),
      ],
    );
  }
}

class _AnimatedTimer extends StatefulWidget {
  const _AnimatedTimer();

  @override
  State<_AnimatedTimer> createState() => _AnimatedTimerState();
}

class _AnimatedTimerState extends State<_AnimatedTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener(
            (status) {
              if (status == AnimationStatus.completed) {
                Navigator.of(context).push(questionRoute);
              }
            },
          );

    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: const Key('ticker'),
      animation: _animationController,
      builder: (context, child) {
        final valueToDisplay = 3 - _animationController.value * 3;

        return Stack(
          alignment: Alignment.center,
          children: [
            _CustomPaint(painter: _Painter(2 * pi, PTColors.lcYellow)),
            _CustomPaint(
              painter: _Painter(
                _animationController.value * 2 * pi,
                const Color(0xFFFDFED5),
              ),
            ),
            Text(
              valueToDisplay.ceil().toString(),
              style: PTTextStyles.h2.copyWith(color: PTColors.textDark),
            ),
          ],
        );
      },
    );
  }
}

class _CustomPaint extends StatelessWidget {
  const _CustomPaint({required this.painter});

  final _Painter painter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: painter,
      size: const Size(145, 145),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.angle, this.color);

  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: size.height,
        width: size.width,
      ),
      -pi / 2,
      angle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedColors,
    required this.colorsToDisplay,
    required this.onSelected,
    this.errorText,
  });

  final Set<Color> selectedColors;
  final List<Color> colorsToDisplay;
  final void Function(Color) onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To confirm you're not a robot, pick LeanCode's colors",
          style: PTTextStyles.h4,
        ),
        const SizedBox(height: 16),
        Text(
          '${selectedColors.length}/3 selected',
          style: PTTextStyles.label,
        ),
        const SizedBox(height: 8),
        Wrap(
          runSpacing: 8,
          spacing: 8,
          children: List.generate(
            9,
            (index) => Builder(
              builder: (context) {
                final color = colorsToDisplay[index];

                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    onSelected(color);
                  },
                  child: SelectableBox(
                    color: color,
                    selected: selectedColors.contains(color),
                  ),
                );
              },
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: PTTextStyles.label.copyWith(color: PTColors.error),
            ),
          ),
      ],
    );
  }
}

class SelectableBox extends StatelessWidget {
  const SelectableBox({
    super.key,
    required this.color,
    required this.selected,
  });

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 108,
          height: 96,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: PTColors.borderGrey),
          ),
        ),
        if (selected)
          Positioned(
            top: 9,
            right: 9,
            child: Icon(
              Icons.check_circle,
              size: 22,
              color: color == PTColors.lcBlack
                  ? PTColors.lcWhite
                  : PTColors.lcBlack,
            ),
          ),
      ],
    );
  }
}
