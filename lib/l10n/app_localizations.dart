import 'package:flutter/widgets.dart';

import '../features/connection/domain/connection_quality.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('hi'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'HiVPN',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      'watchAdToStart': 'Watch ad to start',
      'pleaseSelectServer': 'Please select a server first.',
      'locations': 'Locations',
      'viewAll': 'View all',
      'failedToLoadServers': 'Failed to load servers',
      'termsPrivacy': 'Terms & Privacy',
      'currentIp': 'Current IP',
      'session': 'Session',
      'runSpeedTest': 'Run Speed Test to benchmark your tunnel latency.',
      'legalTitle': 'Legal',
      'legalBody':
          'VPN usage may be regulated in your country. Ensure you understand local laws before connecting.',
      'close': 'Close',
      'sessionExpiredTitle': 'Session expired',
      'sessionExpiredBody':
          'Your 60 minute session is over. Watch another ad to reconnect.',
      'ok': 'Ok',
      'disconnectedWatchAd':
          'Disconnected. Watch another ad to reconnect.',
      'statusConnected': 'Connected',
      'statusConnecting': 'Connecting…',
      'statusPreparing': 'Preparing…',
      'snackbarLimitSaved': 'Data limit saved successfully',
      'statusError': 'Error',
      'statusDisconnected': 'Disconnected',
      'selectServerToBegin': 'Select a server to begin',
      'unlockSecureAccess': 'Unlock secure access',
      'sessionRemaining': 'Session remaining',
      'noServerSelected': 'No server selected',
      'latencyLabel': 'Latency',
      'badgeConnected': 'Connected',
      'badgeSelected': 'Selected',
      'badgeConnect': 'Connect',
      'tutorialChooseLocation': 'Choose a location to route your traffic.',
      'tutorialWatchAd': 'Watch a short ad to unlock 60 minutes.',
      'tutorialSession': 'Your session time shows here.',
      'tutorialSpeed': 'Measure speed, ping, and IP.',
      'tutorialSkip': 'Skip',
      'connectionQualityTitle': 'Connection quality',
      'connectionQualityExcellent': 'Excellent connection',
      'connectionQualityGood': 'Good connection',
      'connectionQualityFair': 'Fair connection',
      'connectionQualityPoor': 'Poor connection',
      'connectionQualityOffline': 'Offline',
      'connectionQualityRefresh': 'Refresh quality',
      'homeWidgetTitle': 'Home status',
      'settingsTitle': 'Settings',
      'settingsConnection': 'Connection',
      'settingsAutoSwitch': 'Automatic server switching',
      'settingsAutoSwitchSubtitle':
          'Switch to the next location when quality drops.',
      'settingsHaptics': 'Haptic feedback',
      'settingsHapticsSubtitle': 'Vibrate on taps and actions.',
      'settingsUsage': 'Data usage',
      'settingsUsageSubtitle': 'Track estimated VPN data consumption.',
      'settingsUsageLimit': 'Monthly limit',
      'settingsUsageNoLimit': 'No monthly limit set',
      'settingsSetLimit': 'Set limit',
      'settingsResetUsage': 'Reset usage',
      'settingsRemoveLimit': 'Remove limit',
      'settingsBackup': 'Backup & restore',
      'settingsCreateBackup': 'Create backup',
      'settingsRestore': 'Restore backup',
      'settingsReferral': 'Referral program',
      'settingsReferralSubtitle': 'Share your code to earn extra time.',
      'settingsAddReferral': 'Add referral code',
      'settingsLanguage': 'Language',
      'settingsLanguageSubtitle': 'Choose your preferred language.',
      'settingsLanguageSystem': 'System',
      'settingsRewards': 'Rewards earned',
      'snackbarBackupCopied': 'Backup ready to copy.',
      'snackbarRestoreComplete': 'Preferences restored successfully.',
      'snackbarRestoreFailed': 'Restore failed. Please check the code.',
      'snackbarReferralAdded': 'Referral recorded! Reward added.',
      'snackbarLimitSaved': 'Monthly limit updated.',
      'adFailedToLoad': 'Ad failed to load. Please try again.',
      'adNotReady': 'Ad not ready. Please try again.',
      'adFailedToShow': 'Ad failed to show. Please try again.',
      'adMustComplete': 'You must complete the ad to connect.',
      'speedTestCardTitle': 'Speed test',
      'speedTestCardStart': 'Start test',
      'speedTestCardRetest': 'Run again',
      'speedTestCardTesting': 'Testing…',
      'speedTestCardLocating': 'Locating nearest site…',
      'speedTestCardDownloadWarmup': 'Warming up download…',
      'speedTestCardDownloadMeasure': 'Measuring download throughput…',
      'speedTestCardUploadWarmup': 'Warming up upload…',
      'speedTestCardUploadMeasure': 'Measuring upload throughput…',
      'speedTestCardComplete': 'Test complete',
      'speedTestCardError': 'Test failed',
      'speedTestCardDownloadLabel': 'Download',
      'speedTestCardUploadLabel': 'Upload',
      'speedTestCardLatencyLabel': 'Latency',
      'speedTestCardLossLabel': 'Loss',
      'speedTestCardServerLabel': 'Server',
      'speedTestErrorTimeout': 'Timed out while measuring. Please retry.',
      'speedTestErrorToken': 'Token expired. Please try the test again.',
      'speedTestErrorTls': 'Secure connection failed. Check your network.',
      'speedTestErrorNoResult': 'No measurement data returned.',
      'speedTestErrorGeneric': 'We could not finish the test. Please retry.',
      'navHome': 'Home',
      'navSpeedTest': 'Speed Test',
      'navHistory': 'History',
      'navSettings': 'Settings',
    },
    'es': {
      'appTitle': 'HiVPN',
      'connect': 'Conectar',
      'disconnect': 'Desconectar',
      'watchAdToStart': 'Ver anuncio para comenzar',
      'pleaseSelectServer': 'Selecciona un servidor primero.',
      'locations': 'Ubicaciones',
      'viewAll': 'Ver todo',
      'failedToLoadServers': 'No se pudieron cargar los servidores',
      'termsPrivacy': 'Términos y privacidad',
      'currentIp': 'IP actual',
      'session': 'Sesión',
      'runSpeedTest': 'Ejecuta la prueba de velocidad para medir el túnel.',
      'legalTitle': 'Legal',
      'legalBody':
          'El uso de VPN puede estar regulado en tu país. Conoce las leyes locales antes de conectarte.',
      'close': 'Cerrar',
      'sessionExpiredTitle': 'Sesión expirada',
      'sessionExpiredBody':
          'Tu sesión de 60 minutos ha terminado. Mira otro anuncio para reconectar.',
      'ok': 'Aceptar',
      'disconnectedWatchAd':
          'Desconectado. Mira otro anuncio para reconectar.',
      'statusConnected': 'Conectado',
      'statusConnecting': 'Conectando…',
      'statusPreparing': 'Preparando…',
      'statusError': 'Error',
      'statusDisconnected': 'Desconectado',
      'selectServerToBegin': 'Selecciona un servidor para comenzar',
      'unlockSecureAccess': 'Desbloquea acceso seguro',
      'sessionRemaining': 'Sesión restante',
      'noServerSelected': 'Sin servidor seleccionado',
      'latencyLabel': 'Latencia',
      'badgeConnected': 'Conectado',
      'badgeSelected': 'Seleccionado',
      'badgeConnect': 'Conectar',
      'tutorialChooseLocation': 'Elige una ubicación para tu tráfico.',
      'tutorialWatchAd': 'Mira un anuncio corto para desbloquear 60 minutos.',
      'tutorialSession': 'Tu tiempo de sesión aparece aquí.',
      'tutorialSpeed': 'Mide velocidad, ping e IP.',
      'tutorialSkip': 'Omitir',
      'connectionQualityTitle': 'Calidad de conexión',
      'connectionQualityExcellent': 'Conexión excelente',
      'connectionQualityGood': 'Conexión buena',
      'connectionQualityFair': 'Conexión regular',
      'connectionQualityPoor': 'Conexión baja',
      'connectionQualityOffline': 'Sin conexión',
      'connectionQualityRefresh': 'Actualizar calidad',
      'homeWidgetTitle': 'Estado general',
      'settingsTitle': 'Configuraciones',
      'settingsConnection': 'Conexión',
      'settingsAutoSwitch': 'Cambio automático de servidor',
      'settingsAutoSwitchSubtitle':
          'Cambiar a la siguiente ubicación cuando la calidad baje.',
      'settingsHaptics': 'Retroalimentación háptica',
      'settingsHapticsSubtitle': 'Vibrar en toques y acciones.',
      'settingsUsage': 'Uso de datos',
      'settingsUsageSubtitle': 'Sigue el consumo estimado de datos VPN.',
      'settingsUsageLimit': 'Límite mensual',
      'settingsUsageNoLimit': 'Sin límite mensual establecido',
      'settingsSetLimit': 'Definir límite',
      'settingsResetUsage': 'Restablecer uso',
      'settingsRemoveLimit': 'Eliminar límite',
      'settingsBackup': 'Copia y restauración',
      'settingsCreateBackup': 'Crear copia',
      'settingsRestore': 'Restaurar copia',
      'settingsReferral': 'Programa de referidos',
      'settingsReferralSubtitle': 'Comparte tu código para ganar tiempo extra.',
      'settingsAddReferral': 'Agregar código de referido',
      'settingsLanguage': 'Idioma',
      'settingsLanguageSubtitle': 'Elige tu idioma preferido.',
      'settingsLanguageSystem': 'Sistema',
      'settingsRewards': 'Recompensas obtenidas',
      'snackbarBackupCopied': 'Respaldo listo para copiar.',
      'snackbarRestoreComplete': 'Preferencias restauradas correctamente.',
      'snackbarRestoreFailed': 'Error al restaurar. Verifica el código.',
      'snackbarReferralAdded': '¡Referido registrado! Recompensa añadida.',
      'snackbarLimitSaved': 'Límite mensual actualizado.',
      'adFailedToLoad': 'No se pudo cargar el anuncio. Inténtalo de nuevo.',
      'adNotReady': 'El anuncio no está listo. Inténtalo de nuevo.',
      'adFailedToShow': 'El anuncio no se pudo mostrar. Inténtalo de nuevo.',
      'adMustComplete': 'Debes completar el anuncio para conectarte.',
      'speedTestCardTitle': 'Prueba de velocidad',
      'speedTestCardStart': 'Iniciar prueba',
      'speedTestCardRetest': 'Probar de nuevo',
      'speedTestCardTesting': 'Probando…',
      'speedTestCardLocating': 'Buscando el sitio más cercano…',
      'speedTestCardDownloadWarmup': 'Preparando descarga…',
      'speedTestCardDownloadMeasure': 'Midiendo descarga…',
      'speedTestCardUploadWarmup': 'Preparando subida…',
      'speedTestCardUploadMeasure': 'Midiendo subida…',
      'speedTestCardComplete': 'Prueba completada',
      'speedTestCardError': 'La prueba falló',
      'speedTestCardDownloadLabel': 'Descarga',
      'speedTestCardUploadLabel': 'Subida',
      'speedTestCardLatencyLabel': 'Latencia',
      'speedTestCardLossLabel': 'Pérdida',
      'speedTestCardServerLabel': 'Servidor',
      'speedTestErrorTimeout': 'Se agotó el tiempo de la medición. Intenta de nuevo.',
      'speedTestErrorToken': 'El token caducó. Vuelve a intentarlo.',
      'speedTestErrorTls': 'Falló la conexión segura. Revisa tu red.',
      'speedTestErrorNoResult': 'La prueba no devolvió datos.',
      'speedTestErrorGeneric': 'No pudimos finalizar la prueba. Intenta otra vez.',
      'navHome': 'Inicio',
      'navSpeedTest': 'Prueba de velocidad',
      'navHistory': 'Historial',
      'navSettings': 'Configuraciones',
    },
    'hi': {
      'appTitle': 'HiVPN',
      'connect': 'कनेक्ट करें',
      'disconnect': 'डिसकनेक्ट करें',
      'watchAdToStart': 'शुरू करने के लिए विज्ञापन देखें',
      'pleaseSelectServer': 'कृपया पहले एक सर्वर चुनें।',
      'locations': 'स्थान',
      'viewAll': 'सभी देखें',
      'failedToLoadServers': 'सर्वर लोड नहीं हो सके',
      'termsPrivacy': 'नियम व गोपनीयता',
      'currentIp': 'वर्तमान IP',
      'session': 'सत्र',
      'runSpeedTest': 'टनल विलंबता मापने के लिए स्पीड टेस्ट चलाएँ।',
      'legalTitle': 'कानूनी',
      'legalBody':
          'आपके देश में VPN उपयोग विनियमित हो सकता है। कनेक्ट करने से पहले स्थानीय कानून जानें।',
      'close': 'बंद करें',
      'sessionExpiredTitle': 'सत्र समाप्त',
      'sessionExpiredBody':
          'आपका 60 मिनट का सत्र समाप्त हो गया है। फिर से जुड़ने के लिए एक और विज्ञापन देखें।',
      'ok': 'ठीक है',
      'disconnectedWatchAd':
          'डिसकनेक्ट हो गया। फिर से जुड़ने के लिए विज्ञापन देखें।',
      'statusConnected': 'कनेक्टेड',
      'statusConnecting': 'कनेक्ट हो रहा है…',
      'statusPreparing': 'तैयारी…',
      'statusError': 'त्रुटि',
      'statusDisconnected': 'डिसकनेक्टेड',
      'selectServerToBegin': 'शुरू करने के लिए सर्वर चुनें',
      'unlockSecureAccess': 'सुरक्षित पहुंच अनलॉक करें',
      'sessionRemaining': 'शेष सत्र',
      'noServerSelected': 'कोई सर्वर चयनित नहीं',
      'latencyLabel': 'लेटेंसी',
      'badgeConnected': 'कनेक्टेड',
      'badgeSelected': 'चयनित',
      'badgeConnect': 'कनेक्ट',
      'tutorialChooseLocation': 'अपने ट्रैफिक के लिए स्थान चुनें।',
      'tutorialWatchAd': '60 मिनट अनलॉक करने के लिए विज्ञापन देखें।',
      'tutorialSession': 'यहाँ आपका सत्र समय दिखेगा।',
      'tutorialSpeed': 'गति, पिंग और IP मापें।',
      'tutorialSkip': 'स्किप करें',
      'connectionQualityTitle': 'कनेक्शन गुणवत्ता',
      'connectionQualityExcellent': 'बेहतरीन कनेक्शन',
      'connectionQualityGood': 'अच्छा कनेक्शन',
      'connectionQualityFair': 'मध्यम कनेक्शन',
      'connectionQualityPoor': 'कमज़ोर कनेक्शन',
      'connectionQualityOffline': 'ऑफ़लाइन',
      'connectionQualityRefresh': 'गुणवत्ता रिफ़्रेश करें',
      'homeWidgetTitle': 'होम स्थिति',
      'settingsTitle': 'सेटिंग्स',
      'settingsConnection': 'कनेक्शन',
      'settingsAutoSwitch': 'स्वचालित सर्वर स्विचिंग',
      'settingsAutoSwitchSubtitle':
          'गुणवत्ता कम होने पर अगले स्थान पर स्विच करें।',
      'settingsHaptics': 'हैप्टिक फीडबैक',
      'settingsHapticsSubtitle': 'टैप और क्रियाओं पर कंपन।',
      'settingsUsage': 'डेटा उपयोग',
      'settingsUsageSubtitle': 'अनुमानित VPN डेटा खपत ट्रैक करें।',
      'settingsUsageLimit': 'मासिक सीमा',
      'settingsUsageNoLimit': 'कोई मासिक सीमा सेट नहीं है',
      'settingsSetLimit': 'सीमा सेट करें',
      'settingsResetUsage': 'उपयोग रीसेट करें',
      'settingsRemoveLimit': 'सीमा हटाएं',
      'settingsBackup': 'बैकअप और पुनर्स्थापना',
      'settingsCreateBackup': 'बैकअप बनाएँ',
      'settingsRestore': 'बैकअप पुनर्स्थापित करें',
      'settingsReferral': 'रेफ़रल प्रोग्राम',
      'settingsReferralSubtitle': 'अतिरिक्त समय कमाने के लिए कोड साझा करें।',
      'settingsAddReferral': 'रेफ़रल कोड जोड़ें',
      'settingsLanguage': 'भाषा',
      'settingsLanguageSubtitle': 'अपनी पसंदीदा भाषा चुनें।',
      'settingsLanguageSystem': 'सिस्टम',
      'settingsRewards': 'कमाए गए रिवार्ड्स',
      'snackbarBackupCopied': 'बैकअप कॉपी करने के लिए तैयार है।',
      'snackbarRestoreComplete': 'प्राथमिकताएँ सफलतापूर्वक पुनर्स्थापित हुईं।',
      'snackbarRestoreFailed': 'पुनर्स्थापना विफल। कृपया कोड जाँचें।',
      'snackbarReferralAdded': 'रेफ़रल दर्ज! रिवार्ड जोड़ा गया।',
      'snackbarLimitSaved': 'मासिक सीमा अपडेट हुई।',
      'adFailedToLoad': 'विज्ञापन लोड नहीं हो सका। कृपया पुनः प्रयास करें।',
      'adNotReady': 'विज्ञापन तैयार नहीं है। कृपया पुनः प्रयास करें।',
      'adFailedToShow': 'विज्ञापन नहीं दिख सका। कृपया पुनः प्रयास करें।',
      'adMustComplete': 'कनेक्ट करने के लिए आपको विज्ञापन पूरा करना होगा।',
      'speedTestCardTitle': 'Speed test',
      'speedTestCardStart': 'Start test',
      'speedTestCardRetest': 'Run again',
      'speedTestCardTesting': 'Testing…',
      'speedTestCardLocating': 'Locating nearest site…',
      'speedTestCardDownloadWarmup': 'Warming up download…',
      'speedTestCardDownloadMeasure': 'Measuring download throughput…',
      'speedTestCardUploadWarmup': 'Warming up upload…',
      'speedTestCardUploadMeasure': 'Measuring upload throughput…',
      'speedTestCardComplete': 'Test complete',
      'speedTestCardError': 'Test failed',
      'speedTestCardDownloadLabel': 'Download',
      'speedTestCardUploadLabel': 'Upload',
      'speedTestCardLatencyLabel': 'Latency',
      'speedTestCardLossLabel': 'Loss',
      'speedTestCardServerLabel': 'Server',
      'speedTestErrorTimeout': 'Timed out while measuring. Please retry.',
      'speedTestErrorToken': 'Token expired. Please try the test again.',
      'speedTestErrorTls': 'Secure connection failed. Check your network.',
      'speedTestErrorNoResult': 'No measurement data returned.',
      'speedTestErrorGeneric': 'We could not finish the test. Please retry.',
      'navHome': 'होम',
      'navSpeedTest': 'स्पीड टेस्ट',
      'navHistory': 'इतिहास',
      'navSettings': 'सेटिंग्स',
    },
  };

  String _value(String key) {
    final language = locale.languageCode;
    if (_localizedValues.containsKey(language) &&
        _localizedValues[language]!.containsKey(key)) {
      return _localizedValues[language]![key]!;
    }
    return _localizedValues['en']![key] ?? key;
  }

  String get appTitle => _value('appTitle');
  String get connect => _value('connect');
  String get disconnect => _value('disconnect');
  String get watchAdToStart => _value('watchAdToStart');
  String get pleaseSelectServer => _value('pleaseSelectServer');
  String get locations => _value('locations');
  String get viewAll => _value('viewAll');
  String get failedToLoadServers => _value('failedToLoadServers');
  String get termsPrivacy => _value('termsPrivacy');
  String get currentIp => _value('currentIp');
  String get sessionLabel => _value('session');
  String get runSpeedTest => _value('runSpeedTest');
  String get legalTitle => _value('legalTitle');
  String get legalBody => _value('legalBody');
  String get close => _value('close');
  String get sessionExpiredTitle => _value('sessionExpiredTitle');
  String get sessionExpiredBody => _value('sessionExpiredBody');
  String get ok => _value('ok');
  String get disconnectedWatchAd => _value('disconnectedWatchAd');
  String get statusConnected => _value('statusConnected');
  String get statusConnecting => _value('statusConnecting');
  String get statusPreparing => _value('statusPreparing');
  String get statusError => _value('statusError');
  String get statusDisconnected => _value('statusDisconnected');
  String get selectServerToBegin => _value('selectServerToBegin');
  String get unlockSecureAccess => _value('unlockSecureAccess');
  String get sessionRemaining => _value('sessionRemaining');
  String get noServerSelected => _value('noServerSelected');
  String get latencyLabel => _value('latencyLabel');
  String get badgeConnected => _value('badgeConnected');
  String get badgeSelected => _value('badgeSelected');
  String get badgeConnect => _value('badgeConnect');
  String get tutorialChooseLocation => _value('tutorialChooseLocation');
  String get tutorialWatchAd => _value('tutorialWatchAd');
  String get tutorialSession => _value('tutorialSession');
  String get tutorialSpeed => _value('tutorialSpeed');
  String get tutorialSkip => _value('tutorialSkip');
  String get connectionQualityTitle => _value('connectionQualityTitle');
  String get connectionQualityRefresh => _value('connectionQualityRefresh');
  String get homeWidgetTitle => _value('homeWidgetTitle');
  String get settingsTitle => _value('settingsTitle');
  String get settingsConnection => _value('settingsConnection');
  String get settingsAutoSwitch => _value('settingsAutoSwitch');
  String get settingsAutoSwitchSubtitle => _value('settingsAutoSwitchSubtitle');
  String get settingsHaptics => _value('settingsHaptics');
  String get settingsHapticsSubtitle => _value('settingsHapticsSubtitle');
  String get settingsUsage => _value('settingsUsage');
  String get settingsUsageSubtitle => _value('settingsUsageSubtitle');
  String get settingsUsageLimit => _value('settingsUsageLimit');
  String get settingsUsageNoLimit => _value('settingsUsageNoLimit');
  String get settingsSetLimit => _value('settingsSetLimit');
  String get settingsResetUsage => _value('settingsResetUsage');
  String get settingsRemoveLimit => _value('settingsRemoveLimit');
  String get settingsBackup => _value('settingsBackup');
  String get settingsCreateBackup => _value('settingsCreateBackup');
  String get settingsRestore => _value('settingsRestore');
  String get settingsReferral => _value('settingsReferral');
  String get settingsReferralSubtitle => _value('settingsReferralSubtitle');
  String get settingsAddReferral => _value('settingsAddReferral');
  String get settingsLanguage => _value('settingsLanguage');
  String get settingsLanguageSubtitle => _value('settingsLanguageSubtitle');
  String get settingsLanguageSystem => _value('settingsLanguageSystem');
  String get settingsRewards => _value('settingsRewards');
  String get snackbarBackupCopied => _value('snackbarBackupCopied');
  String get snackbarRestoreComplete => _value('snackbarRestoreComplete');
  String get snackbarRestoreFailed => _value('snackbarRestoreFailed');
  String get snackbarReferralAdded => _value('snackbarReferralAdded');
  String get snackbarLimitSaved => _value('snackbarLimitSaved');
  String get adFailedToLoad => _value('adFailedToLoad');
  String get adNotReady => _value('adNotReady');
  String get adFailedToShow => _value('adFailedToShow');
  String get adMustComplete => _value('adMustComplete');
  String get navHome => _value('navHome');
  String get navSpeedTest => _value('navSpeedTest');
  String get navHistory => _value('navHistory');
  String get navSettings => _value('navSettings');
  String get speedTestCardTitle => _value('speedTestCardTitle');
  String get speedTestCardStart => _value('speedTestCardStart');
  String get speedTestCardRetest => _value('speedTestCardRetest');
  String get speedTestCardTesting => _value('speedTestCardTesting');
  String get speedTestCardLocating => _value('speedTestCardLocating');
  String get speedTestCardDownloadWarmup =>
      _value('speedTestCardDownloadWarmup');
  String get speedTestCardDownloadMeasure =>
      _value('speedTestCardDownloadMeasure');
  String get speedTestCardUploadWarmup =>
      _value('speedTestCardUploadWarmup');
  String get speedTestCardUploadMeasure =>
      _value('speedTestCardUploadMeasure');
  String get speedTestCardComplete => _value('speedTestCardComplete');
  String get speedTestCardError => _value('speedTestCardError');
  String get speedTestCardDownloadLabel =>
      _value('speedTestCardDownloadLabel');
  String get speedTestCardUploadLabel =>
      _value('speedTestCardUploadLabel');
  String get speedTestCardLatencyLabel =>
      _value('speedTestCardLatencyLabel');
  String get speedTestCardLossLabel => _value('speedTestCardLossLabel');
  String get speedTestCardServerLabel => _value('speedTestCardServerLabel');
  String get speedTestErrorTimeout => _value('speedTestErrorTimeout');
  String get speedTestErrorToken => _value('speedTestErrorToken');
  String get speedTestErrorTls => _value('speedTestErrorTls');
  String get speedTestErrorNoResult => _value('speedTestErrorNoResult');
  String get speedTestErrorGeneric => _value('speedTestErrorGeneric');

  String connectionQualityLabel(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return _value('connectionQualityExcellent');
      case ConnectionQuality.good:
        return _value('connectionQualityGood');
      case ConnectionQuality.fair:
        return _value('connectionQualityFair');
      case ConnectionQuality.poor:
        return _value('connectionQualityPoor');
      case ConnectionQuality.offline:
        return _value('connectionQualityOffline');
    }
  }

  String connectionQualityMetrics({
    required double download,
    required double upload,
    required int ping,
  }) {
    return '↓ ${download.toStringAsFixed(1)} Mbps · ↑ ${upload.toStringAsFixed(1)} Mbps · ${ping}ms';
  }

  String connectedCountdownLabel(String countdown) {
    return '${_value('statusConnected')}: $countdown';
  }

  String homeWidgetSessionRemaining(String remaining) {
    return '${_value('sessionRemaining')}: $remaining';
  }

  String homeWidgetQualitySummary(String qualityLabel) {
    return '${_value('connectionQualityTitle')}: $qualityLabel';
  }

  String usageSummaryText(double usedGb, double? limitGb) {
    final used = usedGb.toStringAsFixed(2);
    if (limitGb == null) {
      return '$used GB · ${settingsUsageNoLimit}';
    }
    final limit = limitGb.toStringAsFixed(2);
    return '$used GB / $limit GB';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((element) => element.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
