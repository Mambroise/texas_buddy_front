//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/cubits/category_filter_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterCubit extends Cubit<Set<String>> {
  CategoryFilterCubit() : super(<String>{});

  // Token réservé pour le mode "events only"
  static const String typeEventToken = '__TYPE:event__';

  /// Ajoute/retire une clé de catégorie
  void toggle(String key) {
    final next = Set<String>.from(state);
    if (!next.remove(key)) next.add(key);
    emit(next);
  }

  /// Ajoute/retire plusieurs catégories d'un coup
  void toggleMany(Set<String> keys) {
    final next = Set<String>.from(state);
    for (final k in keys) {
      if (!next.remove(k)) next.add(k);
    }
    emit(next);
  }

  /// Active/désactive le mode "events only".
  /// Quand on l'active, on vide les catégories.
  void setEventsOnly(bool on) {
    final next = <String>{};
    if (on) next.add(typeEventToken);
    emit(next);
  }

  /// Reset complet (tous)
  void clear() => emit(<String>{});
}

