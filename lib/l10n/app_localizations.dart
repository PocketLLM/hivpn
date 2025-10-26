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
      'networkLocation': 'Location',
      'networkIsp': 'Internet provider',
      'networkTimezone': 'Timezone',
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
      'settingsLegal': 'Legal & privacy',
      'settingsPrivacyPolicy': 'Privacy Policy',
      'settingsPrivacyPolicySubtitle':
          'Understand how HiVPN handles diagnostics and network data.',
      'privacyPolicyDialogTitle': 'Privacy Policy',
      'privacyPolicyAgreeButton': 'I Agree',
      'privacyPolicyCheckboxLabel':
          'I have read and agree to the HiVPN Privacy Policy.',
      'privacyPolicyAvailableInSettings':
          'You can revisit this policy anytime from Settings > Privacy Policy.',
      'privacyPolicyScrollHintAction': 'Need a hint?',
      'privacyPolicyScrollHint':
          'Scroll to the end of the document to enable the agreement checkbox.',
      'privacyPolicyScrollWarning':
          'Please read to the bottom before confirming your agreement.',
      'privacyPolicyAgreementRequired':
          'You need to accept the privacy policy to continue using HiVPN.',
      'privacyPolicyCheckboxReady':
          'Thanks for reviewing! You can now check the box to continue.',
      'privacyPolicySummaryTitle': 'Summary',
      'privacyPolicySummaryBody':
          'HiVPN runs secure VPN sessions and optional speed tests powered by Measurement Lab (M-Lab). When you start a test, network performance metrics and your IP address are sent to M-Lab where results are published for public research. We do not require accounts or store persistent identifiers beyond what is needed to operate the app.',
      'privacyPolicySectionWhoWeAreTitle':
          'Who we are and what this policy covers',
      'privacyPolicySectionWhoWeAreBody':
          'HiVPN is developed by HiVPN Labs. This policy explains how we collect, use, and share information when you use the HiVPN mobile application on Android or iOS, including optional diagnostics such as speed tests.',
      'privacyPolicySectionDataTitle': 'What data the app processes',
      'privacyPolicySectionDataIntro':
          'HiVPN only processes data that is necessary to deliver VPN connectivity and performance insights. Some data stays on your device, and some is transmitted to M-Lab when you initiate a speed test.',
      'privacyPolicySectionDataLocal':
          'Local app data (processed on your device)',
      'privacyPolicySectionDataLocalItem1':
          'VPN connection status, timers, and bandwidth counters that drive the interface.',
      'privacyPolicySectionDataLocalItem2':
          'Temporary telemetry such as throughput, latency, and packet loss while a session or test is running.',
      'privacyPolicySectionDataLocalItem3':
          'Your language preference, haptic toggle, and other settings saved in secure local storage.',
      'privacyPolicySectionDataMLab':
          'Data sent to Measurement Lab (M-Lab) during speed tests',
      'privacyPolicySectionDataMLabItem1':
          'Your public IP address and the general location inferred from that IP.',
      'privacyPolicySectionDataMLabItem2':
          'Speed test performance metrics including throughput, latency (RTT), jitter, and packet loss.',
      'privacyPolicySectionDataMLabItem3':
          'Server selection information such as the M-Lab site, timestamps, and protocol metadata.',
      'privacyPolicySectionDataMLabItem4':
          'WebSocket level diagnostics required to complete the ndt7 test.',
      'privacyPolicySectionDataOptional':
          'Optional diagnostics you may share with us',
      'privacyPolicySectionDataOptionalItem1':
          'Crash or error reports you choose to send when something breaks.',
      'privacyPolicySectionDataOptionalItem2':
          'Support tickets or emails you initiate, which may include contact details.',
      'privacyPolicySectionPurposeTitle': 'How we use this data',
      'privacyPolicySectionPurposeIntro':
          'We process collected data to operate HiVPN responsibly and to help you understand your network quality.',
      'privacyPolicySectionPurposeItem1':
          'Provide and maintain secure VPN sessions and automatic server selection.',
      'privacyPolicySectionPurposeItem2':
          'Display real-time performance metrics and session timers in the app.',
      'privacyPolicySectionPurposeItem3':
          'Match you with the closest available M-Lab server for accurate diagnostics.',
      'privacyPolicySectionPurposeItem4':
          'Investigate reliability issues, prevent abuse, and improve future releases.',
      'privacyPolicySectionPermissionsTitle': 'Device permissions',
      'privacyPolicySectionPermissionsItem1':
          'Network access: required to establish VPN tunnels and run speed tests.',
      'privacyPolicySectionPermissionsItem2':
          'Wi-Fi state (optional): used locally to show you which network you are connected to.',
      'privacyPolicySectionPermissionsItem3':
          'Notifications (optional): if enabled, we may remind you when a session is about to expire.',
      'privacyPolicySectionSharingTitle': 'How we share information',
      'privacyPolicySectionSharingIntro':
          'We do not sell or rent personal data. Sharing is limited to service providers who help us run HiVPN.',
      'privacyPolicySectionSharingMLab': 'With Measurement Lab (M-Lab)',
      'privacyPolicySectionSharingMLabBody':
          'When you start a speed test, data listed above is sent directly to M-Lab. They publish all test results, including IP addresses, as part of public research datasets that cannot be retroactively removed.',
      'privacyPolicySectionSharingVendors': 'With trusted vendors',
      'privacyPolicySectionSharingVendorsBody':
          'If you opt in to crash reporting or contact support, we may use processors who are contractually bound to protect that information and only use it to assist us.',
      'privacyPolicySectionTransfersTitle': 'International transfers',
      'privacyPolicySectionTransfersBody':
          'M-Lab operates servers worldwide. Running a test may route your data to another country. For transfers from the EEA, UK, or Switzerland, we rely on Standard Contractual Clauses or equivalent safeguards.',
      'privacyPolicySectionRetentionTitle': 'Data retention',
      'privacyPolicySectionRetentionBody':
          'HiVPN keeps minimal logs on your device for up to 7 days to troubleshoot performance unless you delete them earlier. M-Lab retains and publishes speed test records indefinitely according to their policies.',
      'privacyPolicySectionRightsTitle': 'Your controls and rights',
      'privacyPolicySectionRightsIntro':
          'Your privacy rights depend on where you live, but we aim to support them wherever possible.',
      'privacyPolicySectionRightsGlobal': 'Global rights available to all users',
      'privacyPolicySectionRightsGlobalItem1':
          'Request a copy of the preferences or diagnostics HiVPN stores on your device.',
      'privacyPolicySectionRightsGlobalItem2':
          'Delete locally stored logs and reset the app from the Settings screen.',
      'privacyPolicySectionRightsGlobalItem3':
          'Withdraw consent by avoiding future speed tests or uninstalling the app.',
      'privacyPolicySectionRightsGlobalItem4':
          'Nominate a representative to contact us on your behalf.',
      'privacyPolicySectionRightsGlobalItem5':
          'Contact us with questions or complaints at privacy@hivpn.app.',
      'privacyPolicySectionRightsGDPR':
          'European Economic Area & UK (GDPR)',
      'privacyPolicySectionRightsGDPRBody':
          'Processing is based on your consent (GDPR Art. 6(1)(a)). You may request access, correction, restriction, objection, or portability by emailing privacy@hivpn.app. You can also lodge a complaint with your local supervisory authority.',
      'privacyPolicySectionRightsIndia': 'India (DPDP 2023)',
      'privacyPolicySectionRightsIndiaBody':
          'You may withdraw consent at any time, request correction or deletion of data we store locally, and appoint a nominee to exercise rights if you are incapacitated. Contact our Grievance Officer at grievance@hivpn.app.',
      'privacyPolicySectionRightsCalifornia': 'California (CCPA/CPRA)',
      'privacyPolicySectionRightsCaliforniaBody':
          'California residents can request to know, access, or delete personal information we maintain, excluding the immutable M-Lab research datasets. We do not sell or share personal information for cross-context behavioural advertising.',
      'privacyPolicySectionRightsChildren': 'Children',
      'privacyPolicySectionRightsChildrenBody':
          'HiVPN is not directed to children under 13, and we do not knowingly collect information from them. If you believe a child has used HiVPN, please contact us so we can delete their information.',
      'privacyPolicySectionSecurityTitle': 'Security practices',
      'privacyPolicySectionSecurityBody':
          'HiVPN encrypts all VPN and speed-test traffic with TLS, stores secrets securely, and limits employee access. We regularly review safeguards and patch vulnerabilities.',
      'privacyPolicySectionContactTitle': 'Contact us',
      'privacyPolicySectionContactBody':
          'Email privacy@hivpn.app for privacy questions, grievance@hivpn.app for India-specific requests, or write to HiVPN Labs, 221B Network Lane, Singapore. We will respond within 30 days.',
      'privacyPolicyFooter':
          'Last updated: April 1, 2024. References: M-Lab Privacy Policy (https://www.measurementlab.net/privacy/) and M-Lab Locate API v2 documentation (https://www.measurementlab.net/develop/locate-v2/).',
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
      'networkLocation': 'Ubicación',
      'networkIsp': 'Proveedor de internet',
      'networkTimezone': 'Zona horaria',
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
      'settingsLegal': 'Legal y privacidad',
      'settingsPrivacyPolicy': 'Política de privacidad',
      'settingsPrivacyPolicySubtitle':
          'Conoce cómo HiVPN gestiona los datos de diagnóstico y red.',
      'privacyPolicyDialogTitle': 'Política de privacidad',
      'privacyPolicyAgreeButton': 'Acepto',
      'privacyPolicyCheckboxLabel':
          'He leído y acepto la Política de privacidad de HiVPN.',
      'privacyPolicyAvailableInSettings':
          'Puedes volver a consultar esta política en Configuración > Política de privacidad.',
      'privacyPolicyScrollHintAction': '¿Necesitas ayuda?',
      'privacyPolicyScrollHint':
          'Desplázate hasta el final del documento para activar la casilla de aceptación.',
      'privacyPolicyScrollWarning':
          'Lee hasta la parte inferior antes de confirmar tu aceptación.',
      'privacyPolicyAgreementRequired':
          'Debes aceptar la política de privacidad para seguir usando HiVPN.',
      'privacyPolicyCheckboxReady':
          '¡Gracias por revisar! Ahora puedes marcar la casilla para continuar.',
      'privacyPolicySummaryTitle': 'Resumen',
      'privacyPolicySummaryBody':
          'HiVPN ejecuta sesiones VPN seguras y pruebas de velocidad opcionales impulsadas por Measurement Lab (M-Lab). Cuando inicias una prueba, las métricas de rendimiento de red y tu dirección IP se envían a M-Lab, donde los resultados se publican para la investigación pública. No requerimos cuentas ni almacenamos identificadores persistentes más allá de lo necesario para operar la app.',
      'privacyPolicySectionWhoWeAreTitle':
          'Quiénes somos y qué cubre esta política',
      'privacyPolicySectionWhoWeAreBody':
          'HiVPN es desarrollado por HiVPN Labs. Esta política explica cómo recopilamos, usamos y compartimos información cuando utilizas la aplicación móvil HiVPN en Android o iOS, incluidas las pruebas de velocidad opcionales.',
      'privacyPolicySectionDataTitle': 'Qué datos procesa la app',
      'privacyPolicySectionDataIntro':
          'HiVPN solo procesa los datos necesarios para ofrecer conectividad VPN y métricas de rendimiento. Parte de la información permanece en tu dispositivo y otra se envía a M-Lab cuando inicias una prueba de velocidad.',
      'privacyPolicySectionDataLocal':
          'Datos locales de la app (procesados en tu dispositivo)',
      'privacyPolicySectionDataLocalItem1':
          'Estado de la conexión VPN, temporizadores y contadores de ancho de banda que alimentan la interfaz.',
      'privacyPolicySectionDataLocalItem2':
          'Telemetría temporal como rendimiento, latencia y pérdida de paquetes mientras se ejecuta una sesión o prueba.',
      'privacyPolicySectionDataLocalItem3':
          'Tu idioma preferido, la vibración y otros ajustes guardados de forma segura en el almacenamiento local.',
      'privacyPolicySectionDataMLab':
          'Datos enviados a Measurement Lab (M-Lab) durante las pruebas de velocidad',
      'privacyPolicySectionDataMLabItem1':
          'Tu dirección IP pública y la ubicación general inferida a partir de ella.',
      'privacyPolicySectionDataMLabItem2':
          'Métricas de rendimiento como velocidad, latencia (RTT), fluctuación y pérdida de paquetes.',
      'privacyPolicySectionDataMLabItem3':
          'Información sobre el servidor como el sitio de M-Lab, marcas de tiempo y metadatos del protocolo.',
      'privacyPolicySectionDataMLabItem4':
          'Diagnósticos a nivel WebSocket necesarios para completar la prueba ndt7.',
      'privacyPolicySectionDataOptional':
          'Datos opcionales que puedes compartir con nosotros',
      'privacyPolicySectionDataOptionalItem1':
          'Informes de fallos o errores que decides enviar cuando algo no funciona.',
      'privacyPolicySectionDataOptionalItem2':
          'Solicitudes de soporte o correos que nos envías y que pueden incluir datos de contacto.',
      'privacyPolicySectionPurposeTitle': 'Cómo usamos estos datos',
      'privacyPolicySectionPurposeIntro':
          'Procesamos los datos recopilados para operar HiVPN de forma responsable y ayudarte a entender la calidad de tu red.',
      'privacyPolicySectionPurposeItem1':
          'Ofrecer y mantener sesiones VPN seguras y selección automática de servidores.',
      'privacyPolicySectionPurposeItem2':
          'Mostrar métricas de rendimiento en tiempo real y temporizadores dentro de la app.',
      'privacyPolicySectionPurposeItem3':
          'Emparejarte con el servidor de M-Lab más cercano para diagnósticos precisos.',
      'privacyPolicySectionPurposeItem4':
          'Investigar problemas de confiabilidad, prevenir abusos y mejorar futuras versiones.',
      'privacyPolicySectionPermissionsTitle': 'Permisos del dispositivo',
      'privacyPolicySectionPermissionsItem1':
          'Acceso a la red: necesario para establecer túneles VPN y ejecutar pruebas de velocidad.',
      'privacyPolicySectionPermissionsItem2':
          'Estado de Wi-Fi (opcional): se usa localmente para mostrar a qué red estás conectado.',
      'privacyPolicySectionPermissionsItem3':
          'Notificaciones (opcional): si están activadas, podemos avisarte cuando una sesión esté por expirar.',
      'privacyPolicySectionSharingTitle': 'Cómo compartimos la información',
      'privacyPolicySectionSharingIntro':
          'No vendemos ni alquilamos datos personales. Solo compartimos con proveedores que nos ayudan a operar HiVPN.',
      'privacyPolicySectionSharingMLab': 'Con Measurement Lab (M-Lab)',
      'privacyPolicySectionSharingMLabBody':
          'Cuando inicias una prueba de velocidad, los datos anteriores se envían directamente a M-Lab. Ellos publican todos los resultados, incluidas las direcciones IP, como parte de conjuntos de datos públicos que no pueden eliminarse retroactivamente.',
      'privacyPolicySectionSharingVendors': 'Con proveedores de confianza',
      'privacyPolicySectionSharingVendorsBody':
          'Si aceptas enviar informes de fallos o contactas soporte, podemos utilizar encargados que están obligados contractualmente a proteger esa información y usarla solo para ayudarnos.',
      'privacyPolicySectionTransfersTitle': 'Transferencias internacionales',
      'privacyPolicySectionTransfersBody':
          'M-Lab opera servidores en todo el mundo. Una prueba puede enrutar tus datos a otro país. Para transferencias desde el EEE, el Reino Unido o Suiza usamos Cláusulas Contractuales Tipo u otras salvaguardas equivalentes.',
      'privacyPolicySectionRetentionTitle': 'Conservación de datos',
      'privacyPolicySectionRetentionBody':
          'HiVPN conserva registros mínimos en tu dispositivo hasta 7 días para resolver incidencias, a menos que los elimines antes. M-Lab conserva y publica los resultados de las pruebas de velocidad de forma indefinida según sus políticas.',
      'privacyPolicySectionRightsTitle': 'Tus controles y derechos',
      'privacyPolicySectionRightsIntro':
          'Tus derechos de privacidad dependen de tu jurisdicción, pero procuramos respaldarlos siempre que sea posible.',
      'privacyPolicySectionRightsGlobal': 'Derechos globales disponibles para todos',
      'privacyPolicySectionRightsGlobalItem1':
          'Solicitar una copia de las preferencias o diagnósticos que HiVPN guarda en tu dispositivo.',
      'privacyPolicySectionRightsGlobalItem2':
          'Borrar los registros almacenados localmente y restablecer la app desde Configuración.',
      'privacyPolicySectionRightsGlobalItem3':
          'Retirar el consentimiento evitando futuras pruebas de velocidad o desinstalando la app.',
      'privacyPolicySectionRightsGlobalItem4':
          'Nombrar a un representante que se comunique con nosotros en tu nombre.',
      'privacyPolicySectionRightsGlobalItem5':
          'Contactarnos con preguntas o reclamaciones en privacy@hivpn.app.',
      'privacyPolicySectionRightsGDPR':
          'Espacio Económico Europeo y Reino Unido (RGPD)',
      'privacyPolicySectionRightsGDPRBody':
          'El tratamiento se basa en tu consentimiento (art. 6.1.a RGPD). Puedes solicitar acceso, rectificación, limitación, oposición o portabilidad escribiendo a privacy@hivpn.app. También puedes presentar una reclamación ante tu autoridad de control.',
      'privacyPolicySectionRightsIndia': 'India (DPDP 2023)',
      'privacyPolicySectionRightsIndiaBody':
          'Puedes retirar el consentimiento en cualquier momento, solicitar corrección o eliminación de los datos locales y nombrar a un representante si no puedes ejercer tus derechos. Contacta a nuestro responsable en grievance@hivpn.app.',
      'privacyPolicySectionRightsCalifornia': 'California (CCPA/CPRA)',
      'privacyPolicySectionRightsCaliforniaBody':
          'Los residentes en California pueden solicitar conocer, acceder o eliminar la información personal que conservamos, excluyendo los conjuntos de datos de investigación inmutables de M-Lab. No vendemos ni compartimos información personal para publicidad contextual.',
      'privacyPolicySectionRightsChildren': 'Menores',
      'privacyPolicySectionRightsChildrenBody':
          'HiVPN no está dirigido a menores de 13 años y no recopilamos deliberadamente información de ellos. Si crees que un menor usó HiVPN, contáctanos para eliminar sus datos.',
      'privacyPolicySectionSecurityTitle': 'Prácticas de seguridad',
      'privacyPolicySectionSecurityBody':
          'HiVPN cifra todo el tráfico VPN y de pruebas de velocidad con TLS, protege las credenciales y limita el acceso del personal. Revisamos periódicamente las medidas y aplicamos parches.',
      'privacyPolicySectionContactTitle': 'Contacto',
      'privacyPolicySectionContactBody':
          'Escríbenos a privacy@hivpn.app para temas de privacidad, a grievance@hivpn.app para solicitudes en India, o a HiVPN Labs, 221B Network Lane, Singapur. Responderemos en un máximo de 30 días.',
      'privacyPolicyFooter':
          'Última actualización: 1 de abril de 2024. Referencias: Política de privacidad de M-Lab (https://www.measurementlab.net/privacy/) y documentación de la API Locate v2 de M-Lab (https://www.measurementlab.net/develop/locate-v2/).',
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
      'networkLocation': 'स्थान',
      'networkIsp': 'इंटरनेट प्रदाता',
      'networkTimezone': 'समय क्षेत्र',
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
      'settingsLegal': 'कानूनी और गोपनीयता',
      'settingsPrivacyPolicy': 'गोपनीयता नीति',
      'settingsPrivacyPolicySubtitle':
          'जानें कि HiVPN निदान और नेटवर्क डेटा को कैसे संभालता है।',
      'privacyPolicyDialogTitle': 'गोपनीयता नीति',
      'privacyPolicyAgreeButton': 'मैं सहमत हूँ',
      'privacyPolicyCheckboxLabel':
          'मैंने HiVPN गोपनीयता नीति पढ़ ली है और सहमत हूँ।',
      'privacyPolicyAvailableInSettings':
          'आप इसे कभी भी सेटिंग्स > गोपनीयता नीति से फिर से देख सकते हैं।',
      'privacyPolicyScrollHintAction': 'संकेत चाहिए?',
      'privacyPolicyScrollHint':
          'स्वीकृति चेकबॉक्स सक्षम करने के लिए दस्तावेज़ के अंत तक स्क्रॉल करें।',
      'privacyPolicyScrollWarning':
          'कृपया सहमति देने से पहले पूरी सामग्री पढ़ें।',
      'privacyPolicyAgreementRequired':
          'HiVPN का उपयोग जारी रखने के लिए आपको गोपनीयता नीति स्वीकार करनी होगी।',
      'privacyPolicyCheckboxReady':
          'समीक्षा के लिए धन्यवाद! अब आप बॉक्स चेक कर सकते हैं।',
      'privacyPolicySummaryTitle': 'सारांश',
      'privacyPolicySummaryBody':
          'HiVPN सुरक्षित VPN सत्र और Measurement Lab (M-Lab) द्वारा संचालित वैकल्पिक स्पीड टेस्ट चलाता है। जब आप टेस्ट शुरू करते हैं तो नेटवर्क प्रदर्शन माप और आपका IP पता M-Lab को भेजा जाता है और शोध हेतु प्रकाशित होता है। हम खाते की आवश्यकता नहीं रखते और ऐप चलाने के लिए जरूरी से अधिक स्थायी पहचानकर्ता संग्रहीत नहीं करते।',
      'privacyPolicySectionWhoWeAreTitle':
          'हम कौन हैं और यह नीति क्या कवर करती है',
      'privacyPolicySectionWhoWeAreBody':
          'HiVPN, HiVPN Labs द्वारा विकसित किया गया है। यह नीति बताती है कि जब आप Android या iOS पर HiVPN मोबाइल ऐप और इसकी वैकल्पिक स्पीड टेस्ट सुविधा का उपयोग करते हैं तो हम डेटा कैसे एकत्र, उपयोग और साझा करते हैं।',
      'privacyPolicySectionDataTitle': 'ऐप कौन सा डेटा संसाधित करता है',
      'privacyPolicySectionDataIntro':
          'HiVPN केवल वही डेटा संसाधित करता है जो VPN कनेक्टिविटी और प्रदर्शन जानकारी प्रदान करने के लिए आवश्यक है। कुछ जानकारी आपके डिवाइस पर रहती है और कुछ स्पीड टेस्ट शुरू करने पर M-Lab को भेजी जाती है।',
      'privacyPolicySectionDataLocal':
          'स्थानीय ऐप डेटा (आपके डिवाइस पर संसाधित)',
      'privacyPolicySectionDataLocalItem1':
          'VPN कनेक्शन की स्थिति, टाइमर और बैंडविड्थ काउंटर जो इंटरफ़ेस को संचालित करते हैं।',
      'privacyPolicySectionDataLocalItem2':
          'सत्र या टेस्ट के दौरान प्राप्त थ्रूपुट, विलंबता और पैकेट लॉस जैसी अस्थायी टेलीमेट्री।',
      'privacyPolicySectionDataLocalItem3':
          'आपकी भाषा, हैप्टिक विकल्प और अन्य सेटिंग्स जो सुरक्षित स्थानीय संग्रह में सहेजी जाती हैं।',
      'privacyPolicySectionDataMLab':
          'स्पीड टेस्ट के दौरान M-Lab को भेजा गया डेटा',
      'privacyPolicySectionDataMLabItem1':
          'आपका सार्वजनिक IP पता और उससे अनुमानित सामान्य स्थान।',
      'privacyPolicySectionDataMLabItem2':
          'थ्रूपुट, विलंबता (RTT), जिटर और पैकेट लॉस सहित प्रदर्शन मेट्रिक्स।',
      'privacyPolicySectionDataMLabItem3':
          'M-Lab साइट, टाइमस्टैम्प और प्रोटोकॉल मेटाडेटा जैसी सर्वर चयन जानकारी।',
      'privacyPolicySectionDataMLabItem4':
          'ndt7 टेस्ट को पूरा करने के लिए आवश्यक वेब-सॉकेट स्तर के निदान।',
      'privacyPolicySectionDataOptional':
          'वैकल्पिक निदान जिन्हें आप साझा कर सकते हैं',
      'privacyPolicySectionDataOptionalItem1':
          'क्रैश या त्रुटि रिपोर्ट जिन्हें आप समस्या होने पर भेजना चुनते हैं।',
      'privacyPolicySectionDataOptionalItem2':
          'सपोर्ट टिकट या ईमेल जो आप हमें भेजते हैं और जिनमें संपर्क विवरण हो सकते हैं।',
      'privacyPolicySectionPurposeTitle': 'हम इन डेटा का उपयोग कैसे करते हैं',
      'privacyPolicySectionPurposeIntro':
          'हम HiVPN को जिम्मेदारी से संचालित करने और आपकी नेटवर्क गुणवत्ता समझाने के लिए एकत्रित डेटा का उपयोग करते हैं।',
      'privacyPolicySectionPurposeItem1':
          'सुरक्षित VPN सत्र और स्वचालित सर्वर चयन प्रदान करना और बनाए रखना।',
      'privacyPolicySectionPurposeItem2':
          'ऐप में वास्तविक समय के प्रदर्शन मेट्रिक्स और सत्र टाइमर दिखाना।',
      'privacyPolicySectionPurposeItem3':
          'सटीक निदान के लिए आपको निकटतम उपलब्ध M-Lab सर्वर से जोड़ना।',
      'privacyPolicySectionPurposeItem4':
          'विश्वसनीयता समस्याओं की जांच करना, दुरुपयोग रोकना और भविष्य के संस्करणों में सुधार करना।',
      'privacyPolicySectionPermissionsTitle': 'डिवाइस अनुमतियाँ',
      'privacyPolicySectionPermissionsItem1':
          'नेटवर्क एक्सेस: VPN टनल स्थापित करने और स्पीड टेस्ट चलाने के लिए आवश्यक।',
      'privacyPolicySectionPermissionsItem2':
          'Wi-Fi स्थिति (वैकल्पिक): केवल स्थानीय रूप से उपयोग होती है ताकि हम आपको दिखा सकें कि आप किस नेटवर्क से जुड़े हैं।',
      'privacyPolicySectionPermissionsItem3':
          'सूचनाएँ (वैकल्पिक): सक्षम होने पर हम आपको सत्र समाप्ति की याद दिला सकते हैं।',
      'privacyPolicySectionSharingTitle': 'हम जानकारी कैसे साझा करते हैं',
      'privacyPolicySectionSharingIntro':
          'हम व्यक्तिगत डेटा नहीं बेचते या किराए पर नहीं देते। साझा करना केवल उन प्रदाताओं तक सीमित है जो HiVPN चलाने में मदद करते हैं।',
      'privacyPolicySectionSharingMLab': 'Measurement Lab (M-Lab) के साथ',
      'privacyPolicySectionSharingMLabBody':
          'जब आप स्पीड टेस्ट शुरू करते हैं तो ऊपर सूचीबद्ध डेटा सीधे M-Lab को भेजा जाता है। वे सभी परिणामों को, IP पतों सहित, सार्वजनिक शोध डेटा के रूप में प्रकाशित करते हैं जिन्हें बाद में हटाया नहीं जा सकता।',
      'privacyPolicySectionSharingVendors': 'विश्वसनीय विक्रेताओं के साथ',
      'privacyPolicySectionSharingVendorsBody':
          'यदि आप क्रैश रिपोर्ट भेजते हैं या समर्थन से संपर्क करते हैं तो हम ऐसे प्रोसेसर का उपयोग कर सकते हैं जो अनुबंध के अनुसार उस जानकारी की रक्षा करेंगे और केवल हमारी सहायता के लिए उसका उपयोग करेंगे।',
      'privacyPolicySectionTransfersTitle': 'अंतर्राष्ट्रीय डेटा अंतरण',
      'privacyPolicySectionTransfersBody':
          'M-Lab विश्वभर में सर्वर संचालित करता है, इसलिए एक टेस्ट आपके डेटा को किसी अन्य देश में भेज सकता है। EEA, UK या स्विट्ज़रलैंड से होने वाले अंतरणों के लिए हम मानक अनुबंध खंडों या समान सुरक्षा उपायों पर भरोसा करते हैं।',
      'privacyPolicySectionRetentionTitle': 'डेटा प्रतिधारण',
      'privacyPolicySectionRetentionBody':
          'HiVPN आपके डिवाइस पर प्रदर्शन समस्या सुलझाने के लिए अधिकतम 7 दिनों तक न्यूनतम लॉग रखता है, जब तक आप उन्हें पहले न हटा दें। M-Lab अपनी नीतियों के अनुसार स्पीड टेस्ट रिकॉर्ड को अनिश्चितकाल तक प्रकाशित करता है।',
      'privacyPolicySectionRightsTitle': 'आपके नियंत्रण और अधिकार',
      'privacyPolicySectionRightsIntro':
          'आपके गोपनीयता अधिकार आपके स्थान पर निर्भर करते हैं, लेकिन हम जहाँ संभव हो उनका समर्थन करने का प्रयास करते हैं।',
      'privacyPolicySectionRightsGlobal': 'सभी उपयोगकर्ताओं के लिए उपलब्ध वैश्विक अधिकार',
      'privacyPolicySectionRightsGlobalItem1':
          'उन प्राथमिकताओं या निदान की प्रतिलिपि माँगें जिन्हें HiVPN आपके डिवाइस पर सहेजता है।',
      'privacyPolicySectionRightsGlobalItem2':
          'सेटिंग्स स्क्रीन से स्थानीय लॉग हटाएँ और ऐप रीसेट करें।',
      'privacyPolicySectionRightsGlobalItem3':
          'भविष्य के स्पीड टेस्ट से बचकर या ऐप हटाकर सहमति वापस लें।',
      'privacyPolicySectionRightsGlobalItem4':
          'अपने behalf पर हमसे संपर्क करने के लिए किसी प्रतिनिधि को नामित करें।',
      'privacyPolicySectionRightsGlobalItem5':
          'प्रश्न या शिकायत के लिए privacy@hivpn.app पर लिखें।',
      'privacyPolicySectionRightsGDPR':
          'यूरोपीय आर्थिक क्षेत्र और यूनाइटेड किंगडम (GDPR)',
      'privacyPolicySectionRightsGDPRBody':
          'प्रसंस्करण आपका सहमति (GDPR अनुच्छेद 6(1)(a)) पर आधारित है। आप privacy@hivpn.app पर ईमेल करके प्रवेश, संशोधन, प्रतिबंध, आपत्ति या पोर्टेबिलिटी का अनुरोध कर सकते हैं और अपने स्थानीय पर्यवेक्षी प्राधिकरण से शिकायत कर सकते हैं।',
      'privacyPolicySectionRightsIndia': 'भारत (DPDP 2023)',
      'privacyPolicySectionRightsIndiaBody':
          'आप किसी भी समय सहमति वापस ले सकते हैं, स्थानीय रूप से संग्रहीत डेटा के सुधार या हटाने का अनुरोध कर सकते हैं और अधिकारों का प्रयोग करने के लिए नामांकित व्यक्ति नियुक्त कर सकते हैं। grievance@hivpn.app पर हमारे शिकायत अधिकारी से संपर्क करें।',
      'privacyPolicySectionRightsCalifornia': 'कैलिफ़ोर्निया (CCPA/CPRA)',
      'privacyPolicySectionRightsCaliforniaBody':
          'कैलिफ़ोर्निया निवासी हमारे पास मौजूद व्यक्तिगत जानकारी को जानने, एक्सेस करने या हटाने का अनुरोध कर सकते हैं, जिसमें M-Lab के अपरिवर्तनीय शोध डेटा शामिल नहीं हैं। हम व्यक्तिगत जानकारी को क्रॉस-संदर्भ विज्ञापन के लिए नहीं बेचते या साझा करते।',
      'privacyPolicySectionRightsChildren': 'बच्चे',
      'privacyPolicySectionRightsChildrenBody':
          'HiVPN का लक्ष्य 13 वर्ष से कम उम्र के बच्चों पर नहीं है और हम उनकी जानकारी जानबूझकर एकत्र नहीं करते। यदि आपको लगता है कि किसी बच्चे ने HiVPN का उपयोग किया है, तो कृपया हमें सूचित करें ताकि हम उसकी जानकारी हटा सकें।',
      'privacyPolicySectionSecurityTitle': 'सुरक्षा उपाय',
      'privacyPolicySectionSecurityBody':
          'HiVPN सभी VPN और स्पीड-टेस्ट ट्रैफ़िक को TLS के साथ एन्क्रिप्ट करता है, क्रेडेंशियल्स को सुरक्षित रखता है और कर्मचारी पहुँच को सीमित करता है। हम नियमित रूप से सुरक्षा उपायों की समीक्षा करते हैं और कमजोरियों को पैच करते हैं।',
      'privacyPolicySectionContactTitle': 'हमसे संपर्क करें',
      'privacyPolicySectionContactBody':
          'गोपनीयता से जुड़े प्रश्नों के लिए privacy@hivpn.app पर, भारत से संबंधित अनुरोधों के लिए grievance@hivpn.app पर, या HiVPN Labs, 221B Network Lane, सिंगापुर पर लिखें। हम 30 दिनों के भीतर उत्तर देंगे।',
      'privacyPolicyFooter':
          'अंतिम अपडेट: 1 अप्रैल 2024। संदर्भ: M-Lab गोपनीयता नीति (https://www.measurementlab.net/privacy/) और M-Lab Locate API v2 दस्तावेज़ (https://www.measurementlab.net/develop/locate-v2/).',
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
  String get networkLocation => _value('networkLocation');
  String get networkIsp => _value('networkIsp');
  String get networkTimezone => _value('networkTimezone');
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
  String get settingsLegal => _value('settingsLegal');
  String get settingsPrivacyPolicy => _value('settingsPrivacyPolicy');
  String get settingsPrivacyPolicySubtitle =>
      _value('settingsPrivacyPolicySubtitle');
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
  String get privacyPolicyDialogTitle => _value('privacyPolicyDialogTitle');
  String get privacyPolicyAgreeButton => _value('privacyPolicyAgreeButton');
  String get privacyPolicyCheckboxLabel =>
      _value('privacyPolicyCheckboxLabel');
  String get privacyPolicyAvailableInSettings =>
      _value('privacyPolicyAvailableInSettings');
  String get privacyPolicyScrollHintAction =>
      _value('privacyPolicyScrollHintAction');
  String get privacyPolicyScrollHint => _value('privacyPolicyScrollHint');
  String get privacyPolicyScrollWarning =>
      _value('privacyPolicyScrollWarning');
  String get privacyPolicyAgreementRequired =>
      _value('privacyPolicyAgreementRequired');
  String get privacyPolicyCheckboxReady =>
      _value('privacyPolicyCheckboxReady');
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
