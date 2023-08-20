import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<Locale, String> mapLocale = {
  const Locale('en'): 'English',
  const Locale('de'): 'Deutsch',
  const Locale('es'): 'Español',
  const Locale('fr'): 'Français',
  const Locale('hr'): 'Hrvatski',
  const Locale('id'): 'Bahasa Indonesia',
  const Locale('it'): 'Italiano',
  const Locale('ja'): '日本語',
  const Locale('nb'): 'Norsk',
  const Locale('nl'): 'Nederlands',
  const Locale('pl'): 'Polski',
  const Locale('pt'): 'Português',
  const Locale('ru'): 'Pусский',
  const Locale('tr'): 'Türkçe',
  const Locale('ar'): 'العربية',
  const Locale('zh'): '中文',
  const Locale('zh', 'TW'): '中文 (台灣)',
};

final sharedPrefs = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

class SignificantFigures extends AsyncNotifier<int> {
  static const prefKey = 'significant_figures';
  static final provider =
      AsyncNotifierProvider<SignificantFigures, int>(SignificantFigures.new);

  @override
  Future<int> build() async {
    var pref = await ref.watch(sharedPrefs.future);
    return pref.getInt(prefKey) ?? 10;
  }

  void set(int value) {
    state = AsyncData(value);
    ref.read(sharedPrefs.future).then((pref) => pref.setInt(prefKey, value));
  }
}

class RemoveTrailingZeros extends AsyncNotifier<bool> {
  static const prefKey = 'remove_trailing_zeros';
  static final provider =
      AsyncNotifierProvider<RemoveTrailingZeros, bool>(RemoveTrailingZeros.new);

  @override
  Future<bool> build() async {
    var pref = await ref.watch(sharedPrefs.future);
    return pref.getBool(prefKey) ?? true;
  }

  void set(bool value) {
    state = AsyncData(value);
    ref.read(sharedPrefs.future).then((pref) => pref.setBool(prefKey, value));
  }
}

class IsDarkAmoled extends AsyncNotifier<bool> {
  static const prefKey = 'isDarkAmoled';
  static final provider =
      AsyncNotifierProvider<IsDarkAmoled, bool>(IsDarkAmoled.new);

  @override
  Future<bool> build() async {
    var pref = await ref.watch(sharedPrefs.future);
    return pref.getBool(prefKey) ?? true;
  }

  void set(bool value) {
    state = AsyncData(value);
    ref.read(sharedPrefs.future).then((pref) => pref.setBool(prefKey, value));
  }
}

class CurrentThemeMode extends AsyncNotifier<ThemeMode> {
  static const prefKey = 'currentThemeMode';
  static final provider =
      AsyncNotifierProvider<CurrentThemeMode, ThemeMode>(CurrentThemeMode.new);

  @override
  Future<ThemeMode> build() async {
    var pref = await ref.watch(sharedPrefs.future);
    return ThemeMode.values[pref.getInt(prefKey) ?? 0];
  }

  void set(ThemeMode value) {
    state = AsyncData(value);
    ref
        .read(sharedPrefs.future)
        .then((pref) => pref.setInt(prefKey, ThemeMode.values.indexOf(value)));
  }
}

class CurrentLocale extends AsyncNotifier<Locale?> {
  static const prefKey = 'locale';
  static final provider =
      AsyncNotifierProvider<CurrentLocale, Locale?>(CurrentLocale.new);

  @override
  Future<Locale?> build() async {
    var pref = await ref.watch(sharedPrefs.future);

    var savedLanguageCode = pref.getString(prefKey);
    if (savedLanguageCode == null) {
      return null;
    }
    return mapLocale.keys.firstWhere(
      (element) => element.languageCode == savedLanguageCode,
      orElse: () => const Locale('en'),
    );
  }

  void set(Locale? value) {
    state = AsyncData(value);
    // TODO deal with null value
    if (value != null) {
      ref
          .read(sharedPrefs.future)
          .then((pref) => pref.setString(prefKey, value.languageCode));
    }
  }
}
