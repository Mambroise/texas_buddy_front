//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/cubits/category_filter_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterCubit extends Cubit<Set<String>> {
  CategoryFilterCubit() : super(<String>{});

  static const String typeEventToken = '__TYPE:event__';

  void toggle(String key) {
    final next = Set<String>.from(state);
    if (!next.remove(key)) next.add(key);
    emit(next);
  }

  void toggleMany(Set<String> keys) {
    final next = Set<String>.from(state);
    for (final k in keys) {
      if (!next.remove(k)) next.add(k);
    }
    emit(next);
  }

  /// Mode "Events only"
  /// - ON  : exclusif → on garde uniquement le token (on efface les catégories)
  /// - OFF : on retire juste le token, on CONSERVE les catégories déjà sélectionnées
  void setEventsOnly(bool on) {
    if (on) {
      emit({typeEventToken}); // exclusif
    } else {
      final next = Set<String>.from(state)..remove(typeEventToken);
      emit(next); // <-- ne vide plus les catégories
    }
  }

  void clear() => emit(<String>{}); // "Tous" = reset complet
}


