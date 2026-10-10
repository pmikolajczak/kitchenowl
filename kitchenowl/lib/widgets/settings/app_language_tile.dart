import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/cubits/settings_cubit.dart';
import 'package:kitchenowl/kitchenowl.dart';

/// Device-local interface language; independent of household product language.
class AppLanguageTile extends StatelessWidget {
  const AppLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => ListTile(
        leading: const Icon(Icons.translate),
        title: Text(strings.language),
        trailing: DropdownButton<String>(
          value: state.appLocale?.languageCode ?? 'system',
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: 'system',
              child: Text(strings.themeSystem),
            ),
            const DropdownMenuItem(value: 'pl', child: Text('Polski')),
            const DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value == null) return;
            context.read<SettingsCubit>().setAppLocale(
                  value == 'system' ? null : Locale(value),
                );
          },
        ),
      ),
    );
  }
}
