import 'package:flutter/material.dart';
import '../widgets/app_motion.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/app_back_button.dart';
import 'pilgrimage_plan_controller.dart';
import 'plan_memo_markdown.dart';

class PlanMemoScreen extends StatefulWidget {
  const PlanMemoScreen({required this.controller, super.key});

  final PilgrimagePlanController controller;

  @override
  State<PlanMemoScreen> createState() => _PlanMemoScreenState();
}

class _PlanMemoScreenState extends State<PlanMemoScreen> {
  late final TextEditingController _memoController;
  var _isEditing = false;
  var _isSaving = false;
  var _isTogglingTask = false;
  var _isUpdatingMemoText = false;

  String get _savedMemo => widget.controller.plan.memo;

  bool get _hasUnsavedChanges => _memoController.text != _savedMemo;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: _savedMemo);
    _memoController.addListener(_handleMemoTextChanged);
    widget.controller.addListener(_handlePlanUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handlePlanUpdated);
    _memoController.removeListener(_handleMemoTextChanged);
    _memoController.dispose();
    super.dispose();
  }

  void _handleMemoTextChanged() {
    if (_isEditing && mounted && !_isUpdatingMemoText) {
      setState(() {});
    }
  }

  void _setMemoText(String text) {
    _isUpdatingMemoText = true;
    _memoController.text = text;
    _isUpdatingMemoText = false;
  }

  void _handlePlanUpdated() {
    if (_isEditing || _memoController.text == _savedMemo) {
      return;
    }
    setState(() {
      _setMemoText(_savedMemo);
    });
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isEditing || !_hasUnsavedChanges) {
      return true;
    }
    final discard = await showConfirmActionDialog(
      context,
      title: l10n.planMemoDiscardTitle,
      message: l10n.planMemoDiscardMessage,
      confirmLabel: l10n.planMemoDiscard,
      cancelLabel: l10n.planMemoKeepEditing,
      notice: l10n.planMemoDiscardNotice,
      emphasizedValues: [l10n.planMemoUnsavedChanges],
    );
    return discard;
  }

  Future<void> _handleBack() async {
    if (_isSaving || _isTogglingTask) {
      ScaffoldMessenger.of(context).showStatusSnack(
        icon: LucideIcons.save,
        kind: AppStatusBannerKind.running,
        title: l10n.planMemoSavingWait,
      );
      return;
    }
    if (!await _confirmDiscardChanges()) {
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _startEditing() {
    if (_isTogglingTask) return;
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveMemo() async {
    if (_isSaving) {
      return;
    }
    final savedText = _memoController.text;
    setState(() {
      _isSaving = true;
    });
    try {
      await widget.controller.updatePlanMemo(savedText);
      if (!mounted) {
        return;
      }
      setState(() {
        _isEditing = _memoController.text != savedText;
      });
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: _isEditing ? l10n.planMemoSavedEditsPending : l10n.planMemoSaved,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.planMemoSaveFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleTaskItem(int taskIndex) async {
    if (_isTogglingTask || _isEditing) {
      return;
    }
    final currentMemo = _savedMemo;
    final toggledMemo = toggleMemoMarkdownTask(currentMemo, taskIndex);
    if (toggledMemo == currentMemo) {
      return;
    }
    setState(() {
      _isTogglingTask = true;
      _setMemoText(toggledMemo);
    });
    try {
      await widget.controller.updatePlanMemo(toggledMemo);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _setMemoText(currentMemo);
      });
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.planMemoTaskSaveFailed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingTask = false;
        });
      }
    }
  }

  void _applyMarkdownAction(_MarkdownAction action) {
    switch (action) {
      case _MarkdownAction.heading:
        _applyLinePrefix('## ', placeholder: l10n.planMemoHeading);
      case _MarkdownAction.bold:
        _wrapSelection('**', '**', placeholder: l10n.planMemoBoldPlaceholder);
      case _MarkdownAction.list:
        _applyLinePrefix('- ', placeholder: l10n.planMemoListPlaceholder);
      case _MarkdownAction.task:
        _applyLinePrefix('- [ ] ', placeholder: l10n.planMemoTaskPlaceholder);
      case _MarkdownAction.quote:
        _applyLinePrefix('> ', placeholder: l10n.planMemoQuotePlaceholder);
      case _MarkdownAction.divider:
        _insertDivider();
      case _MarkdownAction.link:
        _insertLink();
      case _MarkdownAction.code:
        _insertCode();
    }
  }

  TextSelection get _effectiveSelection {
    final selection = _memoController.selection;
    final textLength = _memoController.text.length;
    if (!selection.isValid) {
      return TextSelection.collapsed(offset: textLength);
    }
    return TextSelection(
      baseOffset: selection.start.clamp(0, textLength),
      extentOffset: selection.end.clamp(0, textLength),
    );
  }

  void _replaceSelection(
    String replacement, {
    int? selectionStartInReplacement,
    int? selectionEndInReplacement,
  }) {
    final selection = _effectiveSelection;
    final text = _memoController.text;
    final nextText = text.replaceRange(
      selection.start,
      selection.end,
      replacement,
    );
    final nextSelectionStart =
        selection.start + (selectionStartInReplacement ?? replacement.length);
    final nextSelectionEnd =
        selection.start + (selectionEndInReplacement ?? nextSelectionStart);
    _memoController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection(
        baseOffset: nextSelectionStart.clamp(0, nextText.length),
        extentOffset: nextSelectionEnd.clamp(0, nextText.length),
      ),
    );
  }

  void _wrapSelection(
    String before,
    String after, {
    required String placeholder,
  }) {
    final selection = _effectiveSelection;
    final selected = _memoController.text.substring(
      selection.start,
      selection.end,
    );
    final content = selected.isEmpty ? placeholder : selected;
    _replaceSelection(
      '$before$content$after',
      selectionStartInReplacement: selected.isEmpty ? before.length : null,
      selectionEndInReplacement: selected.isEmpty
          ? before.length + content.length
          : null,
    );
  }

  void _applyLinePrefix(String prefix, {required String placeholder}) {
    final selection = _effectiveSelection;
    final selected = _memoController.text.substring(
      selection.start,
      selection.end,
    );
    if (selected.isEmpty) {
      _replaceSelection(
        '$prefix$placeholder',
        selectionStartInReplacement: prefix.length,
        selectionEndInReplacement: prefix.length + placeholder.length,
      );
      return;
    }
    final replacement = selected
        .split('\n')
        .map((line) => line.trim().isEmpty ? line : '$prefix$line')
        .join('\n');
    _replaceSelection(replacement);
  }

  void _insertDivider() {
    final selection = _effectiveSelection;
    final text = _memoController.text;
    final needsLeadingBreak =
        selection.start > 0 &&
        !text.substring(0, selection.start).endsWith('\n');
    final needsTrailingBreak =
        selection.end < text.length &&
        !text.substring(selection.end).startsWith('\n');
    final replacement =
        '${needsLeadingBreak ? '\n' : ''}---${needsTrailingBreak ? '\n' : ''}';
    _replaceSelection(replacement);
  }

  void _insertLink() {
    final selection = _effectiveSelection;
    final selected = _memoController.text.substring(
      selection.start,
      selection.end,
    );
    final label = selected.isEmpty ? l10n.planMemoLinkPlaceholder : selected;
    final replacement = '[$label](https://example.com)';
    final urlStart = label.length + 3;
    _replaceSelection(
      replacement,
      selectionStartInReplacement: selected.isEmpty ? 1 : urlStart,
      selectionEndInReplacement: selected.isEmpty
          ? 1 + label.length
          : replacement.length - 1,
    );
  }

  void _insertCode() {
    final selection = _effectiveSelection;
    final selected = _memoController.text.substring(
      selection.start,
      selection.end,
    );
    if (selected.contains('\n')) {
      _replaceSelection('```\n$selected\n```');
      return;
    }
    _wrapSelection('`', '`', placeholder: l10n.planMemoCode);
  }

  Future<void> _openMarkdownLink(String? href) async {
    if (href == null || href.trim().isEmpty) {
      return;
    }
    final uri = Uri.tryParse(href.trim());
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.planMemoInvalidLink,
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: AppStatusBannerKind.error,
      title: l10n.planMemoOpenLinkFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final memo = _memoController.text.trim();
    return PopScope(
      canPop:
          !_isSaving &&
          !_isTogglingTask &&
          (!_isEditing || !_hasUnsavedChanges),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(onPressed: _handleBack),
          title: Text(l10n.planMemoTitle),
          actions: [
            AppContentFade(
              revision: (_isEditing, _isSaving),
              child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveMemo,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.save),
                        label: Text(l10n.commonSave),
                      ),
                    )
                  : IconButton(
                      tooltip: l10n.planMemoEdit,
                      onPressed: _isTogglingTask ? null : _startEditing,
                      icon: const Icon(LucideIcons.edit),
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: _isEditing
                ? TextFieldTapRegion(
                    child: Column(
                      children: [
                        _MarkdownToolbar(onAction: _applyMarkdownAction),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.planMemoContent,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: TextField(
                                  key: const ValueKey('plan-memo-editor'),
                                  onTapOutside: dismissKeyboardOnTapOutside,
                                  controller: _memoController,
                                  autofocus: true,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    height: 1.5,
                                    letterSpacing: 0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.planMemoHint,
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.accent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : memo.isEmpty
                ? _EmptyPlanMemo(onStart: _startEditing)
                : _PlanMemoMarkdownPreview(
                    data: _savedMemo,
                    onTapLink: _openMarkdownLink,
                    onToggleTask: _toggleTaskItem,
                  ),
          ),
        ),
      ),
    );
  }
}

