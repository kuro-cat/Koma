import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'input_dialog.dart';

/// Asks for a short free-text note. Returns the trimmed text (empty clears
/// the note), or null when cancelled.
Future<String?> showNoteDialog(
  BuildContext context, {
  required String title,
  String? initial,
  String? hint,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NoteDialog(title: title, initial: initial, hint: hint),
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.title, this.initial, this.hint});

  final String title;
  final String? initial;
  final String? hint;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: widget.title,
      confirmLabel: l10n.commonSave,
      onConfirm: () => Navigator.of(context).pop(_controller.text.trim()),
      content: TextField(
        key: const ValueKey('note-dialog-field'),
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        decoration: appDialogInputDecoration(hintText: widget.hint),
      ),
    );
  }
}
