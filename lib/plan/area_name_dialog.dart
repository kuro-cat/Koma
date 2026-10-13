import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/input_dialog.dart';
import '../widgets/keyboard_dismiss_on_tap.dart';

/// Asks for a new area's name, offering [suggestions] (such as the spots'
/// cities) to pick from. Returns the trimmed name, or null when cancelled.
Future<String?> showAreaNameDialog(
  BuildContext context, {
  Future<List<String>>? suggestions,
  Key? fieldKey,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        _AreaNameDialog(suggestions: suggestions, fieldKey: fieldKey),
  );
}

class _AreaNameDialog extends StatefulWidget {
  const _AreaNameDialog({this.suggestions, this.fieldKey});

  final Future<List<String>>? suggestions;
  final Key? fieldKey;

  @override
  State<_AreaNameDialog> createState() => _AreaNameDialogState();
}

class _AreaNameDialogState extends State<_AreaNameDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = l10n.nearestGroupAssignAreaNameEmpty);
      return;
    }
    Navigator.of(context).pop(name);
  }

  void _pick(String name) {
    setState(() {
      _controller.text = name;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: l10n.planNewArea,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDialogField(
            label: l10n.planAreaName,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              key: widget.fieldKey,
              controller: _controller,
              autofocus: true,
              decoration: appDialogInputDecoration(errorText: _errorText),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _errorText = null),
              onSubmitted: (_) => _submit(),
            ),
          ),
          FutureBuilder<List<String>>(
            future: widget.suggestions,
            builder: (context, snapshot) {
              final names = snapshot.data ?? const <String>[];
              if (names.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  key: const ValueKey('area-name-suggestions'),
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in names)
                      ChoiceChip(
                        label: Text(name),
                        selected: _controller.text.trim() == name,
                        onSelected: (_) => _pick(name),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      confirmLabel: l10n.planCreate,
      onConfirm: _submit,
    );
  }
}