enum _MarkdownAction { heading, bold, list, task, quote, divider, link, code }

class _MarkdownToolbar extends StatelessWidget {
  const _MarkdownToolbar({required this.onAction});

  final ValueChanged<_MarkdownAction> onAction;

  @override
  Widget build(BuildContext context) {
    final tools = [
      _MarkdownToolSpec(
        action: _MarkdownAction.heading,
        icon: LucideIcons.heading,
        tooltip: l10n.planMemoHeading,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.bold,
        icon: LucideIcons.bold,
        tooltip: l10n.planMemoBold,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.list,
        icon: LucideIcons.list,
        tooltip: l10n.planMemoList,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.task,
        icon: LucideIcons.squareCheckBig,
        tooltip: l10n.planMemoTask,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.quote,
        icon: LucideIcons.quote,
        tooltip: l10n.planMemoQuote,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.divider,
        icon: LucideIcons.minus,
        tooltip: l10n.planMemoDivider,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.link,
        icon: LucideIcons.link,
        tooltip: l10n.planMemoLink,
      ),
      _MarkdownToolSpec(
        action: _MarkdownAction.code,
        icon: LucideIcons.code,
        tooltip: l10n.planMemoCode,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tool in tools) ...[
              Tooltip(
                message: tool.tooltip,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onAction(tool.action),
                    icon: Icon(tool.icon, size: 20),
                  ),
                ),
              ),
              if (tool != tools.last) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarkdownToolSpec {
  const _MarkdownToolSpec({
    required this.action,
    required this.icon,
    required this.tooltip,
  });

  final _MarkdownAction action;
  final IconData icon;
  final String tooltip;
}

class _PlanMemoMarkdownPreview extends StatelessWidget {
  const _PlanMemoMarkdownPreview({
    required this.data,
    required this.onTapLink,
    required this.onToggleTask,
  });

  final String data;
  final ValueChanged<String?> onTapLink;
  final ValueChanged<int> onToggleTask;

  @override
  Widget build(BuildContext context) {
    final markdown = prepareMemoMarkdown(data);
    return SingleChildScrollView(
      child: MarkdownBody(
        data: markdown,
        selectable: true,
        softLineBreak: true,
        listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
        styleSheet: _markdownStyleSheet(context),
        onTapLink: (_, href, _) => onTapLink(href),
        checkboxBuilder: _TaskCheckboxBuilder(
          onToggleTask: onToggleTask,
          taskCount: countRenderedMemoTaskCheckboxes(markdown),
        ).build,
        bulletBuilder: _buildMarkdownBullet,
        imageBuilder: (uri, title, alt) => _UnsupportedMarkdownImage(
          label: alt?.trim().isNotEmpty == true ? alt!.trim() : uri.toString(),
        ),
      ),
    );
  }

  static MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final paragraph = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      height: 1.55,
      letterSpacing: 0,
    );
    return base.copyWith(
      a: TextStyle(
        color: AppColors.accentStrongForeground,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.55,
        letterSpacing: 0,
        decoration: TextDecoration.underline,
      ),
      p: paragraph,
      listBullet: paragraph.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
      listBulletPadding: EdgeInsets.zero,
      checkbox: TextStyle(
        color: AppColors.accentStrongForeground,
        fontSize: 24,
      ),
      h1: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: 0,
      ),
      h2: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: 0,
      ),
      h3: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
      strong: const TextStyle(fontWeight: FontWeight.w800),
      blockSpacing: 10,
      blockquote: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
        height: 1.55,
        letterSpacing: 0,
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(left: BorderSide(color: AppColors.accentDark, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      code: TextStyle(
        color: AppColors.textPrimary,
        backgroundColor: AppColors.surfaceMuted,
        fontSize: 14,
        height: 1.45,
        letterSpacing: 0,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
    );
  }
}

/// The markdown widget may parse the same data more than once with one builder
/// (e.g. didUpdateWidget and didChangeDependencies in the same frame), so the
/// callback counter wraps per parse instead of growing past the task count.
class _TaskCheckboxBuilder {
  _TaskCheckboxBuilder({required this.onToggleTask, required this.taskCount});

