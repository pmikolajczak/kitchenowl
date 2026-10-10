import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchenowl/config.dart';
import 'package:kitchenowl/cubits/settings_cubit.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/widgets/settings/app_language_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<SettingsCubit> loadedSettings() async {
  final cubit = SettingsCubit();
  // These unrelated startup probes need no platform plugins in settings tests.
  Config.deviceInfo?.ignore();
  Config.packageInfo?.ignore();
  await cubit.stream.first.timeout(const Duration(seconds: 5));
  return cubit;
}

Widget languageApp(SettingsCubit cubit) => BlocProvider.value(
      value: cubit,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => MaterialApp(
          locale: state.appLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.settings),
              ),
              body: const AppLanguageTile(),
            ),
          ),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'KitchenOwl',
    packageName: 'com.tombursch.kitchenowl',
    version: '0.7.10',
    buildNumber: '124',
    buildSignature: '',
  );

  setUp(() async {
    await (await SharedPreferences.getInstance()).clear();
  });

  test('No preference and unsupported stored languages use the device locale',
      () async {
    final first = await loadedSettings();
    expect(first.state.appLocale, isNull);
    await first.close();

    await (await SharedPreferences.getInstance()).setString('appLanguage', 'xx');
    final restored = await loadedSettings();
    expect(restored.state.appLocale, isNull);
    await restored.close();
  });

  test('Language persists across settings instances and theme updates', () async {
    final cubit = await loadedSettings();
    await cubit.setAppLocale(const Locale('pl'));
    cubit.setTheme(ThemeMode.dark);
    expect(cubit.state.appLocale, const Locale('pl'));
    await cubit.close();

    final restored = await loadedSettings();
    expect(restored.state.appLocale, const Locale('pl'));
    expect(restored.state.themeMode, ThemeMode.dark);
    await restored.close();
  });

  test('System selection removes the override without resetting other settings',
      () async {
    final cubit = await loadedSettings();
    cubit.setTheme(ThemeMode.dark);
    await cubit.setAppLocale(const Locale('en'));
    await cubit.setAppLocale(null);
    expect(cubit.state.appLocale, isNull);
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect((await SharedPreferences.getInstance()).getString('appLanguage'),
        isNull);
    await cubit.close();

    final restored = await loadedSettings();
    expect(restored.state.appLocale, isNull);
    await restored.close();
  });

  testWidgets('English device can switch to Polish, reload, and return to System',
      (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final cubit = (await tester.runAsync(loadedSettings))!;
    await tester.pumpWidget(languageApp(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Polski').last);
    await tester.pumpAndSettle();
    expect(cubit.state.appLocale, const Locale('pl'));
    expect(find.text('Ustawienia'), findsOneWidget);
    expect(find.text('Język'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await cubit.close();
    final restored = (await tester.runAsync(loadedSettings))!;
    await tester.pumpWidget(languageApp(restored));
    await tester.pumpAndSettle();
    expect(find.text('Ustawienia'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(restored.state.appLocale, isNull);
    expect(find.text('Settings'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await restored.close();
  });
}
