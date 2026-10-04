import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../widgets/input_dialog.dart';
import 'coordinate_parser.dart';
import '../l10n/l10n.dart';

Future<LatLng?> showCoordinateInputDialog({
  required BuildContext context,
  required LatLng current,
}) {
  return showDialog<LatLng>(
    context: context,
    builder: (_) => _CoordinateInputDialog(current: current),
  );
}

class _CoordinateInputDialog extends StatefulWidget {
  const _CoordinateInputDialog({required this.current});

  final LatLng current;

  @override
  State<_CoordinateInputDialog> createState() => _CoordinateInputDialogState();
}

class _CoordinateInputDialogState extends State<_CoordinateInputDialog> {
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(
      text: widget.current.latitude.toStringAsFixed(6),
    );
    _longitudeController = TextEditingController(
      text: widget.current.longitude.toStringAsFixed(6),
    );
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _pasteFromClipboard() async {
    LatLng? coordinate;
    try {
      coordinate = await parseClipboardCoordinate();
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _errorText = l10n.coordinateInputClipboardReadFailed);
      return;
    }
    if (!mounted) {
      return;
    }
    if (coordinate == null) {
      setState(() => _errorText = l10n.coordinateInputClipboardNoCoordinate);
      return;
    }
    final parsed = coordinate;
    setState(() {
      _errorText = null;
      _latitudeController.text = parsed.latitude.toStringAsFixed(6);
      _longitudeController.text = parsed.longitude.toStringAsFixed(6);
    });
  }

  void _submit() {
    final latitude = parseCoordinateComponent(
      _latitudeController.text,
      latitude: true,
    );
    final longitude = parseCoordinateComponent(
      _longitudeController.text,
      latitude: false,
    );
    if (latitude == null || longitude == null) {
      setState(() => _errorText = l10n.coordinateInputInvalid);
      return;
    }
    Navigator.of(context).pop(LatLng(latitude, longitude));
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: l10n.coordinateInputTitle,
      errorText: _errorText,
      titleTrailing: AppDialogPasteButton(onPressed: _pasteFromClipboard),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogField(
            label: l10n.coordinateInputLatitude,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _latitudeController,
              onChanged: (_) => _clearError(),
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: appDialogInputDecoration(),
            ),
          ),
          const SizedBox(height: 14),
          AppDialogField(
            label: l10n.coordinateInputLongitude,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _longitudeController,
              onChanged: (_) => _clearError(),
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: appDialogInputDecoration(),
            ),
          ),
        ],
      ),
      confirmLabel: l10n.coordinateInputConfirm,
      onConfirm: _submit,
    );
  }
}
