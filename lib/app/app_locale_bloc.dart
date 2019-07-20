import 'dart:ui';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/shared_pref_util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

final supportedLocaleTitle = <Locale, String>{
  const Locale('en', ''): 'English - en',
};

///
/// Bloc handling change locale and get stream of locales
/// Used to support multi language in app
///
class LocaleBloc implements BaseBloc {
  ///
  /// Sinks
  ///
  final Sink<Locale> changeLocale;

  ///
  /// Streams
  ///
  final ValueObservable<Locale> locale$;


  ///
  /// Tuple2 with Tuple2.item1 is result (true for successful, false for failure),
  /// Tuple2.item2 is error (nullable)
  ///
  final Stream<Tuple2<bool, Object>> changeLocaleResult$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  LocaleBloc._(
    this.changeLocale,
    this.locale$,
    this._dispose,
    this.changeLocaleResult$,
  );

  factory LocaleBloc(SharedPrefUtil sharedPrefUtil) {
    assert(sharedPrefUtil != null, 'sharedPrefUtil cannot be null');
    final changeLocalController = PublishSubject<Locale>(sync: true);

    final changeLocaleResult$ = changeLocalController.distinct().switchMap((locale) {
      return Observable.defer(() => Stream.fromFuture(
        sharedPrefUtil.saveSelectedLanguageCode(locale.languageCode),
      ))
      .map((result) => Tuple2(result, null))
      .onErrorReturnWith((e) => Tuple2(false, e));
    }).publish();

    final selectedLanguageCode$ = sharedPrefUtil.selectedLanguageCode$;
    final selectedLanguageCode = selectedLanguageCode$.value;
    toLocale(String code) => Locale(code, '');

    final locale$ = publishValueSeededDistinct(
      selectedLanguageCode$.map(toLocale),
      seedValue: selectedLanguageCode == null ? null : toLocale(selectedLanguageCode),
    );

    final subscriptions = [
      locale$.connect(),
      changeLocaleResult$.connect(),
    ];

    return LocaleBloc._(
      changeLocalController.sink,
      locale$,
      () {
        changeLocalController.close();
        subscriptions.forEach((s) => s.cancel());
      },
      changeLocaleResult$,
    );
  }

  @override
  void dispose() => _dispose();
}