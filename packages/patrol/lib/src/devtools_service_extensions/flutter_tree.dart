import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Collects the widgets an agent can act on or assert against: interactive
/// widgets, widgets with a key and visible text.
///
/// Each element carries what a Patrol finder can target (`key`, `text`,
/// `type`) and the state an assertion needs (`value`, `enabled`). Interactive
/// widgets absorb the text of their descendants (`ElevatedButton` with a
/// `Text('Save')` child is one element with `text: 'Save'`), so the listing
/// stays short. Elements that a tap at their center would not reach (hidden
/// behind a route, offstage, covered) are left out.
class FlutterTree {
  /// Creates a collector.
  const FlutterTree();

  /// The elements of the current widget tree, in paint order.
  List<Map<String, Object>> collect() {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) {
      return const [];
    }
    final out = <Map<String, Object>>[];
    _visit(root, out);
    return out;
  }

  void _visit(Element element, List<Map<String, Object>> out) {
    final widget = element.widget;
    if (widget is Offstage && widget.offstage) {
      return;
    }
    if (widget is Visibility && !widget.visible) {
      return;
    }

    final interactive = isInteractive(widget);
    final key = _keyValue(widget.key);
    final ownText = _ownText(widget);
    if (interactive || key != null || ownText != null) {
      final data = _describe(element, interactive: interactive, key: key);
      if (data != null) {
        out.add(data);
        if (interactive || ownText != null) {
          // Its texts are already in `text`; its inner widgets (the
          // EditableText of a TextField, the Text of a button, the RichText
          // a Text builds) are parts of this one element.
          return;
        }
      }
    }
    element.visitChildren((child) => _visit(child, out));
  }

  Map<String, Object>? _describe(
    Element element, {
    required bool interactive,
    required String? key,
  }) {
    final box = _renderBox(element);
    if (box == null || !_isHittable(box)) {
      return null;
    }
    final widget = element.widget;
    final data = <String, Object>{'type': widget.runtimeType.toString()};
    if (key != null) {
      data['key'] = key;
    }

    final label = _fieldLabel(element);
    if (label != null) {
      data['label'] = label;
    }
    final text = interactive ? _innerText(element) : _ownText(widget);
    if (text != null && text.isNotEmpty) {
      data['text'] = text;
    }
    final value = _value(element);
    if (value != null) {
      data['value'] = value;
    }
    if (interactive && !_isEnabled(widget)) {
      data['enabled'] = false;
    }

    final offset = box.localToGlobal(Offset.zero);
    data['bounds'] = {
      'x': offset.dx.round(),
      'y': offset.dy.round(),
      'width': box.size.width.round(),
      'height': box.size.height.round(),
    };
    return data;
  }

  /// Widgets a user taps, types into or toggles.
  static bool isInteractive(Widget widget) =>
      widget is ButtonStyleButton ||
      widget is IconButton ||
      widget is FloatingActionButton ||
      widget is InkWell ||
      widget is ListTile ||
      widget is TextField ||
      widget is TextFormField ||
      widget is Checkbox ||
      widget is CheckboxListTile ||
      widget is Switch ||
      widget is SwitchListTile ||
      widget is Radio ||
      widget is RadioListTile ||
      widget is Slider ||
      widget is DropdownButton ||
      widget is PopupMenuButton ||
      widget is Chip ||
      widget is BackButton ||
      widget is CloseButton ||
      (widget is GestureDetector &&
          (widget.onTap != null || widget.onLongPress != null));

  static String? _keyValue(Key? key) {
    if (key is ValueKey) {
      final value = key.value;
      // Enum keys are framework slots (`_ScaffoldSlot.body`), not app keys.
      if (value is String || value is num) {
        return '$value';
      }
    }
    return null;
  }

  static String? _ownText(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText();
    }
    if (widget is RichText) {
      return widget.text.toPlainText();
    }
    return null;
  }

  /// The texts below an interactive widget, joined; a text field's typed
  /// value goes to `value` instead.
  static String? _innerText(Element element) {
    final widget = element.widget;
    if (widget is TextField || widget is TextFormField) {
      return null;
    }
    final texts = <String>[];
    void visit(Element child) {
      final text = _ownText(child.widget);
      if (text != null && text.trim().isNotEmpty) {
        texts.add(text.trim());
        return;
      }
      child.visitChildren(visit);
    }

    element.visitChildren(visit);
    return texts.isEmpty ? null : texts.join(' ');
  }

  /// The state an assertion checks: the typed text of a field, whether a
  /// checkbox or switch is on, a slider's value.
  static String? _value(Element element) {
    final widget = element.widget;
    if (widget is TextField || widget is TextFormField) {
      // The value lives on the inner EditableText's controller, also when the
      // app passes no controller of its own.
      String? found;
      void visit(Element child) {
        if (found != null) {
          return;
        }
        final inner = child.widget;
        if (inner is EditableText) {
          found = inner.obscureText
              ? '•' * inner.controller.text.length
              : inner.controller.text;
          return;
        }
        child.visitChildren(visit);
      }

      element.visitChildren(visit);
      return found;
    }
    return switch (widget) {
      Checkbox(:final value) => '$value',
      CheckboxListTile(:final value) => '$value',
      Switch(:final value) => '$value',
      SwitchListTile(:final value) => '$value',
      Slider(:final value) => '$value',
      _ => null,
    };
  }

  /// The label or hint of a text field; a TextFormField's is read off the
  /// TextField it builds.
  static String? _fieldLabel(Element element) {
    final widget = element.widget;
    TextField? field = widget is TextField ? widget : null;
    if (field == null && widget is TextFormField) {
      void visit(Element child) {
        if (field != null) {
          return;
        }
        final inner = child.widget;
        if (inner is TextField) {
          field = inner;
          return;
        }
        child.visitChildren(visit);
      }

      element.visitChildren(visit);
    }
    final label = field?.decoration?.labelText ?? field?.decoration?.hintText;
    return label == null || label.isEmpty ? null : label;
  }

  static bool _isEnabled(Widget widget) => switch (widget) {
    ButtonStyleButton() => widget.enabled,
    IconButton(:final onPressed) => onPressed != null,
    FloatingActionButton(:final onPressed) => onPressed != null,
    InkWell(:final onTap, :final onLongPress) =>
      onTap != null || onLongPress != null,
    ListTile(:final enabled) => enabled,
    TextField(:final enabled) => enabled ?? true,
    // `bool?` on older Flutter versions, `bool` on newer ones.
    TextFormField(:final bool? enabled) => enabled ?? true,
    Checkbox(:final onChanged) => onChanged != null,
    CheckboxListTile(:final onChanged) => onChanged != null,
    Switch(:final onChanged) => onChanged != null,
    SwitchListTile(:final onChanged) => onChanged != null,
    Slider(:final onChanged) => onChanged != null,
    _ => true,
  };

  static RenderBox? _renderBox(Element element) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return null;
    }
    return renderObject;
  }

  /// Whether a tap at the center of [box] reaches it, the same check as
  /// Patrol's `visible` and `hitTestable()`.
  static bool _isHittable(RenderBox box) {
    final view = WidgetsBinding.instance.renderViews.firstOrNull;
    if (view == null) {
      return false;
    }
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(
      result,
      center,
      view.flutterView.viewId,
    );
    return result.path.any((entry) => entry.target == box);
  }
}
