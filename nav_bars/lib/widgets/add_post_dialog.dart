import 'package:flutter/material.dart';
import 'package:nav_bars/classses/post_class.dart';
import 'package:nav_bars/l10n/app_localizations.dart';

const _presetIcons = [
  Icons.note_outlined,
  Icons.star_border,
  Icons.notifications_outlined,
  Icons.favorite_border,
  Icons.warning_amber_outlined,
  Icons.lightbulb_outline,
];

const _presetColors = [
  Colors.blueAccent,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Colors.teal,
];

class AddPostDialog extends StatefulWidget {
  const AddPostDialog({super.key});

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  int _selectedIcon = 0;
  int _selectedColor = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.newPost),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.postTitle,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleCtrl,
              decoration: InputDecoration(
                labelText: l10n.postDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            Text(l10n.iconLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_presetIcons.length, (i) {
                final selected = _selectedIcon == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = i),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selected
                          ? _presetColors[_selectedColor].withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? _presetColors[_selectedColor]
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _presetIcons[i],
                      color: selected ? _presetColors[_selectedColor] : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(l10n.colorLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_presetColors.length, (i) {
                final selected = _selectedColor == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _presetColors[i],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleCtrl.text.trim();
            final subtitle = _subtitleCtrl.text.trim();
            if (title.isEmpty) return;

            final newPost = Post(
              title: title,
              subtitle: subtitle.isEmpty ? '' : subtitle,
              icon: _presetIcons[_selectedIcon],
              iconColor: _presetColors[_selectedColor],
            );

            Navigator.pop(context, newPost);
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
