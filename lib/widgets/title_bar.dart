import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../theme/theme.dart';

class EconnectTitleBar extends StatelessWidget {
  const EconnectTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final titleBarWidth = MediaQuery.of(context).size.width;
    final containerWidth = titleBarWidth - 510;
    final themeMode = context.watch<ThemeCubit>().state;
    return WindowCaption(
      brightness: Brightness.dark,
      backgroundColor: Theme.of(context).colorScheme.outline,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Icon(
                Icons.app_registration,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'EConnect - Tamilnad Mercantile Bank Ltd.,',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
          Container(
            width: containerWidth,
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
                final theme = context.read<ThemeCubit>().state.toString();
                context.read<GetStorage>().write('theme', theme);
              },
              icon: Icon(
                themeMode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant, // Colors.white70
                // Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
