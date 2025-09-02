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
}
