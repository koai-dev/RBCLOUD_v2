import 'package:bedrive/i18n/styled_text.dart';
import 'package:bedrive/models/file_entry.dart';
import 'package:bedrive/router_provider.dart';
import 'package:bedrive/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShareableLinkTile extends ConsumerWidget {
  final List<FileEntry> entries;

  const ShareableLinkTile(this.entries, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.length > 1 ||
        ref.activeRouteIs(AppRoute.trash) ||
        !entries.every((e) => e.permissions.update)) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.add_link),
      title: const StyledText('Get link'),
      onTap: () {
        context.pop();
        context.pushNamed(
          AppRoute.shareableLink.name,
          extra: entries.first,
        );
      },
    );
  }
}