  final ValueChanged<int> onToggleTask;
  final int taskCount;
  var _buildCount = 0;

  Widget build(bool value) {
    final built = _buildCount++;
    final taskIndex = taskCount > 0 ? built % taskCount : built;
    return Transform.translate(
      offset: Offset.zero,
      child: Tooltip(
        message: value ? l10n.planMemoUncheck : l10n.planMemoMarkDone,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onToggleTask(taskIndex),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              value ? LucideIcons.squareCheckBig : LucideIcons.square,
              size: 25,
              color: value
                  ? AppColors.accentStrongForeground
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMarkdownBullet(MarkdownBulletParameters parameters) {
  if (parameters.style == BulletStyle.orderedList) {
    return Transform.translate(
      offset: const Offset(0, 1),
      child: SizedBox(
        width: 28,
        child: Text(
          '${parameters.index + 1}.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.45,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
  return Transform.translate(
    offset: const Offset(0, 4),
    child: SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          '•',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    ),
  );
}

class _UnsupportedMarkdownImage extends StatelessWidget {
  const _UnsupportedMarkdownImage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.imageOff, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.planMemoImageUnsupported(label),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlanMemo extends StatelessWidget {
  const _EmptyPlanMemo({required this.onStart});

  final VoidCallback onStart;

  static List<({IconData icon, String label, String detail})>
  get _suggestions => [
    (
      icon: LucideIcons.trainFront,
      label: l10n.planMemoSuggestTransport,
      detail: l10n.planMemoSuggestTransportDetail,
    ),
    (
      icon: LucideIcons.hotel,
      label: l10n.planMemoSuggestHotel,
      detail: l10n.planMemoSuggestHotelDetail,
    ),
    (
      icon: LucideIcons.ticket,
      label: l10n.planMemoSuggestTickets,
      detail: l10n.planMemoSuggestTicketsDetail,
    ),
    (
      icon: LucideIcons.camera,
      label: l10n.planMemoSuggestShooting,
      detail: l10n.planMemoSuggestShootingDetail,
    ),
    (
      icon: LucideIcons.bell,
      label: l10n.planMemoSuggestNotes,
      detail: l10n.planMemoSuggestNotesDetail,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final guideWidth = (constraints.maxWidth * 0.84).clamp(0.0, 420.0);
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.stickyNote,
                    color: AppColors.accentStrongForeground,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.planMemoEmptyTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.planMemoEmptyBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: guideWidth,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.lightbulb,
                              color: AppColors.accentForeground,
                              size: 18,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              l10n.planMemoSuggestionsTitle,
                              style: TextStyle(
                                color: AppColors.accentStrongForeground,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (
                          var index = 0;
                          index < _suggestions.length;
                          index++
                        ) ...[
                          _MemoSuggestionItem(suggestion: _suggestions[index]),
                          if (index < _suggestions.length - 1)
                            const Divider(
                              height: 1,
                              indent: 42,
                              color: Color(0xB3FFFFFF),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: guideWidth,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(LucideIcons.notebookPen, size: 20),
                      label: Text(l10n.planMemoStart),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MemoSuggestionItem extends StatelessWidget {
  const _MemoSuggestionItem({required this.suggestion});

  final ({IconData icon, String label, String detail}) suggestion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              suggestion.icon,
              color: AppColors.accentForeground,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
