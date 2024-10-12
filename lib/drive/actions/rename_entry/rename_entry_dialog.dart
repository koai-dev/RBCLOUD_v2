import 'package:bedrive/drive/drive_api_provider.dart';
import 'package:bedrive/i18n/localization_provider.dart';
import 'package:bedrive/i18n/styled_text.dart';
import 'package:bedrive/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../forms/form_validators.dart';
import '../../../http/api_client_exception.dart';
import '../../../models/file_entry.dart';

class RenameEntryDialog extends HookConsumerWidget {
  final FileEntry entry;

  RenameEntryDialog(this.entry, {super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveApi = ref.watch(driveApiProvider).requireValue;
    final localizer = ref.watch(localizationProvider);
    final formPayload = useState<Map<String, String>>({});
    final isLoading = useState(false);
    final backendErrors = useState<Map<String, String?>>({});

    renameEntry() async {
      backendErrors.value.clear();
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();

      try {
        isLoading.value = true;
        await driveApi.renameEntry(
          id: entry.id,
          newName: formPayload.value['name']!,
        );
        context.pop();
        context.showTextSnackBar('Item renamed');
      } on ApiClientException catch (e) {
        if (e.validationErrors != null) {
          backendErrors.value.addAll(e.validationErrors!);
          _formKey.currentState!.validate();
        } else {
          context.showErrorSnackBar(e.message);
        }
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: const StyledText('Rename'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: entry.name,
          onSaved: (v) => formPayload.value['name'] = v!,
          autofocus: true,
          onFieldSubmitted: (_) => renameEntry(),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: localizer.translate('Enter a name...'),
          ),
          validator: FormValidators.compose(localizer, [
            FormValidators.required(),
            FormValidators.backendError(backendErrors.value, 'name')
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const StyledText('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading.value ? null : renameEntry,
          child: const StyledText('Save'),
        ),
      ],
    );
  }
}
