//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/markers/category_icon_mapper.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// features/map/presentation/markers/category_icon_mapper.dart
class CategoryIconMapper {
  static IconData map(String input) {
    final k = input.toLowerCase().trim();

    // 1) Chemin rapide: si c’est du FontAwesome "fa-*"
    if (k.startsWith('fa-')) {
      return _faByName[k] ?? FontAwesomeIcons.locationDot; // fallback FA propre
    }

    // 2) Ancien fallback par mots-clés (utile si pas d'icon côté backend)
    if (_containsAny(k, ['restaurant', 'manger', 'food', 'eat'])) return FontAwesomeIcons.utensils;
    if (_containsAny(k, ['musée', 'museum', 'museo', 'culture', 'cultura', 'university', 'monument', 'monumento'])){
      return FontAwesomeIcons.buildingColumns;}
    if (_containsAny(k, ['hiking', 'randonnée', 'Senderismo'])) return FontAwesomeIcons.personHiking;
    if (_containsAny(k, ['water', 'swimming', 'baignade', 'natación'])) return FontAwesomeIcons.personHiking;
    if (_containsAny(k, ['bar', 'cocktail', 'drink', 'boisson'])) return FontAwesomeIcons.martiniGlass;
    if (_containsAny(k, ['guitar', 'musique', 'concert'])) return FontAwesomeIcons.guitar;
    if (_containsAny(k, ['hotel', 'hébergement', 'bed'])) return FontAwesomeIcons.bed;
    if (_containsAny(k, ['nature', 'naturaleza', 'parc', 'park', 'parque'])) return FontAwesomeIcons.tree; // un peu plus parlant
    if (_containsAny(k, ['panorama', 'vue', 'mirador', 'view'])) return FontAwesomeIcons.binoculars;
    if (_containsAny(k, ['mexicaine', 'pepper', 'spicy'])) return FontAwesomeIcons.pepperHot;
    if (_containsAny(k, ['gratuit', 'free', 'cadeau', 'gift'])) return FontAwesomeIcons.gift;
    if (_containsAny(k, ['espectaculo', 'spectacle', 'show'])) return FontAwesomeIcons.masksTheater;
    if (_containsAny(k, ['honky tonk', 'tonk', 'honky'])) return FontAwesomeIcons.peoplePulling;
    if (_containsAny(k, ['rodeo', 'cowboy'])) return FontAwesomeIcons.hatCowboy;
    if (_containsAny(k, ['horse', 'horseback', 'cheval', 'Cabalgata'])) return FontAwesomeIcons.horse;
    if (_containsAny(k, ['ranch', 'rancho'])) return FontAwesomeIcons.cow;
    if (_containsAny(k, ['mexicana comida', 'cuisine mexicaine', 'mexican food'])) return FontAwesomeIcons.pepperHot;
    if (_containsAny(k, ['art', 'arte'])) return FontAwesomeIcons.palette;
    if (_containsAny(k, ['brunch'])) return FontAwesomeIcons.bacon;
    if (_containsAny(k, ['musica/concierto', 'musique/concert', 'vida nocturna'])) return FontAwesomeIcons.guitar;
    if (_containsAny(k, ['vie nocturne', 'night life', 'music/concert'])) return FontAwesomeIcons.cloudMoon;
    if (_containsAny(k, ['bar/cocktails', 'bar/cocteles'])) return FontAwesomeIcons.martiniGlassCitrus;
    if (_containsAny(k, ['juego/fun', 'jeu/fun', 'game/fun'])) return FontAwesomeIcons.gamepad;

    // 3) Fallback final
    return Icons.place;
  }

  static bool _containsAny(String haystack, List<String> needles) => needles.any(haystack.contains);

  static const Map<String, IconData> _faByName = {
    // existants ...
    'fa-gamepad': FontAwesomeIcons.gamepad,
    'fa-museum': FontAwesomeIcons.buildingColumns,
    'fa-university': FontAwesomeIcons.bookOpen,
    'fa-book-open': FontAwesomeIcons.bookOpen,
    'fa-person-hiking': FontAwesomeIcons.personHiking,
    'fa-cocktail': FontAwesomeIcons.martiniGlassCitrus,
    'fa-martini-glass': FontAwesomeIcons.martiniGlass,
    'fa-glass-cheers': FontAwesomeIcons.champagneGlasses,
    'fa-utensils': FontAwesomeIcons.utensils,
    'fa-guitar': FontAwesomeIcons.guitar,
    'fa-leaf': FontAwesomeIcons.leaf,
    'fa-binoculars': FontAwesomeIcons.binoculars,
    'fa-pepper-hot': FontAwesomeIcons.pepperHot,
    'fa-plate-wheat': FontAwesomeIcons.bowlFood,
    'fa-drumstick-bite' : FontAwesomeIcons.drumstickBite,
    'fa-hotel': FontAwesomeIcons.bed,
    'fa-bed': FontAwesomeIcons.bed,
    'fa-tree': FontAwesomeIcons.tree,
    'fa-music': FontAwesomeIcons.music,
    'fa-moon': FontAwesomeIcons.cloudMoon,
    'fa-city': FontAwesomeIcons.city,
    'fa-landmark': FontAwesomeIcons.landmark,
    'fa-park': FontAwesomeIcons.tree,
    'fa-gift': FontAwesomeIcons.gift,
    'fa-burger': FontAwesomeIcons.burger,
    'fa-bus': FontAwesomeIcons.bus,
    'fa-car': FontAwesomeIcons.car,
    'fa-bicycle': FontAwesomeIcons.bicycle,
    'fa-swimmer': FontAwesomeIcons.personSwimming,
    'fa-swimming-pool': FontAwesomeIcons.personSwimming,
    'fa-person-swimming': FontAwesomeIcons.personSwimming,
    'fa-water': FontAwesomeIcons.water,
    'fa-church': FontAwesomeIcons.church,
    'fa-mosque': FontAwesomeIcons.mosque,
    'fa-synagogue': FontAwesomeIcons.synagogue,
    'fa-theater-masks': FontAwesomeIcons.masksTheater,
    'fa-film': FontAwesomeIcons.film,
    'fa-volleyball-ball': FontAwesomeIcons.volleyball,
    'fa-basketball': FontAwesomeIcons.basketball,
    'fa-hat-cowboy': FontAwesomeIcons.hatCowboy,
    'fa-horse': FontAwesomeIcons.horse,
    'fa-cow': FontAwesomeIcons.cow,
    'fa-palette': FontAwesomeIcons.palette,
    'fa-bacon': FontAwesomeIcons.bacon,

    'fa-building-columns': FontAwesomeIcons.buildingColumns, // “monument”
    'fa-mask': FontAwesomeIcons.mask,                        // “spectacle”
    'fa-person-dancing': FontAwesomeIcons.peoplePulling,     // “honky tonk”
  };
}
