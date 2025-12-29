// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Texas Buddy';

  @override
  String get splashWelcome => 'Bienvenido a Texas Buddy';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get loginLoading => 'Bienvenido a Texas Buddy...';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get firstTimeSignup => '¿Primera vez? ¡Regístrate ahora!';

  @override
  String get forgotPasswordQ => '¿Olvidaste la contraseña?';

  @override
  String get verifyAndSignup => 'Verificar y registrarse';

  @override
  String get forgotRegistrationNumberQ => '¿Olvidaste el número de registro?';

  @override
  String get backToLogin => 'Volver a iniciar sesión';

  @override
  String get backToRegister => 'Volver al registro';

  @override
  String get sendResetCode => 'Enviar código de restablecimiento';

  @override
  String get sendRegistrationNumber => 'Enviar número de registro';

  @override
  String get enterRegistrationCodeTitle => 'Introduce el código enviado para completar el registro';

  @override
  String get enterResetCodeTitle => 'Introduce tu código de verificación secreto';

  @override
  String get codeLabel => 'Código';

  @override
  String get send => 'Enviar';

  @override
  String get setYourPassword => 'Establece tu contraseña';

  @override
  String get setYourNewPassword => 'Establece tu nueva contraseña';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get submit => 'Enviar';

  @override
  String get passwordResetSuccess => 'Contraseña restablecida. Ya puedes iniciar sesión.';

  @override
  String get passwordRuleLength => 'Al menos 8 caracteres';

  @override
  String get passwordRuleNumber => 'Al menos un número';

  @override
  String get passwordRuleSpecial => 'Al menos un carácter especial';

  @override
  String get passwordRuleUpper => 'Al menos una letra mayúscula';

  @override
  String get passwordRuleLetter => 'Al menos una letra';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get profile => 'Tu perfil';

  @override
  String get address => 'Dirección';

  @override
  String get modify => 'Editar';

  @override
  String get accountSecurity => 'Cuenta y seguridad';

  @override
  String get registrationNumber => 'Número de registro';

  @override
  String get firstIp => 'IP primaria';

  @override
  String get secondIp => 'IP secundaria';

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# eventos',
      one: '# evento',
    );
    return '$_temp0';
  }

  @override
  String welcomeUser(Object name) {
    return '¡Bienvenido, $name!';
  }

  @override
  String todayDate(Object date) {
    return 'Hoy es $date';
  }

  @override
  String get mapTab => 'Mapa';

  @override
  String get planningTab => 'Planificación';

  @override
  String get communityTab => 'Comunidad';

  @override
  String get loading => 'Cargando…';

  @override
  String get refresh => 'Actualizar';

  @override
  String get guest => 'Invitado';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileEditComingSoon => 'Próximamente: edición del perfil';

  @override
  String get mapModeEventsTitle => 'Eventos del año';

  @override
  String mapModeEventsSubtitle(int year) {
    return 'Ver los eventos de $year en el área visible';
  }

  @override
  String get mapModeNearbyTitle => 'Actividades y eventos';

  @override
  String get mapModeNearbySubtitle => 'Volver a la búsqueda Nearby';

  @override
  String get recenterMap => 'Recentrar el mapa';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryEvents => 'Eventos';

  @override
  String get categoryEat => 'Comer';

  @override
  String get categoryDrink => 'Beber';

  @override
  String get categoryGoOut => 'Salir';

  @override
  String get categoryHaveFun => 'Divertirse';

  @override
  String get categoryFree => 'Gratis';

  @override
  String get somethingWentWrong => 'Algo salió mal.';

  @override
  String get networkError => 'Error de red. Verifica tu conexión.';

  @override
  String get timeoutError => 'Tiempo de espera agotado. Inténtalo de nuevo.';

  @override
  String get serverUnavailable => 'Servidor no disponible. Inténtalo más tarde.';

  @override
  String get unauthorizedError => 'Necesitas iniciar sesión.';

  @override
  String get forbiddenError => 'No tienes permiso para esto.';

  @override
  String get notFoundError => 'No encontrado.';

  @override
  String get conflictError => 'Conflicto. Inténtalo de nuevo.';

  @override
  String get rateLimitError => 'Demasiadas solicitudes. Espera un momento.';

  @override
  String get validationError => 'Algunos campos no son válidos.';

  @override
  String get parseError => 'Error de datos.';

  @override
  String get tripCreateTitle => 'Nuevo viaje';

  @override
  String get tripCreateNameLabel => 'Título del viaje';

  @override
  String get tripCreateNameHint => 'p. ej., Roadtrip Austin';

  @override
  String get tripCreateDatesLabel => 'Fechas';

  @override
  String get tripCreateDatesPick => 'Seleccionar fechas';

  @override
  String get tripCreateSave => 'Aceptar';

  @override
  String get tripCreateCancel => 'Cancelar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tripCreateCreate => 'Crear';

  @override
  String get tripCreateValidationNameRequired => 'El título es obligatorio';

  @override
  String tripCreateValidationNameMax(Object max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get tripCreateValidationDatesRequired => 'Seleccione un periodo';

  @override
  String get tripCreateTodoPersist => 'TODO: guardar el viaje en la BD';

  @override
  String get trips_create_success => 'Viaje creado con éxito.';

  @override
  String get tripCreateAdults => 'Adultos';

  @override
  String get tripCreateChildren => 'Niños';

  @override
  String get trips_add_label => 'Añadir un viaje';

  @override
  String get trips_actions_delete_tooltip => 'Eliminar';

  @override
  String get trips_actions_edit_tooltip => 'Editar';

  @override
  String get trips_delete_title => '¿Eliminar este viaje?';

  @override
  String get trips_delete_confirm => 'Eliminar';

  @override
  String get trips_delete_toast => 'Eliminación confirmada (solo UI).';

  @override
  String get trips_edit_toast => 'Edición próximamente.';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String trips_delete_message(Object tripTitle) {
    return '«$tripTitle» se eliminará de tu lista. Esta acción es irreversible.';
  }

  @override
  String get trips_delete_success => 'Viaje eliminado.';

  @override
  String get trips_delete_error => 'Error al eliminar el viaje.';

  @override
  String get trips_update_success => 'Viaje actualizado.';

  @override
  String get trips_update_error => 'Error al actualizar el viaje.';

  @override
  String get tripEditTitle => 'Editar viaje';

  @override
  String get tripEditSave => 'Guardar';

  @override
  String get save => 'Guardar';

  @override
  String get tripNoAddress => 'Sin dirección';

  @override
  String get addHotelAddress => 'añadir la dirección';

  @override
  String get country => 'País';

  @override
  String get phone => 'Número de teléfono';

  @override
  String get profileUpdateError => 'No se pudo actualizar el perfil.';

  @override
  String get profileEditSubtitle => 'Actualiza tus datos de contacto y tu país.';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidEmail => 'Dirección de correo electrónico inválida';

  @override
  String get addressFormTitle => 'Definir la dirección del hotel';

  @override
  String get cityLabel => 'Ciudad';

  @override
  String get cityHint => 'p. ej. Dallas';

  @override
  String get addressLabel => 'Dirección';

  @override
  String get addressHint => 'Escribe al menos 3 letras…';

  @override
  String get fillCityFirst => 'Introduce primero la ciudad';

  @override
  String get typeAtLeast3Chars => 'Escribe al menos 3 letras para buscar.';

  @override
  String get genericError => 'Ha ocurrido un error.';

  @override
  String get noResults => 'Sin resultados.';

  @override
  String get planning_select_trip_hint => 'Selecciona un viaje para empezar a planear ✨';

  @override
  String get planning_select_trip_hintDescription => 'Texto del banner que se muestra en la vista de planificación cuando no hay ningún viaje abierto.';

  @override
  String get timeline_delete_title => 'Eliminar etapa';

  @override
  String timeline_delete_message(String stepTitle) {
    return '¿Estás seguro de que deseas eliminar la etapa \"$stepTitle\"?';
  }

  @override
  String timeline_edit_duration_title(String stepTitle) {
    return 'Modificar «$stepTitle»';
  }

  @override
  String get timeline_edit_duration_subtitle => 'Ajusta la duración de la actividad. Los pasos siguientes se ajustarán automáticamente.';

  @override
  String get common_hours_short => 'h';

  @override
  String get common_minutes_short => 'min';

  @override
  String get common_save => 'Guardar';

  @override
  String get timeline_edit_success => 'Duración actualizada, el día ha sido ajustado.';

  @override
  String get timeline_edit_error => 'No se pudo actualizar esta actividad.';

  @override
  String get timeline_drop_occupied => 'Ese horario ya está ocupado';

  @override
  String get interestsTitle => 'Elige tus intereses';

  @override
  String get interestsSubtitle => 'Selecciona algunos temas para personalizar tus recomendaciones.';

  @override
  String get myInterests => 'Mis intereses';

  @override
  String get interestsOpenCta => 'Editar mis intereses';

  @override
  String get search => 'Buscar';

  @override
  String get interestsLoading => 'Cargando intereses…';

  @override
  String get interestsLoadError => 'No pudimos cargar tus intereses.';

  @override
  String get interestsRetry => 'Reintentar';

  @override
  String get interestsSave => 'Guardar';

  @override
  String get interestsSkip => 'Ahora no';

  @override
  String get interestsClose => 'Cerrar';

  @override
  String get close => 'Cerrar';

  @override
  String get interestsMinOneError => 'Selecciona al menos un interés.';

  @override
  String get interestsSaveSuccess => 'Intereses guardados.';

  @override
  String get interestsSaveError => 'No pudimos guardar tus intereses.';
}
