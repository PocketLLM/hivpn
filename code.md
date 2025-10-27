└── lib
    ├── apis
        └── apis.dart
    ├── controllers
        ├── home_controller.dart
        ├── location_controller.dart
        └── native_ad_controller.dart
    ├── firebase_options.dart
    ├── helpers
        ├── ad_helper.dart
        ├── config.dart
        ├── my_dialogs.dart
        └── pref.dart
    ├── main.dart
    ├── models
        ├── ip_details.dart
        ├── network_data.dart
        ├── vpn.dart
        ├── vpn_config.dart
        └── vpn_status.dart
    ├── screens
        ├── home_screen.dart
        ├── location_screen.dart
        ├── network_test_screen.dart
        └── splash_screen.dart
    ├── services
        └── vpn_engine.dart
    └── widgets
        ├── count_down_timer.dart
        ├── home_card.dart
        ├── network_card.dart
        ├── vpn_card.dart
        └── watch_ad_dialog.dart


/lib/apis/apis.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:convert';
 2 | import 'dart:developer';
 3 | 
 4 | import 'package:csv/csv.dart';
 5 | import 'package:get/get.dart';
 6 | import 'package:http/http.dart';
 7 | 
 8 | import '../helpers/my_dialogs.dart';
 9 | import '../helpers/pref.dart';
10 | import '../models/ip_details.dart';
11 | import '../models/vpn.dart';
12 | 
13 | class APIs {
14 |   static Future<List<Vpn>> getVPNServers() async {
15 |     final List<Vpn> vpnList = [];
16 | 
17 |     try {
18 |       final res = await get(Uri.parse('http://www.vpngate.net/api/iphone/'));
19 |       final csvString = res.body.split("#")[1].replaceAll('*', '');
20 | 
21 |       List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
22 | 
23 |       final header = list[0];
24 | 
25 |       for (int i = 1; i < list.length - 1; ++i) {
26 |         Map<String, dynamic> tempJson = {};
27 | 
28 |         for (int j = 0; j < header.length; ++j) {
29 |           tempJson.addAll({header[j].toString(): list[i][j]});
30 |         }
31 |         vpnList.add(Vpn.fromJson(tempJson));
32 |       }
33 |     } catch (e) {
34 |       MyDialogs.error(msg: e.toString());
35 |       log('\ngetVPNServersE: $e');
36 |     }
37 |     vpnList.shuffle();
38 | 
39 |     if (vpnList.isNotEmpty) Pref.vpnList = vpnList;
40 | 
41 |     return vpnList;
42 |   }
43 | 
44 |   static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
45 |     try {
46 |       final res = await get(Uri.parse('http://ip-api.com/json/'));
47 |       final data = jsonDecode(res.body);
48 |       log(data.toString());
49 |       ipData.value = IPDetails.fromJson(data);
50 |     } catch (e) {
51 |       MyDialogs.error(msg: e.toString());
52 |       log('\ngetIPDetailsE: $e');
53 |     }
54 |   }
55 | }
56 | 
57 | // Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36
58 | 
59 | // For Understanding Purpose
60 | 
61 | //*** CSV Data ***
62 | // Name,    Country,  Ping
63 | // Test1,   JP,       12
64 | // Test2,   US,       112
65 | // Test3,   IN,       7
66 | 
67 | //*** List Data ***
68 | // [ [Name, Country, Ping], [Test1, JP, 12], [Test2, US, 112], [Test3, IN, 7] ]
69 | 
70 | //*** Json Data ***
71 | // {"Name": "Test1", "Country": "JP", "Ping": 12}
72 | 
73 | 


--------------------------------------------------------------------------------
/lib/controllers/home_controller.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:convert';
 2 | 
 3 | import 'package:flutter/material.dart';
 4 | import 'package:get/get.dart';
 5 | 
 6 | import '../helpers/ad_helper.dart';
 7 | import '../helpers/my_dialogs.dart';
 8 | import '../helpers/pref.dart';
 9 | import '../models/vpn.dart';
10 | import '../models/vpn_config.dart';
11 | import '../services/vpn_engine.dart';
12 | 
13 | class HomeController extends GetxController {
14 |   final Rx<Vpn> vpn = Pref.vpn.obs;
15 | 
16 |   final vpnState = VpnEngine.vpnDisconnected.obs;
17 | 
18 |   void connectToVpn() async {
19 |     if (vpn.value.openVPNConfigDataBase64.isEmpty) {
20 |       MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
21 |       return;
22 |     }
23 | 
24 |     if (vpnState.value == VpnEngine.vpnDisconnected) {
25 |       // log('\nBefore: ${vpn.value.openVPNConfigDataBase64}');
26 | 
27 |       final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
28 |       final config = Utf8Decoder().convert(data);
29 |       final vpnConfig = VpnConfig(
30 |           country: vpn.value.countryLong,
31 |           username: 'vpn',
32 |           password: 'vpn',
33 |           config: config);
34 | 
35 |       // log('\nAfter: $config');
36 | 
37 |       //code to show interstitial ad and then connect to vpn
38 |       AdHelper.showInterstitialAd(onComplete: () async {
39 |         await VpnEngine.startVpn(vpnConfig);
40 |       });
41 |     } else {
42 |       await VpnEngine.stopVpn();
43 |     }
44 |   }
45 | 
46 |   // vpn buttons color
47 |   Color get getButtonColor {
48 |     switch (vpnState.value) {
49 |       case VpnEngine.vpnDisconnected:
50 |         return Colors.blue;
51 | 
52 |       case VpnEngine.vpnConnected:
53 |         return Colors.green;
54 | 
55 |       default:
56 |         return Colors.orangeAccent;
57 |     }
58 |   }
59 | 
60 |   // vpn button text
61 |   String get getButtonText {
62 |     switch (vpnState.value) {
63 |       case VpnEngine.vpnDisconnected:
64 |         return 'Tap to Connect';
65 | 
66 |       case VpnEngine.vpnConnected:
67 |         return 'Disconnect';
68 | 
69 |       default:
70 |         return 'Connecting...';
71 |     }
72 |   }
73 | }
74 | 


--------------------------------------------------------------------------------
/lib/controllers/location_controller.dart:
--------------------------------------------------------------------------------
 1 | import 'package:get/get.dart';
 2 | 
 3 | import '../apis/apis.dart';
 4 | import '../helpers/pref.dart';
 5 | import '../models/vpn.dart';
 6 | 
 7 | class LocationController extends GetxController {
 8 |   List<Vpn> vpnList = Pref.vpnList;
 9 | 
10 |   final RxBool isLoading = false.obs;
11 | 
12 |   Future<void> getVpnData() async {
13 |     isLoading.value = true;
14 |     vpnList.clear();
15 |     vpnList = await APIs.getVPNServers();
16 |     isLoading.value = false;
17 |   }
18 | }
19 | 


--------------------------------------------------------------------------------
/lib/controllers/native_ad_controller.dart:
--------------------------------------------------------------------------------
1 | import 'package:get/get.dart';
2 | import 'package:google_mobile_ads/google_mobile_ads.dart';
3 | 
4 | class NativeAdController extends GetxController {
5 |   NativeAd? ad;
6 |   final adLoaded = false.obs;
7 | }
8 | 


--------------------------------------------------------------------------------
/lib/firebase_options.dart:
--------------------------------------------------------------------------------
 1 | // File generated by FlutterFire CLI.
 2 | // ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
 3 | import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
 4 | import 'package:flutter/foundation.dart'
 5 |     show defaultTargetPlatform, kIsWeb, TargetPlatform;
 6 | 
 7 | /// Default [FirebaseOptions] for use with your Firebase apps.
 8 | ///
 9 | /// Example:
10 | /// ```dart
11 | /// import 'firebase_options.dart';
12 | /// // ...
13 | /// await Firebase.initializeApp(
14 | ///   options: DefaultFirebaseOptions.currentPlatform,
15 | /// );
16 | /// ```
17 | class DefaultFirebaseOptions {
18 |   static FirebaseOptions get currentPlatform {
19 |     if (kIsWeb) {
20 |       throw UnsupportedError(
21 |         'DefaultFirebaseOptions have not been configured for web - '
22 |         'you can reconfigure this by running the FlutterFire CLI again.',
23 |       );
24 |     }
25 |     switch (defaultTargetPlatform) {
26 |       case TargetPlatform.android:
27 |         return android;
28 |       case TargetPlatform.iOS:
29 |         throw UnsupportedError(
30 |           'DefaultFirebaseOptions have not been configured for ios - '
31 |           'you can reconfigure this by running the FlutterFire CLI again.',
32 |         );
33 |       case TargetPlatform.macOS:
34 |         throw UnsupportedError(
35 |           'DefaultFirebaseOptions have not been configured for macos - '
36 |           'you can reconfigure this by running the FlutterFire CLI again.',
37 |         );
38 |       case TargetPlatform.windows:
39 |         throw UnsupportedError(
40 |           'DefaultFirebaseOptions have not been configured for windows - '
41 |           'you can reconfigure this by running the FlutterFire CLI again.',
42 |         );
43 |       case TargetPlatform.linux:
44 |         throw UnsupportedError(
45 |           'DefaultFirebaseOptions have not been configured for linux - '
46 |           'you can reconfigure this by running the FlutterFire CLI again.',
47 |         );
48 |       default:
49 |         throw UnsupportedError(
50 |           'DefaultFirebaseOptions are not supported for this platform.',
51 |         );
52 |     }
53 |   }
54 | 
55 |   static const FirebaseOptions android = FirebaseOptions(
56 |     apiKey: 'AIzaSyB278a0ik31BTSL3w2tgMgSgQQJj7avakM',
57 |     appId: '1:480415667223:android:6a5177701d3e4bb2e63852',
58 |     messagingSenderId: '480415667223',
59 |     projectId: 'freevpn-flutter',
60 |     storageBucket: 'freevpn-flutter.appspot.com',
61 |   );
62 | 
63 | }


--------------------------------------------------------------------------------
/lib/helpers/ad_helper.dart:
--------------------------------------------------------------------------------
  1 | import 'dart:developer';
  2 | 
  3 | import 'package:flutter/foundation.dart';
  4 | import 'package:get/get.dart';
  5 | import 'package:google_mobile_ads/google_mobile_ads.dart';
  6 | 
  7 | import '../controllers/native_ad_controller.dart';
  8 | import 'config.dart';
  9 | import 'my_dialogs.dart';
 10 | 
 11 | class AdHelper {
 12 |   // for initializing ads sdk
 13 |   static Future<void> initAds() async {
 14 |     await MobileAds.instance.initialize();
 15 |   }
 16 | 
 17 |   static InterstitialAd? _interstitialAd;
 18 |   static bool _interstitialAdLoaded = false;
 19 | 
 20 |   static NativeAd? _nativeAd;
 21 |   static bool _nativeAdLoaded = false;
 22 | 
 23 |   //*****************Interstitial Ad******************
 24 | 
 25 |   static void precacheInterstitialAd() {
 26 |     log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');
 27 | 
 28 |     if (Config.hideAds) return;
 29 | 
 30 |     InterstitialAd.load(
 31 |       adUnitId: Config.interstitialAd,
 32 |       request: AdRequest(),
 33 |       adLoadCallback: InterstitialAdLoadCallback(
 34 |         onAdLoaded: (ad) {
 35 |           //ad listener
 36 |           ad.fullScreenContentCallback =
 37 |               FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
 38 |             _resetInterstitialAd();
 39 |             precacheInterstitialAd();
 40 |           });
 41 |           _interstitialAd = ad;
 42 |           _interstitialAdLoaded = true;
 43 |         },
 44 |         onAdFailedToLoad: (err) {
 45 |           _resetInterstitialAd();
 46 |           log('Failed to load an interstitial ad: ${err.message}');
 47 |         },
 48 |       ),
 49 |     );
 50 |   }
 51 | 
 52 |   static void _resetInterstitialAd() {
 53 |     _interstitialAd?.dispose();
 54 |     _interstitialAd = null;
 55 |     _interstitialAdLoaded = false;
 56 |   }
 57 | 
 58 |   static void showInterstitialAd({required VoidCallback onComplete}) {
 59 |     log('Interstitial Ad Id: ${Config.interstitialAd}');
 60 | 
 61 |     if (Config.hideAds) {
 62 |       onComplete();
 63 |       return;
 64 |     }
 65 | 
 66 |     if (_interstitialAdLoaded && _interstitialAd != null) {
 67 |       _interstitialAd?.show();
 68 |       onComplete();
 69 |       return;
 70 |     }
 71 | 
 72 |     MyDialogs.showProgress();
 73 | 
 74 |     InterstitialAd.load(
 75 |       adUnitId: Config.interstitialAd,
 76 |       request: AdRequest(),
 77 |       adLoadCallback: InterstitialAdLoadCallback(
 78 |         onAdLoaded: (ad) {
 79 |           //ad listener
 80 |           ad.fullScreenContentCallback =
 81 |               FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
 82 |             onComplete();
 83 |             _resetInterstitialAd();
 84 |             precacheInterstitialAd();
 85 |           });
 86 |           Get.back();
 87 |           ad.show();
 88 |         },
 89 |         onAdFailedToLoad: (err) {
 90 |           Get.back();
 91 |           log('Failed to load an interstitial ad: ${err.message}');
 92 |           onComplete();
 93 |         },
 94 |       ),
 95 |     );
 96 |   }
 97 | 
 98 |   //*****************Native Ad******************
 99 | 
100 |   static void precacheNativeAd() {
101 |     log('Precache Native Ad - Id: ${Config.nativeAd}');
102 | 
103 |     if (Config.hideAds) return;
104 | 
105 |     _nativeAd = NativeAd(
106 |         adUnitId: Config.nativeAd,
107 |         listener: NativeAdListener(
108 |           onAdLoaded: (ad) {
109 |             log('$NativeAd loaded.');
110 |             _nativeAdLoaded = true;
111 |           },
112 |           onAdFailedToLoad: (ad, error) {
113 |             _resetNativeAd();
114 |             log('$NativeAd failed to load: $error');
115 |           },
116 |         ),
117 |         request: const AdRequest(),
118 |         // Styling
119 |         nativeTemplateStyle:
120 |             NativeTemplateStyle(templateType: TemplateType.small))
121 |       ..load();
122 |   }
123 | 
124 |   static void _resetNativeAd() {
125 |     _nativeAd?.dispose();
126 |     _nativeAd = null;
127 |     _nativeAdLoaded = false;
128 |   }
129 | 
130 |   static NativeAd? loadNativeAd({required NativeAdController adController}) {
131 |     log('Native Ad Id: ${Config.nativeAd}');
132 | 
133 |     if (Config.hideAds) return null;
134 | 
135 |     if (_nativeAdLoaded && _nativeAd != null) {
136 |       adController.adLoaded.value = true;
137 |       return _nativeAd;
138 |     }
139 | 
140 |     return NativeAd(
141 |         adUnitId: Config.nativeAd,
142 |         listener: NativeAdListener(
143 |           onAdLoaded: (ad) {
144 |             log('$NativeAd loaded.');
145 |             adController.adLoaded.value = true;
146 |             _resetNativeAd();
147 |             precacheNativeAd();
148 |           },
149 |           onAdFailedToLoad: (ad, error) {
150 |             _resetNativeAd();
151 |             log('$NativeAd failed to load: $error');
152 |           },
153 |         ),
154 |         request: const AdRequest(),
155 |         // Styling
156 |         nativeTemplateStyle:
157 |             NativeTemplateStyle(templateType: TemplateType.small))
158 |       ..load();
159 |   }
160 | 
161 |   //*****************Rewarded Ad******************
162 | 
163 |   static void showRewardedAd({required VoidCallback onComplete}) {
164 |     log('Rewarded Ad Id: ${Config.rewardedAd}');
165 | 
166 |     if (Config.hideAds) {
167 |       onComplete();
168 |       return;
169 |     }
170 | 
171 |     MyDialogs.showProgress();
172 | 
173 |     RewardedAd.load(
174 |       adUnitId: Config.rewardedAd,
175 |       request: AdRequest(),
176 |       rewardedAdLoadCallback: RewardedAdLoadCallback(
177 |         onAdLoaded: (ad) {
178 |           Get.back();
179 | 
180 |           //reward listener
181 |           ad.show(
182 |               onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
183 |             onComplete();
184 |           });
185 |         },
186 |         onAdFailedToLoad: (err) {
187 |           Get.back();
188 |           log('Failed to load an interstitial ad: ${err.message}');
189 |           // onComplete();
190 |         },
191 |       ),
192 |     );
193 |   }
194 | }
195 | 


--------------------------------------------------------------------------------
/lib/helpers/config.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:developer';
 2 | 
 3 | import 'package:firebase_remote_config/firebase_remote_config.dart';
 4 | 
 5 | class Config {
 6 |   static final _config = FirebaseRemoteConfig.instance;
 7 | 
 8 |   static const _defaultValues = {
 9 |     "interstitial_ad": "ca-app-pub-3940256099942544/1033173712",
10 |     "native_ad": "ca-app-pub-3940256099942544/2247696110",
11 |     "rewarded_ad": "ca-app-pub-3940256099942544/5224354917",
12 |     "show_ads": true
13 |   };
14 | 
15 |   static Future<void> initConfig() async {
16 |     await _config.setConfigSettings(RemoteConfigSettings(
17 |         fetchTimeout: const Duration(minutes: 1),
18 |         minimumFetchInterval: const Duration(minutes: 30)));
19 | 
20 |     await _config.setDefaults(_defaultValues);
21 |     await _config.fetchAndActivate();
22 |     log('Remote Config Data: ${_config.getBool('show_ads')}');
23 | 
24 |     _config.onConfigUpdated.listen((event) async {
25 |       await _config.activate();
26 |       log('Updated: ${_config.getBool('show_ads')}');
27 |     });
28 |   }
29 | 
30 |   static bool get _showAd => _config.getBool('show_ads');
31 | 
32 |   //ad ids
33 |   static String get nativeAd => _config.getString('native_ad');
34 |   static String get interstitialAd => _config.getString('interstitial_ad');
35 |   static String get rewardedAd => _config.getString('rewarded_ad');
36 | 
37 |   static bool get hideAds => !_showAd;
38 | }
39 | 


--------------------------------------------------------------------------------
/lib/helpers/my_dialogs.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | import 'package:get/get.dart';
 3 | 
 4 | class MyDialogs {
 5 |   static success({required String msg}) {
 6 |     Get.snackbar('Success', msg,
 7 |         colorText: Colors.white, backgroundColor: Colors.green.withOpacity(.9));
 8 |   }
 9 | 
10 |   static error({required String msg}) {
11 |     Get.snackbar('Error', msg,
12 |         colorText: Colors.white,
13 |         backgroundColor: Colors.redAccent.withOpacity(.9));
14 |   }
15 | 
16 |   static info({required String msg}) {
17 |     Get.snackbar('Info', msg, colorText: Colors.white);
18 |   }
19 | 
20 |   static showProgress() {
21 |     Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
22 |   }
23 | }
24 | 


--------------------------------------------------------------------------------
/lib/helpers/pref.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:convert';
 2 | 
 3 | import 'package:hive_flutter/hive_flutter.dart';
 4 | 
 5 | import '../models/vpn.dart';
 6 | 
 7 | class Pref {
 8 |   static late Box _box;
 9 | 
10 |   static Future<void> initializeHive() async {
11 |     await Hive.initFlutter();
12 |     _box = await Hive.openBox('data');
13 |   }
14 | 
15 |   //for storing theme data
16 |   static bool get isDarkMode => _box.get('isDarkMode') ?? false;
17 |   static set isDarkMode(bool v) => _box.put('isDarkMode', v);
18 | 
19 |   //for storing single selected vpn details
20 |   static Vpn get vpn => Vpn.fromJson(jsonDecode(_box.get('vpn') ?? '{}'));
21 |   static set vpn(Vpn v) => _box.put('vpn', jsonEncode(v));
22 | 
23 |   //for storing vpn servers details
24 |   static List<Vpn> get vpnList {
25 |     List<Vpn> temp = [];
26 |     final data = jsonDecode(_box.get('vpnList') ?? '[]');
27 | 
28 |     for (var i in data) temp.add(Vpn.fromJson(i));
29 | 
30 |     return temp;
31 |   }
32 | 
33 |   static set vpnList(List<Vpn> v) => _box.put('vpnList', jsonEncode(v));
34 | }
35 | 


--------------------------------------------------------------------------------
/lib/main.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | import 'package:flutter/services.dart';
 3 | import 'package:get/get.dart';
 4 | import 'package:firebase_core/firebase_core.dart';
 5 | 
 6 | import 'helpers/ad_helper.dart';
 7 | import 'helpers/config.dart';
 8 | import 'helpers/pref.dart';
 9 | import 'screens/splash_screen.dart';
10 | 
11 | //global object for accessing device screen size
12 | late Size mq;
13 | 
14 | Future<void> main() async {
15 |   WidgetsFlutterBinding.ensureInitialized();
16 | 
17 |   //enter full-screen
18 |   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
19 | 
20 |   //firebase initialization
21 |   await Firebase.initializeApp();
22 | 
23 |   //initializing remote config
24 |   await Config.initConfig();
25 | 
26 |   await Pref.initializeHive();
27 | 
28 |   await AdHelper.initAds();
29 | 
30 |   //for setting orientation to portrait only
31 |   await SystemChrome.setPreferredOrientations(
32 |       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
33 |     runApp(const MyApp());
34 |   });
35 | }
36 | 
37 | class MyApp extends StatelessWidget {
38 |   const MyApp({super.key});
39 | 
40 |   @override
41 |   Widget build(BuildContext context) {
42 |     return GetMaterialApp(
43 |       title: 'OpenVpn Demo',
44 |       home: SplashScreen(),
45 | 
46 |       //theme
47 |       theme: ThemeData(
48 |         appBarTheme: AppBarTheme(centerTitle: true, elevation: 3),
49 |         useMaterial3: false,
50 |       ),
51 | 
52 |       themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
53 | 
54 |       //dark theme
55 |       darkTheme: ThemeData(
56 |           brightness: Brightness.dark,
57 |           useMaterial3: false,
58 |           appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
59 | 
60 |       debugShowCheckedModeBanner: false,
61 |     );
62 |   }
63 | }
64 | 
65 | extension AppTheme on ThemeData {
66 |   Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
67 |   Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.blue;
68 | }
69 | 


--------------------------------------------------------------------------------
/lib/models/ip_details.dart:
--------------------------------------------------------------------------------
 1 | class IPDetails {
 2 |   late final String country;
 3 |   late final String regionName;
 4 |   late final String city;
 5 |   late final String zip;
 6 |   late final String timezone;
 7 |   late final String isp;
 8 |   late final String query;
 9 | 
10 |   IPDetails({
11 |     required this.country,
12 |     required this.regionName,
13 |     required this.city,
14 |     required this.zip,
15 |     required this.timezone,
16 |     required this.isp,
17 |     required this.query,
18 |   });
19 | 
20 |   IPDetails.fromJson(Map<String, dynamic> json) {
21 |     country = json['country'] ?? '';
22 |     regionName = json['regionName'] ?? '';
23 |     city = json['city'] ?? '';
24 |     zip = json['zip'] ?? ' - - - - ';
25 |     timezone = json['timezone'] ?? 'Unknown';
26 |     isp = json['isp'] ?? 'Unknown';
27 |     query = json['query'] ?? 'Not available';
28 |   }
29 | }
30 | 


--------------------------------------------------------------------------------
/lib/models/network_data.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | 
 3 | class NetworkData {
 4 |   String title, subtitle;
 5 |   Icon icon;
 6 | 
 7 |   NetworkData(
 8 |       {required this.title, required this.subtitle, required this.icon});
 9 | }
10 | 


--------------------------------------------------------------------------------
/lib/models/vpn.dart:
--------------------------------------------------------------------------------
 1 | class Vpn {
 2 |   late final String hostname;
 3 |   late final String ip;
 4 |   late final String ping;
 5 |   late final int speed;
 6 |   late final String countryLong;
 7 |   late final String countryShort;
 8 |   late final int numVpnSessions;
 9 |   late final String openVPNConfigDataBase64;
10 | 
11 |   Vpn(
12 |       {required this.hostname,
13 |       required this.ip,
14 |       required this.ping,
15 |       required this.speed,
16 |       required this.countryLong,
17 |       required this.countryShort,
18 |       required this.numVpnSessions,
19 |       required this.openVPNConfigDataBase64});
20 | 
21 |   Vpn.fromJson(Map<String, dynamic> json) {
22 |     hostname = json['HostName'] ?? '';
23 |     ip = json['IP'] ?? '';
24 |     ping = json['Ping'].toString();
25 |     speed = json['Speed'] ?? 0;
26 |     countryLong = json['CountryLong'] ?? '';
27 |     countryShort = json['CountryShort'] ?? '';
28 |     numVpnSessions = json['NumVpnSessions'] ?? 0;
29 | 
30 |     openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
31 |   }
32 | 
33 |   Map<String, dynamic> toJson() {
34 |     final data = <String, dynamic>{};
35 |     data['HostName'] = hostname;
36 |     data['IP'] = ip;
37 |     data['Ping'] = ping;
38 |     data['Speed'] = speed;
39 |     data['CountryLong'] = countryLong;
40 |     data['CountryShort'] = countryShort;
41 |     data['NumVpnSessions'] = numVpnSessions;
42 |     data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
43 |     return data;
44 |   }
45 | }
46 | 


--------------------------------------------------------------------------------
/lib/models/vpn_config.dart:
--------------------------------------------------------------------------------
 1 | class VpnConfig {
 2 |   VpnConfig({
 3 |     required this.country,
 4 |     required this.username,
 5 |     required this.password,
 6 |     required this.config,
 7 |   });
 8 | 
 9 |   final String country;
10 |   final String username;
11 |   final String password;
12 |   final String config;
13 | }
14 | 


--------------------------------------------------------------------------------
/lib/models/vpn_status.dart:
--------------------------------------------------------------------------------
 1 | class VpnStatus {
 2 |   VpnStatus({this.duration, this.lastPacketReceive, this.byteIn, this.byteOut});
 3 | 
 4 |   String? duration;
 5 |   String? lastPacketReceive;
 6 |   String? byteIn;
 7 |   String? byteOut;
 8 | 
 9 |   factory VpnStatus.fromJson(Map<String, dynamic> json) => VpnStatus(
10 |         duration: json['duration'],
11 |         lastPacketReceive: json['last_packet_receive'],
12 |         byteIn: json['byte_in'],
13 |         byteOut: json['byte_out'],
14 |       );
15 | 
16 |   Map<String, dynamic> toJson() => {
17 |         'duration': duration,
18 |         'last_packet_receive': lastPacketReceive,
19 |         'byte_in': byteIn,
20 |         'byte_out': byteOut
21 |       };
22 | }
23 | 


--------------------------------------------------------------------------------
/lib/screens/home_screen.dart:
--------------------------------------------------------------------------------
  1 | import 'package:flutter/cupertino.dart';
  2 | import 'package:flutter/material.dart';
  3 | import 'package:get/get.dart';
  4 | 
  5 | import '../controllers/home_controller.dart';
  6 | import '../helpers/ad_helper.dart';
  7 | import '../helpers/config.dart';
  8 | import '../helpers/pref.dart';
  9 | import '../main.dart';
 10 | import '../models/vpn_status.dart';
 11 | import '../services/vpn_engine.dart';
 12 | import '../widgets/count_down_timer.dart';
 13 | import '../widgets/home_card.dart';
 14 | import '../widgets/watch_ad_dialog.dart';
 15 | import 'location_screen.dart';
 16 | import 'network_test_screen.dart';
 17 | 
 18 | class HomeScreen extends StatelessWidget {
 19 |   HomeScreen({super.key});
 20 | 
 21 |   final _controller = Get.put(HomeController());
 22 | 
 23 |   @override
 24 |   Widget build(BuildContext context) {
 25 |     mq = MediaQuery.sizeOf(context);
 26 | 
 27 |     ///Add listener to update vpn state
 28 |     VpnEngine.vpnStageSnapshot().listen((event) {
 29 |       _controller.vpnState.value = event;
 30 |     });
 31 | 
 32 |     return Scaffold(
 33 |       //app bar
 34 |       appBar: AppBar(
 35 |         leading: Icon(CupertinoIcons.home),
 36 |         title: Text('Free OpenVPN'),
 37 |         actions: [
 38 |           IconButton(
 39 |               onPressed: () {
 40 |                 //ad dialog
 41 | 
 42 |                 if (Config.hideAds) {
 43 |                   Get.changeThemeMode(
 44 |                       Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
 45 |                   Pref.isDarkMode = !Pref.isDarkMode;
 46 |                   return;
 47 |                 }
 48 | 
 49 |                 Get.dialog(WatchAdDialog(onComplete: () {
 50 |                   //watch ad to gain reward
 51 |                   AdHelper.showRewardedAd(onComplete: () {
 52 |                     Get.changeThemeMode(
 53 |                         Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
 54 |                     Pref.isDarkMode = !Pref.isDarkMode;
 55 |                   });
 56 |                 }));
 57 |               },
 58 |               icon: Icon(
 59 |                 Icons.brightness_medium,
 60 |                 size: 26,
 61 |               )),
 62 |           IconButton(
 63 |               padding: EdgeInsets.only(right: 8),
 64 |               onPressed: () => Get.to(() => NetworkTestScreen()),
 65 |               icon: Icon(
 66 |                 CupertinoIcons.info,
 67 |                 size: 27,
 68 |               )),
 69 |         ],
 70 |       ),
 71 | 
 72 |       bottomNavigationBar: _changeLocation(context),
 73 | 
 74 |       //body
 75 |       body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
 76 |         //vpn button
 77 |         Obx(() => _vpnButton()),
 78 | 
 79 |         Obx(
 80 |           () => Row(
 81 |             mainAxisAlignment: MainAxisAlignment.center,
 82 |             children: [
 83 |               //country flag
 84 |               HomeCard(
 85 |                   title: _controller.vpn.value.countryLong.isEmpty
 86 |                       ? 'Country'
 87 |                       : _controller.vpn.value.countryLong,
 88 |                   subtitle: 'FREE',
 89 |                   icon: CircleAvatar(
 90 |                     radius: 30,
 91 |                     backgroundColor: Colors.blue,
 92 |                     child: _controller.vpn.value.countryLong.isEmpty
 93 |                         ? Icon(Icons.vpn_lock_rounded,
 94 |                             size: 30, color: Colors.white)
 95 |                         : null,
 96 |                     backgroundImage: _controller.vpn.value.countryLong.isEmpty
 97 |                         ? null
 98 |                         : AssetImage(
 99 |                             'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
100 |                   )),
101 | 
102 |               //ping time
103 |               HomeCard(
104 |                   title: _controller.vpn.value.countryLong.isEmpty
105 |                       ? '100 ms'
106 |                       : '${_controller.vpn.value.ping} ms',
107 |                   subtitle: 'PING',
108 |                   icon: CircleAvatar(
109 |                     radius: 30,
110 |                     backgroundColor: Colors.orange,
111 |                     child: Icon(Icons.equalizer_rounded,
112 |                         size: 30, color: Colors.white),
113 |                   )),
114 |             ],
115 |           ),
116 |         ),
117 | 
118 |         StreamBuilder<VpnStatus?>(
119 |             initialData: VpnStatus(),
120 |             stream: VpnEngine.vpnStatusSnapshot(),
121 |             builder: (context, snapshot) => Row(
122 |                   mainAxisAlignment: MainAxisAlignment.center,
123 |                   children: [
124 |                     //download
125 |                     HomeCard(
126 |                         title: '${snapshot.data?.byteIn ?? '0 kbps'}',
127 |                         subtitle: 'DOWNLOAD',
128 |                         icon: CircleAvatar(
129 |                           radius: 30,
130 |                           backgroundColor: Colors.lightGreen,
131 |                           child: Icon(Icons.arrow_downward_rounded,
132 |                               size: 30, color: Colors.white),
133 |                         )),
134 | 
135 |                     //upload
136 |                     HomeCard(
137 |                         title: '${snapshot.data?.byteOut ?? '0 kbps'}',
138 |                         subtitle: 'UPLOAD',
139 |                         icon: CircleAvatar(
140 |                           radius: 30,
141 |                           backgroundColor: Colors.blue,
142 |                           child: Icon(Icons.arrow_upward_rounded,
143 |                               size: 30, color: Colors.white),
144 |                         )),
145 |                   ],
146 |                 ))
147 |       ]),
148 |     );
149 |   }
150 | 
151 |   //vpn button
152 |   Widget _vpnButton() => Column(
153 |         children: [
154 |           //button
155 |           Semantics(
156 |             button: true,
157 |             child: InkWell(
158 |               onTap: () {
159 |                 _controller.connectToVpn();
160 |               },
161 |               borderRadius: BorderRadius.circular(100),
162 |               child: Container(
163 |                 padding: EdgeInsets.all(16),
164 |                 decoration: BoxDecoration(
165 |                     shape: BoxShape.circle,
166 |                     color: _controller.getButtonColor.withOpacity(.1)),
167 |                 child: Container(
168 |                   padding: EdgeInsets.all(16),
169 |                   decoration: BoxDecoration(
170 |                       shape: BoxShape.circle,
171 |                       color: _controller.getButtonColor.withOpacity(.3)),
172 |                   child: Container(
173 |                     width: mq.height * .14,
174 |                     height: mq.height * .14,
175 |                     decoration: BoxDecoration(
176 |                         shape: BoxShape.circle,
177 |                         color: _controller.getButtonColor),
178 |                     child: Column(
179 |                       mainAxisAlignment: MainAxisAlignment.center,
180 |                       children: [
181 |                         //icon
182 |                         Icon(
183 |                           Icons.power_settings_new,
184 |                           size: 28,
185 |                           color: Colors.white,
186 |                         ),
187 | 
188 |                         SizedBox(height: 4),
189 | 
190 |                         //text
191 |                         Text(
192 |                           _controller.getButtonText,
193 |                           style: TextStyle(
194 |                               fontSize: 12.5,
195 |                               color: Colors.white,
196 |                               fontWeight: FontWeight.w500),
197 |                         )
198 |                       ],
199 |                     ),
200 |                   ),
201 |                 ),
202 |               ),
203 |             ),
204 |           ),
205 | 
206 |           //connection status label
207 |           Container(
208 |             margin:
209 |                 EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
210 |             padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
211 |             decoration: BoxDecoration(
212 |                 color: Colors.blue, borderRadius: BorderRadius.circular(15)),
213 |             child: Text(
214 |               _controller.vpnState.value == VpnEngine.vpnDisconnected
215 |                   ? 'Not Connected'
216 |                   : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
217 |               style: TextStyle(fontSize: 12.5, color: Colors.white),
218 |             ),
219 |           ),
220 | 
221 |           //count down timer
222 |           Obx(() => CountDownTimer(
223 |               startTimer:
224 |                   _controller.vpnState.value == VpnEngine.vpnConnected)),
225 |         ],
226 |       );
227 | 
228 |   //bottom nav to change location
229 |   Widget _changeLocation(BuildContext context) => SafeArea(
230 |           child: Semantics(
231 |         button: true,
232 |         child: InkWell(
233 |           onTap: () => Get.to(() => LocationScreen()),
234 |           child: Container(
235 |               color: Theme.of(context).bottomNav,
236 |               padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
237 |               height: 60,
238 |               child: Row(
239 |                 children: [
240 |                   //icon
241 |                   Icon(CupertinoIcons.globe, color: Colors.white, size: 28),
242 | 
243 |                   //for adding some space
244 |                   SizedBox(width: 10),
245 | 
246 |                   //text
247 |                   Text(
248 |                     'Change Location',
249 |                     style: TextStyle(
250 |                         color: Colors.white,
251 |                         fontSize: 18,
252 |                         fontWeight: FontWeight.w500),
253 |                   ),
254 | 
255 |                   //for covering available spacing
256 |                   Spacer(),
257 | 
258 |                   //icon
259 |                   CircleAvatar(
260 |                     backgroundColor: Colors.white,
261 |                     child: Icon(Icons.keyboard_arrow_right_rounded,
262 |                         color: Colors.blue, size: 26),
263 |                   )
264 |                 ],
265 |               )),
266 |         ),
267 |       ));
268 | }
269 | 


--------------------------------------------------------------------------------
/lib/screens/location_screen.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/cupertino.dart';
 2 | import 'package:flutter/material.dart';
 3 | import 'package:get/get.dart';
 4 | import 'package:google_mobile_ads/google_mobile_ads.dart';
 5 | import 'package:lottie/lottie.dart';
 6 | 
 7 | import '../controllers/location_controller.dart';
 8 | import '../controllers/native_ad_controller.dart';
 9 | import '../helpers/ad_helper.dart';
10 | import '../main.dart';
11 | import '../widgets/vpn_card.dart';
12 | 
13 | class LocationScreen extends StatelessWidget {
14 |   LocationScreen({super.key});
15 | 
16 |   final _controller = LocationController();
17 |   final _adController = NativeAdController();
18 | 
19 |   @override
20 |   Widget build(BuildContext context) {
21 |     if (_controller.vpnList.isEmpty) _controller.getVpnData();
22 | 
23 |     _adController.ad = AdHelper.loadNativeAd(adController: _adController);
24 | 
25 |     return Obx(
26 |       () => Scaffold(
27 |         //app bar
28 |         appBar: AppBar(
29 |           title: Text('VPN Locations (${_controller.vpnList.length})'),
30 |         ),
31 | 
32 |         bottomNavigationBar:
33 |             // Config.hideAds ? null:
34 |             _adController.ad != null && _adController.adLoaded.isTrue
35 |                 ? SafeArea(
36 |                     child: SizedBox(
37 |                         height: 85, child: AdWidget(ad: _adController.ad!)))
38 |                 : null,
39 | 
40 |         //refresh button
41 |         floatingActionButton: Padding(
42 |           padding: const EdgeInsets.only(bottom: 10, right: 10),
43 |           child: FloatingActionButton(
44 |               onPressed: () => _controller.getVpnData(),
45 |               child: Icon(CupertinoIcons.refresh)),
46 |         ),
47 | 
48 |         body: _controller.isLoading.value
49 |             ? _loadingWidget()
50 |             : _controller.vpnList.isEmpty
51 |                 ? _noVPNFound()
52 |                 : _vpnData(),
53 |       ),
54 |     );
55 |   }
56 | 
57 |   _vpnData() => ListView.builder(
58 |       itemCount: _controller.vpnList.length,
59 |       physics: BouncingScrollPhysics(),
60 |       padding: EdgeInsets.only(
61 |           top: mq.height * .015,
62 |           bottom: mq.height * .1,
63 |           left: mq.width * .04,
64 |           right: mq.width * .04),
65 |       itemBuilder: (ctx, i) => VpnCard(vpn: _controller.vpnList[i]));
66 | 
67 |   _loadingWidget() => SizedBox(
68 |         width: double.infinity,
69 |         height: double.infinity,
70 |         child: Column(
71 |           mainAxisAlignment: MainAxisAlignment.center,
72 |           children: [
73 |             //lottie animation
74 |             LottieBuilder.asset('assets/lottie/loading.json',
75 |                 width: mq.width * .7),
76 | 
77 |             //text
78 |             Text(
79 |               'Loading VPNs... 😌',
80 |               style: TextStyle(
81 |                   fontSize: 18,
82 |                   color: Colors.black54,
83 |                   fontWeight: FontWeight.bold),
84 |             )
85 |           ],
86 |         ),
87 |       );
88 | 
89 |   _noVPNFound() => Center(
90 |         child: Text(
91 |           'VPNs Not Found! 😔',
92 |           style: TextStyle(
93 |               fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
94 |         ),
95 |       );
96 | }
97 | 


--------------------------------------------------------------------------------
/lib/screens/network_test_screen.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/cupertino.dart';
 2 | import 'package:flutter/material.dart';
 3 | import 'package:get/get.dart';
 4 | 
 5 | import '../apis/apis.dart';
 6 | import '../main.dart';
 7 | import '../models/ip_details.dart';
 8 | import '../models/network_data.dart';
 9 | import '../widgets/network_card.dart';
10 | 
11 | class NetworkTestScreen extends StatelessWidget {
12 |   const NetworkTestScreen({super.key});
13 | 
14 |   @override
15 |   Widget build(BuildContext context) {
16 |     final ipData = IPDetails.fromJson({}).obs;
17 |     APIs.getIPDetails(ipData: ipData);
18 | 
19 |     return Scaffold(
20 |       appBar: AppBar(title: Text('Network Test Screen')),
21 | 
22 |       //refresh button
23 |       floatingActionButton: Padding(
24 |         padding: const EdgeInsets.only(bottom: 10, right: 10),
25 |         child: FloatingActionButton(
26 |             onPressed: () {
27 |               ipData.value = IPDetails.fromJson({});
28 |               APIs.getIPDetails(ipData: ipData);
29 |             },
30 |             child: Icon(CupertinoIcons.refresh)),
31 |       ),
32 | 
33 |       body: Obx(
34 |         () => ListView(
35 |             physics: BouncingScrollPhysics(),
36 |             padding: EdgeInsets.only(
37 |                 left: mq.width * .04,
38 |                 right: mq.width * .04,
39 |                 top: mq.height * .01,
40 |                 bottom: mq.height * .1),
41 |             children: [
42 |               //ip
43 |               NetworkCard(
44 |                   data: NetworkData(
45 |                       title: 'IP Address',
46 |                       subtitle: ipData.value.query,
47 |                       icon: Icon(CupertinoIcons.location_solid,
48 |                           color: Colors.blue))),
49 | 
50 |               //isp
51 |               NetworkCard(
52 |                   data: NetworkData(
53 |                       title: 'Internet Provider',
54 |                       subtitle: ipData.value.isp,
55 |                       icon: Icon(Icons.business, color: Colors.orange))),
56 | 
57 |               //location
58 |               NetworkCard(
59 |                   data: NetworkData(
60 |                       title: 'Location',
61 |                       subtitle: ipData.value.country.isEmpty
62 |                           ? 'Fetching ...'
63 |                           : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
64 |                       icon: Icon(CupertinoIcons.location, color: Colors.pink))),
65 | 
66 |               //pin code
67 |               NetworkCard(
68 |                   data: NetworkData(
69 |                       title: 'Pin-code',
70 |                       subtitle: ipData.value.zip,
71 |                       icon: Icon(CupertinoIcons.location_solid,
72 |                           color: Colors.cyan))),
73 | 
74 |               //timezone
75 |               NetworkCard(
76 |                   data: NetworkData(
77 |                       title: 'Timezone',
78 |                       subtitle: ipData.value.timezone,
79 |                       icon: Icon(CupertinoIcons.time, color: Colors.green))),
80 |             ]),
81 |       ),
82 |     );
83 |   }
84 | }
85 | 


--------------------------------------------------------------------------------
/lib/screens/splash_screen.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | import 'package:flutter/services.dart';
 3 | import 'package:get/route_manager.dart';
 4 | 
 5 | import '../helpers/ad_helper.dart';
 6 | import '../main.dart';
 7 | import 'home_screen.dart';
 8 | 
 9 | class SplashScreen extends StatefulWidget {
10 |   const SplashScreen({super.key});
11 | 
12 |   @override
13 |   State<SplashScreen> createState() => _SplashScreenState();
14 | }
15 | 
16 | class _SplashScreenState extends State<SplashScreen> {
17 |   @override
18 |   void initState() {
19 |     super.initState();
20 |     Future.delayed(Duration(milliseconds: 1500), () {
21 |       //exit full-screen
22 |       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
23 | 
24 |       AdHelper.precacheInterstitialAd();
25 |       AdHelper.precacheNativeAd();
26 | 
27 |       //navigate to home
28 |       Get.off(() => HomeScreen());
29 |       // Navigator.pushReplacement(
30 |       //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
31 |     });
32 |   }
33 | 
34 |   @override
35 |   Widget build(BuildContext context) {
36 |     //initializing media query (for getting device screen size)
37 |     mq = MediaQuery.of(context).size;
38 | 
39 |     return Scaffold(
40 |       body: Stack(
41 |         children: [
42 |           //app logo
43 |           Positioned(
44 |               left: mq.width * .3,
45 |               top: mq.height * .2,
46 |               width: mq.width * .4,
47 |               child: Image.asset('assets/images/logo.png')),
48 | 
49 |           //label
50 |           Positioned(
51 |               bottom: mq.height * .15,
52 |               width: mq.width,
53 |               child: Text(
54 |                 'MADE IN INDIA WITH ❤️',
55 |                 textAlign: TextAlign.center,
56 |                 style: TextStyle(
57 |                     color: Theme.of(context).lightText, letterSpacing: 1),
58 |               ))
59 |         ],
60 |       ),
61 |     );
62 |   }
63 | }
64 | 


--------------------------------------------------------------------------------
/lib/services/vpn_engine.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:convert';
 2 | 
 3 | import 'package:flutter/services.dart';
 4 | 
 5 | import '../models/vpn_config.dart';
 6 | import '../models/vpn_status.dart';
 7 | 
 8 | class VpnEngine {
 9 |   ///Channel to native
10 |   static final String _eventChannelVpnStage = "vpnStage";
11 |   static final String _eventChannelVpnStatus = "vpnStatus";
12 |   static final String _methodChannelVpnControl = "vpnControl";
13 | 
14 |   ///Snapshot of VPN Connection Stage
15 |   static Stream<String> vpnStageSnapshot() =>
16 |       EventChannel(_eventChannelVpnStage).receiveBroadcastStream().cast();
17 | 
18 |   ///Snapshot of VPN Connection Status
19 |   static Stream<VpnStatus?> vpnStatusSnapshot() =>
20 |       EventChannel(_eventChannelVpnStatus)
21 |           .receiveBroadcastStream()
22 |           .map((event) => VpnStatus.fromJson(jsonDecode(event)))
23 |           .cast();
24 | 
25 |   ///Start VPN easily
26 |   static Future<void> startVpn(VpnConfig vpnConfig) async {
27 |     // log(vpnConfig.config);
28 |     return MethodChannel(_methodChannelVpnControl).invokeMethod(
29 |       "start",
30 |       {
31 |         "config": vpnConfig.config,
32 |         "country": vpnConfig.country,
33 |         "username": vpnConfig.username,
34 |         "password": vpnConfig.password,
35 |       },
36 |     );
37 |   }
38 | 
39 |   ///Stop vpn
40 |   static Future<void> stopVpn() =>
41 |       MethodChannel(_methodChannelVpnControl).invokeMethod("stop");
42 | 
43 |   ///Open VPN Settings
44 |   static Future<void> openKillSwitch() =>
45 |       MethodChannel(_methodChannelVpnControl).invokeMethod("kill_switch");
46 | 
47 |   ///Trigger native to get stage connection
48 |   static Future<void> refreshStage() =>
49 |       MethodChannel(_methodChannelVpnControl).invokeMethod("refresh");
50 | 
51 |   ///Get latest stage
52 |   static Future<String?> stage() =>
53 |       MethodChannel(_methodChannelVpnControl).invokeMethod("stage");
54 | 
55 |   ///Check if vpn is connected
56 |   static Future<bool> isConnected() =>
57 |       stage().then((value) => value?.toLowerCase() == "connected");
58 | 
59 |   ///All Stages of connection
60 |   static const String vpnConnected = "connected";
61 |   static const String vpnDisconnected = "disconnected";
62 |   static const String vpnWaitConnection = "wait_connection";
63 |   static const String vpnAuthenticating = "authenticating";
64 |   static const String vpnReconnect = "reconnect";
65 |   static const String vpnNoConnection = "no_connection";
66 |   static const String vpnConnecting = "connecting";
67 |   static const String vpnPrepare = "prepare";
68 |   static const String vpnDenied = "denied";
69 | }
70 | 


--------------------------------------------------------------------------------
/lib/widgets/count_down_timer.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:async';
 2 | 
 3 | import 'package:flutter/material.dart';
 4 | 
 5 | class CountDownTimer extends StatefulWidget {
 6 |   final bool startTimer;
 7 | 
 8 |   const CountDownTimer({super.key, required this.startTimer});
 9 | 
10 |   @override
11 |   State<CountDownTimer> createState() => _CountDownTimerState();
12 | }
13 | 
14 | class _CountDownTimerState extends State<CountDownTimer> {
15 |   Duration _duration = Duration();
16 |   Timer? _timer;
17 | 
18 |   _startTimer() {
19 |     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
20 |       setState(() {
21 |         _duration = Duration(seconds: _duration.inSeconds + 1);
22 |       });
23 |     });
24 |   }
25 | 
26 |   _stopTimer() {
27 |     setState(() {
28 |       _timer?.cancel();
29 |       _timer = null;
30 |       _duration = Duration();
31 |     });
32 |   }
33 | 
34 |   @override
35 |   Widget build(BuildContext context) {
36 |     if (_timer == null || !widget.startTimer)
37 |       widget.startTimer ? _startTimer() : _stopTimer();
38 | 
39 |     String twoDigit(int n) => n.toString().padLeft(2, '0');
40 |     final minutes = twoDigit(_duration.inMinutes.remainder(60));
41 |     final seconds = twoDigit(_duration.inSeconds.remainder(60));
42 |     final hours = twoDigit(_duration.inHours.remainder(60));
43 | 
44 |     return Text('$hours: $minutes: $seconds', style: TextStyle(fontSize: 22));
45 |   }
46 | }
47 | 


--------------------------------------------------------------------------------
/lib/widgets/home_card.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | 
 3 | import '../main.dart';
 4 | 
 5 | //card to represent status in home screen
 6 | class HomeCard extends StatelessWidget {
 7 |   final String title, subtitle;
 8 |   final Widget icon;
 9 | 
10 |   const HomeCard(
11 |       {super.key,
12 |       required this.title,
13 |       required this.subtitle,
14 |       required this.icon});
15 | 
16 |   @override
17 |   Widget build(BuildContext context) {
18 |     return SizedBox(
19 |         width: mq.width * .45,
20 |         child: Column(
21 |           children: [
22 |             //icon
23 |             icon,
24 | 
25 |             //for adding some space
26 |             const SizedBox(height: 6),
27 | 
28 |             //title
29 |             Text(title,
30 |                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
31 | 
32 |             //for adding some space
33 |             const SizedBox(height: 6),
34 | 
35 |             //subtitle
36 |             Text(
37 |               subtitle,
38 |               style: TextStyle(
39 |                   color: Theme.of(context).lightText,
40 |                   fontWeight: FontWeight.w500,
41 |                   fontSize: 12),
42 |             ),
43 |           ],
44 |         ));
45 |   }
46 | }
47 | 


--------------------------------------------------------------------------------
/lib/widgets/network_card.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/material.dart';
 2 | 
 3 | import '../main.dart';
 4 | import '../models/network_data.dart';
 5 | 
 6 | class NetworkCard extends StatelessWidget {
 7 |   final NetworkData data;
 8 | 
 9 |   const NetworkCard({super.key, required this.data});
10 | 
11 |   @override
12 |   Widget build(BuildContext context) {
13 |     return Card(
14 |         elevation: 5,
15 |         margin: EdgeInsets.symmetric(vertical: mq.height * .01),
16 |         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
17 |         child: InkWell(
18 |           onTap: () {},
19 |           borderRadius: BorderRadius.circular(15),
20 |           child: ListTile(
21 |             shape:
22 |                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
23 | 
24 |             //flag
25 |             leading: Icon(data.icon.icon,
26 |                 color: data.icon.color, size: data.icon.size ?? 28),
27 | 
28 |             //title
29 |             title: Text(data.title),
30 | 
31 |             //subtitle
32 |             subtitle: Text(data.subtitle),
33 |           ),
34 |         ));
35 |   }
36 | }
37 | 


--------------------------------------------------------------------------------
/lib/widgets/vpn_card.dart:
--------------------------------------------------------------------------------
 1 | import 'dart:math';
 2 | 
 3 | import 'package:flutter/cupertino.dart';
 4 | import 'package:flutter/material.dart';
 5 | import 'package:get/get.dart';
 6 | 
 7 | import '../controllers/home_controller.dart';
 8 | import '../helpers/pref.dart';
 9 | import '../main.dart';
10 | import '../models/vpn.dart';
11 | import '../services/vpn_engine.dart';
12 | 
13 | class VpnCard extends StatelessWidget {
14 |   final Vpn vpn;
15 | 
16 |   const VpnCard({super.key, required this.vpn});
17 | 
18 |   @override
19 |   Widget build(BuildContext context) {
20 |     final controller = Get.find<HomeController>();
21 | 
22 |     return Card(
23 |         elevation: 5,
24 |         margin: EdgeInsets.symmetric(vertical: mq.height * .01),
25 |         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
26 |         child: InkWell(
27 |           onTap: () {
28 |             controller.vpn.value = vpn;
29 |             Pref.vpn = vpn;
30 |             Get.back();
31 | 
32 |             // MyDialogs.success(msg: 'Connecting VPN Location...');
33 | 
34 |             if (controller.vpnState.value == VpnEngine.vpnConnected) {
35 |               VpnEngine.stopVpn();
36 |               Future.delayed(
37 |                   Duration(seconds: 2), () => controller.connectToVpn());
38 |             } else {
39 |               controller.connectToVpn();
40 |             }
41 |           },
42 |           borderRadius: BorderRadius.circular(15),
43 |           child: ListTile(
44 |             shape:
45 |                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
46 | 
47 |             //flag
48 |             leading: Container(
49 |               padding: EdgeInsets.all(.5),
50 |               decoration: BoxDecoration(
51 |                   border: Border.all(color: Colors.black12),
52 |                   borderRadius: BorderRadius.circular(5)),
53 |               child: ClipRRect(
54 |                 borderRadius: BorderRadius.circular(5),
55 |                 child: Image.asset(
56 |                     'assets/flags/${vpn.countryShort.toLowerCase()}.png',
57 |                     height: 40,
58 |                     width: mq.width * .15,
59 |                     fit: BoxFit.cover),
60 |               ),
61 |             ),
62 | 
63 |             //title
64 |             title: Text(vpn.countryLong),
65 | 
66 |             //subtitle
67 |             subtitle: Row(
68 |               children: [
69 |                 Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
70 |                 SizedBox(width: 4),
71 |                 Text(_formatBytes(vpn.speed, 1), style: TextStyle(fontSize: 13))
72 |               ],
73 |             ),
74 | 
75 |             //trailing
76 |             trailing: Row(
77 |               mainAxisSize: MainAxisSize.min,
78 |               children: [
79 |                 Text(vpn.numVpnSessions.toString(),
80 |                     style: TextStyle(
81 |                         fontSize: 13,
82 |                         fontWeight: FontWeight.w500,
83 |                         color: Theme.of(context).lightText)),
84 |                 SizedBox(width: 4),
85 |                 Icon(CupertinoIcons.person_3, color: Colors.blue),
86 |               ],
87 |             ),
88 |           ),
89 |         ));
90 |   }
91 | 
92 |   String _formatBytes(int bytes, int decimals) {
93 |     if (bytes <= 0) return "0 B";
94 |     const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
95 |     var i = (log(bytes) / log(1024)).floor();
96 |     return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
97 |   }
98 | }
99 | 


--------------------------------------------------------------------------------
/lib/widgets/watch_ad_dialog.dart:
--------------------------------------------------------------------------------
 1 | import 'package:flutter/cupertino.dart';
 2 | import 'package:flutter/material.dart';
 3 | import 'package:get/get.dart';
 4 | 
 5 | class WatchAdDialog extends StatelessWidget {
 6 |   final VoidCallback onComplete;
 7 | 
 8 |   const WatchAdDialog({super.key, required this.onComplete});
 9 | 
10 |   @override
11 |   Widget build(BuildContext context) {
12 |     return CupertinoAlertDialog(
13 |       title: Text('Change Theme'),
14 |       content: Text('Watch an Ad to Change App Theme.'),
15 |       actions: [
16 |         CupertinoDialogAction(
17 |             isDefaultAction: true,
18 |             textStyle: TextStyle(color: Colors.green),
19 |             child: Text('Watch Ad'),
20 |             onPressed: () {
21 |               Get.back();
22 |               onComplete();
23 |             }),
24 |       ],
25 |     );
26 |   }
27 | }
28 | 


--------------------------------------------------------------------------------


└── android
    └── vpnLib
        ├── build.gradle
        ├── proguard-rules.pro
        └── src
            └── main
                ├── AndroidManifest.xml
                ├── aidl
                    ├── com
                    │   └── android
                    │   │   └── vending
                    │   │       └── billing
                    │   │           └── IInAppBillingService.aidl
                    └── de
                    │   └── blinkt
                    │       └── openvpn
                    │           ├── api
                    │               ├── APIVpnProfile.aidl
                    │               ├── ExternalCertificateProvider.aidl
                    │               ├── IOpenVPNAPIService.aidl
                    │               └── IOpenVPNStatusCallback.aidl
                    │           └── core
                    │               ├── ConnectionStatus.aidl
                    │               ├── IOpenVPNServiceInternal.aidl
                    │               ├── IServiceStatus.aidl
                    │               ├── IStatusCallbacks.aidl
                    │               ├── LogItem.aidl
                    │               └── TrafficHistory.aidl
                ├── assets
                    ├── nopie_openvpn.arm64-v8a
                    ├── nopie_openvpn.armeabi-v7a
                    ├── nopie_openvpn.x86
                    ├── nopie_openvpn.x86_64
                    ├── pie_openvpn.arm64-v8a
                    ├── pie_openvpn.armeabi-v7a
                    ├── pie_openvpn.x86
                    └── pie_openvpn.x86_64
                ├── java
                    ├── de
                    │   └── blinkt
                    │   │   └── openvpn
                    │   │       ├── DisconnectVPNActivity.java
                    │   │       ├── FileProvider.java
                    │   │       ├── LaunchVPN.java
                    │   │       ├── OnBootReceiver.java
                    │   │       ├── OpenVpnApi.java
                    │   │       ├── VpnProfile.java
                    │   │       ├── activities
                    │   │           └── DisconnectVPN.java
                    │   │       ├── api
                    │   │           ├── APIVpnProfile.java
                    │   │           ├── AppRestrictions.java
                    │   │           ├── ConfirmDialog.java
                    │   │           ├── ExternalAppDatabase.java
                    │   │           ├── ExternalOpenVPNService.java
                    │   │           ├── GrantPermissionsActivity.java
                    │   │           ├── RemoteAction.java
                    │   │           └── SecurityRemoteException.java
                    │   │       ├── core
                    │   │           ├── CIDRIP.java
                    │   │           ├── ConfigParser.java
                    │   │           ├── Connection.java
                    │   │           ├── ConnectionStatus.java
                    │   │           ├── DeviceStateReceiver.java
                    │   │           ├── ExtAuthHelper.java
                    │   │           ├── ICSOpenVPNApplication.java
                    │   │           ├── LogFileHandler.java
                    │   │           ├── LogItem.java
                    │   │           ├── LollipopDeviceStateListener.java
                    │   │           ├── NativeUtils.java
                    │   │           ├── NetworkSpace.java
                    │   │           ├── NetworkUtils.java
                    │   │           ├── OpenVPNManagement.java
                    │   │           ├── OpenVPNService.java
                    │   │           ├── OpenVPNStatusService.java
                    │   │           ├── OpenVPNThread.java
                    │   │           ├── OpenVpnManagementThread.java
                    │   │           ├── OrbotHelper.java
                    │   │           ├── PRNGFixes.java
                    │   │           ├── PasswordCache.java
                    │   │           ├── Preferences.java
                    │   │           ├── ProfileManager.java
                    │   │           ├── ProxyDetection.java
                    │   │           ├── StatusListener.java
                    │   │           ├── TrafficHistory.java
                    │   │           ├── VPNLaunchHelper.java
                    │   │           ├── VpnStatus.java
                    │   │           └── X509Utils.java
                    │   │       └── utils
                    │   │           ├── PropertiesService.java
                    │   │           └── TotalTraffic.java
                    └── org
                    │   └── spongycastle
                    │       └── util
                    │           ├── encoders
                    │               ├── Base64.java
                    │               ├── Base64Encoder.java
                    │               └── Encoder.java
                    │           └── io
                    │               └── pem
                    │                   ├── PemGenerationException.java
                    │                   ├── PemHeader.java
                    │                   ├── PemObject.java
                    │                   ├── PemObjectGenerator.java
                    │                   ├── PemReader.java
                    │                   └── PemWriter.java
                ├── jniLibs
                    ├── arm64-v8a
                    │   ├── libjbcrypto.so
                    │   ├── libopenvpn.so
                    │   ├── libopvpnutil.so
                    │   └── libovpnexec.so
                    ├── armeabi-v7a
                    │   ├── libjbcrypto.so
                    │   ├── libopenvpn.so
                    │   ├── libopvpnutil.so
                    │   └── libovpnexec.so
                    ├── x86
                    │   ├── libjbcrypto.so
                    │   ├── libopenvpn.so
                    │   ├── libopvpnutil.so
                    │   └── libovpnexec.so
                    └── x86_64
                    │   ├── libjbcrypto.so
                    │   ├── libopenvpn.so
                    │   ├── libopvpnutil.so
                    │   └── libovpnexec.so
                └── res
                    ├── drawable-hdpi
                        ├── ic_menu_archive.png
                        ├── ic_menu_copy_holo_light.png
                        ├── ic_menu_log.png
                        ├── ic_quick.png
                        ├── ic_stat_vpn.png
                        ├── ic_stat_vpn_empty_halo.png
                        ├── ic_stat_vpn_offline.png
                        ├── ic_stat_vpn_outline.png
                        └── vpn_item_settings.png
                    ├── drawable-mdpi
                        ├── ic_menu_archive.png
                        ├── ic_menu_copy_holo_light.png
                        ├── ic_menu_log.png
                        ├── ic_quick.png
                        ├── ic_stat_vpn.png
                        ├── ic_stat_vpn_empty_halo.png
                        ├── ic_stat_vpn_offline.png
                        ├── ic_stat_vpn_outline.png
                        └── vpn_item_settings.png
                    ├── drawable-xhdpi
                        ├── ic_menu_archive.png
                        ├── ic_menu_copy_holo_light.png
                        ├── ic_menu_log.png
                        ├── ic_quick.png
                        ├── ic_stat_vpn.png
                        ├── ic_stat_vpn_empty_halo.png
                        ├── ic_stat_vpn_offline.png
                        ├── ic_stat_vpn_outline.png
                        └── vpn_item_settings.png
                    ├── drawable-xxhdpi
                        ├── ic_menu_copy_holo_light.png
                        ├── ic_menu_log.png
                        ├── ic_quick.png
                        ├── ic_stat_vpn.png
                        ├── ic_stat_vpn_empty_halo.png
                        ├── ic_stat_vpn_offline.png
                        └── ic_stat_vpn_outline.png
                    ├── drawable
                        └── ic_notification.png
                    ├── layout
                        ├── api_confirm.xml
                        ├── import_as_config.xml
                        ├── launchvpn.xml
                        └── userpass.xml
                    ├── values-sw600dp
                        ├── dimens.xml
                        └── styles.xml
                    ├── values-v29
                        └── bools.xml
                    ├── values
                        ├── arrays.xml
                        ├── attrs.xml
                        ├── bools.xml
                        ├── colours.xml
                        ├── dimens.xml
                        ├── ic_launcher_background.xml
                        ├── plurals.xml
                        ├── refs.xml
                        ├── strings.xml
                        ├── styles.xml
                        └── untranslatable.xml
                    └── xml
                        └── app_restrictions.xml


/android/vpnLib/build.gradle:
--------------------------------------------------------------------------------
 1 | apply plugin: 'com.android.library'
 2 | android {
 3 |     namespace "de.blinkt.openvpn"
 4 |     compileSdkVersion 34
 5 | 
 6 |     defaultConfig {
 7 |         minSdkVersion 21
 8 |         targetSdkVersion 34
 9 |     }
10 | 
11 |      buildFeatures {
12 |          buildConfig true
13 |      }
14 | 
15 |     buildTypes {
16 |         release {
17 |             minifyEnabled false
18 |             proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
19 |         }
20 |     }
21 |     compileOptions {
22 |         sourceCompatibility JavaVersion.VERSION_1_8
23 |         targetCompatibility JavaVersion.VERSION_1_8
24 |     }
25 | }
26 | 
27 | dependencies {
28 |     implementation fileTree(dir: 'libs', include: ['*.jar'])
29 |     implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.0.0'
30 |     implementation 'androidx.appcompat:appcompat:1.1.0'
31 | }
32 | 


--------------------------------------------------------------------------------
/android/vpnLib/proguard-rules.pro:
--------------------------------------------------------------------------------
 1 | # Add project specific ProGuard rules here.
 2 | # By default, the flags in this file are appended to flags specified
 3 | # in /Users/huangyifei/Library/Android/sdk/tools/proguard/proguard-android.txt
 4 | # You can edit the include path and order by changing the proguardFiles
 5 | # directive in build.gradle.
 6 | #
 7 | # For more details, see
 8 | #   http://developer.android.com/guide/developing/tools/proguard.html
 9 | 
10 | # Add any project specific keep options here:
11 | 
12 | # If your project uses WebView with JS, uncomment the following
13 | # and specify the fully qualified class name to the JavaScript interface
14 | # class:
15 | #-keepclassmembers class fqcn.of.javascript.interface.for.webview {
16 | #   public *;
17 | #}
18 | 
19 | 
20 | -keep class com.github.mikephil.charting.** { *; }
21 | -dontwarn io.realm.**


--------------------------------------------------------------------------------
/android/vpnLib/src/main/AndroidManifest.xml:
--------------------------------------------------------------------------------
1 | <manifest />
2 | <!--    package="de.blinkt.openvpn" -->
3 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/com/android/vending/billing/IInAppBillingService.aidl:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (C) 2012 The Android Open Source Project
  3 |  *
  4 |  * Licensed under the Apache License, Version 2.0 (the "License");
  5 |  * you may not use this file except in compliance with the License.
  6 |  * You may obtain a copy of the License at
  7 |  *
  8 |  *      http://www.apache.org/licenses/LICENSE-2.0
  9 |  *
 10 |  * Unless required by applicable law or agreed to in writing, software
 11 |  * distributed under the License is distributed on an "AS IS" BASIS,
 12 |  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 13 |  * See the License for the specific language governing permissions and
 14 |  * limitations under the License.
 15 |  */
 16 | 
 17 | package com.android.vending.billing;
 18 | 
 19 | import android.os.Bundle;
 20 | 
 21 | /**
 22 |  * InAppBillingService is the service that provides in-app billing version 3 and beyond.
 23 |  * This service provides the following features:
 24 |  * 1. Provides a new API to get details of in-app items published for the app including
 25 |  *    price, type, title and description.
 26 |  * 2. The purchase flow is synchronous and purchase information is available immediately
 27 |  *    after it completes.
 28 |  * 3. Purchase information of in-app purchases is maintained within the Google Play system
 29 |  *    till the purchase is consumed.
 30 |  * 4. An API to consume a purchase of an inapp item. All purchases of one-time
 31 |  *    in-app items are consumable and thereafter can be purchased again.
 32 |  * 5. An API to get current purchases of the user immediately. This will not contain any
 33 |  *    consumed purchases.
 34 |  *
 35 |  * All calls will give a response code with the following possible values
 36 |  * RESULT_OK = 0 - success
 37 |  * RESULT_USER_CANCELED = 1 - user pressed back or canceled a dialog
 38 |  * RESULT_BILLING_UNAVAILABLE = 3 - this billing API version is not supported for the type requested
 39 |  * RESULT_ITEM_UNAVAILABLE = 4 - requested SKU is not available for purchase
 40 |  * RESULT_DEVELOPER_ERROR = 5 - invalid arguments provided to the API
 41 |  * RESULT_ERROR = 6 - Fatal error during the API action
 42 |  * RESULT_ITEM_ALREADY_OWNED = 7 - Failure to purchase since item is already owned
 43 |  * RESULT_ITEM_NOT_OWNED = 8 - Failure to consume since item is not owned
 44 |  */
 45 | interface IInAppBillingService {
 46 |     /**
 47 |      * Checks support for the requested billing API version, package and in-app type.
 48 |      * Minimum API version supported by this interface is 3.
 49 |      * @param apiVersion the billing version which the app is using
 50 |      * @param packageName the package name of the calling app
 51 |      * @param type type of the in-app item being purchased "inapp" for one-time purchases
 52 |      *        and "subs" for subscription.
 53 |      * @return RESULT_OK(0) on success, corresponding result code on failures
 54 |      */
 55 |     int isBillingSupported(int apiVersion, String packageName, String type);
 56 | 
 57 |     /**
 58 |      * Provides details of a list of SKUs
 59 |      * Given a list of SKUs of a valid type in the skusBundle, this returns a bundle
 60 |      * with a list JSON strings containing the productId, price, title and description.
 61 |      * This API can be called with a maximum of 20 SKUs.
 62 |      * @param apiVersion billing API version that the Third-party is using
 63 |      * @param packageName the package name of the calling app
 64 |      * @param skusBundle bundle containing a StringArrayList of SKUs with key "ITEM_ID_LIST"
 65 |      * @return Bundle containing the following key-value pairs
 66 |      *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, other response codes on
 67 |      *              failure as listed above.
 68 |      *         "DETAILS_LIST" with a StringArrayList containing purchase information
 69 |      *              in JSON format similar to:
 70 |      *              '{ "productId" : "exampleSku", "type" : "inapp", "price" : "$5.00",
 71 |      *                 "title : "Example Title", "description" : "This is an example description" }'
 72 |      */
 73 |     Bundle getSkuDetails(int apiVersion, String packageName, String type, in Bundle skusBundle);
 74 | 
 75 |     /**
 76 |      * Returns a pending intent to launch the purchase flow for an in-app item by providing a SKU,
 77 |      * the type, a unique purchase token and an optional developer payload.
 78 |      * @param apiVersion billing API version that the app is using
 79 |      * @param packageName package name of the calling app
 80 |      * @param sku the SKU of the in-app item as published in the developer console
 81 |      * @param type the type of the in-app item ("inapp" for one-time purchases
 82 |      *        and "subs" for subscription).
 83 |      * @param developerPayload optional argument to be sent back with the purchase information
 84 |      * @return Bundle containing the following key-value pairs
 85 |      *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, other response codes on
 86 |      *              failure as listed above.
 87 |      *         "BUY_INTENT" - PendingIntent to start the purchase flow
 88 |      *
 89 |      * The Pending intent should be launched with startIntentSenderForResult. When purchase flow
 90 |      * has completed, the onActivityResult() will give a resultCode of OK or CANCELED.
 91 |      * If the purchase is successful, the result data will contain the following key-value pairs
 92 |      *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, other response codes on
 93 |      *              failure as listed above.
 94 |      *         "INAPP_PURCHASE_DATA" - String in JSON format similar to
 95 |      *              '{"orderId":"12999763169054705758.1371079406387615",
 96 |      *                "packageName":"com.example.app",
 97 |      *                "productId":"exampleSku",
 98 |      *                "purchaseTime":1345678900000,
 99 |      *                "purchaseToken" : "122333444455555",
100 |      *                "developerPayload":"example developer payload" }'
101 |      *         "INAPP_DATA_SIGNATURE" - String containing the signature of the purchase data that
102 |      *                                  was signed with the private key of the developer
103 |      *                                  TODO: change this to app-specific keys.
104 |      */
105 |     Bundle getBuyIntent(int apiVersion, String packageName, String sku, String type,
106 |         String developerPayload);
107 | 
108 |     /**
109 |      * Returns the current SKUs owned by the user of the type and package name specified along with
110 |      * purchase information and a signature of the data to be validated.
111 |      * This will return all SKUs that have been purchased in V3 and managed items purchased using
112 |      * V1 and V2 that have not been consumed.
113 |      * @param apiVersion billing API version that the app is using
114 |      * @param packageName package name of the calling app
115 |      * @param type the type of the in-app items being requested
116 |      *        ("inapp" for one-time purchases and "subs" for subscription).
117 |      * @param continuationToken to be set as null for the first call, if the number of owned
118 |      *        skus are too many, a continuationToken is returned in the response bundle.
119 |      *        This method can be called again with the continuation token to get the next set of
120 |      *        owned skus.
121 |      * @return Bundle containing the following key-value pairs
122 |      *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, other response codes on
123 |      *              failure as listed above.
124 |      *         "INAPP_PURCHASE_ITEM_LIST" - StringArrayList containing the list of SKUs
125 |      *         "INAPP_PURCHASE_DATA_LIST" - StringArrayList containing the purchase information
126 |      *         "INAPP_DATA_SIGNATURE_LIST"- StringArrayList containing the signatures
127 |      *                                      of the purchase information
128 |      *         "INAPP_CONTINUATION_TOKEN" - String containing a continuation token for the
129 |      *                                      next set of in-app purchases. Only set if the
130 |      *                                      user has more owned skus than the current list.
131 |      */
132 |     Bundle getPurchases(int apiVersion, String packageName, String type, String continuationToken);
133 | 
134 |     /**
135 |      * Consume the last purchase of the given SKU. This will result in this item being removed
136 |      * from all subsequent responses to getPurchases() and allow re-purchase of this item.
137 |      * @param apiVersion billing API version that the app is using
138 |      * @param packageName package name of the calling app
139 |      * @param purchaseToken token in the purchase information JSON that identifies the purchase
140 |      *        to be consumed
141 |      * @return 0 if consumption succeeded. Appropriate error values for failures.
142 |      */
143 |     int consumePurchase(int apiVersion, String packageName, String purchaseToken);
144 | }
145 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/api/APIVpnProfile.aidl:
--------------------------------------------------------------------------------
1 | package de.blinkt.openvpn.api;
2 | 
3 | parcelable APIVpnProfile;
4 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/api/ExternalCertificateProvider.aidl:
--------------------------------------------------------------------------------
 1 | // ExternalCertificateProvider.aidl
 2 | package de.blinkt.openvpn.api;
 3 | 
 4 | 
 5 | /*
 6 |  * This is very simple interface that is specialised to have only the minimal set of crypto
 7 |  * operation that are needed for OpenVPN to authenticate with an external certificate
 8 |  */
 9 | interface ExternalCertificateProvider {
10 |     /**
11 |      * Requests signing the data with RSA/ECB/PKCS1PADDING
12 |      * for RSA certficate and with NONEwithECDSA for EC certificates
13 |      * @parm alias the parameter that
14 |      */
15 |     byte[] getSignedData(in String alias, in byte[] data);
16 | 
17 |     /**
18 |      * Requests the certificate chain for the selected alias
19 |      * The first certifcate returned is assumed to be
20 |      * the user certificate
21 |      */
22 |     byte[] getCertificateChain(in String alias);
23 | 
24 |     /**
25 |      * This function is called for the app to get additional meta information from the
26 |      * external provider and will be called with the stored alias in the app
27 |      *
28 |      * For external app provider that do not provide an activity to configure them, this
29 |      * is used to get the alias that should be used.
30 |      * The format is the same as the activity should return, i.e.
31 |      *
32 |      * EXTRA_ALIAS = "de.blinkt.openvpn.api.KEY_ALIAS"
33 |      * EXTRA_DESCRIPTION = "de.blinkt.openvpn.api.KEY_DESCRIPTION"
34 |      *
35 |      * as the keys for the bundle.
36 |      *
37 |      */
38 |     Bundle getCertificateMetaData(in String alias);
39 | }
40 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/api/IOpenVPNAPIService.aidl:
--------------------------------------------------------------------------------
 1 | // IOpenVPNAPIService.aidl
 2 | package de.blinkt.openvpn.api;
 3 | 
 4 | import de.blinkt.openvpn.api.APIVpnProfile;
 5 | import de.blinkt.openvpn.api.IOpenVPNStatusCallback; 
 6 | 
 7 | import android.content.Intent;
 8 | import android.os.ParcelFileDescriptor;
 9 | 
10 | interface IOpenVPNAPIService {
11 | 	List<APIVpnProfile> getProfiles();
12 | 	
13 | 	void startProfile (String profileUUID);
14 | 	
15 | 	/** Use a profile with all certificates etc. embedded,
16 | 	 * old version which does not return the UUID of the addded profile, see
17 | 	 * below for a version that return the UUID on add */
18 | 	boolean addVPNProfile (String name, String config);
19 | 	
20 | 	/** start a profile using a config as inline string. Make sure that all needed data is inlined,
21 | 	 * e.g., using <ca>...</ca> or <auth-user-pass>...</auth-user-pass>
22 | 	 * See the OpenVPN manual page for more on inlining files */
23 | 	void startVPN (in String inlineconfig);
24 | 	
25 | 	/** This permission framework is used  to avoid confused deputy style attack to the VPN
26 | 	 * calling this will give null if the app is allowed to use the external API and an Intent
27 | 	 * that can be launched to request permissions otherwise */
28 | 	Intent prepare (in String packagename);
29 | 	
30 | 	/** Used to trigger to the Android VPN permission dialog (VPNService.prepare()) in advance,
31 | 	 * if this return null OpenVPN for ANdroid already has the permissions otherwise you can start the returned Intent
32 | 	 * to let OpenVPN for Android request the permission */
33 | 	Intent prepareVPNService ();
34 | 
35 | 	/* Disconnect the VPN */
36 |     void disconnect();
37 | 
38 |     /* Pause the VPN (same as using the pause feature in the notifcation bar) */
39 |     void pause();
40 | 
41 |     /* Resume the VPN (same as using the pause feature in the notifcation bar) */
42 |     void resume();
43 |     
44 |     /**
45 |       * Registers to receive OpenVPN Status Updates
46 |       */
47 |     void registerStatusCallback(in IOpenVPNStatusCallback cb);
48 |     
49 |     /**
50 |      * Remove a previously registered callback interface.
51 |      */
52 |     void unregisterStatusCallback(in IOpenVPNStatusCallback cb);
53 | 
54 | 	/** Remove a profile by UUID */
55 | 	void removeProfile (in String profileUUID);
56 | 
57 | 	/** Request a socket to be protected as a VPN socket would be. Useful for creating
58 | 	  * a helper socket for an app controlling OpenVPN
59 | 	  * Before calling this function you should make sure OpenVPN for Android may actually
60 | 	  * this function by checking if prepareVPNService returns null; */
61 | 	boolean protectSocket(in ParcelFileDescriptor fd);
62 | 
63 | 
64 |     /** Use a profile with all certificates etc. embedded */
65 |     APIVpnProfile addNewVPNProfile (String name, boolean userEditable, String config);
66 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/api/IOpenVPNStatusCallback.aidl:
--------------------------------------------------------------------------------
 1 | package de.blinkt.openvpn.api;
 2 | 
 3 | /**
 4 |  * Example of a callback interface used by IRemoteService to send
 5 |  * synchronous notifications back to its clients.  Note that this is a
 6 |  * one-way interface so the server does not block waiting for the client.
 7 |  */
 8 | interface IOpenVPNStatusCallback {
 9 |     /**
10 |      * Called when the service has a new status for you.
11 |      */
12 |     oneway void newStatus(in String uuid, in String state, in String message, in String level);
13 | }
14 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/ConnectionStatus.aidl:
--------------------------------------------------------------------------------
1 | package de.blinkt.openvpn.core;
2 | 
3 | parcelable ConnectionStatus;


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/IOpenVPNServiceInternal.aidl:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | /**
 9 |  * Created by arne on 15.11.16.
10 |  */
11 | 
12 | interface IOpenVPNServiceInternal {
13 | 
14 |     boolean protect(int fd);
15 | 
16 |     void userPause(boolean b);
17 | 
18 |     /**
19 |      * @param replaceConnection True if the VPN is connected by a new connection.
20 |      * @return true if there was a process that has been send a stop signal
21 |      */
22 |     boolean stopVPN(boolean replaceConnection);
23 | 
24 |     void addAllowedExternalApp(String packagename);
25 | 
26 |     boolean isAllowedExternalApp(String packagename);
27 | 
28 |     void challengeResponse(String repsonse);
29 | }
30 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/IServiceStatus.aidl:
--------------------------------------------------------------------------------
 1 | // StatusIPC.aidl
 2 | package de.blinkt.openvpn.core;
 3 | 
 4 | // Declare any non-default types here with import statements
 5 | import de.blinkt.openvpn.core.IStatusCallbacks;
 6 | import android.os.ParcelFileDescriptor;
 7 | import de.blinkt.openvpn.core.TrafficHistory;
 8 | 
 9 | 
10 | interface IServiceStatus {
11 |          /**
12 |           * Registers to receive OpenVPN Status Updates and gets a
13 |           * ParcelFileDescript back that contains the log up to that point
14 |           */
15 |          ParcelFileDescriptor registerStatusCallback(in IStatusCallbacks cb);
16 | 
17 |          /**
18 |            * Remove a previously registered callback interface.
19 |            */
20 |         void unregisterStatusCallback(in IStatusCallbacks cb);
21 | 
22 |         /**
23 |          * Returns the last connedcted VPN
24 |          */
25 |         String getLastConnectedVPN();
26 | 
27 |         /**
28 |           * Sets a cached password
29 |           */
30 |        void setCachedPassword(in String uuid, int type, String password);
31 | 
32 |        /**
33 |        * Gets the traffic history
34 |        */
35 |        TrafficHistory getTrafficHistory();
36 | }
37 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/IStatusCallbacks.aidl:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import de.blinkt.openvpn.core.LogItem;
 9 | import de.blinkt.openvpn.core.ConnectionStatus;
10 | 
11 | 
12 | 
13 | interface IStatusCallbacks {
14 |     /**
15 |      * Called when the service has a new status for you.
16 |      */
17 |     oneway void newLogItem(in LogItem item);
18 | 
19 |     oneway void updateStateString(in String state, in String msg, in int resid, in ConnectionStatus level, in Intent intent);
20 | 
21 |     oneway void updateByteCount(long inBytes, long outBytes);
22 | 
23 |     oneway void connectedVPN(String uuid);
24 | }
25 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/LogItem.aidl:
--------------------------------------------------------------------------------
1 | package de.blinkt.openvpn.core;
2 | 
3 | parcelable LogItem;


--------------------------------------------------------------------------------
/android/vpnLib/src/main/aidl/de/blinkt/openvpn/core/TrafficHistory.aidl:
--------------------------------------------------------------------------------
1 | package de.blinkt.openvpn.core;
2 | 
3 | 
4 | parcelable TrafficHistory;
5 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/nopie_openvpn.arm64-v8a:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/nopie_openvpn.arm64-v8a


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/nopie_openvpn.armeabi-v7a:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/nopie_openvpn.armeabi-v7a


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/nopie_openvpn.x86:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/nopie_openvpn.x86


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/nopie_openvpn.x86_64:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/nopie_openvpn.x86_64


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/pie_openvpn.arm64-v8a:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/pie_openvpn.arm64-v8a


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/pie_openvpn.armeabi-v7a:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/pie_openvpn.armeabi-v7a


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/pie_openvpn.x86:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/pie_openvpn.x86


--------------------------------------------------------------------------------
/android/vpnLib/src/main/assets/pie_openvpn.x86_64:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/assets/pie_openvpn.x86_64


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/DisconnectVPNActivity.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | package de.blinkt.openvpn;
 6 | 
 7 | import android.app.Activity;
 8 | import android.app.AlertDialog;
 9 | import android.content.ComponentName;
10 | import android.content.Context;
11 | import android.content.DialogInterface;
12 | import android.content.Intent;
13 | import android.content.ServiceConnection;
14 | import android.os.IBinder;
15 | 
16 | 
17 | import de.blinkt.openvpn.core.OpenVPNService;
18 | import de.blinkt.openvpn.core.ProfileManager;
19 | 
20 | public class DisconnectVPNActivity extends Activity implements DialogInterface.OnClickListener, DialogInterface.OnCancelListener {
21 |     protected static OpenVPNService mService;
22 |     private ServiceConnection mConnection = new ServiceConnection() {
23 |         @Override
24 |         public void onServiceConnected(ComponentName className, IBinder service) {
25 | //            // We've bound to LocalService, cast the IBinder and get LocalService instance
26 |             OpenVPNService.LocalBinder binder = (OpenVPNService.LocalBinder) service;
27 |             mService = binder.getService();
28 |         }
29 | 
30 |         @Override
31 |         public void onServiceDisconnected(ComponentName arg0) {
32 |             mService = null;
33 |         }
34 |     };
35 | 
36 | 
37 |     @Override
38 |     protected void onResume() {
39 |         super.onResume();
40 |         Intent intent = new Intent(this, OpenVPNService.class);
41 |         intent.setAction(OpenVPNService.START_SERVICE);
42 |         bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
43 |         showDisconnectDialog();
44 |     }
45 | 
46 |     @Override
47 |     protected void onPause() {
48 |         super.onPause();
49 |         unbindService(mConnection);
50 |     }
51 | 
52 |     private void showDisconnectDialog() {
53 | 
54 |         AlertDialog.Builder builder = new AlertDialog.Builder(this);
55 |         builder.setTitle(R.string.title_cancel);
56 |         builder.setMessage(R.string.cancel_connection_query);
57 |         builder.setNegativeButton(android.R.string.no, this);
58 |         builder.setPositiveButton(android.R.string.yes, this);
59 |         builder.setOnCancelListener(this);
60 |         builder.show();
61 |     }
62 | 
63 |     @Override
64 |     public void onClick(DialogInterface dialog, int which) {
65 |         if (which == DialogInterface.BUTTON_POSITIVE) {
66 |             stopVpn();
67 |         }
68 |         finish();
69 |     }
70 |     public void stopVpn(){
71 |         ProfileManager.setConntectedVpnProfileDisconnected(this);
72 |         if (mService != null && mService.getManagement() != null) {
73 |             mService.getManagement().stopVPN(false);
74 |         }
75 |     }
76 | 
77 | 
78 |     @Override
79 |     public void onCancel(DialogInterface dialog) {
80 |         finish();
81 |     }
82 | 
83 | }
84 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/FileProvider.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn;
  7 | 
  8 | import java.io.File;
  9 | import java.io.FileInputStream;
 10 | import java.io.FileNotFoundException;
 11 | import java.io.FileOutputStream;
 12 | import java.io.IOException;
 13 | import java.io.InputStream;
 14 | 
 15 | import android.content.ContentProvider;
 16 | import android.content.ContentProvider.PipeDataWriter;
 17 | import android.content.ContentValues;
 18 | import android.content.res.AssetFileDescriptor;
 19 | import android.database.Cursor;
 20 | import android.database.MatrixCursor;
 21 | import android.net.Uri;
 22 | import android.os.Bundle;
 23 | import android.os.ParcelFileDescriptor;
 24 | import android.provider.OpenableColumns;
 25 | import android.util.Log;
 26 | import de.blinkt.openvpn.core.VpnStatus;
 27 | 
 28 | /**
 29 |  * A very simple content provider that can serve arbitrary asset files from
 30 |  * our .apk.
 31 |  */
 32 | public class FileProvider extends ContentProvider
 33 | implements PipeDataWriter<InputStream> {
 34 | 	@Override
 35 | 	public boolean onCreate() {
 36 | 		return true;
 37 | 	}
 38 | 
 39 | 	@Override
 40 | 	public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs,
 41 | 			String sortOrder) {
 42 | 		try {
 43 | 			File dumpfile = getFileFromURI(uri);
 44 | 
 45 | 
 46 | 			MatrixCursor c = new MatrixCursor(projection);
 47 | 
 48 | 			Object[] row = new Object[projection.length];
 49 | 			int i=0;
 50 | 			for (String r:projection) {
 51 | 				if(r.equals(OpenableColumns.SIZE))
 52 | 					row[i] = dumpfile.length();
 53 | 				if(r.equals(OpenableColumns.DISPLAY_NAME))
 54 | 					row[i] = dumpfile.getName();
 55 | 				i++;
 56 | 			}
 57 | 			c.addRow(row);
 58 | 			return c;
 59 | 		} catch (FileNotFoundException e) {
 60 |             VpnStatus.logException(e);
 61 |             return null;
 62 | 		}
 63 | 
 64 | 
 65 | 	}
 66 | 
 67 | 	@Override
 68 | 	public Uri insert(Uri uri, ContentValues values) {
 69 | 		// Don't support inserts.
 70 | 		return null;
 71 | 	}
 72 | 
 73 | 	@Override
 74 | 	public int delete(Uri uri, String selection, String[] selectionArgs) {
 75 | 		// Don't support deletes.
 76 | 		return 0;
 77 | 	}
 78 | 
 79 | 	@Override
 80 | 	public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
 81 | 		// Don't support updates.
 82 | 		return 0;
 83 | 	}
 84 | 
 85 | 	@Override
 86 | 	public String getType(Uri uri) {
 87 | 		// For this sample, assume all files are .apks.
 88 | 		return "application/octet-stream";
 89 | 	}
 90 | 
 91 | 	@Override
 92 | 	public AssetFileDescriptor openAssetFile(Uri uri, String mode) throws FileNotFoundException {
 93 | 		File dumpfile = getFileFromURI(uri);
 94 | 
 95 | 		try {
 96 | 
 97 | 			InputStream is = new FileInputStream(dumpfile);
 98 | 			// Start a new thread that pipes the stream data back to the caller.
 99 | 			return new AssetFileDescriptor(
100 | 					openPipeHelper(uri, null, null, is, this), 0,
101 | 					dumpfile.length());
102 | 		} catch (IOException e) {
103 |             throw new FileNotFoundException("Unable to open minidump " + uri);
104 | 		}
105 | 	}
106 | 
107 | 	private File getFileFromURI(Uri uri) throws FileNotFoundException {
108 | 		// Try to open an asset with the given name.
109 | 		String path = uri.getPath();
110 | 		if(path.startsWith("/"))
111 | 			path = path.replaceFirst("/", "");       
112 | 
113 | 		// I think this already random enough, no need for magic secure cookies
114 | 		// 1f9563a4-a1f5-2165-255f2219-111823ef.dmp
115 | 		if (!path.matches("^[0-9a-z-.]*(dmp|dmp.log)
quot;))
116 | 			throw new FileNotFoundException("url not in expect format " + uri);
117 | 		File cachedir = getContext().getCacheDir();
118 |         return new File(cachedir,path);
119 | 	}
120 | 
121 | 	@Override
122 | 	public void writeDataToPipe(ParcelFileDescriptor output, Uri uri, String mimeType,
123 | 			Bundle opts, InputStream args) {
124 | 		// Transfer data from the asset to the pipe the client is reading.
125 | 		byte[] buffer = new byte[8192];
126 | 		int n;
127 | 		FileOutputStream fout = new FileOutputStream(output.getFileDescriptor());
128 | 		try {
129 | 			while ((n=args.read(buffer)) >= 0) {
130 | 				fout.write(buffer, 0, n);
131 | 			}
132 | 		} catch (IOException e) {
133 | 			Log.i("OpenVPNFileProvider", "Failed transferring", e);
134 | 		} finally {
135 | 			try {
136 | 				args.close();
137 | 			} catch (IOException e) {
138 | 			}
139 | 			try {
140 | 				fout.close();
141 | 			} catch (IOException e) {
142 | 			}
143 | 		}
144 | 	}
145 | }
146 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/LaunchVPN.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn;
  7 | 
  8 | import android.annotation.SuppressLint;
  9 | import android.annotation.TargetApi;
 10 | import android.app.Activity;
 11 | import android.app.AlertDialog;
 12 | import android.content.ActivityNotFoundException;
 13 | import android.content.ComponentName;
 14 | import android.content.Context;
 15 | import android.content.DialogInterface;
 16 | import android.content.DialogInterface.OnClickListener;
 17 | import android.content.Intent;
 18 | import android.content.ServiceConnection;
 19 | import android.content.SharedPreferences;
 20 | import android.net.VpnService;
 21 | import android.os.Build;
 22 | import android.os.Bundle;
 23 | import android.os.IBinder;
 24 | import android.os.RemoteException;
 25 | import android.preference.PreferenceManager;
 26 | import android.text.InputType;
 27 | import android.text.TextUtils;
 28 | import android.text.method.PasswordTransformationMethod;
 29 | import android.view.View;
 30 | import android.widget.CheckBox;
 31 | import android.widget.CompoundButton;
 32 | import android.widget.EditText;
 33 | 
 34 | import java.io.IOException;
 35 | 
 36 | import de.blinkt.openvpn.api.ExternalAppDatabase;
 37 | import de.blinkt.openvpn.core.ConnectionStatus;
 38 | import de.blinkt.openvpn.core.IServiceStatus;
 39 | import de.blinkt.openvpn.core.OpenVPNStatusService;
 40 | import de.blinkt.openvpn.core.PasswordCache;
 41 | import de.blinkt.openvpn.core.Preferences;
 42 | import de.blinkt.openvpn.core.ProfileManager;
 43 | import de.blinkt.openvpn.core.VPNLaunchHelper;
 44 | import de.blinkt.openvpn.core.VpnStatus;
 45 | 
 46 | /**
 47 |  * This Activity actually handles two stages of a launcher shortcut's life cycle.
 48 |  * <p/>
 49 |  * 1. Your application offers to provide shortcuts to the launcher.  When
 50 |  * the user installs a shortcut, an activity within your application
 51 |  * generates the actual shortcut and returns it to the launcher, where it
 52 |  * is shown to the user as an icon.
 53 |  * <p/>
 54 |  * 2. Any time the user clicks on an installed shortcut, an intent is sent.
 55 |  * Typically this would then be handled as necessary by an activity within
 56 |  * your application.
 57 |  * <p/>
 58 |  * We handle stage 1 (creating a shortcut) by simply sending back the information (in the form
 59 |  * of an {@link android.content.Intent} that the launcher will use to create the shortcut.
 60 |  * <p/>
 61 |  * You can also implement this in an interactive way, by having your activity actually present
 62 |  * UI for the user to select the specific nature of the shortcut, such as a contact, picture, URL,
 63 |  * media item, or action.
 64 |  * <p/>
 65 |  * We handle stage 2 (responding to a shortcut) in this sample by simply displaying the contents
 66 |  * of the incoming {@link android.content.Intent}.
 67 |  * <p/>
 68 |  * In a real application, you would probably use the shortcut intent to display specific content
 69 |  * or start a particular operation.
 70 |  */
 71 | public class LaunchVPN extends Activity {
 72 | 
 73 |     public static final String EXTRA_KEY = "de.blinkt.openvpn.shortcutProfileUUID";
 74 |     public static final String EXTRA_NAME = "de.blinkt.openvpn.shortcutProfileName";
 75 |     public static final String EXTRA_HIDELOG = "de.blinkt.openvpn.showNoLogWindow";
 76 |     public static final String CLEARLOG = "clearlogconnect";
 77 | 
 78 | 
 79 |     private static final int START_VPN_PROFILE = 70;
 80 | 
 81 | 
 82 |     private VpnProfile mSelectedProfile;
 83 |     private boolean mhideLog = false;
 84 | 
 85 |     private boolean mCmfixed = false;
 86 |     private String mTransientAuthPW;
 87 |     private String mTransientCertOrPCKS12PW;
 88 | 
 89 |     @Override
 90 |     public void onCreate(Bundle icicle) {
 91 |         super.onCreate(icicle);
 92 |         setContentView(R.layout.launchvpn);
 93 |         startVpnFromIntent();
 94 |     }
 95 | 
 96 |     private ServiceConnection mConnection = new ServiceConnection() {
 97 |         @Override
 98 |         public void onServiceConnected(ComponentName componentName, IBinder binder) {
 99 |             IServiceStatus service = IServiceStatus.Stub.asInterface(binder);
100 |             try {
101 |                 if (mTransientAuthPW != null)
102 | 
103 |                     service.setCachedPassword(mSelectedProfile.getUUIDString(), PasswordCache.AUTHPASSWORD, mTransientAuthPW);
104 |                 if (mTransientCertOrPCKS12PW != null)
105 |                     service.setCachedPassword(mSelectedProfile.getUUIDString(), PasswordCache.PCKS12ORCERTPASSWORD, mTransientCertOrPCKS12PW);
106 | 
107 |                 onActivityResult(START_VPN_PROFILE, Activity.RESULT_OK, null);
108 | 
109 |             } catch (RemoteException e) {
110 |                 e.printStackTrace();
111 |             }
112 | 
113 |             unbindService(this);
114 |         }
115 | 
116 |         @Override
117 |         public void onServiceDisconnected(ComponentName componentName) {
118 | 
119 |         }
120 |     };
121 | 
122 |     protected void startVpnFromIntent() {
123 |         // Resolve the intent
124 | 
125 |         final Intent intent = getIntent();
126 |         final String action = intent.getAction();
127 | 
128 |         // If the intent is a request to create a shortcut, we'll do that and exit
129 | 
130 | 
131 |         if (Intent.ACTION_MAIN.equals(action)) {
132 |             // Check if we need to clear the log
133 |             if (Preferences.getDefaultSharedPreferences(this).getBoolean(CLEARLOG, true))
134 |                 VpnStatus.clearLog();
135 | 
136 |             // we got called to be the starting point, most likely a shortcut
137 |             String shortcutUUID = intent.getStringExtra(EXTRA_KEY);
138 |             String shortcutName = intent.getStringExtra(EXTRA_NAME);
139 |             mhideLog = intent.getBooleanExtra(EXTRA_HIDELOG, false);
140 | 
141 |             VpnProfile profileToConnect = ProfileManager.get(this, shortcutUUID);
142 |             if (shortcutName != null && profileToConnect == null) {
143 |                 profileToConnect = ProfileManager.getInstance(this).getProfileByName(shortcutName);
144 |                 if (!(new ExternalAppDatabase(this).checkRemoteActionPermission(this, getCallingPackage()))) {
145 |                     finish();
146 |                     return;
147 |                 }
148 |             }
149 | 
150 | 
151 |             if (profileToConnect == null) {
152 |                 VpnStatus.logError(R.string.shortcut_profile_notfound);
153 |                 // show Log window to display error
154 |                 showLogWindow();
155 |                 finish();
156 |             } else {
157 |                 mSelectedProfile = profileToConnect;
158 |                 launchVPN();
159 |             }
160 |         }
161 |     }
162 | 
163 |     private void askForPW(final int type) {
164 | 
165 |         final EditText entry = new EditText(this);
166 | 
167 |         entry.setSingleLine();
168 |         entry.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
169 |         entry.setTransformationMethod(new PasswordTransformationMethod());
170 | 
171 |         AlertDialog.Builder dialog = new AlertDialog.Builder(this);
172 |         dialog.setTitle(getString(R.string.pw_request_dialog_title, getString(type)));
173 |         dialog.setMessage(getString(R.string.pw_request_dialog_prompt, mSelectedProfile.mName));
174 | 
175 | 
176 |         @SuppressLint("InflateParams") final View userpwlayout = getLayoutInflater().inflate(R.layout.userpass, null, false);
177 | 
178 |         if (type == R.string.password) {
179 |             ((EditText) userpwlayout.findViewById(R.id.username)).setText(mSelectedProfile.mUsername);
180 |             ((EditText) userpwlayout.findViewById(R.id.password)).setText(mSelectedProfile.mPassword);
181 |             ((CheckBox) userpwlayout.findViewById(R.id.save_password)).setChecked(!TextUtils.isEmpty(mSelectedProfile.mPassword));
182 |             ((CheckBox) userpwlayout.findViewById(R.id.show_password)).setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
183 |                 @Override
184 |                 public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
185 |                     if (isChecked)
186 |                         ((EditText) userpwlayout.findViewById(R.id.password)).setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
187 |                     else
188 |                         ((EditText) userpwlayout.findViewById(R.id.password)).setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
189 |                 }
190 |             });
191 | 
192 |             dialog.setView(userpwlayout);
193 |         } else {
194 |             dialog.setView(entry);
195 |         }
196 | 
197 |         AlertDialog.Builder builder = dialog.setPositiveButton(android.R.string.ok,
198 |                 new OnClickListener() {
199 |                     @Override
200 |                     public void onClick(DialogInterface dialog, int which) {
201 | 
202 |                         if (type == R.string.password) {
203 |                             mSelectedProfile.mUsername = ((EditText) userpwlayout.findViewById(R.id.username)).getText().toString();
204 | 
205 |                             String pw = ((EditText) userpwlayout.findViewById(R.id.password)).getText().toString();
206 |                             if (((CheckBox) userpwlayout.findViewById(R.id.save_password)).isChecked()) {
207 |                                 mSelectedProfile.mPassword = pw;
208 |                             } else {
209 |                                 mSelectedProfile.mPassword = null;
210 |                                 mTransientAuthPW = pw;
211 |                             }
212 |                         } else {
213 |                             mTransientCertOrPCKS12PW = entry.getText().toString();
214 |                         }
215 |                         Intent intent = new Intent(LaunchVPN.this, OpenVPNStatusService.class);
216 |                         bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
217 |                     }
218 | 
219 |                 });
220 |         dialog.setNegativeButton(android.R.string.cancel,
221 |                 new DialogInterface.OnClickListener() {
222 |                     @Override
223 |                     public void onClick(DialogInterface dialog, int which) {
224 |                         VpnStatus.updateStateString("USER_VPN_PASSWORD_CANCELLED", "", R.string.state_user_vpn_password_cancelled,
225 |                                 ConnectionStatus.LEVEL_NOTCONNECTED);
226 |                         finish();
227 |                     }
228 |                 });
229 | 
230 |         dialog.create().show();
231 | 
232 |     }
233 | 
234 |     @Override
235 |     protected void onActivityResult(int requestCode, int resultCode, Intent data) {
236 |         super.onActivityResult(requestCode, resultCode, data);
237 | 
238 |         if (requestCode == START_VPN_PROFILE) {
239 |             if (resultCode == Activity.RESULT_OK) {
240 |                 int needpw = mSelectedProfile.needUserPWInput(mTransientCertOrPCKS12PW, mTransientAuthPW);
241 |                 if (needpw != 0) {
242 |                     VpnStatus.updateStateString("USER_VPN_PASSWORD", "", R.string.state_user_vpn_password,
243 |                             ConnectionStatus.LEVEL_WAITING_FOR_USER_INPUT);
244 |                     askForPW(needpw);
245 |                 } else {
246 |                     SharedPreferences prefs = Preferences.getDefaultSharedPreferences(this);
247 |                     boolean showLogWindow = prefs.getBoolean("showlogwindow", true);
248 | 
249 |                     if (!mhideLog && showLogWindow)
250 |                         showLogWindow();
251 |                     ProfileManager.updateLRU(this, mSelectedProfile);
252 |                     VPNLaunchHelper.startOpenVpn(mSelectedProfile, getBaseContext());
253 |                     finish();
254 |                 }
255 |             } else if (resultCode == Activity.RESULT_CANCELED) {
256 |                 // User does not want us to start, so we just vanish
257 |                 VpnStatus.updateStateString("USER_VPN_PERMISSION_CANCELLED", "", R.string.state_user_vpn_permission_cancelled,
258 |                         ConnectionStatus.LEVEL_NOTCONNECTED);
259 | 
260 |                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
261 |                     VpnStatus.logError(R.string.nought_alwayson_warning);
262 | 
263 |                 finish();
264 |             }
265 |         }
266 |     }
267 | 
268 |     void showLogWindow() {
269 | 
270 |         Intent startLW = new Intent();
271 |         startLW.setComponent(new ComponentName(this, getPackageName() + ".activities.LogWindow"));
272 |         startLW.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
273 |         startActivity(startLW);
274 | 
275 |     }
276 | 
277 |     void showConfigErrorDialog(int vpnok) {
278 |         AlertDialog.Builder d = new AlertDialog.Builder(this);
279 |         d.setTitle(R.string.config_error_found);
280 |         d.setMessage(vpnok);
281 |         d.setPositiveButton(android.R.string.ok, new OnClickListener() {
282 | 
283 |             @Override
284 |             public void onClick(DialogInterface dialog, int which) {
285 |                 finish();
286 | 
287 |             }
288 |         });
289 |         d.setOnCancelListener(new DialogInterface.OnCancelListener() {
290 |             @Override
291 |             public void onCancel(DialogInterface dialog) {
292 |                 finish();
293 |             }
294 |         });
295 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1)
296 |             setOnDismissListener(d);
297 |         d.show();
298 |     }
299 | 
300 |     @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
301 |     private void setOnDismissListener(AlertDialog.Builder d) {
302 |         d.setOnDismissListener(new DialogInterface.OnDismissListener() {
303 |             @Override
304 |             public void onDismiss(DialogInterface dialog) {
305 |                 finish();
306 |             }
307 |         });
308 |     }
309 | 
310 |     void launchVPN() {
311 |         int vpnok = mSelectedProfile.checkProfile(this);
312 |         if (vpnok != R.string.no_error_found) {
313 |             showConfigErrorDialog(vpnok);
314 |             return;
315 |         }
316 | 
317 |         Intent intent = VpnService.prepare(this);
318 |         // Check if we want to fix /dev/tun
319 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(this);
320 |         boolean usecm9fix = prefs.getBoolean("useCM9Fix", false);
321 |         boolean loadTunModule = prefs.getBoolean("loadTunModule", false);
322 | 
323 |         if (loadTunModule)
324 |             execeuteSUcmd("insmod /system/lib/modules/tun.ko");
325 | 
326 |         if (usecm9fix && !mCmfixed) {
327 |             execeuteSUcmd("chown system /dev/tun");
328 |         }
329 | 
330 |         if (intent != null) {
331 |             VpnStatus.updateStateString("USER_VPN_PERMISSION", "", R.string.state_user_vpn_permission,
332 |                     ConnectionStatus.LEVEL_WAITING_FOR_USER_INPUT);
333 |             // Start the query
334 |             try {
335 |                 startActivityForResult(intent, START_VPN_PROFILE);
336 |             } catch (ActivityNotFoundException ane) {
337 |                 // Shame on you Sony! At least one user reported that
338 |                 // an official Sony Xperia Arc S image triggers this exception
339 |                 VpnStatus.logError(R.string.no_vpn_support_image);
340 |                 showLogWindow();
341 |             }
342 |         } else {
343 |             onActivityResult(START_VPN_PROFILE, Activity.RESULT_OK, null);
344 |         }
345 | 
346 |     }
347 | 
348 |     private void execeuteSUcmd(String command) {
349 |         try {
350 |             ProcessBuilder pb = new ProcessBuilder("su", "-c", command);
351 |             Process p = pb.start();
352 |             int ret = p.waitFor();
353 |             if (ret == 0)
354 |                 mCmfixed = true;
355 |         } catch (InterruptedException | IOException e) {
356 |             VpnStatus.logException("SU command", e);
357 |         }
358 |     }
359 | }
360 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/OnBootReceiver.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn;
 7 | 
 8 | import android.content.BroadcastReceiver;
 9 | import android.content.Context;
10 | import android.content.Intent;
11 | import android.content.SharedPreferences;
12 | 
13 | import de.blinkt.openvpn.core.Preferences;
14 | import de.blinkt.openvpn.core.ProfileManager;
15 | 
16 | 
17 | public class OnBootReceiver extends BroadcastReceiver {
18 | 
19 | 
20 | 
21 | 	// Debug: am broadcast -a android.intent.action.BOOT_COMPLETED
22 | 	@Override
23 | 	public void onReceive(Context context, Intent intent) {
24 | 
25 | 		final String action = intent.getAction();
26 | 		SharedPreferences prefs = Preferences.getDefaultSharedPreferences(context);
27 | 
28 | 		boolean useStartOnBoot = prefs.getBoolean("restartvpnonboot", false);
29 | 		if (!useStartOnBoot)
30 | 			return;
31 | 
32 | 		if(Intent.ACTION_BOOT_COMPLETED.equals(action) || Intent.ACTION_MY_PACKAGE_REPLACED.equals(action)) {
33 | 			VpnProfile bootProfile = ProfileManager.getAlwaysOnVPN(context);
34 | 			if(bootProfile != null) {
35 | 				launchVPN(bootProfile, context);
36 | 			}		
37 | 		}
38 | 	}
39 | 
40 | 	void launchVPN(VpnProfile profile, Context context) {
41 | 		Intent startVpnIntent = new Intent(Intent.ACTION_MAIN);
42 | 		startVpnIntent.setClass(context, LaunchVPN.class);
43 | 		startVpnIntent.putExtra(LaunchVPN.EXTRA_KEY,profile.getUUIDString());
44 | 		startVpnIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
45 | 		startVpnIntent.putExtra(LaunchVPN.EXTRA_HIDELOG, true);
46 | 
47 | 		context.startActivity(startVpnIntent);
48 | 	}
49 | }
50 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/OpenVpnApi.java:
--------------------------------------------------------------------------------
 1 | package de.blinkt.openvpn;
 2 | 
 3 | import android.annotation.TargetApi;
 4 | import android.content.Context;
 5 | import android.content.Intent;
 6 | import android.net.VpnService;
 7 | import android.os.Build;
 8 | import android.os.RemoteException;
 9 | import android.text.TextUtils;
10 | import android.util.Log;
11 | 
12 | import java.io.IOException;
13 | import java.io.StringReader;
14 | 
15 | import de.blinkt.openvpn.core.ConfigParser;
16 | import de.blinkt.openvpn.core.ProfileManager;
17 | import de.blinkt.openvpn.core.VPNLaunchHelper;
18 | 
19 | public class OpenVpnApi {
20 | 
21 |     private static final String  TAG = "OpenVpnApi";
22 |     @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1)
23 |     public static void startVpn(Context context, String inlineConfig, String sCountry, String userName, String pw) throws RemoteException {
24 |         if (TextUtils.isEmpty(inlineConfig)) throw new RemoteException("config is empty");
25 |             startVpnInternal(context, inlineConfig, sCountry, userName, pw);
26 |     }
27 | 
28 |     static void startVpnInternal(Context context, String inlineConfig, String sCountry, String userName, String pw) throws RemoteException {
29 |         ConfigParser cp = new ConfigParser();
30 |         try {
31 |             cp.parseConfig(new StringReader(inlineConfig));
32 |             VpnProfile vp = cp.convertProfile();// Analysis.ovpn
33 |             Log.d(TAG, "startVpnInternal: =============="+cp+"\n" +
34 |                     vp);
35 |             vp.mName = sCountry;
36 |             if (vp.checkProfile(context) != de.blinkt.openvpn.R.string.no_error_found){
37 |                 throw new RemoteException(context.getString(vp.checkProfile(context)));
38 |             }
39 |             vp.mProfileCreator = context.getPackageName();
40 |             vp.mUsername = userName;
41 |             vp.mPassword = pw;
42 |             ProfileManager.setTemporaryProfile(context, vp);
43 |             VPNLaunchHelper.startOpenVpn(vp, context);
44 |         } catch (IOException | ConfigParser.ConfigParseError e) {
45 |             throw new RemoteException(e.getMessage());
46 |         }
47 |     }
48 | }
49 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/VpnProfile.java:
--------------------------------------------------------------------------------
   1 | /*
   2 |  * Copyright (c) 2012-2016 Arne Schwabe
   3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
   4 |  */
   5 | 
   6 | package de.blinkt.openvpn;
   7 | 
   8 | import android.annotation.SuppressLint;
   9 | import android.content.Context;
  10 | import android.content.Intent;
  11 | import android.content.SharedPreferences;
  12 | import android.content.pm.PackageInfo;
  13 | import android.content.pm.PackageManager;
  14 | import android.os.Build;
  15 | import android.preference.PreferenceManager;
  16 | import android.security.KeyChain;
  17 | import android.security.KeyChainException;
  18 | import androidx.annotation.NonNull;
  19 | import androidx.annotation.Nullable;
  20 | import android.text.TextUtils;
  21 | import android.util.Base64;
  22 | 
  23 | import de.blinkt.openvpn.core.*;
  24 | import org.spongycastle.util.io.pem.PemObject;
  25 | import org.spongycastle.util.io.pem.PemWriter;
  26 | 
  27 | import java.io.File;
  28 | import java.io.FileNotFoundException;
  29 | import java.io.FileReader;
  30 | import java.io.FileWriter;
  31 | import java.io.IOException;
  32 | import java.io.Serializable;
  33 | import java.io.StringWriter;
  34 | import java.lang.reflect.InvocationTargetException;
  35 | import java.lang.reflect.Method;
  36 | import java.security.*;
  37 | import java.security.cert.Certificate;
  38 | import java.security.cert.CertificateException;
  39 | import java.security.cert.X509Certificate;
  40 | import java.util.Collection;
  41 | import java.util.HashSet;
  42 | import java.util.Locale;
  43 | import java.util.UUID;
  44 | import java.util.Vector;
  45 | 
  46 | import javax.crypto.BadPaddingException;
  47 | import javax.crypto.Cipher;
  48 | import javax.crypto.IllegalBlockSizeException;
  49 | import javax.crypto.NoSuchPaddingException;
  50 | 
  51 | public class VpnProfile implements Serializable, Cloneable {
  52 |     // Note that this class cannot be moved to core where it belongs since
  53 |     // the profile loading depends on it being here
  54 |     // The Serializable documentation mentions that class name change are possible
  55 |     // but the how is unclear
  56 |     //
  57 |     transient public static final long MAX_EMBED_FILE_SIZE = 2048 * 1024; // 2048kB
  58 |     // Don't change this, not all parts of the program use this constant
  59 |     public static final String EXTRA_PROFILEUUID = "de.blinkt.openvpn.profileUUID";
  60 |     public static final String INLINE_TAG = "[[INLINE]]";
  61 |     public static final String DISPLAYNAME_TAG = "[[NAME]]";
  62 |     public static final int MAXLOGLEVEL = 4;
  63 |     public static final int CURRENT_PROFILE_VERSION = 8;
  64 |     public static final int DEFAULT_MSSFIX_SIZE = 1280;
  65 |     public static final int TYPE_CERTIFICATES = 0;
  66 |     public static final int TYPE_PKCS12 = 1;
  67 |     public static final int TYPE_KEYSTORE = 2;
  68 |     public static final int TYPE_USERPASS = 3;
  69 |     public static final int TYPE_STATICKEYS = 4;
  70 |     public static final int TYPE_USERPASS_CERTIFICATES = 5;
  71 |     public static final int TYPE_USERPASS_PKCS12 = 6;
  72 |     public static final int TYPE_USERPASS_KEYSTORE = 7;
  73 |     public static final int TYPE_EXTERNAL_APP = 8;
  74 |     public static final int X509_VERIFY_TLSREMOTE = 0;
  75 |     public static final int X509_VERIFY_TLSREMOTE_COMPAT_NOREMAPPING = 1;
  76 |     public static final int X509_VERIFY_TLSREMOTE_DN = 2;
  77 |     public static final int X509_VERIFY_TLSREMOTE_RDN = 3;
  78 |     public static final int X509_VERIFY_TLSREMOTE_RDN_PREFIX = 4;
  79 |     public static final int AUTH_RETRY_NONE_FORGET = 0;
  80 |     public static final int AUTH_RETRY_NOINTERACT = 2;
  81 |     public static final boolean mIsOpenVPN22 = false;
  82 |     private static final long serialVersionUID = 7085688938959334563L;
  83 |     private static final int AUTH_RETRY_NONE_KEEP = 1;
  84 |     private static final int AUTH_RETRY_INTERACT = 3;
  85 |     public static String DEFAULT_DNS1 = "8.8.8.8";
  86 |     public static String DEFAULT_DNS2 = "8.8.4.4";
  87 |     // variable named wrong and should haven beeen transient
  88 |     // but needs to keep wrong name to guarante loading of old
  89 |     // profiles
  90 |     public transient boolean profileDeleted = false;
  91 |     public int mAuthenticationType = TYPE_KEYSTORE;
  92 |     public String mName;
  93 |     public String mAlias;
  94 |     public String mClientCertFilename;
  95 |     public String mTLSAuthDirection = "";
  96 |     public String mTLSAuthFilename;
  97 |     public String mClientKeyFilename;
  98 |     public String mCaFilename;
  99 |     public boolean mUseLzo = true;
 100 |     public String mPKCS12Filename;
 101 |     public String mPKCS12Password;
 102 |     public boolean mUseTLSAuth = false;
 103 |     public String mDNS1 = DEFAULT_DNS1;
 104 |     public String mDNS2 = DEFAULT_DNS2;
 105 |     public String mIPv4Address;
 106 |     public String mIPv6Address;
 107 |     public boolean mOverrideDNS = false;
 108 |     public String mSearchDomain = "blinkt.de";
 109 |     public boolean mUseDefaultRoute = true;
 110 |     public boolean mUsePull = true;
 111 |     public String mCustomRoutes;
 112 |     public boolean mCheckRemoteCN = true;
 113 |     public boolean mExpectTLSCert = false;
 114 |     public String mRemoteCN = "";
 115 |     public String mPassword = "";
 116 |     public String mUsername = "";
 117 |     public boolean mRoutenopull = false;
 118 |     public boolean mUseRandomHostname = false;
 119 |     public boolean mUseFloat = false;
 120 |     public boolean mUseCustomConfig = false;
 121 |     public String mCustomConfigOptions = "";
 122 |     public String mVerb = "1";  //ignored
 123 |     public String mCipher = "";
 124 |     public boolean mNobind = true;
 125 |     public boolean mUseDefaultRoutev6 = true;
 126 |     public String mCustomRoutesv6 = "";
 127 |     public String mKeyPassword = "";
 128 |     public boolean mPersistTun = false;
 129 |     public String mConnectRetryMax = "-1";
 130 |     public String mConnectRetry = "2";
 131 |     public String mConnectRetryMaxTime = "300";
 132 |     public boolean mUserEditable = true;
 133 |     public String mAuth = "";
 134 |     public int mX509AuthType = X509_VERIFY_TLSREMOTE_RDN;
 135 |     public String mx509UsernameField = null;
 136 |     public boolean mAllowLocalLAN;
 137 |     public String mExcludedRoutes;
 138 |     public String mExcludedRoutesv6;
 139 |     public int mMssFix = 0; // -1 is default,
 140 |     public Connection[] mConnections = new Connection[0];
 141 |     public boolean mRemoteRandom = false;
 142 |     public HashSet<String> mAllowedAppsVpn = new HashSet<>();
 143 |     public boolean mAllowedAppsVpnAreDisallowed = true;
 144 |     public boolean mAllowAppVpnBypass = false;
 145 |     public String mCrlFilename;
 146 |     public String mProfileCreator;
 147 |     public String mExternalAuthenticator;
 148 |     public int mAuthRetry = AUTH_RETRY_NONE_FORGET;
 149 |     public int mTunMtu;
 150 |     public boolean mPushPeerInfo = false;
 151 |     public int mVersion = 0;
 152 |     // timestamp when the profile was last used
 153 |     public long mLastUsed;
 154 |     public String importedProfileHash;
 155 |     /* Options no longer used in new profiles */
 156 |     public String mServerName = "openvpn.example.com";
 157 |     public String mServerPort = "1194";
 158 |     public boolean mUseUdp = true;
 159 |     public boolean mTemporaryProfile = false;
 160 |     private transient PrivateKey mPrivateKey;
 161 |     // Public attributes, since I got mad with getter/setter
 162 |     // set members to default values
 163 |     private UUID mUuid;
 164 |     private int mProfileVersion;
 165 | 
 166 |     public boolean mBlockUnusedAddressFamilies =true;
 167 | 
 168 |     public VpnProfile(String name) {
 169 |         mUuid = UUID.randomUUID();
 170 |         mName = name;
 171 |         mProfileVersion = CURRENT_PROFILE_VERSION;
 172 | 
 173 |         mConnections = new Connection[1];
 174 |         mConnections[0] = new Connection();
 175 |         mLastUsed = System.currentTimeMillis();
 176 |     }
 177 | 
 178 |     public static String openVpnEscape(String unescaped) {
 179 |         if (unescaped == null)
 180 |             return null;
 181 |         String escapedString = unescaped.replace("\\", "\\\\");
 182 |         escapedString = escapedString.replace("\"", "\\\"");
 183 |         escapedString = escapedString.replace("\n", "\\n");
 184 | 
 185 |         if (escapedString.equals(unescaped) && !escapedString.contains(" ") &&
 186 |                 !escapedString.contains("#") && !escapedString.contains(";")
 187 |                 && !escapedString.equals(""))
 188 |             return unescaped;
 189 |         else
 190 |             return '"' + escapedString + '"';
 191 |     }
 192 | 
 193 |     public static boolean doUseOpenVPN3(Context c) {
 194 |         // Nerver use OpenVPN3
 195 |         return false;
 196 |     }
 197 | 
 198 |     //! Put inline data inline and other data as normal escaped filename
 199 |     public static String insertFileData(String cfgentry, String filedata) {
 200 |         if (filedata == null) {
 201 |             return String.format("%s %s\n", cfgentry, "file missing in config profile");
 202 |         } else if (isEmbedded(filedata)) {
 203 |             String dataWithOutHeader = getEmbeddedContent(filedata);
 204 |             return String.format(Locale.ENGLISH, "<%s>\n%s\n</%s>\n", cfgentry, dataWithOutHeader, cfgentry);
 205 |         } else {
 206 |             return String.format(Locale.ENGLISH, "%s %s\n", cfgentry, openVpnEscape(filedata));
 207 |         }
 208 |     }
 209 | 
 210 |     public static String getDisplayName(String embeddedFile) {
 211 |         int start = DISPLAYNAME_TAG.length();
 212 |         int end = embeddedFile.indexOf(INLINE_TAG);
 213 |         return embeddedFile.substring(start, end);
 214 |     }
 215 | 
 216 |     public static String getEmbeddedContent(String data) {
 217 |         if (!data.contains(INLINE_TAG))
 218 |             return data;
 219 | 
 220 |         int start = data.indexOf(INLINE_TAG) + INLINE_TAG.length();
 221 |         return data.substring(start);
 222 |     }
 223 | 
 224 |     public static boolean isEmbedded(String data) {
 225 |         if (data == null)
 226 |             return false;
 227 |         if (data.startsWith(INLINE_TAG) || data.startsWith(DISPLAYNAME_TAG))
 228 |             return true;
 229 |         else
 230 |             return false;
 231 |     }
 232 | 
 233 |     @Override
 234 |     public boolean equals(Object obj) {
 235 |         if (obj instanceof VpnProfile) {
 236 |             VpnProfile vpnProfile = (VpnProfile) obj;
 237 |             return mUuid.equals(vpnProfile.mUuid);
 238 |         } else {
 239 |             return false;
 240 |         }
 241 |     }
 242 | 
 243 |     public void clearDefaults() {
 244 |         mServerName = "unknown";
 245 |         mUsePull = false;
 246 |         mUseLzo = false;
 247 |         mUseDefaultRoute = false;
 248 |         mUseDefaultRoutev6 = false;
 249 |         mExpectTLSCert = false;
 250 |         mCheckRemoteCN = false;
 251 |         mPersistTun = false;
 252 |         mAllowLocalLAN = true;
 253 |         mPushPeerInfo = false;
 254 |         mMssFix = 0;
 255 |         mNobind = false;
 256 |     }
 257 | 
 258 |     public UUID getUUID() {
 259 |         return mUuid;
 260 | 
 261 |     }
 262 | 
 263 |     // Only used for the special case of managed profiles
 264 |     public void setUUID(UUID uuid) {
 265 |         mUuid = uuid;
 266 |     }
 267 | 
 268 |     public String getName() {
 269 |         if (TextUtils.isEmpty(mName))
 270 |             return "No profile name";
 271 |         return mName;
 272 |     }
 273 | 
 274 |     public void upgradeProfile() {
 275 | 
 276 |         /* Fallthrough is intended here */
 277 |         switch(mProfileVersion) {
 278 |             case 0:
 279 |             case 1:
 280 |                 /* default to the behaviour the OS used */
 281 |                 mAllowLocalLAN = Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT;
 282 |             case 2:
 283 |             case 3:
 284 |                 moveOptionsToConnection();
 285 |                 mAllowedAppsVpnAreDisallowed = true;
 286 | 
 287 |                 if (mAllowedAppsVpn == null)
 288 |                     mAllowedAppsVpn = new HashSet<>();
 289 | 
 290 |                 if (mConnections == null)
 291 |                     mConnections = new Connection[0];
 292 |             case 4:
 293 |             case 5:
 294 | 
 295 |                 if (TextUtils.isEmpty(mProfileCreator))
 296 |                     mUserEditable = true;
 297 |             case 6:
 298 |                 for (Connection c : mConnections)
 299 |                     if (c.mProxyType == null)
 300 |                         c.mProxyType = Connection.ProxyType.NONE;
 301 |             case 7:
 302 |                 if (mAllowAppVpnBypass)
 303 |                     mBlockUnusedAddressFamilies = !mAllowAppVpnBypass;
 304 |             default:
 305 |         }
 306 | 
 307 |         mProfileVersion = CURRENT_PROFILE_VERSION;
 308 | 
 309 |     }
 310 | 
 311 |     private void moveOptionsToConnection() {
 312 |         mConnections = new Connection[1];
 313 |         Connection conn = new Connection();
 314 | 
 315 |         conn.mServerName = mServerName;
 316 |         conn.mServerPort = mServerPort;
 317 |         conn.mUseUdp = mUseUdp;
 318 |         conn.mCustomConfiguration = "";
 319 | 
 320 |         mConnections[0] = conn;
 321 | 
 322 |     }
 323 | 
 324 |     public String getConfigFile(Context context, boolean configForOvpn3) {
 325 | 
 326 |         File cacheDir = context.getCacheDir();
 327 |         StringBuilder cfg = new StringBuilder();
 328 | 
 329 |         if (!configForOvpn3) {
 330 |             // Enable management interface
 331 |             cfg.append("# Config for OpenVPN 2.x\n");
 332 |             cfg.append("# Enables connection to GUI\n");
 333 |             cfg.append("management ");
 334 | 
 335 |             cfg.append(cacheDir.getAbsolutePath()).append("/").append("mgmtsocket");
 336 |             cfg.append(" unix\n");
 337 |             cfg.append("management-client\n");
 338 |             // Not needed, see updated man page in 2.3
 339 |             //cfg += "management-signal\n";
 340 |             cfg.append("management-query-passwords\n");
 341 |             cfg.append("management-hold\n\n");
 342 | 
 343 |             cfg.append(String.format("setenv IV_GUI_VER %s \n", openVpnEscape(getVersionEnvString(context))));
 344 |             cfg.append("setenv IV_SSO openurl,crtext\n");
 345 |             String versionString = getPlatformVersionEnvString();
 346 |             cfg.append(String.format("setenv IV_PLAT_VER %s\n", openVpnEscape(versionString)));
 347 |         } else {
 348 |             cfg.append("# Config for OpenVPN 3 C++\n");
 349 |         }
 350 | 
 351 | 
 352 |         if (!configForOvpn3) {
 353 |             cfg.append("machine-readable-output\n");
 354 |             if (!mIsOpenVPN22)
 355 |                 cfg.append("allow-recursive-routing\n");
 356 | 
 357 |             // Users are confused by warnings that are misleading...
 358 |             cfg.append("ifconfig-nowarn\n");
 359 |         }
 360 | 
 361 |         boolean useTLSClient = (mAuthenticationType != TYPE_STATICKEYS);
 362 | 
 363 |         if (useTLSClient && mUsePull)
 364 |             cfg.append("client\n");
 365 |         else if (mUsePull)
 366 |             cfg.append("pull\n");
 367 |         else if (useTLSClient)
 368 |             cfg.append("tls-client\n");
 369 | 
 370 | 
 371 |         //cfg += "verb " + mVerb + "\n";
 372 |         cfg.append("verb " + MAXLOGLEVEL + "\n");
 373 | 
 374 |         if (mConnectRetryMax == null) {
 375 |             mConnectRetryMax = "-1";
 376 |         }
 377 | 
 378 |         if (!mConnectRetryMax.equals("-1"))
 379 |             cfg.append("connect-retry-max ").append(mConnectRetryMax).append("\n");
 380 | 
 381 |         if (TextUtils.isEmpty(mConnectRetry))
 382 |             mConnectRetry = "2";
 383 | 
 384 |         if (TextUtils.isEmpty(mConnectRetryMaxTime))
 385 |             mConnectRetryMaxTime = "300";
 386 | 
 387 | 
 388 |         if (!mIsOpenVPN22)
 389 |             cfg.append("connect-retry ").append(mConnectRetry).append(" ").append(mConnectRetryMaxTime).append("\n");
 390 |         else if (mIsOpenVPN22 && !mUseUdp)
 391 |             cfg.append("connect-retry ").append(mConnectRetry).append("\n");
 392 | 
 393 | 
 394 |         cfg.append("resolv-retry 60\n");
 395 | 
 396 | 
 397 |         // We cannot use anything else than tun
 398 |         cfg.append("dev tun\n");
 399 | 
 400 | 
 401 |         boolean canUsePlainRemotes = true;
 402 | 
 403 |         if (mConnections.length == 1) {
 404 |             cfg.append(mConnections[0].getConnectionBlock(configForOvpn3));
 405 |         } else {
 406 |             for (Connection conn : mConnections) {
 407 |                 canUsePlainRemotes = canUsePlainRemotes && conn.isOnlyRemote();
 408 |             }
 409 | 
 410 |             if (mRemoteRandom)
 411 |                 cfg.append("remote-random\n");
 412 | 
 413 |             if (canUsePlainRemotes) {
 414 |                 for (Connection conn : mConnections) {
 415 |                     if (conn.mEnabled) {
 416 |                         cfg.append(conn.getConnectionBlock(configForOvpn3));
 417 |                     }
 418 |                 }
 419 |             }
 420 |         }
 421 | 
 422 | 
 423 |         switch (mAuthenticationType) {
 424 |             case VpnProfile.TYPE_USERPASS_CERTIFICATES:
 425 |                 cfg.append("auth-user-pass\n");
 426 |             case VpnProfile.TYPE_CERTIFICATES:
 427 |                 // Ca
 428 |                 cfg.append(insertFileData("ca", mCaFilename));
 429 | 
 430 |                 // Client Cert + Key
 431 |                 cfg.append(insertFileData("key", mClientKeyFilename));
 432 |                 cfg.append(insertFileData("cert", mClientCertFilename));
 433 | 
 434 |                 break;
 435 |             case VpnProfile.TYPE_USERPASS_PKCS12:
 436 |                 cfg.append("auth-user-pass\n");
 437 |             case VpnProfile.TYPE_PKCS12:
 438 |                 cfg.append(insertFileData("pkcs12", mPKCS12Filename));
 439 | 
 440 |                 if (!TextUtils.isEmpty(mCaFilename))
 441 |                 {
 442 |                     cfg.append(insertFileData("ca", mCaFilename));
 443 |                 }
 444 |                 break;
 445 | 
 446 |             case VpnProfile.TYPE_USERPASS_KEYSTORE:
 447 |                 cfg.append("auth-user-pass\n");
 448 |             case VpnProfile.TYPE_KEYSTORE:
 449 |             case VpnProfile.TYPE_EXTERNAL_APP:
 450 |                 if (!configForOvpn3) {
 451 |                     String[] ks = getExternalCertificates(context);
 452 |                     cfg.append("### From Keystore/ext auth app ####\n");
 453 |                     if (ks != null) {
 454 |                         cfg.append("<ca>\n").append(ks[0]).append("\n</ca>\n");
 455 |                         if (!TextUtils.isEmpty(ks[1]))
 456 |                             cfg.append("<extra-certs>\n").append(ks[1]).append("\n</extra-certs>\n");
 457 |                         cfg.append("<cert>\n").append(ks[2]).append("\n</cert>\n");
 458 |                         cfg.append("management-external-key nopadding\n");
 459 |                     } else {
 460 |                         cfg.append(context.getString(R.string.keychain_access)).append("\n");
 461 |                         if (Build.VERSION.SDK_INT == Build.VERSION_CODES.JELLY_BEAN)
 462 |                             if (!mAlias.matches("^[a-zA-Z0-9]
quot;))
 463 |                                 cfg.append(context.getString(R.string.jelly_keystore_alphanumeric_bug)).append("\n");
 464 |                     }
 465 |                 }
 466 |                 break;
 467 |             case VpnProfile.TYPE_USERPASS:
 468 |                 cfg.append("auth-user-pass\n");
 469 |                 cfg.append(insertFileData("ca", mCaFilename));
 470 |                 if (configForOvpn3) {
 471 |                     // OpenVPN 3 needs to be told that a client certificate is not required
 472 |                     cfg.append("client-cert-not-required\n");
 473 |                 }
 474 |         }
 475 | 
 476 |         if (isUserPWAuth()) {
 477 |             if (mAuthRetry == AUTH_RETRY_NOINTERACT)
 478 |                 cfg.append("auth-retry nointeract\n");
 479 |         }
 480 | 
 481 |         if (!TextUtils.isEmpty(mCrlFilename))
 482 |             cfg.append(insertFileData("crl-verify", mCrlFilename));
 483 | 
 484 |         if (mUseLzo) {
 485 |             cfg.append("comp-lzo\n");
 486 |         }
 487 | 
 488 |         if (mUseTLSAuth) {
 489 |             boolean useTlsCrypt = mTLSAuthDirection.equals("tls-crypt");
 490 |             boolean useTlsCrypt2 = mTLSAuthDirection.equals("tls-crypt-v2");
 491 | 
 492 |             if (mAuthenticationType == TYPE_STATICKEYS)
 493 |                 cfg.append(insertFileData("secret", mTLSAuthFilename));
 494 |             else if (useTlsCrypt)
 495 |                 cfg.append(insertFileData("tls-crypt", mTLSAuthFilename));
 496 |             else if (useTlsCrypt2)
 497 |                 cfg.append(insertFileData("tls-crypt-v2", mTLSAuthFilename));
 498 |             else
 499 |                 cfg.append(insertFileData("tls-auth", mTLSAuthFilename));
 500 | 
 501 |             if (!TextUtils.isEmpty(mTLSAuthDirection) && !useTlsCrypt && !useTlsCrypt2) {
 502 |                 cfg.append("key-direction ");
 503 |                 cfg.append(mTLSAuthDirection);
 504 |                 cfg.append("\n");
 505 |             }
 506 | 
 507 |         }
 508 | 
 509 |         if (!mUsePull) {
 510 |             if (!TextUtils.isEmpty(mIPv4Address))
 511 |                 cfg.append("ifconfig ").append(cidrToIPAndNetmask(mIPv4Address)).append("\n");
 512 | 
 513 |             if (!TextUtils.isEmpty(mIPv6Address)) {
 514 |                 // Use our own ip as gateway since we ignore it anyway
 515 |                 String fakegw = mIPv6Address.split("/", 2)[0];
 516 |                 cfg.append("ifconfig-ipv6 ").append(mIPv6Address).append(" ").append(fakegw).append("\n");
 517 |             }
 518 | 
 519 |         }
 520 | 
 521 |         if (mUsePull && mRoutenopull)
 522 |             cfg.append("route-nopull\n");
 523 | 
 524 |         String routes = "";
 525 | 
 526 |         if (mUseDefaultRoute)
 527 |             routes += "route 0.0.0.0 0.0.0.0 vpn_gateway\n";
 528 |         else {
 529 |             for (String route : getCustomRoutes(mCustomRoutes)) {
 530 |                 routes += "route " + route + " vpn_gateway\n";
 531 |             }
 532 | 
 533 |             for (String route : getCustomRoutes(mExcludedRoutes)) {
 534 |                 routes += "route " + route + " net_gateway\n";
 535 |             }
 536 |         }
 537 | 
 538 | 
 539 |         if (mUseDefaultRoutev6)
 540 |             cfg.append("route-ipv6 ::/0\n");
 541 |         else
 542 |             for (String route : getCustomRoutesv6(mCustomRoutesv6)) {
 543 |                 routes += "route-ipv6 " + route + "\n";
 544 |             }
 545 | 
 546 |         cfg.append(routes);
 547 | 
 548 |         if (mOverrideDNS || !mUsePull) {
 549 |             if (!TextUtils.isEmpty(mDNS1)) {
 550 |                 cfg.append("dhcp-option DNS ").append(mDNS1).append("\n");
 551 |             }
 552 |             if (!TextUtils.isEmpty(mDNS2)) {
 553 |                 cfg.append("dhcp-option DNS ").append(mDNS2).append("\n");
 554 |             }
 555 |             if (!TextUtils.isEmpty(mSearchDomain))
 556 |                 cfg.append("dhcp-option DOMAIN ").append(mSearchDomain).append("\n");
 557 | 
 558 |         }
 559 | 
 560 |         if (mMssFix != 0) {
 561 |             if (mMssFix != 1450) {
 562 |                 if (configForOvpn3)
 563 |                     cfg.append(String.format(Locale.US, "mssfix %d mtu\n", mMssFix));
 564 |                 else
 565 |                     cfg.append(String.format(Locale.US, "mssfix %d\n", mMssFix));
 566 |             } else
 567 |                 cfg.append("mssfix\n");
 568 |         }
 569 | 
 570 |         if (mTunMtu >= 48 && mTunMtu != 1500) {
 571 |             cfg.append(String.format(Locale.US, "tun-mtu %d\n", mTunMtu));
 572 |         }
 573 | 
 574 |         if (mNobind)
 575 |             cfg.append("nobind\n");
 576 | 
 577 | 
 578 |         // Authentication
 579 |         if (mAuthenticationType != TYPE_STATICKEYS) {
 580 |             if (mCheckRemoteCN) {
 581 |                 if (mRemoteCN == null || mRemoteCN.equals(""))
 582 |                     cfg.append("verify-x509-name ").append(openVpnEscape(mConnections[0].mServerName)).append(" name\n");
 583 |                 else
 584 |                     switch (mX509AuthType) {
 585 | 
 586 |                         // 2.2 style x509 checks
 587 |                         case X509_VERIFY_TLSREMOTE_COMPAT_NOREMAPPING:
 588 |                             cfg.append("compat-names no-remapping\n");
 589 |                         case X509_VERIFY_TLSREMOTE:
 590 |                             cfg.append("tls-remote ").append(openVpnEscape(mRemoteCN)).append("\n");
 591 |                             break;
 592 | 
 593 |                         case X509_VERIFY_TLSREMOTE_RDN:
 594 |                             cfg.append("verify-x509-name ").append(openVpnEscape(mRemoteCN)).append(" name\n");
 595 |                             break;
 596 | 
 597 |                         case X509_VERIFY_TLSREMOTE_RDN_PREFIX:
 598 |                             cfg.append("verify-x509-name ").append(openVpnEscape(mRemoteCN)).append(" name-prefix\n");
 599 |                             break;
 600 | 
 601 |                         case X509_VERIFY_TLSREMOTE_DN:
 602 |                             cfg.append("verify-x509-name ").append(openVpnEscape(mRemoteCN)).append("\n");
 603 |                             break;
 604 |                     }
 605 |                 if (!TextUtils.isEmpty(mx509UsernameField))
 606 |                     cfg.append("x509-username-field ").append(openVpnEscape(mx509UsernameField)).append("\n");
 607 |             }
 608 |             if (mExpectTLSCert)
 609 |                 cfg.append("remote-cert-tls server\n");
 610 |         }
 611 | 
 612 |         if (!TextUtils.isEmpty(mCipher)) {
 613 |             cfg.append("cipher ").append(mCipher).append("\n");
 614 |         }
 615 | 
 616 |         if (!TextUtils.isEmpty(mAuth)) {
 617 |             cfg.append("auth ").append(mAuth).append("\n");
 618 |         }
 619 | 
 620 |         // Obscure Settings dialog
 621 |         if (mUseRandomHostname)
 622 |             cfg.append("#my favorite options :)\nremote-random-hostname\n");
 623 | 
 624 |         if (mUseFloat)
 625 |             cfg.append("float\n");
 626 | 
 627 |         if (mPersistTun) {
 628 |             cfg.append("persist-tun\n");
 629 |             cfg.append("# persist-tun also enables pre resolving to avoid DNS resolve problem\n");
 630 |             if (!mIsOpenVPN22)
 631 |                 cfg.append("preresolve\n");
 632 |         }
 633 | 
 634 |         if (mPushPeerInfo)
 635 |             cfg.append("push-peer-info\n");
 636 | 
 637 |         SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
 638 |         boolean usesystemproxy = prefs.getBoolean("usesystemproxy", true);
 639 |         if (usesystemproxy && !mIsOpenVPN22 && !configForOvpn3 && !usesExtraProxyOptions()) {
 640 |             cfg.append("# Use system proxy setting\n");
 641 |             cfg.append("management-query-proxy\n");
 642 |         }
 643 | 
 644 | 
 645 |         if (mUseCustomConfig) {
 646 |             cfg.append("# Custom configuration options\n");
 647 |             cfg.append("# You are on your on own here :)\n");
 648 |             cfg.append(mCustomConfigOptions);
 649 |             cfg.append("\n");
 650 | 
 651 |         }
 652 | 
 653 |         if (!canUsePlainRemotes) {
 654 |             cfg.append("# Connection Options are at the end to allow global options (and global custom options) to influence connection blocks\n");
 655 |             for (Connection conn : mConnections) {
 656 |                 if (conn.mEnabled) {
 657 |                     cfg.append("<connection>\n");
 658 |                     cfg.append(conn.getConnectionBlock(configForOvpn3));
 659 |                     cfg.append("</connection>\n");
 660 |                 }
 661 |             }
 662 |         }
 663 | 
 664 | 
 665 |         return cfg.toString();
 666 |     }
 667 | 
 668 |     public String getPlatformVersionEnvString() {
 669 |         return String.format(Locale.US, "%d %s %s %s %s %s", Build.VERSION.SDK_INT, Build.VERSION.RELEASE,
 670 |                 NativeUtils.getNativeAPI(), Build.BRAND, Build.BOARD, Build.MODEL);
 671 |     }
 672 | 
 673 |     static public String getVersionEnvString(Context c) {
 674 |         String version = "unknown";
 675 |         try {
 676 |             PackageInfo packageinfo = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
 677 |             version = packageinfo.versionName;
 678 |         } catch (PackageManager.NameNotFoundException e) {
 679 |             VpnStatus.logException(e);
 680 |         }
 681 |         return String.format(Locale.US, "%s %s", c.getPackageName(), version);
 682 | 
 683 |     }
 684 | 
 685 |     @NonNull
 686 |     private Collection<String> getCustomRoutes(String routes) {
 687 |         Vector<String> cidrRoutes = new Vector<>();
 688 |         if (routes == null) {
 689 |             // No routes set, return empty vector
 690 |             return cidrRoutes;
 691 |         }
 692 |         for (String route : routes.split("[\n \t]")) {
 693 |             if (!route.equals("")) {
 694 |                 String cidrroute = cidrToIPAndNetmask(route);
 695 |                 if (cidrroute == null)
 696 |                     return cidrRoutes;
 697 | 
 698 |                 cidrRoutes.add(cidrroute);
 699 |             }
 700 |         }
 701 | 
 702 |         return cidrRoutes;
 703 |     }
 704 | 
 705 |     private Collection<String> getCustomRoutesv6(String routes) {
 706 |         Vector<String> cidrRoutes = new Vector<>();
 707 |         if (routes == null) {
 708 |             // No routes set, return empty vector
 709 |             return cidrRoutes;
 710 |         }
 711 |         for (String route : routes.split("[\n \t]")) {
 712 |             if (!route.equals("")) {
 713 |                 cidrRoutes.add(route);
 714 |             }
 715 |         }
 716 | 
 717 |         return cidrRoutes;
 718 |     }
 719 | 
 720 |     private String cidrToIPAndNetmask(String route) {
 721 |         String[] parts = route.split("/");
 722 | 
 723 |         // No /xx, assume /32 as netmask
 724 |         if (parts.length == 1)
 725 |             parts = (route + "/32").split("/");
 726 | 
 727 |         if (parts.length != 2)
 728 |             return null;
 729 |         int len;
 730 |         try {
 731 |             len = Integer.parseInt(parts[1]);
 732 |         } catch (NumberFormatException ne) {
 733 |             return null;
 734 |         }
 735 |         if (len < 0 || len > 32)
 736 |             return null;
 737 | 
 738 | 
 739 |         long nm = 0xffffffffL;
 740 |         nm = (nm << (32 - len)) & 0xffffffffL;
 741 | 
 742 |         String netmask = String.format(Locale.ENGLISH, "%d.%d.%d.%d", (nm & 0xff000000) >> 24, (nm & 0xff0000) >> 16, (nm & 0xff00) >> 8, nm & 0xff);
 743 |         return parts[0] + "  " + netmask;
 744 |     }
 745 | 
 746 |     public Intent prepareStartService(Context context) {
 747 |         Intent intent = getStartServiceIntent(context);
 748 | 
 749 |         // TODO: Handle this?!
 750 | //        if (mAuthenticationType == VpnProfile.TYPE_KEYSTORE || mAuthenticationType == VpnProfile.TYPE_USERPASS_KEYSTORE) {
 751 | //            if (getKeyStoreCertificates(context) == null)
 752 | //                return null;
 753 | //        }
 754 | 
 755 |         return intent;
 756 |     }
 757 | 
 758 |     public void writeConfigFile(Context context) throws IOException {
 759 |         FileWriter cfg = new FileWriter(VPNLaunchHelper.getConfigFilePath(context));
 760 |         cfg.write(getConfigFile(context, false));
 761 |         cfg.flush();
 762 |         cfg.close();
 763 | 
 764 |     }
 765 | 
 766 |     public Intent getStartServiceIntent(Context context) {
 767 |         String prefix = context.getPackageName();
 768 | 
 769 |         Intent intent = new Intent(context, OpenVPNService.class);
 770 |         intent.putExtra(prefix + ".profileUUID", mUuid.toString());
 771 |         intent.putExtra(prefix + ".profileVersion", mVersion);
 772 |         return intent;
 773 |     }
 774 | 
 775 |     public void checkForRestart(final Context context) {
 776 |         /* This method is called when OpenVPNService is restarted */
 777 | 
 778 |         if ((mAuthenticationType == VpnProfile.TYPE_KEYSTORE || mAuthenticationType == VpnProfile.TYPE_USERPASS_KEYSTORE)
 779 |                 && mPrivateKey == null) {
 780 |             new Thread(new Runnable() {
 781 |                 @Override
 782 |                 public void run() {
 783 |                     getExternalCertificates(context);
 784 | 
 785 |                 }
 786 |             }).start();
 787 |         }
 788 |     }
 789 | 
 790 |     @Override
 791 |     protected VpnProfile clone() throws CloneNotSupportedException {
 792 |         VpnProfile copy = (VpnProfile) super.clone();
 793 |         copy.mUuid = UUID.randomUUID();
 794 |         copy.mConnections = new Connection[mConnections.length];
 795 |         int i = 0;
 796 |         for (Connection conn : mConnections) {
 797 |             copy.mConnections[i++] = conn.clone();
 798 |         }
 799 |         copy.mAllowedAppsVpn = (HashSet<String>) mAllowedAppsVpn.clone();
 800 |         return copy;
 801 |     }
 802 | 
 803 |     public VpnProfile copy(String name) {
 804 |         try {
 805 |             VpnProfile copy = clone();
 806 |             copy.mName = name;
 807 |             return copy;
 808 | 
 809 |         } catch (CloneNotSupportedException e) {
 810 |             e.printStackTrace();
 811 |             return null;
 812 |         }
 813 |     }
 814 | 
 815 |     public void pwDidFail(Context c) {
 816 | 
 817 |     }
 818 | 
 819 |     private X509Certificate[] getKeyStoreCertificates(Context context) throws KeyChainException, InterruptedException {
 820 |         PrivateKey privateKey = KeyChain.getPrivateKey(context, mAlias);
 821 |         mPrivateKey = privateKey;
 822 | 
 823 | 
 824 |         X509Certificate[] caChain = KeyChain.getCertificateChain(context, mAlias);
 825 |         return caChain;
 826 |     }
 827 | 
 828 |     private X509Certificate[] getExtAppCertificates(Context context) throws KeyChainException {
 829 |         if (mExternalAuthenticator == null || mAlias == null)
 830 |             throw new KeyChainException("Alias or external auth provider name not set");
 831 |         return ExtAuthHelper.getCertificateChain(context, mExternalAuthenticator, mAlias);
 832 |     }
 833 | 
 834 |     public String[] getExternalCertificates(Context context) {
 835 |         return getExternalCertificates(context, 5);
 836 |     }
 837 | 
 838 | 
 839 |     synchronized String[] getExternalCertificates(Context context, int tries) {
 840 |         // Force application context- KeyChain methods will block long enough that by the time they
 841 |         // are finished and try to unbind, the original activity context might have been destroyed.
 842 |         context = context.getApplicationContext();
 843 | 
 844 |         try {
 845 |             String keystoreChain = null;
 846 | 
 847 |             X509Certificate caChain[];
 848 |             if (mAuthenticationType == TYPE_EXTERNAL_APP) {
 849 |                 caChain = getExtAppCertificates(context);
 850 |             } else {
 851 |                 caChain = getKeyStoreCertificates(context);
 852 |             }
 853 |             if (caChain == null)
 854 |                 throw new NoCertReturnedException("No certificate returned from Keystore");
 855 | 
 856 |             if (caChain.length <= 1 && TextUtils.isEmpty(mCaFilename)) {
 857 |                 VpnStatus.logMessage(VpnStatus.LogLevel.ERROR, "", context.getString(R.string.keychain_nocacert));
 858 |             } else {
 859 |                 StringWriter ksStringWriter = new StringWriter();
 860 | 
 861 |                 PemWriter pw = new PemWriter(ksStringWriter);
 862 |                 for (int i = 1; i < caChain.length; i++) {
 863 |                     X509Certificate cert = caChain[i];
 864 |                     pw.writeObject(new PemObject("CERTIFICATE", cert.getEncoded()));
 865 |                 }
 866 |                 pw.close();
 867 |                 keystoreChain = ksStringWriter.toString();
 868 |             }
 869 | 
 870 | 
 871 |             String caout = null;
 872 |             if (!TextUtils.isEmpty(mCaFilename)) {
 873 |                 try {
 874 |                     Certificate[] cacerts = X509Utils.getCertificatesFromFile(mCaFilename);
 875 |                     StringWriter caoutWriter = new StringWriter();
 876 |                     PemWriter pw = new PemWriter(caoutWriter);
 877 | 
 878 |                     for (Certificate cert : cacerts)
 879 |                         pw.writeObject(new PemObject("CERTIFICATE", cert.getEncoded()));
 880 |                     pw.close();
 881 |                     caout = caoutWriter.toString();
 882 | 
 883 |                 } catch (Exception e) {
 884 |                     VpnStatus.logError("Could not read CA certificate" + e.getLocalizedMessage());
 885 |                 }
 886 |             }
 887 | 
 888 | 
 889 |             StringWriter certout = new StringWriter();
 890 | 
 891 | 
 892 |             if (caChain.length >= 1) {
 893 |                 X509Certificate usercert = caChain[0];
 894 | 
 895 |                 PemWriter upw = new PemWriter(certout);
 896 |                 upw.writeObject(new PemObject("CERTIFICATE", usercert.getEncoded()));
 897 |                 upw.close();
 898 | 
 899 |             }
 900 |             String user = certout.toString();
 901 | 
 902 | 
 903 |             String ca, extra;
 904 |             if (caout == null) {
 905 |                 ca = keystoreChain;
 906 |                 extra = null;
 907 |             } else {
 908 |                 ca = caout;
 909 |                 extra = keystoreChain;
 910 |             }
 911 | 
 912 |             return new String[]{ca, extra, user};
 913 |         } catch (InterruptedException | IOException | KeyChainException | NoCertReturnedException | IllegalArgumentException
 914 |                 | CertificateException e) {
 915 |             e.printStackTrace();
 916 |             VpnStatus.logError(R.string.keyChainAccessError, e.getLocalizedMessage());
 917 | 
 918 |             VpnStatus.logError(R.string.keychain_access);
 919 |             if (Build.VERSION.SDK_INT == Build.VERSION_CODES.JELLY_BEAN) {
 920 |                 if (!mAlias.matches("^[a-zA-Z0-9]
quot;)) {
 921 |                     VpnStatus.logError(R.string.jelly_keystore_alphanumeric_bug);
 922 |                 }
 923 |             }
 924 |             return null;
 925 | 
 926 |         } catch (AssertionError e) {
 927 |             if (tries == 0)
 928 |                 return null;
 929 |             VpnStatus.logError(String.format("Failure getting Keystore Keys (%s), retrying", e.getLocalizedMessage()));
 930 |             try {
 931 |                 Thread.sleep(3000);
 932 |             } catch (InterruptedException e1) {
 933 |                 VpnStatus.logException(e1);
 934 |             }
 935 |             return getExternalCertificates(context, tries - 1);
 936 |         }
 937 | 
 938 |     }
 939 | 
 940 |     public int checkProfile(Context c) {
 941 |         return checkProfile(c, doUseOpenVPN3(c));
 942 |     }
 943 | 
 944 |     //! Return an error if something is wrong
 945 |     public int checkProfile(Context context, boolean useOpenVPN3) {
 946 |         if (mAuthenticationType == TYPE_KEYSTORE || mAuthenticationType == TYPE_USERPASS_KEYSTORE || mAuthenticationType == TYPE_EXTERNAL_APP) {
 947 |             if (mAlias == null)
 948 |                 return R.string.no_keystore_cert_selected;
 949 |         } else if (mAuthenticationType == TYPE_CERTIFICATES || mAuthenticationType == TYPE_USERPASS_CERTIFICATES) {
 950 |             if (TextUtils.isEmpty(mCaFilename))
 951 |                 return R.string.no_ca_cert_selected;
 952 |         }
 953 | 
 954 |         if (mCheckRemoteCN && mX509AuthType == X509_VERIFY_TLSREMOTE)
 955 |             return R.string.deprecated_tls_remote;
 956 | 
 957 |         if (!mUsePull || mAuthenticationType == TYPE_STATICKEYS) {
 958 |             if (mIPv4Address == null || cidrToIPAndNetmask(mIPv4Address) == null)
 959 |                 return R.string.ipv4_format_error;
 960 |         }
 961 |         if (!mUseDefaultRoute) {
 962 |             if (!TextUtils.isEmpty(mCustomRoutes) && getCustomRoutes(mCustomRoutes).size() == 0)
 963 |                 return R.string.custom_route_format_error;
 964 | 
 965 |             if (!TextUtils.isEmpty(mExcludedRoutes) && getCustomRoutes(mExcludedRoutes).size() == 0)
 966 |                 return R.string.custom_route_format_error;
 967 | 
 968 |         }
 969 | 
 970 |         if (mUseTLSAuth && TextUtils.isEmpty(mTLSAuthFilename))
 971 |             return R.string.missing_tlsauth;
 972 | 
 973 |         if ((mAuthenticationType == TYPE_USERPASS_CERTIFICATES || mAuthenticationType == TYPE_CERTIFICATES)
 974 |                 && (TextUtils.isEmpty(mClientCertFilename) || TextUtils.isEmpty(mClientKeyFilename)))
 975 |             return R.string.missing_certificates;
 976 | 
 977 |         if ((mAuthenticationType == TYPE_CERTIFICATES || mAuthenticationType == TYPE_USERPASS_CERTIFICATES)
 978 |                 && TextUtils.isEmpty(mCaFilename))
 979 |             return R.string.missing_ca_certificate;
 980 | 
 981 | 
 982 |         boolean noRemoteEnabled = true;
 983 |         for (Connection c : mConnections) {
 984 |             if (c.mEnabled)
 985 |                 noRemoteEnabled = false;
 986 | 
 987 |         }
 988 |         if (noRemoteEnabled)
 989 |             return R.string.remote_no_server_selected;
 990 | 
 991 |         if (useOpenVPN3) {
 992 |             if (mAuthenticationType == TYPE_STATICKEYS) {
 993 |                 return R.string.openvpn3_nostatickeys;
 994 |             }
 995 |             if (mAuthenticationType == TYPE_PKCS12 || mAuthenticationType == TYPE_USERPASS_PKCS12) {
 996 |                 return R.string.openvpn3_pkcs12;
 997 |             }
 998 |             for (Connection conn : mConnections) {
 999 |                 if (conn.mProxyType == Connection.ProxyType.ORBOT || conn.mProxyType == Connection.ProxyType.SOCKS5)
1000 |                     return R.string.openvpn3_socksproxy;
1001 |             }
1002 |         }
1003 |         for (Connection c : mConnections) {
1004 |             if (c.mProxyType == Connection.ProxyType.ORBOT) {
1005 |                 if (usesExtraProxyOptions())
1006 |                     return R.string.error_orbot_and_proxy_options;
1007 |                 if (!OrbotHelper.checkTorReceier(context))
1008 |                     return R.string.no_orbotfound;
1009 |             }
1010 |         }
1011 | 
1012 | 
1013 |         // Everything okay
1014 |         return R.string.no_error_found;
1015 | 
1016 |     }
1017 | 
1018 |     //! Openvpn asks for a "Private Key", this should be pkcs12 key
1019 |     //
1020 |     public String getPasswordPrivateKey() {
1021 |         String cachedPw = PasswordCache.getPKCS12orCertificatePassword(mUuid, true);
1022 |         if (cachedPw != null) {
1023 |             return cachedPw;
1024 |         }
1025 |         switch (mAuthenticationType) {
1026 |             case TYPE_PKCS12:
1027 |             case TYPE_USERPASS_PKCS12:
1028 |                 return mPKCS12Password;
1029 | 
1030 |             case TYPE_CERTIFICATES:
1031 |             case TYPE_USERPASS_CERTIFICATES:
1032 |                 return mKeyPassword;
1033 | 
1034 |             case TYPE_USERPASS:
1035 |             case TYPE_STATICKEYS:
1036 |             default:
1037 |                 return null;
1038 |         }
1039 |     }
1040 | 
1041 |     public boolean isUserPWAuth() {
1042 |         switch (mAuthenticationType) {
1043 |             case TYPE_USERPASS:
1044 |             case TYPE_USERPASS_CERTIFICATES:
1045 |             case TYPE_USERPASS_KEYSTORE:
1046 |             case TYPE_USERPASS_PKCS12:
1047 |                 return true;
1048 |             default:
1049 |                 return false;
1050 | 
1051 |         }
1052 |     }
1053 | 
1054 |     public boolean requireTLSKeyPassword() {
1055 |         if (TextUtils.isEmpty(mClientKeyFilename))
1056 |             return false;
1057 | 
1058 |         String data = "";
1059 |         if (isEmbedded(mClientKeyFilename))
1060 |             data = mClientKeyFilename;
1061 |         else {
1062 |             char[] buf = new char[2048];
1063 |             FileReader fr;
1064 |             try {
1065 |                 fr = new FileReader(mClientKeyFilename);
1066 |                 int len = fr.read(buf);
1067 |                 while (len > 0) {
1068 |                     data += new String(buf, 0, len);
1069 |                     len = fr.read(buf);
1070 |                 }
1071 |                 fr.close();
1072 |             } catch (FileNotFoundException e) {
1073 |                 return false;
1074 |             } catch (IOException e) {
1075 |                 return false;
1076 |             }
1077 | 
1078 |         }
1079 | 
1080 |         if (data.contains("Proc-Type: 4,ENCRYPTED"))
1081 |             return true;
1082 |         else if (data.contains("-----BEGIN ENCRYPTED PRIVATE KEY-----"))
1083 |             return true;
1084 |         else
1085 |             return false;
1086 |     }
1087 | 
1088 |     public int needUserPWInput(String transientCertOrPkcs12PW, String mTransientAuthPW) {
1089 |         if ((mAuthenticationType == TYPE_PKCS12 || mAuthenticationType == TYPE_USERPASS_PKCS12) &&
1090 |                 (mPKCS12Password == null || mPKCS12Password.equals(""))) {
1091 |             if (transientCertOrPkcs12PW == null)
1092 |                 return R.string.pkcs12_file_encryption_key;
1093 |         }
1094 | 
1095 |         if (mAuthenticationType == TYPE_CERTIFICATES || mAuthenticationType == TYPE_USERPASS_CERTIFICATES) {
1096 |             if (requireTLSKeyPassword() && TextUtils.isEmpty(mKeyPassword))
1097 |                 if (transientCertOrPkcs12PW == null) {
1098 |                     return R.string.private_key_password;
1099 |                 }
1100 |         }
1101 | 
1102 |         if (isUserPWAuth() &&
1103 |                 (TextUtils.isEmpty(mUsername) ||
1104 |                         (TextUtils.isEmpty(mPassword) && mTransientAuthPW == null))) {
1105 |             return R.string.password;
1106 |         }
1107 |         return 0;
1108 |     }
1109 | 
1110 |     public String getPasswordAuth() {
1111 |         String cachedPw = PasswordCache.getAuthPassword(mUuid, true);
1112 |         if (cachedPw != null) {
1113 |             return cachedPw;
1114 |         } else {
1115 |             return mPassword;
1116 |         }
1117 |     }
1118 | 
1119 |     // Used by the Array Adapter
1120 |     @Override
1121 |     public String toString() {
1122 |         return mName;
1123 |     }
1124 | 
1125 |     public String getUUIDString() {
1126 |         return mUuid.toString().toLowerCase(Locale.ENGLISH);
1127 |     }
1128 | 
1129 |     public PrivateKey getKeystoreKey() {
1130 |         return mPrivateKey;
1131 |     }
1132 | 
1133 |     @Nullable
1134 |     public String getSignedData(Context c, String b64data, boolean pkcs1padding) {
1135 |         byte[] data = Base64.decode(b64data, Base64.DEFAULT);
1136 |         byte[] signed_bytes;
1137 |         if (mAuthenticationType == TYPE_EXTERNAL_APP)
1138 |             signed_bytes = getExtAppSignedData(c, data);
1139 |         else
1140 |             signed_bytes = getKeyChainSignedData(data, pkcs1padding);
1141 | 
1142 |         if (signed_bytes != null)
1143 |             return Base64.encodeToString(signed_bytes, Base64.NO_WRAP);
1144 |         else
1145 |             return null;
1146 |     }
1147 | 
1148 |     private byte[] getExtAppSignedData(Context c, byte[] data) {
1149 |         if (TextUtils.isEmpty(mExternalAuthenticator))
1150 |             return null;
1151 |         try {
1152 |             return ExtAuthHelper.signData(c, mExternalAuthenticator, mAlias, data);
1153 |         } catch (KeyChainException | InterruptedException e) {
1154 |             VpnStatus.logError(R.string.error_extapp_sign, mExternalAuthenticator, e.getClass().toString(), e.getLocalizedMessage());
1155 |             return null;
1156 |         }
1157 |     }
1158 | 
1159 |     private byte[] getKeyChainSignedData(byte[] data, boolean pkcs1padding) {
1160 | 
1161 |         PrivateKey privkey = getKeystoreKey();
1162 |         // The Jelly Bean *evil* Hack
1163 |         // 4.2 implements the RSA/ECB/PKCS1PADDING in the OpenSSLprovider
1164 |         if (Build.VERSION.SDK_INT == Build.VERSION_CODES.JELLY_BEAN) {
1165 |             return processSignJellyBeans(privkey, data, pkcs1padding);
1166 |         }
1167 | 
1168 | 
1169 |         try {
1170 |             @SuppressLint("GetInstance")
1171 |             String keyalgorithm = privkey.getAlgorithm();
1172 | 
1173 |             byte[] signed_bytes;
1174 |             if (keyalgorithm.equals("EC")) {
1175 |                 Signature signer = Signature.getInstance("NONEwithECDSA");
1176 | 
1177 |                 signer.initSign(privkey);
1178 |                 signer.update(data);
1179 |                 signed_bytes = signer.sign();
1180 | 
1181 |             } else {
1182 |             /* ECB is perfectly fine in this special case, since we are using it for
1183 |                the public/private part in the TLS exchange
1184 |              */
1185 |                 Cipher signer;
1186 |                 if (pkcs1padding)
1187 |                     signer = Cipher.getInstance("RSA/ECB/PKCS1PADDING");
1188 |                 else
1189 |                     signer = Cipher.getInstance("RSA/ECB/NoPadding");
1190 | 
1191 | 
1192 |                 signer.init(Cipher.ENCRYPT_MODE, privkey);
1193 | 
1194 |                 signed_bytes = signer.doFinal(data);
1195 |             }
1196 |             return signed_bytes;
1197 |         } catch (NoSuchAlgorithmException | InvalidKeyException | IllegalBlockSizeException
1198 |                 | BadPaddingException | NoSuchPaddingException | SignatureException e) {
1199 |             VpnStatus.logError(R.string.error_rsa_sign, e.getClass().toString(), e.getLocalizedMessage());
1200 |             return null;
1201 |         }
1202 |     }
1203 | 
1204 |     private byte[] processSignJellyBeans(PrivateKey privkey, byte[] data, boolean pkcs1padding) {
1205 |         try {
1206 |             Method getKey = privkey.getClass().getSuperclass().getDeclaredMethod("getOpenSSLKey");
1207 |             getKey.setAccessible(true);
1208 | 
1209 |             // Real object type is OpenSSLKey
1210 |             Object opensslkey = getKey.invoke(privkey);
1211 | 
1212 |             getKey.setAccessible(false);
1213 | 
1214 |             Method getPkeyContext = opensslkey.getClass().getDeclaredMethod("getPkeyContext");
1215 | 
1216 |             // integer pointer to EVP_pkey
1217 |             getPkeyContext.setAccessible(true);
1218 |             int pkey = (Integer) getPkeyContext.invoke(opensslkey);
1219 |             getPkeyContext.setAccessible(false);
1220 | 
1221 |             // 112 with TLS 1.2 (172 back with 4.3), 36 with TLS 1.0
1222 |             return NativeUtils.rsasign(data, pkey, pkcs1padding);
1223 | 
1224 |         } catch (NoSuchMethodException | InvalidKeyException | InvocationTargetException | IllegalAccessException | IllegalArgumentException e) {
1225 |             VpnStatus.logError(R.string.error_rsa_sign, e.getClass().toString(), e.getLocalizedMessage());
1226 |             return null;
1227 |         }
1228 |     }
1229 | 
1230 |     private boolean usesExtraProxyOptions() {
1231 |         if (mUseCustomConfig && mCustomConfigOptions != null && mCustomConfigOptions.contains("http-proxy-option "))
1232 |             return true;
1233 |         for (Connection c : mConnections)
1234 |             if (c.usesExtraProxyOptions())
1235 |                 return true;
1236 | 
1237 |         return false;
1238 |     }
1239 | 
1240 |     class NoCertReturnedException extends Exception {
1241 |         public NoCertReturnedException(String msg) {
1242 |             super(msg);
1243 |         }
1244 |     }
1245 | 
1246 | 
1247 | }
1248 | 
1249 | 
1250 | 
1251 | 
1252 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/activities/DisconnectVPN.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.activities;
  7 | 
  8 | import android.app.Activity;
  9 | import android.app.AlertDialog;
 10 | import android.content.ComponentName;
 11 | import android.content.Context;
 12 | import android.content.DialogInterface;
 13 | import android.content.Intent;
 14 | import android.content.ServiceConnection;
 15 | import android.os.IBinder;
 16 | import android.os.RemoteException;
 17 | 
 18 | import de.blinkt.openvpn.LaunchVPN;
 19 | import de.blinkt.openvpn.R;
 20 | import de.blinkt.openvpn.core.IOpenVPNServiceInternal;
 21 | import de.blinkt.openvpn.core.OpenVPNService;
 22 | import de.blinkt.openvpn.core.ProfileManager;
 23 | import de.blinkt.openvpn.core.VpnStatus;
 24 | 
 25 | /**
 26 |  * Created by arne on 13.10.13.
 27 |  */
 28 | public class DisconnectVPN extends Activity implements DialogInterface.OnClickListener, DialogInterface.OnCancelListener {
 29 |     private IOpenVPNServiceInternal mService;
 30 |     private ServiceConnection mConnection = new ServiceConnection() {
 31 | 
 32 | 
 33 | 
 34 |         @Override
 35 |         public void onServiceConnected(ComponentName className,
 36 |                                        IBinder service) {
 37 | 
 38 |             mService = IOpenVPNServiceInternal.Stub.asInterface(service);
 39 |         }
 40 | 
 41 |         @Override
 42 |         public void onServiceDisconnected(ComponentName arg0) {
 43 |             mService = null;
 44 |         }
 45 | 
 46 |     };
 47 | 
 48 |     @Override
 49 |     protected void onResume() {
 50 |         super.onResume();
 51 |         Intent intent = new Intent(this, OpenVPNService.class);
 52 |         intent.setAction(OpenVPNService.START_SERVICE);
 53 |         bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
 54 |         showDisconnectDialog();
 55 |     }
 56 | 
 57 |     @Override
 58 |     protected void onPause() {
 59 |         super.onPause();
 60 |         unbindService(mConnection);
 61 |     }
 62 | 
 63 |     private void showDisconnectDialog() {
 64 |         AlertDialog.Builder builder = new AlertDialog.Builder(this);
 65 |         builder.setTitle(R.string.title_cancel);
 66 |         builder.setMessage(R.string.cancel_connection_query);
 67 |         builder.setNegativeButton(android.R.string.cancel, this);
 68 |         builder.setPositiveButton(R.string.cancel_connection, this);
 69 |         builder.setNeutralButton(R.string.reconnect, this);
 70 |         builder.setOnCancelListener(this);
 71 | 
 72 |         builder.show();
 73 |     }
 74 | 
 75 |     @Override
 76 |     public void onClick(DialogInterface dialog, int which) {
 77 |         if (which == DialogInterface.BUTTON_POSITIVE) {
 78 |             ProfileManager.setConntectedVpnProfileDisconnected(this);
 79 |             if (mService != null) {
 80 |                 try {
 81 |                     mService.stopVPN(false);
 82 |                 } catch (RemoteException e) {
 83 |                     VpnStatus.logException(e);
 84 |                 }
 85 |             }
 86 |         } else if (which == DialogInterface.BUTTON_NEUTRAL) {
 87 |             Intent intent = new Intent(this, LaunchVPN.class);
 88 |             intent.putExtra(LaunchVPN.EXTRA_KEY, VpnStatus.getLastConnectedVPNProfile());
 89 |             intent.setAction(Intent.ACTION_MAIN);
 90 |             startActivity(intent);
 91 |         }
 92 |         finish();
 93 |     }
 94 | 
 95 |     @Override
 96 |     public void onCancel(DialogInterface dialog) {
 97 |         finish();
 98 |     }
 99 | }
100 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/APIVpnProfile.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.api;
 7 | 
 8 | import android.os.Parcel;
 9 | import android.os.Parcelable;
10 | 
11 | public class APIVpnProfile implements Parcelable {
12 | 
13 |     public final String mUUID;
14 |     public final String mName;
15 |     public final boolean mUserEditable;
16 |     //public final String mProfileCreator;
17 | 
18 |     public APIVpnProfile(Parcel in) {
19 |         mUUID = in.readString();
20 |         mName = in.readString();
21 |         mUserEditable = in.readInt() != 0;
22 |         //mProfileCreator = in.readString();
23 |     }
24 | 
25 |     public APIVpnProfile(String uuidString, String name, boolean userEditable, String profileCreator) {
26 |         mUUID = uuidString;
27 |         mName = name;
28 |         mUserEditable = userEditable;
29 |         //mProfileCreator = profileCreator;
30 |     }
31 | 
32 |     @Override
33 |     public int describeContents() {
34 |         return 0;
35 |     }
36 | 
37 |     @Override
38 |     public void writeToParcel(Parcel dest, int flags) {
39 |         dest.writeString(mUUID);
40 |         dest.writeString(mName);
41 |         if (mUserEditable)
42 |             dest.writeInt(0);
43 |         else
44 |             dest.writeInt(1);
45 |         //dest.writeString(mProfileCreator);
46 |     }
47 | 
48 |     public static final Parcelable.Creator<APIVpnProfile> CREATOR
49 |             = new Parcelable.Creator<APIVpnProfile>() {
50 |         public APIVpnProfile createFromParcel(Parcel in) {
51 |             return new APIVpnProfile(in);
52 |         }
53 | 
54 |         public APIVpnProfile[] newArray(int size) {
55 |             return new APIVpnProfile[size];
56 |         }
57 |     };
58 | 
59 | 
60 | }
61 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/AppRestrictions.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2018 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.api;
  7 | 
  8 | import android.annotation.TargetApi;
  9 | import android.content.*;
 10 | import android.os.Build;
 11 | import android.os.Bundle;
 12 | import android.os.Parcelable;
 13 | import de.blinkt.openvpn.VpnProfile;
 14 | import de.blinkt.openvpn.core.ConfigParser;
 15 | import de.blinkt.openvpn.core.Connection;
 16 | import de.blinkt.openvpn.core.ProfileManager;
 17 | import de.blinkt.openvpn.core.VpnStatus;
 18 | 
 19 | import java.io.IOException;
 20 | import java.io.StringReader;
 21 | import java.math.BigInteger;
 22 | import java.security.MessageDigest;
 23 | import java.security.NoSuchAlgorithmException;
 24 | import java.util.*;
 25 | 
 26 | 
 27 | @TargetApi(Build.VERSION_CODES.LOLLIPOP)
 28 | public class AppRestrictions {
 29 |     public static final String PROFILE_CREATOR = "de.blinkt.openvpn.api.AppRestrictions";
 30 |     final static int CONFIG_VERSION = 1;
 31 |     static boolean alreadyChecked = false;
 32 |     private static AppRestrictions mInstance;
 33 |     private RestrictionsManager mRestrictionsMgr;
 34 |     private BroadcastReceiver mRestrictionsReceiver;
 35 | 
 36 |     private AppRestrictions(Context c) {
 37 | 
 38 |     }
 39 | 
 40 |     public static AppRestrictions getInstance(Context c) {
 41 |         if (mInstance == null)
 42 |             mInstance = new AppRestrictions(c);
 43 |         return mInstance;
 44 |     }
 45 | 
 46 |     private void addChangesListener(Context c) {
 47 |         IntentFilter restrictionsFilter =
 48 |                 new IntentFilter(Intent.ACTION_APPLICATION_RESTRICTIONS_CHANGED);
 49 |         mRestrictionsReceiver = new BroadcastReceiver() {
 50 |             @Override
 51 |             public void onReceive(Context context, Intent intent) {
 52 |                 applyRestrictions(context);
 53 |             }
 54 |         };
 55 |         c.registerReceiver(mRestrictionsReceiver, restrictionsFilter);
 56 |     }
 57 | 
 58 |     private void removeChangesListener(Context c) {
 59 |         c.unregisterReceiver(mRestrictionsReceiver);
 60 |     }
 61 | 
 62 |     private String hashConfig(String config) {
 63 |         MessageDigest digest;
 64 |         try {
 65 |             digest = MessageDigest.getInstance("SHA1");
 66 |             byte utf8_bytes[] = config.getBytes();
 67 |             digest.update(utf8_bytes, 0, utf8_bytes.length);
 68 |             return new BigInteger(1, digest.digest()).toString(16);
 69 |         } catch (NoSuchAlgorithmException e) {
 70 |             e.printStackTrace();
 71 |             return null;
 72 |         }
 73 |     }
 74 | 
 75 |     private void applyRestrictions(Context c) {
 76 |         mRestrictionsMgr = (RestrictionsManager) c.getSystemService(Context.RESTRICTIONS_SERVICE);
 77 |         if (mRestrictionsMgr == null)
 78 |             return;
 79 |         Bundle restrictions = mRestrictionsMgr.getApplicationRestrictions();
 80 |         if (restrictions == null)
 81 |             return;
 82 | 
 83 |         String configVersion = restrictions.getString("version", "(not set)");
 84 |         try {
 85 |             if (Integer.parseInt(configVersion) != CONFIG_VERSION)
 86 |                 throw new NumberFormatException("Wrong version");
 87 |         } catch (NumberFormatException nex) {
 88 |             if ("(not set)".equals(configVersion))
 89 |                 // Ignore error if no version present
 90 |                 return;
 91 |             VpnStatus.logError(String.format(Locale.US, "App restriction version %s does not match expected version %d", configVersion, CONFIG_VERSION));
 92 |             return;
 93 |         }
 94 |         Parcelable[] profileList = restrictions.getParcelableArray(("vpn_configuration_list"));
 95 |         if (profileList == null) {
 96 |             VpnStatus.logError("App restriction does not contain a profile list (vpn_configuration_list)");
 97 |             return;
 98 |         }
 99 | 
100 |         Set<String> provisionedUuids = new HashSet<>();
101 | 
102 |         ProfileManager pm = ProfileManager.getInstance(c);
103 |         for (Parcelable profile : profileList) {
104 |             if (!(profile instanceof Bundle)) {
105 |                 VpnStatus.logError("App restriction profile has wrong type");
106 |                 continue;
107 |             }
108 |             Bundle p = (Bundle) profile;
109 | 
110 |             String uuid = p.getString("uuid");
111 |             String ovpn = p.getString("ovpn");
112 |             String name = p.getString("name");
113 | 
114 |             if (uuid == null || ovpn == null || name == null) {
115 |                 VpnStatus.logError("App restriction profile misses uuid, ovpn or name key");
116 |                 continue;
117 |             }
118 | 
119 |             String ovpnHash = hashConfig(ovpn);
120 | 
121 |             provisionedUuids.add(uuid.toLowerCase(Locale.ENGLISH));
122 |             // Check if the profile already exists
123 |             VpnProfile vpnProfile = ProfileManager.get(c, uuid);
124 | 
125 | 
126 |             if (vpnProfile != null) {
127 |                 // Profile exists, check if need to update it
128 |                 if (ovpnHash.equals(vpnProfile.importedProfileHash))
129 |                     // not modified skip to next profile
130 |                     continue;
131 | 
132 |             }
133 |             addProfile(c, ovpn, uuid, name, vpnProfile);
134 |         }
135 | 
136 |         Vector<VpnProfile> profilesToRemove = new Vector<>();
137 |         // get List of all managed profiles
138 |         for (VpnProfile vp: pm.getProfiles())
139 |         {
140 |             if (PROFILE_CREATOR.equals(vp.mProfileCreator)) {
141 |                 if (!provisionedUuids.contains(vp.getUUIDString()))
142 |                     profilesToRemove.add(vp);
143 |             }
144 |         }
145 |         for (VpnProfile vp: profilesToRemove) {
146 |             VpnStatus.logInfo("Remove with uuid: %s and name: %s since it is no longer in the list of managed profiles");
147 |             pm.removeProfile(c, vp);
148 |         }
149 | 
150 |     }
151 | 
152 |     private String prepare(String config) {
153 |         String newLine = System.getProperty("line.separator");
154 |         if (!config.contains(newLine)&& !config.contains(" ")) {
155 |             try {
156 |                 byte[] decoded = android.util.Base64.decode(config.getBytes(), android.util.Base64.DEFAULT);
157 |                 config  = new String(decoded);
158 |                 return config; 
159 |             } catch(IllegalArgumentException e) {
160 |                
161 |             }
162 |         }
163 |         return config;
164 |     };
165 |     
166 |     private void addProfile(Context c, String config, String uuid, String name, VpnProfile vpnProfile) {
167 |         config  = prepare(config);
168 |         ConfigParser cp = new ConfigParser();
169 |         try {
170 |             cp.parseConfig(new StringReader(config));
171 |             VpnProfile vp = cp.convertProfile();
172 |             vp.mProfileCreator = PROFILE_CREATOR;
173 | 
174 |             // We don't want provisioned profiles to be editable
175 |             vp.mUserEditable = false;
176 | 
177 |             vp.mName = name;
178 |             vp.setUUID(UUID.fromString(uuid));
179 |             vp.importedProfileHash = hashConfig(config);
180 | 
181 |             ProfileManager pm = ProfileManager.getInstance(c);
182 | 
183 |             if (vpnProfile != null) {
184 |                 vp.mVersion = vpnProfile.mVersion + 1;
185 |                 vp.mAlias = vpnProfile.mAlias;
186 |             }
187 | 
188 |             // The add method will replace any older profiles with the same UUID
189 |             pm.addProfile(vp);
190 |             pm.saveProfile(c, vp);
191 |             pm.saveProfileList(c);
192 | 
193 |         } catch (ConfigParser.ConfigParseError | IOException | IllegalArgumentException e) {
194 |             VpnStatus.logException("Error during import of managed profile", e);
195 |         }
196 |     }
197 | 
198 |     public void checkRestrictions(Context c) {
199 |         if (alreadyChecked) {
200 |             return;
201 |         }
202 |         alreadyChecked = true;
203 |         addChangesListener(c);
204 |         applyRestrictions(c);
205 |     }
206 | 
207 |     public void pauseCheckRestrictions(Context c)
208 |     {
209 |         removeChangesListener(c);
210 |     }
211 | }
212 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/ConfirmDialog.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (C) 2011 The Android Open Source Project
  3 |  *
  4 |  * Licensed under the Apache License, Version 2.0 (the "License");
  5 |  * you may not use this file except in compliance with the License.
  6 |  * You may obtain a copy of the License at
  7 |  *
  8 |  *      http://www.apache.org/licenses/LICENSE-2.0
  9 |  *
 10 |  * Unless required by applicable law or agreed to in writing, software
 11 |  * distributed under the License is distributed on an "AS IS" BASIS,
 12 |  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 13 |  * See the License for the specific language governing permissions and
 14 |  * limitations under the License.
 15 |  */
 16 | 
 17 | package de.blinkt.openvpn.api;
 18 | 
 19 | import android.app.Activity;
 20 | import android.app.AlertDialog;
 21 | import android.app.AlertDialog.Builder;
 22 | import android.content.ComponentName;
 23 | import android.content.Context;
 24 | import android.content.DialogInterface;
 25 | import android.content.DialogInterface.OnShowListener;
 26 | import android.content.Intent;
 27 | import android.content.ServiceConnection;
 28 | import android.content.pm.ApplicationInfo;
 29 | import android.content.pm.PackageManager;
 30 | import android.os.IBinder;
 31 | import android.os.RemoteException;
 32 | import android.util.Log;
 33 | import android.view.View;
 34 | import android.widget.Button;
 35 | import android.widget.CompoundButton;
 36 | import android.widget.ImageView;
 37 | import android.widget.TextView;
 38 | 
 39 | import de.blinkt.openvpn.R;
 40 | import de.blinkt.openvpn.core.IOpenVPNServiceInternal;
 41 | import de.blinkt.openvpn.core.OpenVPNService;
 42 | 
 43 | 
 44 | public class ConfirmDialog extends Activity implements
 45 |         CompoundButton.OnCheckedChangeListener, DialogInterface.OnClickListener {
 46 |     private static final String TAG = "OpenVPNVpnConfirm";
 47 | 
 48 |     public static final String EXTRA_PACKAGE_NAME = "android.intent.extra.PACKAGE_NAME";
 49 | 
 50 |     public static final String ANONYMOUS_PACKAGE = "de.blinkt.openvpn.ANYPACKAGE";
 51 | 
 52 |     private String mPackage;
 53 | 
 54 |     private Button mButton;
 55 | 
 56 |     private AlertDialog mAlert;
 57 | 
 58 |     private IOpenVPNServiceInternal mService;
 59 |     private ServiceConnection mConnection = new ServiceConnection() {
 60 |         @Override
 61 |         public void onServiceConnected(ComponentName className,
 62 |                                        IBinder service) {
 63 |             mService = IOpenVPNServiceInternal.Stub.asInterface(service);
 64 |         }
 65 | 
 66 |         @Override
 67 |         public void onServiceDisconnected(ComponentName arg0) {
 68 |             mService = null;
 69 |         }
 70 | 
 71 |     };
 72 | 
 73 |     @Override
 74 |     protected void onResume() {
 75 |         super.onResume();
 76 | 
 77 |         Intent serviceintent = new Intent(this, OpenVPNService.class);
 78 |         serviceintent.setAction(OpenVPNService.START_SERVICE);
 79 |         bindService(serviceintent, mConnection, Context.BIND_AUTO_CREATE);
 80 | 
 81 |         Intent intent = getIntent();
 82 |         if (intent.getStringExtra(EXTRA_PACKAGE_NAME) != null) {
 83 |             mPackage = intent.getStringExtra(EXTRA_PACKAGE_NAME);
 84 |         } else {
 85 |             mPackage = getCallingPackage();
 86 |             if (mPackage == null) {
 87 |                 finish();
 88 |                 return;
 89 |             }
 90 |         }
 91 | 
 92 |         try {
 93 |             View view = View.inflate(this, R.layout.api_confirm, null);
 94 |             CharSequence appString;
 95 |             if (mPackage.equals(ANONYMOUS_PACKAGE)) {
 96 |                 appString = getString(R.string.all_app_prompt, getString(R.string.app));
 97 |             } else {
 98 |                 PackageManager pm = getPackageManager();
 99 |                 ApplicationInfo app = pm.getApplicationInfo(mPackage, 0);
100 |                 appString = getString(R.string.prompt, app.loadLabel(pm), getString(R.string.app));
101 |                 ((ImageView) view.findViewById(R.id.icon)).setImageDrawable(app.loadIcon(pm));
102 |             }
103 | 
104 | 
105 |             ((TextView) view.findViewById(R.id.prompt)).setText(appString);
106 |             ((CompoundButton) view.findViewById(R.id.check)).setOnCheckedChangeListener(this);
107 | 
108 | 
109 |             Builder builder = new AlertDialog.Builder(this);
110 | 
111 |             builder.setView(view);
112 | 
113 |             builder.setIconAttribute(android.R.attr.alertDialogIcon);
114 |             builder.setTitle(android.R.string.dialog_alert_title);
115 |             builder.setPositiveButton(android.R.string.ok, this);
116 |             builder.setNegativeButton(android.R.string.cancel, this);
117 | 
118 |             mAlert = builder.create();
119 |             mAlert.setCanceledOnTouchOutside(false);
120 | 
121 |             mAlert.setOnShowListener(new OnShowListener() {
122 |                 @Override
123 |                 public void onShow(DialogInterface dialog) {
124 |                     mButton = mAlert.getButton(DialogInterface.BUTTON_POSITIVE);
125 |                     mButton.setEnabled(false);
126 | 
127 |                 }
128 |             });
129 | 
130 |             //setCloseOnTouchOutside(false);
131 | 
132 |             mAlert.show();
133 | 
134 |         } catch (Exception e) {
135 |             Log.e(TAG, "onResume", e);
136 |             finish();
137 |         }
138 |     }
139 | 
140 |     @Override
141 |     public void onBackPressed() {
142 |         setResult(RESULT_CANCELED);
143 |         finish();
144 |     }
145 | 
146 |     @Override
147 |     public void onCheckedChanged(CompoundButton button, boolean checked) {
148 |         mButton.setEnabled(checked);
149 |     }
150 | 
151 |     @Override
152 |     protected void onPause() {
153 |         super.onPause();
154 |         unbindService(mConnection);
155 | 
156 |     }
157 | 
158 |     @Override
159 |     public void onClick(DialogInterface dialog, int which) {
160 | 
161 |         if (which == DialogInterface.BUTTON_POSITIVE) {
162 |             try {
163 |                 mService.addAllowedExternalApp(mPackage);
164 |             } catch (RemoteException e) {
165 |                 e.printStackTrace();
166 |                 throw new RuntimeException(e);
167 |             }
168 |             setResult(RESULT_OK);
169 |             finish();
170 |         }
171 | 
172 |         if (which == DialogInterface.BUTTON_NEGATIVE) {
173 |             setResult(RESULT_CANCELED);
174 |             finish();
175 |         }
176 |     }
177 | 
178 | }
179 | 
180 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/ExternalAppDatabase.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.api;
  7 | 
  8 | import android.app.Activity;
  9 | import android.content.Context;
 10 | import android.content.Intent;
 11 | import android.content.SharedPreferences;
 12 | import android.content.SharedPreferences.Editor;
 13 | import android.content.pm.ApplicationInfo;
 14 | import android.content.pm.PackageManager;
 15 | import android.os.Binder;
 16 | 
 17 | import java.util.HashSet;
 18 | import java.util.Set;
 19 | 
 20 | import de.blinkt.openvpn.core.Preferences;
 21 | 
 22 | import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;
 23 | 
 24 | public class ExternalAppDatabase {
 25 | 
 26 | 	Context mContext;
 27 | 	
 28 | 	public ExternalAppDatabase(Context c) {
 29 | 		mContext =c;
 30 | 	}
 31 | 
 32 | 	private final String PREFERENCES_KEY = "allowed_apps";
 33 | 
 34 | 	boolean isAllowed(String packagename) {
 35 | 		Set<String> allowedapps = getExtAppList();
 36 | 
 37 | 		return allowedapps.contains(packagename); 
 38 | 
 39 | 	}
 40 | 
 41 | 	public Set<String> getExtAppList() {
 42 | 		SharedPreferences prefs = Preferences.getDefaultSharedPreferences(mContext);
 43 |         return prefs.getStringSet(PREFERENCES_KEY, new HashSet<String>());
 44 | 	}
 45 | 	
 46 | 	public void addApp(String packagename)
 47 | 	{
 48 | 		Set<String> allowedapps = getExtAppList();
 49 | 		allowedapps.add(packagename);
 50 | 		saveExtAppList(allowedapps);
 51 | 	}
 52 | 
 53 | 	private void saveExtAppList( Set<String> allowedapps) {
 54 | 		SharedPreferences prefs = Preferences.getDefaultSharedPreferences(mContext);
 55 | 		Editor prefedit = prefs.edit();
 56 | 
 57 | 		// Workaround for bug
 58 | 		prefedit.putStringSet(PREFERENCES_KEY, allowedapps);
 59 | 		int counter = prefs.getInt("counter", 0);
 60 | 		prefedit.putInt("counter", counter + 1);
 61 | 		prefedit.apply();
 62 | 	}
 63 | 	
 64 | 	public void clearAllApiApps() {
 65 | 		saveExtAppList(new HashSet<String>());
 66 | 	}
 67 | 
 68 | 	public void removeApp(String packagename) {
 69 | 		Set<String> allowedapps = getExtAppList();
 70 | 		allowedapps.remove(packagename);
 71 | 		saveExtAppList(allowedapps);		
 72 | 	}
 73 | 
 74 | 
 75 | 	public String checkOpenVPNPermission(PackageManager pm) throws SecurityRemoteException {
 76 | 
 77 | 		for (String appPackage : getExtAppList()) {
 78 | 			ApplicationInfo app;
 79 | 			try {
 80 | 				app = pm.getApplicationInfo(appPackage, 0);
 81 | 				if (Binder.getCallingUid() == app.uid) {
 82 | 					return appPackage;
 83 | 				}
 84 | 			} catch (PackageManager.NameNotFoundException e) {
 85 | 				// App not found. Remove it from the list
 86 | 				removeApp(appPackage);
 87 | 			}
 88 | 
 89 | 		}
 90 | 		throw new SecurityException("Unauthorized OpenVPN API Caller");
 91 | 	}
 92 | 
 93 | 
 94 | 	public boolean checkRemoteActionPermission(Context c, String callingPackage) {
 95 | 		if (callingPackage == null)
 96 | 			callingPackage = ConfirmDialog.ANONYMOUS_PACKAGE;
 97 | 
 98 | 		if (isAllowed(callingPackage)) {
 99 | 			return true;
100 | 		} else {
101 | 			Intent confirmDialog = new Intent(c, ConfirmDialog.class);
102 | 			confirmDialog.addFlags(FLAG_ACTIVITY_NEW_TASK);
103 | 			confirmDialog.putExtra(ConfirmDialog.EXTRA_PACKAGE_NAME, callingPackage);
104 | 			c.startActivity(confirmDialog);
105 | 			return false;
106 | 		}
107 | 	}
108 | }
109 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/ExternalOpenVPNService.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.api;
  7 | 
  8 | import android.annotation.TargetApi;
  9 | import android.app.PendingIntent;
 10 | import android.app.Service;
 11 | import android.content.BroadcastReceiver;
 12 | import android.content.ComponentName;
 13 | import android.content.Context;
 14 | import android.content.Intent;
 15 | import android.content.IntentFilter;
 16 | import android.content.ServiceConnection;
 17 | import android.content.pm.ApplicationInfo;
 18 | import android.content.pm.PackageManager;
 19 | import android.content.pm.PackageManager.NameNotFoundException;
 20 | import android.net.VpnService;
 21 | import android.os.Binder;
 22 | import android.os.Build;
 23 | import android.os.Handler;
 24 | import android.os.IBinder;
 25 | import android.os.Message;
 26 | import android.os.ParcelFileDescriptor;
 27 | import android.os.RemoteCallbackList;
 28 | import android.os.RemoteException;
 29 | 
 30 | import java.io.IOException;
 31 | import java.io.StringReader;
 32 | import java.lang.ref.WeakReference;
 33 | import java.util.LinkedList;
 34 | import java.util.List;
 35 | 
 36 | import de.blinkt.openvpn.R;
 37 | import de.blinkt.openvpn.VpnProfile;
 38 | import de.blinkt.openvpn.core.ConfigParser;
 39 | import de.blinkt.openvpn.core.ConfigParser.ConfigParseError;
 40 | import de.blinkt.openvpn.core.ConnectionStatus;
 41 | import de.blinkt.openvpn.core.IOpenVPNServiceInternal;
 42 | import de.blinkt.openvpn.core.OpenVPNService;
 43 | import de.blinkt.openvpn.core.ProfileManager;
 44 | import de.blinkt.openvpn.core.VPNLaunchHelper;
 45 | import de.blinkt.openvpn.core.VpnStatus;
 46 | import de.blinkt.openvpn.core.VpnStatus.StateListener;
 47 | 
 48 | @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1)
 49 | public class ExternalOpenVPNService extends Service implements StateListener {
 50 | 
 51 |     private static final int SEND_TOALL = 0;
 52 | 
 53 |     final RemoteCallbackList<IOpenVPNStatusCallback> mCallbacks =
 54 |             new RemoteCallbackList<>();
 55 | 
 56 |     private IOpenVPNServiceInternal mService;
 57 |     private ExternalAppDatabase mExtAppDb;
 58 | 
 59 | 
 60 |     private ServiceConnection mConnection = new ServiceConnection() {
 61 | 
 62 | 
 63 |         @Override
 64 |         public void onServiceConnected(ComponentName className,
 65 |                                        IBinder service) {
 66 |             // We've bound to LocalService, cast the IBinder and get LocalService instance
 67 |             mService = (IOpenVPNServiceInternal) (service);
 68 |         }
 69 | 
 70 |         @Override
 71 |         public void onServiceDisconnected(ComponentName arg0) {
 72 |             mService = null;
 73 |         }
 74 | 
 75 |     };
 76 | 
 77 |     private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
 78 |         @Override
 79 |         public void onReceive(Context context, Intent intent) {
 80 |             if (intent != null && Intent.ACTION_UNINSTALL_PACKAGE.equals(intent.getAction())){
 81 |                 // Check if the running config is temporary and installed by the app being uninstalled
 82 |                 VpnProfile vp = ProfileManager.getLastConnectedVpn();
 83 |                 if (ProfileManager.isTempProfile()) {
 84 |                     if(intent.getPackage().equals(vp.mProfileCreator)) {
 85 |                         if (mService != null)
 86 |                             try {
 87 |                                 mService.stopVPN(false);
 88 |                             } catch (RemoteException e) {
 89 |                                 e.printStackTrace();
 90 |                             }
 91 |                     }
 92 |                 }
 93 |             }
 94 |         }
 95 |     };
 96 | 
 97 |     @Override
 98 |     public void onCreate() {
 99 |         super.onCreate();
100 |         VpnStatus.addStateListener(this);
101 |         mExtAppDb = new ExternalAppDatabase(this);
102 | 
103 |         Intent intent = new Intent(getBaseContext(), OpenVPNService.class);
104 |         intent.setAction(OpenVPNService.START_SERVICE);
105 | 
106 |         bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
107 |         mHandler.setService(this);
108 |         IntentFilter uninstallBroadcast = new IntentFilter(Intent.ACTION_PACKAGE_REMOVED );
109 |         registerReceiver(mBroadcastReceiver, uninstallBroadcast);
110 | 
111 |     }
112 | 
113 |     private final IOpenVPNAPIService.Stub mBinder = new IOpenVPNAPIService.Stub() {
114 | 
115 |         @Override
116 |         public List<APIVpnProfile> getProfiles() throws RemoteException {
117 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
118 | 
119 |             ProfileManager pm = ProfileManager.getInstance(getBaseContext());
120 | 
121 |             List<APIVpnProfile> profiles = new LinkedList<>();
122 | 
123 |             for (VpnProfile vp : pm.getProfiles()) {
124 |                 if (!vp.profileDeleted)
125 |                     profiles.add(new APIVpnProfile(vp.getUUIDString(), vp.mName, vp.mUserEditable, vp.mProfileCreator));
126 |             }
127 | 
128 |             return profiles;
129 |         }
130 | 
131 | 
132 |         private void startProfile(VpnProfile vp)
133 |         {
134 |             Intent vpnPermissionIntent = VpnService.prepare(ExternalOpenVPNService.this);
135 |             /* Check if we need to show the confirmation dialog,
136 |              * Check if we need to ask for username/password */
137 | 
138 |             int neddPassword = vp.needUserPWInput(null, null);
139 | 
140 |             if(vpnPermissionIntent != null || neddPassword != 0){
141 |                 Intent shortVPNIntent = new Intent(Intent.ACTION_MAIN);
142 |                 shortVPNIntent.setClass(getBaseContext(), de.blinkt.openvpn.LaunchVPN.class);
143 |                 shortVPNIntent.putExtra(de.blinkt.openvpn.LaunchVPN.EXTRA_KEY, vp.getUUIDString());
144 |                 shortVPNIntent.putExtra(de.blinkt.openvpn.LaunchVPN.EXTRA_HIDELOG, true);
145 |                 shortVPNIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
146 |                 startActivity(shortVPNIntent);
147 |             } else {
148 |                 VPNLaunchHelper.startOpenVpn(vp, getBaseContext());
149 |             }
150 | 
151 |         }
152 | 
153 |         @Override
154 |         public void startProfile(String profileUUID) throws RemoteException {
155 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
156 | 
157 |             VpnProfile vp = ProfileManager.get(getBaseContext(), profileUUID);
158 |             if (vp.checkProfile(getApplicationContext()) != R.string.no_error_found)
159 |                 throw new RemoteException(getString(vp.checkProfile(getApplicationContext())));
160 | 
161 |             startProfile(vp);
162 |         }
163 | 
164 |         public void startVPN(String inlineConfig) throws RemoteException {
165 |             String callingApp = mExtAppDb.checkOpenVPNPermission(getPackageManager());
166 | 
167 |             ConfigParser cp = new ConfigParser();
168 |             try {
169 |                 cp.parseConfig(new StringReader(inlineConfig));
170 |                 VpnProfile vp = cp.convertProfile();
171 |                 vp.mName = "Remote APP VPN";
172 |                 if (vp.checkProfile(getApplicationContext()) != R.string.no_error_found)
173 |                     throw new RemoteException(getString(vp.checkProfile(getApplicationContext())));
174 | 
175 |                 vp.mProfileCreator = callingApp;
176 | 
177 |                 /*int needpw = vp.needUserPWInput(false);
178 |                 if(needpw !=0)
179 |                     throw new RemoteException("The inline file would require user input: " + getString(needpw));
180 |                     */
181 | 
182 |                 ProfileManager.setTemporaryProfile(ExternalOpenVPNService.this, vp);
183 | 
184 |                 startProfile(vp);
185 | 
186 |             } catch (IOException | ConfigParseError e) {
187 |                 throw new RemoteException(e.getMessage());
188 |             }
189 |         }
190 | 
191 | 
192 |         @Override
193 |         public boolean addVPNProfile(String name, String config) throws RemoteException {
194 |             return addNewVPNProfile(name, true, config) != null;
195 |         }
196 | 
197 | 
198 |         @Override
199 |         public APIVpnProfile addNewVPNProfile(String name, boolean userEditable, String config) throws RemoteException {
200 |             String callingPackage = mExtAppDb.checkOpenVPNPermission(getPackageManager());
201 | 
202 |             ConfigParser cp = new ConfigParser();
203 |             try {
204 |                 cp.parseConfig(new StringReader(config));
205 |                 VpnProfile vp = cp.convertProfile();
206 |                 vp.mName = name;
207 |                 vp.mProfileCreator = callingPackage;
208 |                 vp.mUserEditable = userEditable;
209 |                 ProfileManager pm = ProfileManager.getInstance(getBaseContext());
210 |                 pm.addProfile(vp);
211 |                 pm.saveProfile(ExternalOpenVPNService.this, vp);
212 |                 pm.saveProfileList(ExternalOpenVPNService.this);
213 |                 return new APIVpnProfile(vp.getUUIDString(), vp.mName, vp.mUserEditable, vp.mProfileCreator);
214 |             } catch (IOException e) {
215 |                 VpnStatus.logException(e);
216 |                 return null;
217 |             } catch (ConfigParseError e) {
218 |                 VpnStatus.logException(e);
219 |                 return null;
220 |             }
221 |         }
222 | 
223 |         @Override
224 |         public void removeProfile(String profileUUID) throws RemoteException {
225 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
226 |             ProfileManager pm = ProfileManager.getInstance(getBaseContext());
227 |             VpnProfile vp = ProfileManager.get(getBaseContext(), profileUUID);
228 |             pm.removeProfile(ExternalOpenVPNService.this, vp);
229 |         }
230 | 
231 |         @Override
232 |         public boolean protectSocket(ParcelFileDescriptor pfd) throws RemoteException {
233 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
234 |             try {
235 |                 boolean success= mService.protect(pfd.getFd());
236 |                 pfd.close();
237 |                 return success;
238 |             } catch (IOException e) {
239 |                 throw new RemoteException(e.getMessage());
240 |             }
241 |         }
242 | 
243 | 
244 |         @Override
245 |         public Intent prepare(String packageName) {
246 |             if (new ExternalAppDatabase(ExternalOpenVPNService.this).isAllowed(packageName))
247 |                 return null;
248 | 
249 |             Intent intent = new Intent();
250 |             intent.setClass(ExternalOpenVPNService.this, ConfirmDialog.class);
251 |             return intent;
252 |         }
253 | 
254 |         @Override
255 |         public Intent prepareVPNService() throws RemoteException {
256 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
257 | 
258 |             if (VpnService.prepare(ExternalOpenVPNService.this) == null)
259 |                 return null;
260 |             else
261 |                 return new Intent(getBaseContext(), GrantPermissionsActivity.class);
262 |         }
263 | 
264 | 
265 |         @Override
266 |         public void registerStatusCallback(IOpenVPNStatusCallback cb)
267 |                 throws RemoteException {
268 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
269 | 
270 |             if (cb != null) {
271 |                 cb.newStatus(mMostRecentState.vpnUUID, mMostRecentState.state,
272 |                         mMostRecentState.logmessage, mMostRecentState.level.name());
273 |                 mCallbacks.register(cb);
274 |             }
275 | 
276 | 
277 |         }
278 | 
279 |         @Override
280 |         public void unregisterStatusCallback(IOpenVPNStatusCallback cb)
281 |                 throws RemoteException {
282 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
283 | 
284 |             if (cb != null)
285 |                 mCallbacks.unregister(cb);
286 |         }
287 | 
288 |         @Override
289 |         public void disconnect() throws RemoteException {
290 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
291 |             if (mService != null)
292 |                 mService.stopVPN(false);
293 |         }
294 | 
295 |         @Override
296 |         public void pause() throws RemoteException {
297 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
298 |             if (mService != null)
299 |                 mService.userPause(true);
300 |         }
301 | 
302 |         @Override
303 |         public void resume() throws RemoteException {
304 |             mExtAppDb.checkOpenVPNPermission(getPackageManager());
305 |             if (mService != null)
306 |                 mService.userPause(false);
307 | 
308 |         }
309 |     };
310 | 
311 | 
312 |     private UpdateMessage mMostRecentState;
313 | 
314 |     @Override
315 |     public IBinder onBind(Intent intent) {
316 |         return mBinder;
317 |     }
318 | 
319 |     @Override
320 |     public void onDestroy() {
321 |         super.onDestroy();
322 |         mCallbacks.kill();
323 |         unbindService(mConnection);
324 |         VpnStatus.removeStateListener(this);
325 |         unregisterReceiver(mBroadcastReceiver);
326 |     }
327 | 
328 | 
329 | 
330 |     class UpdateMessage {
331 |         public String state;
332 |         public String logmessage;
333 |         public ConnectionStatus level;
334 |         String vpnUUID;
335 | 
336 |         UpdateMessage(String state, String logmessage, ConnectionStatus level) {
337 |             this.state = state;
338 |             this.logmessage = logmessage;
339 |             this.level = level;
340 |         }
341 |     }
342 | 
343 |     @Override
344 |     public void updateState(String state, String logmessage, int resid, ConnectionStatus level, Intent intent) {
345 |         mMostRecentState = new UpdateMessage(state, logmessage, level);
346 |         if (ProfileManager.getLastConnectedVpn() != null)
347 |             mMostRecentState.vpnUUID = ProfileManager.getLastConnectedVpn().getUUIDString();
348 | 
349 |         Message msg = mHandler.obtainMessage(SEND_TOALL, mMostRecentState);
350 |         msg.sendToTarget();
351 | 
352 |     }
353 | 
354 |     @Override
355 |     public void setConnectedVPN(String uuid) {
356 | 
357 |     }
358 | 
359 |     private static final OpenVPNServiceHandler mHandler = new OpenVPNServiceHandler();
360 | 
361 | 
362 |     static class OpenVPNServiceHandler extends Handler {
363 |         WeakReference<ExternalOpenVPNService> service = null;
364 | 
365 |         private void setService(ExternalOpenVPNService eos) {
366 |             service = new WeakReference<>(eos);
367 |         }
368 | 
369 |         @Override
370 |         public void handleMessage(Message msg) {
371 | 
372 |             RemoteCallbackList<IOpenVPNStatusCallback> callbacks;
373 |             switch (msg.what) {
374 |                 case SEND_TOALL:
375 |                     if (service == null || service.get() == null)
376 |                         return;
377 | 
378 |                     callbacks = service.get().mCallbacks;
379 | 
380 | 
381 |                     // Broadcast to all clients the new value.
382 |                     final int N = callbacks.beginBroadcast();
383 |                     for (int i = 0; i < N; i++) {
384 |                         try {
385 |                             sendUpdate(callbacks.getBroadcastItem(i), (UpdateMessage) msg.obj);
386 |                         } catch (RemoteException e) {
387 |                             // The RemoteCallbackList will take care of removing
388 |                             // the dead object for us.
389 |                         }
390 |                     }
391 |                     callbacks.finishBroadcast();
392 |                     break;
393 |             }
394 |         }
395 | 
396 |         private void sendUpdate(IOpenVPNStatusCallback broadcastItem,
397 |                                 UpdateMessage um) throws RemoteException {
398 |             broadcastItem.newStatus(um.vpnUUID, um.state, um.logmessage, um.level.name());
399 |         }
400 |     }
401 | 
402 | 
403 | 
404 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/GrantPermissionsActivity.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.api;
 7 | 
 8 | import android.app.Activity;
 9 | import android.content.Intent;
10 | import android.net.VpnService;
11 | 
12 | public class GrantPermissionsActivity extends Activity {
13 | 	private static final int VPN_PREPARE = 0;
14 | 
15 | 	@Override
16 | 	protected void onStart() {
17 | 		super.onStart();
18 | 		Intent i= VpnService.prepare(this);
19 | 		if(i==null)
20 | 			onActivityResult(VPN_PREPARE, RESULT_OK, null);
21 | 		else
22 | 			startActivityForResult(i, VPN_PREPARE);
23 | 	}
24 | 	
25 | 	@Override
26 | 	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
27 | 		super.onActivityResult(requestCode, resultCode, data);
28 | 		setResult(resultCode);
29 | 		finish();
30 | 	}
31 | }
32 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/RemoteAction.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2017 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.api;
  7 | 
  8 | import android.app.Activity;
  9 | import android.content.ComponentName;
 10 | import android.content.Context;
 11 | import android.content.Intent;
 12 | import android.content.ServiceConnection;
 13 | import android.os.Bundle;
 14 | import android.os.IBinder;
 15 | import android.os.RemoteException;
 16 | import android.widget.Toast;
 17 | 
 18 | import de.blinkt.openvpn.LaunchVPN;
 19 | import de.blinkt.openvpn.VpnProfile;
 20 | import de.blinkt.openvpn.core.IOpenVPNServiceInternal;
 21 | import de.blinkt.openvpn.core.OpenVPNService;
 22 | import de.blinkt.openvpn.core.ProfileManager;
 23 | 
 24 | public class RemoteAction extends Activity {
 25 | 
 26 |     public static final String EXTRA_NAME = "de.blinkt.openvpn.api.profileName";
 27 |     private ExternalAppDatabase mExtAppDb;
 28 |     private boolean mDoDisconnect;
 29 |     private IOpenVPNServiceInternal mService;
 30 |     private ServiceConnection mConnection = new ServiceConnection() {
 31 |         @Override
 32 |         public void onServiceConnected(ComponentName className,
 33 |                                        IBinder service) {
 34 | 
 35 |             mService = IOpenVPNServiceInternal.Stub.asInterface(service);
 36 |             try {
 37 |                 performAction();
 38 |             } catch (RemoteException e) {
 39 |                 e.printStackTrace();
 40 |             }
 41 |         }
 42 | 
 43 |         @Override
 44 |         public void onServiceDisconnected(ComponentName arg0) {
 45 |             //mService = null;
 46 |         }
 47 | 
 48 |     };
 49 | 
 50 |     @Override
 51 |     protected void onCreate(Bundle savedInstanceState) {
 52 |         super.onCreate(savedInstanceState);
 53 | 
 54 |         mExtAppDb = new ExternalAppDatabase(this);
 55 |     }
 56 | 
 57 |     @Override
 58 |     protected void onResume() {
 59 |         super.onResume();
 60 | 
 61 |         Intent intent = new Intent(this, OpenVPNService.class);
 62 |         intent.setAction(OpenVPNService.START_SERVICE);
 63 |         getApplicationContext().bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
 64 | 
 65 |     }
 66 | 
 67 |     private void performAction() throws RemoteException {
 68 | 
 69 |         if (!mService.isAllowedExternalApp(getCallingPackage())) {
 70 |             finish();
 71 |             return;
 72 |         }
 73 | 
 74 |         Intent intent = getIntent();
 75 |         setIntent(null);
 76 |         ComponentName component = intent.getComponent();
 77 |         if (component.getShortClassName().equals(".api.DisconnectVPN")) {
 78 |             mService.stopVPN(false);
 79 |         } else if (component.getShortClassName().equals(".api.ConnectVPN")) {
 80 |             String vpnName = intent.getStringExtra(EXTRA_NAME);
 81 |             VpnProfile profile = ProfileManager.getInstance(this).getProfileByName(vpnName);
 82 |             if (profile == null) {
 83 |                 Toast.makeText(this, String.format("Vpn profile %s from API call not found", vpnName), Toast.LENGTH_LONG).show();
 84 |             } else {
 85 |                 Intent startVPN = new Intent(this, LaunchVPN.class);
 86 |                 startVPN.putExtra(LaunchVPN.EXTRA_KEY, profile.getUUID().toString());
 87 |                 startVPN.setAction(Intent.ACTION_MAIN);
 88 |                 startActivity(startVPN);
 89 |             }
 90 |         }
 91 |         finish();
 92 | 
 93 | 
 94 | 
 95 |     }
 96 | 
 97 |     @Override
 98 |     public void finish() {
 99 |         if(mService!=null) {
100 |             mService = null;
101 |             getApplicationContext().unbindService(mConnection);
102 |         }
103 |         super.finish();
104 |     }
105 | }
106 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/api/SecurityRemoteException.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.api;
 7 | 
 8 | import android.os.RemoteException;
 9 | 
10 | public class SecurityRemoteException extends RemoteException {
11 | 
12 | 	/**
13 | 	 * 
14 | 	 */
15 | 	private static final long serialVersionUID = 1L;
16 | 
17 | }
18 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/CIDRIP.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import java.util.Locale;
 9 | 
10 | class CIDRIP {
11 |     String mIp;
12 |     int len;
13 | 
14 | 
15 |     public CIDRIP(String ip, String mask) {
16 |         mIp = ip;
17 |         len = calculateLenFromMask(mask);
18 | 
19 |     }
20 | 
21 |     public static int calculateLenFromMask(String mask) {
22 |         long netmask = getInt(mask);
23 | 
24 |         // Add 33. bit to ensure the loop terminates
25 |         netmask += 1l << 32;
26 | 
27 |         int lenZeros = 0;
28 |         while ((netmask & 0x1) == 0) {
29 |             lenZeros++;
30 |             netmask = netmask >> 1;
31 |         }
32 |         int len;
33 |         // Check if rest of netmask is only 1s
34 |         if (netmask != (0x1ffffffffl >> lenZeros)) {
35 |             // Asume no CIDR, set /32
36 |             len = 32;
37 |         } else {
38 |             len = 32 - lenZeros;
39 |         }
40 |         return len;
41 |     }
42 | 
43 |     public CIDRIP(String address, int prefix_length) {
44 |         len = prefix_length;
45 |         mIp = address;
46 |     }
47 | 
48 |     @Override
49 |     public String toString() {
50 |         return String.format(Locale.ENGLISH, "%s/%d", mIp, len);
51 |     }
52 | 
53 |     public boolean normalise() {
54 |         long ip = getInt(mIp);
55 | 
56 |         long newip = ip & (0xffffffffL << (32 - len));
57 |         if (newip != ip) {
58 |             mIp = String.format(Locale.US,"%d.%d.%d.%d", (newip & 0xff000000) >> 24, (newip & 0xff0000) >> 16, (newip & 0xff00) >> 8, newip & 0xff);
59 |             return true;
60 |         } else {
61 |             return false;
62 |         }
63 | 
64 |     }
65 | 
66 |     static long getInt(String ipaddr) {
67 |         String[] ipt = ipaddr.split("\\.");
68 |         long ip = 0;
69 | 
70 |         ip += Long.parseLong(ipt[0]) << 24;
71 |         ip += Integer.parseInt(ipt[1]) << 16;
72 |         ip += Integer.parseInt(ipt[2]) << 8;
73 |         ip += Integer.parseInt(ipt[3]);
74 | 
75 |         return ip;
76 |     }
77 | 
78 |     public long getInt() {
79 |         return getInt(mIp);
80 |     }
81 | 
82 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ConfigParser.java:
--------------------------------------------------------------------------------
   1 | /*
   2 |  * Copyright (c) 2012-2016 Arne Schwabe
   3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
   4 |  */
   5 | 
   6 | package de.blinkt.openvpn.core;
   7 | 
   8 | import android.os.Build;
   9 | import androidx.core.util.Pair;
  10 | import android.text.TextUtils;
  11 | 
  12 | import java.io.BufferedReader;
  13 | import java.io.IOException;
  14 | import java.io.Reader;
  15 | import java.io.StringReader;
  16 | import java.util.*;
  17 | 
  18 | import de.blinkt.openvpn.VpnProfile;
  19 | 
  20 | //! Openvpn Config FIle Parser, probably not 100% accurate but close enough
  21 | 
  22 | // And remember, this is valid :)
  23 | // --<foo>
  24 | // bar
  25 | // </foo>
  26 | public class ConfigParser {
  27 | 
  28 | 
  29 |     public static final String CONVERTED_PROFILE = "converted Profile";
  30 |     final String[] unsupportedOptions = {"config",
  31 |             "tls-server"
  32 | 
  33 |     };
  34 |     // Ignore all scripts
  35 |     // in most cases these won't work and user who wish to execute scripts will
  36 |     // figure out themselves
  37 |     private final String[] ignoreOptions = {"tls-client",
  38 |             "allow-recursive-routing",
  39 |             "askpass",
  40 |             "auth-nocache",
  41 |             "up",
  42 |             "down",
  43 |             "route-up",
  44 |             "ipchange",
  45 |             "route-pre-down",
  46 |             "auth-user-pass-verify",
  47 |             "block-outside-dns",
  48 |             "client-cert-not-required",
  49 |             "dhcp-release",
  50 |             "dhcp-renew",
  51 |             "dh",
  52 |             "group",
  53 |             "ip-win32",
  54 |             "ifconfig-nowarn",
  55 |             "management-hold",
  56 |             "management",
  57 |             "management-client",
  58 |             "management-query-remote",
  59 |             "management-query-passwords",
  60 |             "management-query-proxy",
  61 |             "management-external-key",
  62 |             "management-forget-disconnect",
  63 |             "management-signal",
  64 |             "management-log-cache",
  65 |             "management-up-down",
  66 |             "management-client-user",
  67 |             "management-client-group",
  68 |             "pause-exit",
  69 |             "preresolve",
  70 |             "plugin",
  71 |             "machine-readable-output",
  72 |             "persist-key",
  73 |             "push",
  74 |             "register-dns",
  75 |             "route-delay",
  76 |             "route-gateway",
  77 |             "route-metric",
  78 |             "route-method",
  79 |             "status",
  80 |             "script-security",
  81 |             "show-net-up",
  82 |             "suppress-timestamps",
  83 |             "tap-sleep",
  84 |             "tmp-dir",
  85 |             "tun-ipv6",
  86 |             "topology",
  87 |             "user",
  88 |             "win-sys",
  89 |     };
  90 |     private final String[][] ignoreOptionsWithArg =
  91 |             {
  92 |                     {"setenv", "IV_GUI_VER"},
  93 |                     {"setenv", "IV_SSO"},
  94 |                     {"setenv", "IV_PLAT_VER"},
  95 |                     {"setenv", "IV_OPENVPN_GUI_VERSION"},
  96 |                     {"engine", "dynamic"},
  97 |                     {"setenv", "CLIENT_CERT"},
  98 |                     {"resolv-retry", "60"}
  99 |             };
 100 |     private final String[] connectionOptions = {
 101 |             "local",
 102 |             "remote",
 103 |             "float",
 104 |             "port",
 105 |             "connect-retry",
 106 |             "connect-timeout",
 107 |             "connect-retry-max",
 108 |             "link-mtu",
 109 |             "tun-mtu",
 110 |             "tun-mtu-extra",
 111 |             "fragment",
 112 |             "mtu-disc",
 113 |             "local-port",
 114 |             "remote-port",
 115 |             "bind",
 116 |             "nobind",
 117 |             "proto",
 118 |             "http-proxy",
 119 |             "http-proxy-retry",
 120 |             "http-proxy-timeout",
 121 |             "http-proxy-option",
 122 |             "socks-proxy",
 123 |             "socks-proxy-retry",
 124 |             "http-proxy-user-pass",
 125 |             "explicit-exit-notify",
 126 |     };
 127 |     private HashSet<String>  connectionOptionsSet = new HashSet<>(Arrays.asList(connectionOptions));
 128 | 
 129 |     private HashMap<String, Vector<Vector<String>>> options = new HashMap<>();
 130 |     private HashMap<String, Vector<String>> meta = new HashMap<String, Vector<String>>();
 131 |     private String auth_user_pass_file;
 132 | 
 133 |     static public void useEmbbedUserAuth(VpnProfile np, String inlinedata) {
 134 |         String data = VpnProfile.getEmbeddedContent(inlinedata);
 135 |         String[] parts = data.split("\n");
 136 |         if (parts.length >= 2) {
 137 |             np.mUsername = parts[0];
 138 |             np.mPassword = parts[1];
 139 |         }
 140 |     }
 141 | 
 142 |     static public void useEmbbedHttpAuth(Connection c, String inlinedata) {
 143 |         String data = VpnProfile.getEmbeddedContent(inlinedata);
 144 |         String[] parts = data.split("\n");
 145 |         if (parts.length >= 2) {
 146 |             c.mProxyAuthUser = parts[0];
 147 |             c.mProxyAuthPassword = parts[1];
 148 |             c.mUseProxyAuth = true;
 149 |         }
 150 |     }
 151 | 
 152 |     public void parseConfig(Reader reader) throws IOException, ConfigParseError {
 153 | 
 154 |         HashMap<String, String> optionAliases = new HashMap<>();
 155 |         optionAliases.put("server-poll-timeout", "timeout-connect");
 156 | 
 157 |         BufferedReader br = new BufferedReader(reader);
 158 | 
 159 |         int lineno = 0;
 160 |         try {
 161 |             while (true) {
 162 |                 String line = br.readLine();
 163 |                 lineno++;
 164 |                 if (line == null)
 165 |                     break;
 166 | 
 167 |                 if (lineno == 1) {
 168 |                     if ((line.startsWith("PK\003\004")
 169 |                             || (line.startsWith("PK\007\008")))) {
 170 |                         throw new ConfigParseError("Input looks like a ZIP Archive. Import is only possible for OpenVPN config files (.ovpn/.conf)");
 171 |                     }
 172 |                     if (line.startsWith("\uFEFF")) {
 173 |                         line = line.substring(1);
 174 |                     }
 175 |                 }
 176 | 
 177 |                 // Check for OpenVPN Access Server Meta information
 178 |                 if (line.startsWith("# OVPN_ACCESS_SERVER_")) {
 179 |                     Vector<String> metaarg = parsemeta(line);
 180 |                     meta.put(metaarg.get(0), metaarg);
 181 |                     continue;
 182 |                 }
 183 |                 Vector<String> args = parseline(line);
 184 | 
 185 |                 if (args.size() == 0)
 186 |                     continue;
 187 | 
 188 | 
 189 |                 if (args.get(0).startsWith("--"))
 190 |                     args.set(0, args.get(0).substring(2));
 191 | 
 192 |                 checkinlinefile(args, br);
 193 | 
 194 |                 String optionname = args.get(0);
 195 |                 if (optionAliases.get(optionname) != null)
 196 |                     optionname = optionAliases.get(optionname);
 197 | 
 198 |                 if (!options.containsKey(optionname)) {
 199 |                     options.put(optionname, new Vector<Vector<String>>());
 200 |                 }
 201 |                 options.get(optionname).add(args);
 202 |             }
 203 |         } catch (java.lang.OutOfMemoryError memoryError) {
 204 |             throw new ConfigParseError("File too large to parse: " + memoryError.getLocalizedMessage());
 205 |         }
 206 |     }
 207 | 
 208 |     private Vector<String> parsemeta(String line) {
 209 |         String meta = line.split("#\\sOVPN_ACCESS_SERVER_", 2)[1];
 210 |         String[] parts = meta.split("=", 2);
 211 |         Vector<String> rval = new Vector<String>();
 212 |         Collections.addAll(rval, parts);
 213 |         return rval;
 214 | 
 215 |     }
 216 | 
 217 |     private void checkinlinefile(Vector<String> args, BufferedReader br) throws IOException, ConfigParseError {
 218 |         String arg0 = args.get(0).trim();
 219 |         // CHeck for <foo>
 220 |         if (arg0.startsWith("<") && arg0.endsWith(">")) {
 221 |             String argname = arg0.substring(1, arg0.length() - 1);
 222 |             String inlinefile = VpnProfile.INLINE_TAG;
 223 | 
 224 |             String endtag = String.format("</%s>", argname);
 225 |             do {
 226 |                 String line = br.readLine();
 227 |                 if (line == null) {
 228 |                     throw new ConfigParseError(String.format("No endtag </%s> for starttag <%s> found", argname, argname));
 229 |                 }
 230 |                 if (line.trim().equals(endtag))
 231 |                     break;
 232 |                 else {
 233 |                     inlinefile += line;
 234 |                     inlinefile += "\n";
 235 |                 }
 236 |             } while (true);
 237 | 
 238 |             if (inlinefile.endsWith("\n"))
 239 |                 inlinefile = inlinefile.substring(0, inlinefile.length() - 1);
 240 | 
 241 |             args.clear();
 242 |             args.add(argname);
 243 |             args.add(inlinefile);
 244 |         }
 245 | 
 246 |     }
 247 | 
 248 |     public String getAuthUserPassFile() {
 249 |         return auth_user_pass_file;
 250 |     }
 251 | 
 252 |     private boolean space(char c) {
 253 |         // I really hope nobody is using zero bytes inside his/her config file
 254 |         // to sperate parameter but here we go:
 255 |         return Character.isWhitespace(c) || c == '\0';
 256 | 
 257 |     }
 258 | 
 259 |     // adapted openvpn's parse function to java
 260 |     private Vector<String> parseline(String line) throws ConfigParseError {
 261 |         Vector<String> parameters = new Vector<String>();
 262 | 
 263 |         if (line.length() == 0)
 264 |             return parameters;
 265 | 
 266 | 
 267 |         linestate state = linestate.initial;
 268 |         boolean backslash = false;
 269 |         char out = 0;
 270 | 
 271 |         int pos = 0;
 272 |         String currentarg = "";
 273 | 
 274 |         do {
 275 |             // Emulate the c parsing ...
 276 |             char in;
 277 |             if (pos < line.length())
 278 |                 in = line.charAt(pos);
 279 |             else
 280 |                 in = '\0';
 281 | 
 282 |             if (!backslash && in == '\\' && state != linestate.readin_single_quote) {
 283 |                 backslash = true;
 284 |             } else {
 285 |                 if (state == linestate.initial) {
 286 |                     if (!space(in)) {
 287 |                         if (in == ';' || in == '#') /* comment */
 288 |                             break;
 289 |                         if (!backslash && in == '\"')
 290 |                             state = linestate.reading_quoted;
 291 |                         else if (!backslash && in == '\'')
 292 |                             state = linestate.readin_single_quote;
 293 |                         else {
 294 |                             out = in;
 295 |                             state = linestate.reading_unquoted;
 296 |                         }
 297 |                     }
 298 |                 } else if (state == linestate.reading_unquoted) {
 299 |                     if (!backslash && space(in))
 300 |                         state = linestate.done;
 301 |                     else
 302 |                         out = in;
 303 |                 } else if (state == linestate.reading_quoted) {
 304 |                     if (!backslash && in == '\"')
 305 |                         state = linestate.done;
 306 |                     else
 307 |                         out = in;
 308 |                 } else if (state == linestate.readin_single_quote) {
 309 |                     if (in == '\'')
 310 |                         state = linestate.done;
 311 |                     else
 312 |                         out = in;
 313 |                 }
 314 | 
 315 |                 if (state == linestate.done) {
 316 |                     /* ASSERT (parm_len > 0); */
 317 |                     state = linestate.initial;
 318 |                     parameters.add(currentarg);
 319 |                     currentarg = "";
 320 |                     out = 0;
 321 |                 }
 322 | 
 323 |                 if (backslash && out != 0) {
 324 |                     if (!(out == '\\' || out == '\"' || space(out))) {
 325 |                         throw new ConfigParseError("Options warning: Bad backslash ('\\') usage");
 326 |                     }
 327 |                 }
 328 |                 backslash = false;
 329 |             }
 330 | 
 331 |             /* store parameter character */
 332 |             if (out != 0) {
 333 |                 currentarg += out;
 334 |             }
 335 |         } while (pos++ < line.length());
 336 | 
 337 |         return parameters;
 338 |     }
 339 | 
 340 |     // This method is far too long
 341 |     @SuppressWarnings("ConstantConditions")
 342 |     public VpnProfile convertProfile() throws ConfigParseError, IOException {
 343 |         boolean noauthtypeset = true;
 344 |         VpnProfile np = new VpnProfile(CONVERTED_PROFILE);
 345 |         // Pull, client, tls-client
 346 |         np.clearDefaults();
 347 | 
 348 |         if (options.containsKey("client") || options.containsKey("pull")) {
 349 |             np.mUsePull = true;
 350 |             options.remove("pull");
 351 |             options.remove("client");
 352 |         }
 353 | 
 354 |         Vector<String> secret = getOption("secret", 1, 2);
 355 |         if (secret != null) {
 356 |             np.mAuthenticationType = VpnProfile.TYPE_STATICKEYS;
 357 |             noauthtypeset = false;
 358 |             np.mUseTLSAuth = true;
 359 |             np.mTLSAuthFilename = secret.get(1);
 360 |             if (secret.size() == 3)
 361 |                 np.mTLSAuthDirection = secret.get(2);
 362 | 
 363 |         }
 364 | 
 365 |         Vector<Vector<String>> routes = getAllOption("route", 1, 4);
 366 |         if (routes != null) {
 367 |             String routeopt = "";
 368 |             String routeExcluded = "";
 369 |             for (Vector<String> route : routes) {
 370 |                 String netmask = "255.255.255.255";
 371 |                 String gateway = "vpn_gateway";
 372 | 
 373 |                 if (route.size() >= 3)
 374 |                     netmask = route.get(2);
 375 |                 if (route.size() >= 4)
 376 |                     gateway = route.get(3);
 377 | 
 378 |                 String net = route.get(1);
 379 |                 try {
 380 |                     CIDRIP cidr = new CIDRIP(net, netmask);
 381 |                     if (gateway.equals("net_gateway"))
 382 |                         routeExcluded += cidr.toString() + " ";
 383 |                     else
 384 |                         routeopt += cidr.toString() + " ";
 385 |                 } catch (ArrayIndexOutOfBoundsException aioob) {
 386 |                     throw new ConfigParseError("Could not parse netmask of route " + netmask);
 387 |                 } catch (NumberFormatException ne) {
 388 | 
 389 | 
 390 |                     throw new ConfigParseError("Could not parse netmask of route " + netmask);
 391 |                 }
 392 | 
 393 |             }
 394 |             np.mCustomRoutes = routeopt;
 395 |             np.mExcludedRoutes = routeExcluded;
 396 |         }
 397 | 
 398 |         Vector<Vector<String>> routesV6 = getAllOption("route-ipv6", 1, 4);
 399 |         if (routesV6 != null) {
 400 |             String customIPv6Routes = "";
 401 |             for (Vector<String> route : routesV6) {
 402 |                 customIPv6Routes += route.get(1) + " ";
 403 |             }
 404 | 
 405 |             np.mCustomRoutesv6 = customIPv6Routes;
 406 |         }
 407 | 
 408 |         Vector<String> routeNoPull = getOption("route-nopull", 0, 0);
 409 |         if (routeNoPull != null)
 410 |             np.mRoutenopull = true;
 411 | 
 412 |         // Also recognize tls-auth [inline] direction ...
 413 |         Vector<Vector<String>> tlsauthoptions = getAllOption("tls-auth", 1, 2);
 414 |         if (tlsauthoptions != null) {
 415 |             for (Vector<String> tlsauth : tlsauthoptions) {
 416 |                 if (tlsauth != null) {
 417 |                     if (!tlsauth.get(1).equals("[inline]")) {
 418 |                         np.mTLSAuthFilename = tlsauth.get(1);
 419 |                         np.mUseTLSAuth = true;
 420 |                     }
 421 |                     if (tlsauth.size() == 3)
 422 |                         np.mTLSAuthDirection = tlsauth.get(2);
 423 |                 }
 424 |             }
 425 |         }
 426 | 
 427 |         Vector<String> direction = getOption("key-direction", 1, 1);
 428 |         if (direction != null)
 429 |             np.mTLSAuthDirection = direction.get(1);
 430 | 
 431 |         for (String crypt: new String[]{"tls-crypt", "tls-crypt-v2"}) {
 432 |             Vector<String> tlscrypt = getOption(crypt, 1, 1);
 433 |             if (tlscrypt != null) {
 434 |                 np.mUseTLSAuth = true;
 435 |                 np.mTLSAuthFilename = tlscrypt.get(1);
 436 |                 np.mTLSAuthDirection = crypt;
 437 |             }
 438 |         }
 439 | 
 440 |         Vector<Vector<String>> defgw = getAllOption("redirect-gateway", 0, 7);
 441 |         if (defgw != null) {
 442 |             checkRedirectParameters(np, defgw, true);
 443 |         }
 444 | 
 445 |         Vector<Vector<String>> redirectPrivate = getAllOption("redirect-private", 0, 5);
 446 |         if (redirectPrivate != null) {
 447 |             checkRedirectParameters(np, redirectPrivate, false);
 448 |         }
 449 |         Vector<String> dev = getOption("dev", 1, 1);
 450 |         Vector<String> devtype = getOption("dev-type", 1, 1);
 451 | 
 452 |         if ((devtype != null && devtype.get(1).equals("tun")) ||
 453 |                 (dev != null && dev.get(1).startsWith("tun")) ||
 454 |                 (devtype == null && dev == null)) {
 455 |             //everything okay
 456 |         } else {
 457 |             throw new ConfigParseError("Sorry. Only tun mode is supported. See the FAQ for more detail");
 458 |         }
 459 | 
 460 |         Vector<String> mssfix = getOption("mssfix", 0, 2);
 461 | 
 462 |         if (mssfix != null) {
 463 |             if (mssfix.size() >= 2) {
 464 |                 try {
 465 |                     np.mMssFix = Integer.parseInt(mssfix.get(1));
 466 |                 } catch (NumberFormatException e) {
 467 |                     throw new ConfigParseError("Argument to --mssfix has to be an integer");
 468 |                 }
 469 |             } else {
 470 |                 np.mMssFix = 1450; // OpenVPN default size
 471 |             }
 472 |             // Ignore mtu argument of OpenVPN3 and report error otherwise
 473 |             if (mssfix.size() >= 3 && !(mssfix.get(2).equals("mtu"))) {
 474 |                 throw new ConfigParseError("Second argument to --mssfix unkonwn");
 475 |             }
 476 |         }
 477 | 
 478 | 
 479 |         Vector<String> tunmtu = getOption("tun-mtu", 1, 1);
 480 | 
 481 |         if (tunmtu != null) {
 482 |             try {
 483 |                 np.mTunMtu = Integer.parseInt(tunmtu.get(1));
 484 |             } catch (NumberFormatException e) {
 485 |                 throw new ConfigParseError("Argument to --tun-mtu has to be an integer");
 486 |             }
 487 |         }
 488 | 
 489 | 
 490 |         Vector<String> mode = getOption("mode", 1, 1);
 491 |         if (mode != null) {
 492 |             if (!mode.get(1).equals("p2p"))
 493 |                 throw new ConfigParseError("Invalid mode for --mode specified, need p2p");
 494 |         }
 495 | 
 496 | 
 497 |         Vector<Vector<String>> dhcpoptions = getAllOption("dhcp-option", 2, 2);
 498 |         if (dhcpoptions != null) {
 499 |             for (Vector<String> dhcpoption : dhcpoptions) {
 500 |                 String type = dhcpoption.get(1);
 501 |                 String arg = dhcpoption.get(2);
 502 |                 if (type.equals("DOMAIN")) {
 503 |                     np.mSearchDomain = dhcpoption.get(2);
 504 |                 } else if (type.equals("DNS")) {
 505 |                     np.mOverrideDNS = true;
 506 |                     if (np.mDNS1.equals(VpnProfile.DEFAULT_DNS1))
 507 |                         np.mDNS1 = arg;
 508 |                     else
 509 |                         np.mDNS2 = arg;
 510 |                 }
 511 |             }
 512 |         }
 513 | 
 514 |         Vector<String> ifconfig = getOption("ifconfig", 2, 2);
 515 |         if (ifconfig != null) {
 516 |             try {
 517 |                 CIDRIP cidr = new CIDRIP(ifconfig.get(1), ifconfig.get(2));
 518 |                 np.mIPv4Address = cidr.toString();
 519 |             } catch (NumberFormatException nfe) {
 520 |                 throw new ConfigParseError("Could not pase ifconfig IP address: " + nfe.getLocalizedMessage());
 521 |             }
 522 | 
 523 |         }
 524 | 
 525 |         if (getOption("remote-random-hostname", 0, 0) != null)
 526 |             np.mUseRandomHostname = true;
 527 | 
 528 |         if (getOption("float", 0, 0) != null)
 529 |             np.mUseFloat = true;
 530 | 
 531 |         if (getOption("comp-lzo", 0, 1) != null)
 532 |             np.mUseLzo = true;
 533 | 
 534 |         Vector<String> cipher = getOption("cipher", 1, 1);
 535 |         if (cipher != null)
 536 |             np.mCipher = cipher.get(1);
 537 | 
 538 |         Vector<String> auth = getOption("auth", 1, 1);
 539 |         if (auth != null)
 540 |             np.mAuth = auth.get(1);
 541 | 
 542 | 
 543 |         Vector<String> ca = getOption("ca", 1, 1);
 544 |         if (ca != null) {
 545 |             np.mCaFilename = ca.get(1);
 546 |         }
 547 | 
 548 |         Vector<String> cert = getOption("cert", 1, 1);
 549 |         if (cert != null) {
 550 |             np.mClientCertFilename = cert.get(1);
 551 |             np.mAuthenticationType = VpnProfile.TYPE_CERTIFICATES;
 552 |             noauthtypeset = false;
 553 |         }
 554 |         Vector<String> key = getOption("key", 1, 1);
 555 |         if (key != null)
 556 |             np.mClientKeyFilename = key.get(1);
 557 | 
 558 |         Vector<String> pkcs12 = getOption("pkcs12", 1, 1);
 559 |         if (pkcs12 != null) {
 560 |             np.mPKCS12Filename = pkcs12.get(1);
 561 |             np.mAuthenticationType = VpnProfile.TYPE_KEYSTORE;
 562 |             noauthtypeset = false;
 563 |         }
 564 | 
 565 |         Vector<String> cryptoapicert = getOption("cryptoapicert", 1, 1);
 566 |         if (cryptoapicert != null) {
 567 |             np.mAuthenticationType = VpnProfile.TYPE_KEYSTORE;
 568 |             noauthtypeset = false;
 569 |         }
 570 | 
 571 |         Vector<String> compatnames = getOption("compat-names", 1, 2);
 572 |         Vector<String> nonameremapping = getOption("no-name-remapping", 1, 1);
 573 |         Vector<String> tlsremote = getOption("tls-remote", 1, 1);
 574 |         if (tlsremote != null) {
 575 |             np.mRemoteCN = tlsremote.get(1);
 576 |             np.mCheckRemoteCN = true;
 577 |             np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE;
 578 | 
 579 |             if ((compatnames != null && compatnames.size() > 2) ||
 580 |                     (nonameremapping != null))
 581 |                 np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE_COMPAT_NOREMAPPING;
 582 |         }
 583 | 
 584 |         Vector<String> verifyx509name = getOption("verify-x509-name", 1, 2);
 585 |         if (verifyx509name != null) {
 586 |             np.mRemoteCN = verifyx509name.get(1);
 587 |             np.mCheckRemoteCN = true;
 588 |             if (verifyx509name.size() > 2) {
 589 |                 if (verifyx509name.get(2).equals("name"))
 590 |                     np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE_RDN;
 591 |                 else if (verifyx509name.get(2).equals("subject"))
 592 |                     np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE_DN;
 593 |                 else if (verifyx509name.get(2).equals("name-prefix"))
 594 |                     np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE_RDN_PREFIX;
 595 |                 else
 596 |                     throw new ConfigParseError("Unknown parameter to verify-x509-name: " + verifyx509name.get(2));
 597 |             } else {
 598 |                 np.mX509AuthType = VpnProfile.X509_VERIFY_TLSREMOTE_DN;
 599 |             }
 600 | 
 601 |         }
 602 | 
 603 |         Vector<String> x509usernamefield = getOption("x509-username-field", 1, 1);
 604 |         if (x509usernamefield != null) {
 605 |             np.mx509UsernameField = x509usernamefield.get(1);
 606 |         }
 607 | 
 608 | 
 609 |         Vector<String> verb = getOption("verb", 1, 1);
 610 |         if (verb != null) {
 611 |             np.mVerb = verb.get(1);
 612 |         }
 613 | 
 614 | 
 615 |         if (getOption("nobind", 0, 0) != null)
 616 |             np.mNobind = true;
 617 | 
 618 |         if (getOption("persist-tun", 0, 0) != null)
 619 |             np.mPersistTun = true;
 620 | 
 621 |         if (getOption("push-peer-info", 0, 0) != null)
 622 |             np.mPushPeerInfo = true;
 623 | 
 624 |         Vector<String> connectretry = getOption("connect-retry", 1, 2);
 625 |         if (connectretry != null) {
 626 |             np.mConnectRetry = connectretry.get(1);
 627 |             if (connectretry.size() > 2)
 628 |                 np.mConnectRetryMaxTime = connectretry.get(2);
 629 |         }
 630 | 
 631 |         Vector<String> connectretrymax = getOption("connect-retry-max", 1, 1);
 632 |         if (connectretrymax != null)
 633 |             np.mConnectRetryMax = connectretrymax.get(1);
 634 | 
 635 |         Vector<Vector<String>> remotetls = getAllOption("remote-cert-tls", 1, 1);
 636 |         if (remotetls != null)
 637 |             if (remotetls.get(0).get(1).equals("server"))
 638 |                 np.mExpectTLSCert = true;
 639 |             else
 640 |                 options.put("remotetls", remotetls);
 641 | 
 642 |         Vector<String> authuser = getOption("auth-user-pass", 0, 1);
 643 | 
 644 |         if (authuser != null) {
 645 |             if (noauthtypeset) {
 646 |                 np.mAuthenticationType = VpnProfile.TYPE_USERPASS;
 647 |             } else if (np.mAuthenticationType == VpnProfile.TYPE_CERTIFICATES) {
 648 |                 np.mAuthenticationType = VpnProfile.TYPE_USERPASS_CERTIFICATES;
 649 |             } else if (np.mAuthenticationType == VpnProfile.TYPE_KEYSTORE) {
 650 |                 np.mAuthenticationType = VpnProfile.TYPE_USERPASS_KEYSTORE;
 651 |             }
 652 |             if (authuser.size() > 1) {
 653 |                 if (!authuser.get(1).startsWith(VpnProfile.INLINE_TAG))
 654 |                     auth_user_pass_file = authuser.get(1);
 655 |                 np.mUsername = null;
 656 |                 useEmbbedUserAuth(np, authuser.get(1));
 657 |             }
 658 |         }
 659 | 
 660 |         Vector<String> authretry = getOption("auth-retry", 1, 1);
 661 |         if (authretry != null) {
 662 |             if (authretry.get(1).equals("none"))
 663 |                 np.mAuthRetry = VpnProfile.AUTH_RETRY_NONE_FORGET;
 664 |             else if (authretry.get(1).equals("nointeract"))
 665 |                 np.mAuthRetry = VpnProfile.AUTH_RETRY_NOINTERACT;
 666 |             else if (authretry.get(1).equals("interact"))
 667 |                 np.mAuthRetry = VpnProfile.AUTH_RETRY_NOINTERACT;
 668 |             else
 669 |                 throw new ConfigParseError("Unknown parameter to auth-retry: " + authretry.get(2));
 670 |         }
 671 | 
 672 | 
 673 |         Vector<String> crlfile = getOption("crl-verify", 1, 2);
 674 |         if (crlfile != null) {
 675 |             // If the 'dir' parameter is present just add it as custom option ..
 676 |             if (crlfile.size() == 3 && crlfile.get(2).equals("dir"))
 677 |                 np.mCustomConfigOptions += join(" ", crlfile) + "\n";
 678 |             else
 679 |                 // Save the filename for the config converter to add later
 680 |                 np.mCrlFilename = crlfile.get(1);
 681 | 
 682 |         }
 683 | 
 684 | 
 685 |         Pair<Connection, Connection[]> conns = parseConnectionOptions(null);
 686 |         np.mConnections = conns.second;
 687 | 
 688 |         Vector<Vector<String>> connectionBlocks = getAllOption("connection", 1, 1);
 689 | 
 690 |         if (np.mConnections.length > 0 && connectionBlocks != null) {
 691 |             throw new ConfigParseError("Using a <connection> block and --remote is not allowed.");
 692 |         }
 693 | 
 694 |         if (connectionBlocks != null) {
 695 |             np.mConnections = new Connection[connectionBlocks.size()];
 696 | 
 697 |             int connIndex = 0;
 698 |             for (Vector<String> conn : connectionBlocks) {
 699 |                 Pair<Connection, Connection[]> connectionBlockConnection =
 700 |                         parseConnection(conn.get(1), conns.first);
 701 | 
 702 |                 if (connectionBlockConnection.second.length != 1)
 703 |                     throw new ConfigParseError("A <connection> block must have exactly one remote");
 704 |                 np.mConnections[connIndex] = connectionBlockConnection.second[0];
 705 |                 connIndex++;
 706 |             }
 707 |         }
 708 |         if (getOption("remote-random", 0, 0) != null)
 709 |             np.mRemoteRandom = true;
 710 | 
 711 |         Vector<String> protoforce = getOption("proto-force", 1, 1);
 712 |         if (protoforce != null) {
 713 |             boolean disableUDP;
 714 |             String protoToDisable = protoforce.get(1);
 715 |             if (protoToDisable.equals("udp"))
 716 |                 disableUDP = true;
 717 |             else if (protoToDisable.equals("tcp"))
 718 |                 disableUDP = false;
 719 |             else
 720 |                 throw new ConfigParseError(String.format("Unknown protocol %s in proto-force", protoToDisable));
 721 | 
 722 |             for (Connection conn : np.mConnections)
 723 |                 if (conn.mUseUdp == disableUDP)
 724 |                     conn.mEnabled = false;
 725 |         }
 726 | 
 727 |         // Parse OpenVPN Access Server extra
 728 |         for (String as_name_directive: new String[]{"PROFILE", "FRIENDLY_NAME"}) {
 729 |             Vector<String> friendlyname = meta.get(as_name_directive);
 730 |             if (friendlyname != null && friendlyname.size() > 1)
 731 |                 np.mName = friendlyname.get(1);
 732 |         }
 733 | 
 734 | 
 735 |         Vector<String> ocusername = meta.get("USERNAME");
 736 |         if (ocusername != null && ocusername.size() > 1)
 737 |             np.mUsername = ocusername.get(1);
 738 | 
 739 |         checkIgnoreAndInvalidOptions(np);
 740 |         fixup(np);
 741 | 
 742 |         return np;
 743 |     }
 744 | 
 745 |     private String join(String s, Vector<String> str) {
 746 |         if (Build.VERSION.SDK_INT > 26)
 747 |             return String.join(s, str);
 748 |         else
 749 |             return TextUtils.join(s, str);
 750 |     }
 751 | 
 752 |     private Pair<Connection, Connection[]> parseConnection(String connection, Connection defaultValues) throws IOException, ConfigParseError {
 753 |         // Parse a connection Block as a new configuration file
 754 | 
 755 | 
 756 |         ConfigParser connectionParser = new ConfigParser();
 757 |         StringReader reader = new StringReader(connection.substring(VpnProfile.INLINE_TAG.length()));
 758 |         connectionParser.parseConfig(reader);
 759 | 
 760 |         Pair<Connection, Connection[]> conn = connectionParser.parseConnectionOptions(defaultValues);
 761 | 
 762 |         return conn;
 763 |     }
 764 | 
 765 |     private Pair<Connection, Connection[]> parseConnectionOptions(Connection connDefault) throws ConfigParseError {
 766 |         Connection conn;
 767 |         if (connDefault != null)
 768 |             try {
 769 |                 conn = connDefault.clone();
 770 |             } catch (CloneNotSupportedException e) {
 771 |                 e.printStackTrace();
 772 |                 return null;
 773 |             }
 774 |         else
 775 |             conn = new Connection();
 776 | 
 777 |         Vector<String> port = getOption("port", 1, 1);
 778 |         if (port != null) {
 779 |             conn.mServerPort = port.get(1);
 780 |         }
 781 | 
 782 |         Vector<String> rport = getOption("rport", 1, 1);
 783 |         if (rport != null) {
 784 |             conn.mServerPort = rport.get(1);
 785 |         }
 786 | 
 787 |         Vector<String> proto = getOption("proto", 1, 1);
 788 |         if (proto != null) {
 789 |             conn.mUseUdp = isUdpProto(proto.get(1));
 790 |         }
 791 | 
 792 |         Vector<String> connectTimeout = getOption("connect-timeout", 1, 1);
 793 |         if (connectTimeout != null) {
 794 |             try {
 795 |                 conn.mConnectTimeout = Integer.parseInt(connectTimeout.get(1));
 796 |             } catch (NumberFormatException nfe) {
 797 |                 throw new ConfigParseError(String.format("Argument to connect-timeout (%s) must to be an integer: %s",
 798 |                         connectTimeout.get(1), nfe.getLocalizedMessage()));
 799 | 
 800 |             }
 801 |         }
 802 | 
 803 |         Vector<String> proxy = getOption("socks-proxy", 1, 2);
 804 |         if (proxy == null)
 805 |             proxy = getOption("http-proxy", 2, 2);
 806 | 
 807 |         if (proxy != null) {
 808 |             if (proxy.get(0).equals("socks-proxy")) {
 809 |                 conn.mProxyType = Connection.ProxyType.SOCKS5;
 810 |                 // socks defaults to 1080, http always sets port
 811 |                 conn.mProxyPort = "1080";
 812 |             } else {
 813 |                 conn.mProxyType = Connection.ProxyType.HTTP;
 814 |             }
 815 | 
 816 |             conn.mProxyName = proxy.get(1);
 817 |             if (proxy.size() >= 3)
 818 |                 conn.mProxyPort = proxy.get(2);
 819 |         }
 820 | 
 821 |         Vector<String> httpproxyauthhttp = getOption("http-proxy-user-pass", 1, 1);
 822 |         if (httpproxyauthhttp != null)
 823 |             useEmbbedHttpAuth(conn, httpproxyauthhttp.get(1));
 824 | 
 825 | 
 826 |         // Parse remote config
 827 |         Vector<Vector<String>> remotes = getAllOption("remote", 1, 3);
 828 | 
 829 | 
 830 | 
 831 |         Vector <String> optionsToRemove = new Vector<>();
 832 |         // Assume that we need custom options if connectionDefault are set or in the connection specific set
 833 |         for (Map.Entry<String, Vector<Vector<String>>> option : options.entrySet()) {
 834 |             if (connDefault != null || connectionOptionsSet.contains(option.getKey())) {
 835 |                 conn.mCustomConfiguration += getOptionStrings(option.getValue());
 836 |                 optionsToRemove.add(option.getKey());
 837 |             }
 838 |         }
 839 |         for (String o: optionsToRemove)
 840 |             options.remove(o);
 841 | 
 842 |         if (!(conn.mCustomConfiguration == null || "".equals(conn.mCustomConfiguration.trim())))
 843 |             conn.mUseCustomConfig = true;
 844 | 
 845 |         // Make remotes empty to simplify code
 846 |         if (remotes == null)
 847 |             remotes = new Vector<Vector<String>>();
 848 | 
 849 |         Connection[] connections = new Connection[remotes.size()];
 850 | 
 851 | 
 852 |         int i = 0;
 853 |         for (Vector<String> remote : remotes) {
 854 |             try {
 855 |                 connections[i] = conn.clone();
 856 |             } catch (CloneNotSupportedException e) {
 857 |                 e.printStackTrace();
 858 |             }
 859 |             switch (remote.size()) {
 860 |                 case 4:
 861 |                     connections[i].mUseUdp = isUdpProto(remote.get(3));
 862 |                 case 3:
 863 |                     connections[i].mServerPort = remote.get(2);
 864 |                 case 2:
 865 |                     connections[i].mServerName = remote.get(1);
 866 |             }
 867 |             i++;
 868 |         }
 869 | 
 870 |         return Pair.create(conn, connections);
 871 | 
 872 |     }
 873 | 
 874 |     private void checkRedirectParameters(VpnProfile np, Vector<Vector<String>> defgw, boolean defaultRoute) {
 875 | 
 876 |         boolean noIpv4 = false;
 877 |         if (defaultRoute)
 878 | 
 879 |             for (Vector<String> redirect : defgw)
 880 |                 for (int i = 1; i < redirect.size(); i++) {
 881 |                     if (redirect.get(i).equals("block-local"))
 882 |                         np.mAllowLocalLAN = false;
 883 |                     else if (redirect.get(i).equals("unblock-local"))
 884 |                         np.mAllowLocalLAN = true;
 885 |                     else if (redirect.get(i).equals("!ipv4"))
 886 |                         noIpv4 = true;
 887 |                     else if (redirect.get(i).equals("ipv6"))
 888 |                         np.mUseDefaultRoutev6 = true;
 889 |                 }
 890 |         if (defaultRoute && !noIpv4)
 891 |             np.mUseDefaultRoute = true;
 892 |     }
 893 | 
 894 |     private boolean isUdpProto(String proto) throws ConfigParseError {
 895 |         boolean isudp;
 896 |         if (proto.equals("udp") || proto.equals("udp4") || proto.equals("udp6"))
 897 |             isudp = true;
 898 |         else if (proto.equals("tcp-client") ||
 899 |                 proto.equals("tcp") ||
 900 |                 proto.equals("tcp4") ||
 901 |                 proto.endsWith("tcp4-client") ||
 902 |                 proto.equals("tcp6") ||
 903 |                 proto.endsWith("tcp6-client"))
 904 |             isudp = false;
 905 |         else
 906 |             throw new ConfigParseError("Unsupported option to --proto " + proto);
 907 |         return isudp;
 908 |     }
 909 | 
 910 |     private void checkIgnoreAndInvalidOptions(VpnProfile np) throws ConfigParseError {
 911 |         for (String option : unsupportedOptions)
 912 |             if (options.containsKey(option))
 913 |                 throw new ConfigParseError(String.format("Unsupported Option %s encountered in config file. Aborting", option));
 914 | 
 915 |         for (String option : ignoreOptions)
 916 |             // removing an item which is not in the map is no error
 917 |             options.remove(option);
 918 | 
 919 | 
 920 |         boolean customOptions=false;
 921 |         for (Vector<Vector<String>>  option: options.values())
 922 |         {
 923 |             for (Vector<String> optionsline : option) {
 924 |                 if (!ignoreThisOption(optionsline)) {
 925 |                     customOptions = true;
 926 |                 }
 927 |             }
 928 |         }
 929 |         if (customOptions) {
 930 |             np.mCustomConfigOptions = "# These options found in the config file do not map to config settings:\n"
 931 |                     + np.mCustomConfigOptions;
 932 | 
 933 |             for (Vector<Vector<String>> option : options.values()) {
 934 | 
 935 |                 np.mCustomConfigOptions += getOptionStrings(option);
 936 | 
 937 |             }
 938 |             np.mUseCustomConfig = true;
 939 | 
 940 |         }
 941 |     }
 942 | 
 943 |     boolean ignoreThisOption(Vector<String> option) {
 944 |         for (String[] ignoreOption : ignoreOptionsWithArg) {
 945 | 
 946 |             if (option.size() < ignoreOption.length)
 947 |                 continue;
 948 | 
 949 |             boolean ignore = true;
 950 |             for (int i = 0; i < ignoreOption.length; i++) {
 951 |                 if (!ignoreOption[i].equals(option.get(i)))
 952 |                     ignore = false;
 953 |             }
 954 |             if (ignore)
 955 |                 return true;
 956 | 
 957 |         }
 958 |         return false;
 959 |     }
 960 | 
 961 |     //! Generate options for custom options
 962 |     private String getOptionStrings(Vector<Vector<String>> option) {
 963 |         String custom = "";
 964 |         for (Vector<String> optionsline : option) {
 965 |             if (!ignoreThisOption(optionsline)) {
 966 |                 // Check if option had been inlined and inline again
 967 |                 if (optionsline.size() == 2 &&
 968 |                         "extra-certs".equals(optionsline.get(0))) {
 969 |                     custom += VpnProfile.insertFileData(optionsline.get(0), optionsline.get(1));
 970 |                 } else {
 971 |                     for (String arg : optionsline)
 972 |                         custom += VpnProfile.openVpnEscape(arg) + " ";
 973 |                     custom += "\n";
 974 |                 }
 975 |             }
 976 |         }
 977 |         return custom;
 978 |     }
 979 | 
 980 |     private void fixup(VpnProfile np) {
 981 |         if (np.mRemoteCN.equals(np.mServerName)) {
 982 |             np.mRemoteCN = "";
 983 |         }
 984 |     }
 985 | 
 986 |     private Vector<String> getOption(String option, int minarg, int maxarg) throws ConfigParseError {
 987 |         Vector<Vector<String>> alloptions = getAllOption(option, minarg, maxarg);
 988 |         if (alloptions == null)
 989 |             return null;
 990 |         else
 991 |             return alloptions.lastElement();
 992 |     }
 993 | 
 994 |     private Vector<Vector<String>> getAllOption(String option, int minarg, int maxarg) throws ConfigParseError {
 995 |         Vector<Vector<String>> args = options.get(option);
 996 |         if (args == null)
 997 |             return null;
 998 | 
 999 |         for (Vector<String> optionline : args)
1000 | 
1001 |             if (optionline.size() < (minarg + 1) || optionline.size() > maxarg + 1) {
1002 |                 String err = String.format(Locale.getDefault(), "Option %s has %d parameters, expected between %d and %d",
1003 |                         option, optionline.size() - 1, minarg, maxarg);
1004 |                 throw new ConfigParseError(err);
1005 |             }
1006 |         options.remove(option);
1007 |         return args;
1008 |     }
1009 | 
1010 |     enum linestate {
1011 |         initial,
1012 |         readin_single_quote, reading_quoted, reading_unquoted, done
1013 |     }
1014 | 
1015 |     public static class ConfigParseError extends Exception {
1016 |         private static final long serialVersionUID = -60L;
1017 | 
1018 |         public ConfigParseError(String msg) {
1019 |             super(msg);
1020 |         }
1021 |     }
1022 | 
1023 | }
1024 | 
1025 | 
1026 | 
1027 | 
1028 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/Connection.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.text.TextUtils;
 9 | 
10 | import java.io.Serializable;
11 | import java.util.Locale;
12 | 
13 | public class Connection implements Serializable, Cloneable {
14 |     public String mServerName = "openvpn.example.com";
15 |     public String mServerPort = "1194";
16 |     public boolean mUseUdp = true;
17 |     public String mCustomConfiguration = "";
18 |     public boolean mUseCustomConfig = false;
19 |     public boolean mEnabled = true;
20 |     public int mConnectTimeout = 0;
21 |     public static final int CONNECTION_DEFAULT_TIMEOUT = 120;
22 |     public ProxyType mProxyType = ProxyType.NONE;
23 |     public String mProxyName = "proxy.example.com";
24 |     public String mProxyPort = "8080";
25 | 
26 |     public boolean mUseProxyAuth;
27 |     public String mProxyAuthUser = null;
28 |     public String mProxyAuthPassword = null;
29 | 
30 |     public enum ProxyType {
31 |         NONE,
32 |         HTTP,
33 |         SOCKS5,
34 |         ORBOT
35 |     }
36 | 
37 |     private static final long serialVersionUID = 92031902903829089L;
38 | 
39 | 
40 |     public String getConnectionBlock(boolean isOpenVPN3) {
41 |         String cfg = "";
42 | 
43 |         // Server Address
44 |         cfg += "remote ";
45 |         cfg += mServerName;
46 |         cfg += " ";
47 |         cfg += mServerPort;
48 |         if (mUseUdp)
49 |             cfg += " udp\n";
50 |         else
51 |             cfg += " tcp-client\n";
52 | 
53 |         if (mConnectTimeout != 0)
54 |             cfg += String.format(Locale.US, " connect-timeout  %d\n", mConnectTimeout);
55 | 
56 |         // OpenVPN 2.x manages proxy connection via management interface
57 |         if ((isOpenVPN3 || usesExtraProxyOptions()) && mProxyType == ProxyType.HTTP)
58 |         {
59 |             cfg+=String.format(Locale.US,"http-proxy %s %s\n", mProxyName, mProxyPort);
60 |             if (mUseProxyAuth)
61 |                 cfg+=String.format(Locale.US, "<http-proxy-user-pass>\n%s\n%s\n</http-proxy-user-pass>\n", mProxyAuthUser, mProxyAuthPassword);
62 |         }
63 |         if (usesExtraProxyOptions() && mProxyType == ProxyType.SOCKS5) {
64 |             cfg+=String.format(Locale.US,"socks-proxy %s %s\n", mProxyName, mProxyPort);
65 |         }
66 | 
67 |         if (!TextUtils.isEmpty(mCustomConfiguration) && mUseCustomConfig) {
68 |             cfg += mCustomConfiguration;
69 |             cfg += "\n";
70 |         }
71 | 
72 | 
73 |         return cfg;
74 |     }
75 | 
76 |     public boolean usesExtraProxyOptions() {
77 |         return (mUseCustomConfig && mCustomConfiguration.contains("http-proxy-option "));
78 |     }
79 | 
80 | 
81 |     @Override
82 |     public Connection clone() throws CloneNotSupportedException {
83 |         return (Connection) super.clone();
84 |     }
85 | 
86 |     public boolean isOnlyRemote() {
87 |         return TextUtils.isEmpty(mCustomConfiguration) || !mUseCustomConfig;
88 |     }
89 | 
90 |     public int getTimeout() {
91 |         if (mConnectTimeout <= 0)
92 |             return CONNECTION_DEFAULT_TIMEOUT;
93 |         else
94 |             return mConnectTimeout;
95 |     }
96 | }
97 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ConnectionStatus.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.os.Parcel;
 9 | import android.os.Parcelable;
10 | 
11 | /**
12 |  * Created by arne on 08.11.16.
13 |  */
14 | public enum ConnectionStatus implements Parcelable {
15 |     LEVEL_CONNECTED,
16 |     LEVEL_VPNPAUSED,
17 |     LEVEL_CONNECTING_SERVER_REPLIED,
18 |     LEVEL_CONNECTING_NO_SERVER_REPLY_YET,
19 |     LEVEL_NONETWORK,
20 |     LEVEL_NOTCONNECTED,
21 |     LEVEL_START,
22 |     LEVEL_AUTH_FAILED,
23 |     LEVEL_WAITING_FOR_USER_INPUT,
24 |     UNKNOWN_LEVEL;
25 | 
26 |     @Override
27 |     public void writeToParcel(Parcel dest, int flags) {
28 |         dest.writeInt(ordinal());
29 |     }
30 | 
31 |     @Override
32 |     public int describeContents() {
33 |         return 0;
34 |     }
35 | 
36 |     public static final Creator<ConnectionStatus> CREATOR = new Creator<ConnectionStatus>() {
37 |         @Override
38 |         public ConnectionStatus createFromParcel(Parcel in) {
39 |             return ConnectionStatus.values()[in.readInt()];
40 |         }
41 | 
42 |         @Override
43 |         public ConnectionStatus[] newArray(int size) {
44 |             return new ConnectionStatus[size];
45 |         }
46 |     };
47 | }
48 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/DeviceStateReceiver.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.content.BroadcastReceiver;
  9 | import android.content.Context;
 10 | import android.content.Intent;
 11 | import android.content.SharedPreferences;
 12 | import android.net.ConnectivityManager;
 13 | import android.net.NetworkInfo;
 14 | import android.net.NetworkInfo.State;
 15 | import android.os.Handler;
 16 | import android.preference.PreferenceManager;
 17 | 
 18 | import de.blinkt.openvpn.R;
 19 | import de.blinkt.openvpn.core.VpnStatus.ByteCountListener;
 20 | 
 21 | import java.util.LinkedList;
 22 | import java.util.Objects;
 23 | import java.util.StringTokenizer;
 24 | 
 25 | import static de.blinkt.openvpn.core.OpenVPNManagement.pauseReason;
 26 | 
 27 | public class DeviceStateReceiver extends BroadcastReceiver implements ByteCountListener, OpenVPNManagement.PausedStateCallback {
 28 |     private final Handler mDisconnectHandler;
 29 |     private int lastNetwork = -1;
 30 |     private OpenVPNManagement mManagement;
 31 | 
 32 |     // Window time in s
 33 |     private final int TRAFFIC_WINDOW = 60;
 34 |     // Data traffic limit in bytes
 35 |     private final long TRAFFIC_LIMIT = 64 * 1024;
 36 | 
 37 |     // Time to wait after network disconnect to pause the VPN
 38 |     private final int DISCONNECT_WAIT = 20;
 39 | 
 40 | 
 41 |     connectState network = connectState.DISCONNECTED;
 42 |     connectState screen = connectState.SHOULDBECONNECTED;
 43 |     connectState userpause = connectState.SHOULDBECONNECTED;
 44 | 
 45 |     private String lastStateMsg = null;
 46 |     private java.lang.Runnable mDelayDisconnectRunnable = new Runnable() {
 47 |         @Override
 48 |         public void run() {
 49 |             if (!(network == connectState.PENDINGDISCONNECT))
 50 |                 return;
 51 | 
 52 |             network = connectState.DISCONNECTED;
 53 | 
 54 |             // Set screen state to be disconnected if disconnect pending
 55 |             if (screen == connectState.PENDINGDISCONNECT)
 56 |                 screen = connectState.DISCONNECTED;
 57 | 
 58 |             mManagement.pause(getPauseReason());
 59 |         }
 60 |     };
 61 |     private NetworkInfo lastConnectedNetwork;
 62 | 
 63 |     @Override
 64 |     public boolean shouldBeRunning() {
 65 |         return shouldBeConnected();
 66 |     }
 67 | 
 68 |     private enum connectState {
 69 |         SHOULDBECONNECTED,
 70 |         PENDINGDISCONNECT,
 71 |         DISCONNECTED
 72 |     }
 73 | 
 74 |     private static class Datapoint {
 75 |         private Datapoint(long t, long d) {
 76 |             timestamp = t;
 77 |             data = d;
 78 |         }
 79 | 
 80 |         long timestamp;
 81 |         long data;
 82 |     }
 83 | 
 84 |     private LinkedList<Datapoint> trafficdata = new LinkedList<>();
 85 | 
 86 | 
 87 |     @Override
 88 |     public void updateByteCount(long in, long out, long diffIn, long diffOut) {
 89 |         if (screen != connectState.PENDINGDISCONNECT)
 90 |             return;
 91 | 
 92 |         long total = diffIn + diffOut;
 93 |         trafficdata.add(new Datapoint(System.currentTimeMillis(), total));
 94 | 
 95 |         while (trafficdata.getFirst().timestamp <= (System.currentTimeMillis() - TRAFFIC_WINDOW * 1000)) {
 96 |             trafficdata.removeFirst();
 97 |         }
 98 | 
 99 |         long windowtraffic = 0;
100 |         for (Datapoint dp : trafficdata)
101 |             windowtraffic += dp.data;
102 | 
103 |         if (windowtraffic < TRAFFIC_LIMIT) {
104 |             screen = connectState.DISCONNECTED;
105 |             VpnStatus.logInfo(R.string.screenoff_pause,
106 |                     "64 kB", TRAFFIC_WINDOW);
107 | 
108 |             mManagement.pause(getPauseReason());
109 |         }
110 |     }
111 | 
112 | 
113 |     public void userPause(boolean pause) {
114 |         if (pause) {
115 |             userpause = connectState.DISCONNECTED;
116 |             // Check if we should disconnect
117 |             mManagement.pause(getPauseReason());
118 |         } else {
119 |             boolean wereConnected = shouldBeConnected();
120 |             userpause = connectState.SHOULDBECONNECTED;
121 |             if (shouldBeConnected() && !wereConnected)
122 |                 mManagement.resume();
123 |             else
124 |                 // Update the reason why we currently paused
125 |                 mManagement.pause(getPauseReason());
126 |         }
127 |     }
128 | 
129 |     public DeviceStateReceiver(OpenVPNManagement magnagement) {
130 |         super();
131 |         mManagement = magnagement;
132 |         mManagement.setPauseCallback(this);
133 |         mDisconnectHandler = new Handler();
134 |     }
135 | 
136 | 
137 |     @Override
138 |     public void onReceive(Context context, Intent intent) {
139 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(context);
140 | 
141 | 
142 |         if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
143 |             networkStateChange(context);
144 |         } else if (Intent.ACTION_SCREEN_OFF.equals(intent.getAction())) {
145 |             boolean screenOffPause = prefs.getBoolean("screenoff", false);
146 | 
147 |             if (screenOffPause) {
148 |                 if (ProfileManager.getLastConnectedVpn() != null && !ProfileManager.getLastConnectedVpn().mPersistTun)
149 |                     VpnStatus.logError(R.string.screen_nopersistenttun);
150 | 
151 |                 screen = connectState.PENDINGDISCONNECT;
152 |                 fillTrafficData();
153 |                 if (network == connectState.DISCONNECTED || userpause == connectState.DISCONNECTED)
154 |                     screen = connectState.DISCONNECTED;
155 |             }
156 |         } else if (Intent.ACTION_SCREEN_ON.equals(intent.getAction())) {
157 |             // Network was disabled because screen off
158 |             boolean connected = shouldBeConnected();
159 |             screen = connectState.SHOULDBECONNECTED;
160 | 
161 |             /* We should connect now, cancel any outstanding disconnect timer */
162 |             mDisconnectHandler.removeCallbacks(mDelayDisconnectRunnable);
163 |             /* should be connected has changed because the screen is on now, connect the VPN */
164 |             if (shouldBeConnected() != connected)
165 |                 mManagement.resume();
166 |             else if (!shouldBeConnected())
167 |                 /*Update the reason why we are still paused */
168 |                 mManagement.pause(getPauseReason());
169 | 
170 |         }
171 |     }
172 | 
173 | 
174 |     private void fillTrafficData() {
175 |         trafficdata.add(new Datapoint(System.currentTimeMillis(), TRAFFIC_LIMIT));
176 |     }
177 | 
178 |     public static boolean equalsObj(Object a, Object b) {
179 |         return (a == null) ? (b == null) : a.equals(b);
180 |     }
181 | 
182 | 
183 |     public void networkStateChange(Context context) {
184 |         NetworkInfo networkInfo = getCurrentNetworkInfo(context);
185 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(context);
186 |         boolean sendusr1 = prefs.getBoolean("netchangereconnect", true);
187 | 
188 | 
189 |         String netstatestring;
190 |         if (networkInfo == null) {
191 |             netstatestring = "not connected";
192 |         } else {
193 |             String subtype = networkInfo.getSubtypeName();
194 |             if (subtype == null)
195 |                 subtype = "";
196 |             String extrainfo = networkInfo.getExtraInfo();
197 |             if (extrainfo == null)
198 |                 extrainfo = "";
199 | 
200 | 			/*
201 |             if(networkInfo.getType()==android.net.ConnectivityManager.TYPE_WIFI) {
202 | 				WifiManager wifiMgr = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
203 | 				WifiInfo wifiinfo = wifiMgr.getConnectionInfo();
204 | 				extrainfo+=wifiinfo.getBSSID();
205 | 
206 | 				subtype += wifiinfo.getNetworkId();
207 | 			}*/
208 | 
209 | 
210 |             netstatestring = String.format("%2$s %4$s to %1$s %3$s", networkInfo.getTypeName(),
211 |                     networkInfo.getDetailedState(), extrainfo, subtype);
212 |         }
213 | 
214 |         if (networkInfo != null && networkInfo.getState() == State.CONNECTED) {
215 |             int newnet = networkInfo.getType();
216 | 
217 |             boolean pendingDisconnect = (network == connectState.PENDINGDISCONNECT);
218 |             network = connectState.SHOULDBECONNECTED;
219 | 
220 |             boolean sameNetwork;
221 |             if (lastConnectedNetwork == null
222 |                     || lastConnectedNetwork.getType() != networkInfo.getType()
223 |                     || !equalsObj(lastConnectedNetwork.getExtraInfo(), networkInfo.getExtraInfo())
224 |                     )
225 |                 sameNetwork = false;
226 |             else
227 |                 sameNetwork = true;
228 | 
229 |             /* Same network, connection still 'established' */
230 |             if (pendingDisconnect && sameNetwork) {
231 |                 mDisconnectHandler.removeCallbacks(mDelayDisconnectRunnable);
232 |                 // Reprotect the sockets just be sure
233 |                 mManagement.networkChange(true);
234 |             } else {
235 |                 /* Different network or connection not established anymore */
236 | 
237 |                 if (screen == connectState.PENDINGDISCONNECT)
238 |                     screen = connectState.DISCONNECTED;
239 | 
240 |                 if (shouldBeConnected()) {
241 |                     mDisconnectHandler.removeCallbacks(mDelayDisconnectRunnable);
242 | 
243 |                     if (pendingDisconnect || !sameNetwork)
244 |                         mManagement.networkChange(sameNetwork);
245 |                     else
246 |                         mManagement.resume();
247 |                 }
248 | 
249 |                 lastNetwork = newnet;
250 |                 lastConnectedNetwork = networkInfo;
251 |             }
252 |         } else if (networkInfo == null) {
253 |             // Not connected, stop openvpn, set last connected network to no network
254 |             lastNetwork = -1;
255 |             if (sendusr1) {
256 |                 network = connectState.PENDINGDISCONNECT;
257 |                 mDisconnectHandler.postDelayed(mDelayDisconnectRunnable, DISCONNECT_WAIT * 1000);
258 | 
259 |             }
260 |         }
261 | 
262 | 
263 |         if (!netstatestring.equals(lastStateMsg))
264 |             VpnStatus.logInfo(R.string.netstatus, netstatestring);
265 |         VpnStatus.logDebug(String.format("Debug state info: %s, pause: %s, shouldbeconnected: %s, network: %s ",
266 |                 netstatestring, getPauseReason(), shouldBeConnected(), network));
267 |         lastStateMsg = netstatestring;
268 | 
269 |     }
270 | 
271 | 
272 |     public boolean isUserPaused() {
273 |         return userpause == connectState.DISCONNECTED;
274 |     }
275 | 
276 |     private boolean shouldBeConnected() {
277 |         return (screen == connectState.SHOULDBECONNECTED && userpause == connectState.SHOULDBECONNECTED &&
278 |                 network == connectState.SHOULDBECONNECTED);
279 |     }
280 | 
281 |     private pauseReason getPauseReason() {
282 |         if (userpause == connectState.DISCONNECTED)
283 |             return pauseReason.userPause;
284 | 
285 |         if (screen == connectState.DISCONNECTED)
286 |             return pauseReason.screenOff;
287 | 
288 |         if (network == connectState.DISCONNECTED)
289 |             return pauseReason.noNetwork;
290 | 
291 |         return pauseReason.userPause;
292 |     }
293 | 
294 |     private NetworkInfo getCurrentNetworkInfo(Context context) {
295 |         ConnectivityManager conn = (ConnectivityManager)
296 |                 context.getSystemService(Context.CONNECTIVITY_SERVICE);
297 | 
298 |         return conn.getActiveNetworkInfo();
299 |     }
300 | }
301 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ExtAuthHelper.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2018 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.content.ComponentName;
  9 | import android.content.Context;
 10 | import android.content.Intent;
 11 | import android.content.ServiceConnection;
 12 | import android.content.pm.PackageManager;
 13 | import android.content.pm.ResolveInfo;
 14 | import android.os.*;
 15 | import android.security.KeyChainException;
 16 | import androidx.annotation.NonNull;
 17 | import androidx.annotation.Nullable;
 18 | import androidx.annotation.WorkerThread;
 19 | import android.widget.ArrayAdapter;
 20 | import android.widget.Spinner;
 21 | import android.widget.SpinnerAdapter;
 22 | import de.blinkt.openvpn.api.ExternalCertificateProvider;
 23 | 
 24 | import java.io.ByteArrayInputStream;
 25 | import java.io.Closeable;
 26 | import java.io.UnsupportedEncodingException;
 27 | import java.security.cert.CertificateException;
 28 | import java.security.cert.CertificateFactory;
 29 | import java.security.cert.X509Certificate;
 30 | import java.util.*;
 31 | import java.util.concurrent.BlockingQueue;
 32 | import java.util.concurrent.LinkedBlockingQueue;
 33 | 
 34 | public class ExtAuthHelper {
 35 | 
 36 |     public static final String ACTION_CERT_CONFIGURATION = "de.blinkt.openvpn.api.ExternalCertificateConfiguration";
 37 |     public static final String ACTION_CERT_PROVIDER = "de.blinkt.openvpn.api.ExternalCertificateProvider";
 38 | 
 39 |     public static final String EXTRA_ALIAS = "de.blinkt.openvpn.api.KEY_ALIAS";
 40 |     public static final String EXTRA_DESCRIPTION = "de.blinkt.openvpn.api.KEY_DESCRIPTION";
 41 | 
 42 | 
 43 |     public static void setExternalAuthProviderSpinnerList(Spinner spinner, String selectedApp) {
 44 |         Context c = spinner.getContext();
 45 |         final PackageManager pm = c.getPackageManager();
 46 |         ArrayList<ExternalAuthProvider> extProviders = getExternalAuthProviderList(c);
 47 | 
 48 |         int selectedPos = -1;
 49 | 
 50 |         if (extProviders.size() ==0)
 51 |         {
 52 |             selectedApp = "";
 53 |             ExternalAuthProvider noauthprovider = new ExternalAuthProvider();
 54 |             noauthprovider.label = "No external auth provider found";
 55 |             noauthprovider.packageName = selectedApp;
 56 |             noauthprovider.configurable = false;
 57 |             extProviders.add(noauthprovider);
 58 |         }
 59 | 
 60 | 
 61 |         for (int i = 0; i < extProviders.size(); i++) {
 62 |             if (extProviders.get(i).packageName.equals(selectedApp))
 63 |                 selectedPos = i;
 64 |         }
 65 |         SpinnerAdapter extAppAdapter = new ArrayAdapter<ExternalAuthProvider>(c, android.R.layout.simple_spinner_item, android.R.id.text1, extProviders);
 66 |         spinner.setAdapter(extAppAdapter);
 67 |         if (selectedPos != -1)
 68 |             spinner.setSelection(selectedPos);
 69 |     }
 70 | 
 71 |     static ArrayList<ExternalAuthProvider> getExternalAuthProviderList(Context c) {
 72 |         Intent configureExtAuth = new Intent(ACTION_CERT_CONFIGURATION);
 73 | 
 74 |         final PackageManager packageManager = c.getPackageManager();
 75 |         List<ResolveInfo> configureList =
 76 |                 packageManager.queryIntentActivities(configureExtAuth, 0);
 77 | 
 78 |         Intent serviceExtAuth = new Intent(ACTION_CERT_PROVIDER);
 79 | 
 80 |         List<ResolveInfo> serviceList =
 81 |                 packageManager.queryIntentServices(serviceExtAuth, 0);
 82 | 
 83 | 
 84 |         // For now only list those who appear in both lists
 85 | 
 86 |         ArrayList<ExternalAuthProvider> providers = new ArrayList<ExternalAuthProvider>();
 87 | 
 88 |         for (ResolveInfo service : serviceList) {
 89 |             ExternalAuthProvider ext = new ExternalAuthProvider();
 90 |             ext.packageName = service.serviceInfo.packageName;
 91 | 
 92 |             ext.label = (String) service.serviceInfo.applicationInfo.loadLabel(packageManager);
 93 | 
 94 |             for (ResolveInfo activity : configureList) {
 95 |                 if (service.serviceInfo.packageName.equals(activity.activityInfo.packageName)) {
 96 |                     ext.configurable = true;
 97 |                 }
 98 |             }
 99 |             providers.add(ext);
100 | 
101 |         }
102 |         return providers;
103 | 
104 |     }
105 | 
106 |     @Nullable
107 |     @WorkerThread
108 |     public static byte[] signData(@NonNull Context context,
109 |                                   @NonNull String extAuthPackageName,
110 |                                   @NonNull String alias,
111 |                                   @NonNull byte[] data
112 |     ) throws KeyChainException, InterruptedException
113 | 
114 |     {
115 | 
116 | 
117 |         try (ExternalAuthProviderConnection authProviderConnection = bindToExtAuthProvider(context.getApplicationContext(), extAuthPackageName)) {
118 |             ExternalCertificateProvider externalAuthProvider = authProviderConnection.getService();
119 |             return externalAuthProvider.getSignedData(alias, data);
120 | 
121 |         } catch (RemoteException e) {
122 |             throw new KeyChainException(e);
123 |         }
124 |     }
125 | 
126 |     @Nullable
127 |     @WorkerThread
128 |     public static X509Certificate[] getCertificateChain(@NonNull Context context,
129 |                                                         @NonNull String extAuthPackageName,
130 |                                                         @NonNull String alias) throws KeyChainException {
131 | 
132 |         final byte[] certificateBytes;
133 |         try (ExternalAuthProviderConnection authProviderConnection = bindToExtAuthProvider(context.getApplicationContext(), extAuthPackageName)) {
134 |             ExternalCertificateProvider externalAuthProvider = authProviderConnection.getService();
135 |             certificateBytes = externalAuthProvider.getCertificateChain(alias);
136 |             if (certificateBytes == null) {
137 |                 return null;
138 |             }
139 |             Collection<X509Certificate> chain = toCertificates(certificateBytes);
140 |             return chain.toArray(new X509Certificate[chain.size()]);
141 | 
142 |         } catch (RemoteException | RuntimeException | InterruptedException e) {
143 |             throw new KeyChainException(e);
144 |         }
145 |     }
146 | 
147 |     public static Bundle getCertificateMetaData(@NonNull Context context,
148 |                                                 @NonNull String extAuthPackageName,
149 |                                                 String alias) throws KeyChainException
150 |     {
151 |         try (ExternalAuthProviderConnection authProviderConnection = bindToExtAuthProvider(context.getApplicationContext(), extAuthPackageName)) {
152 |             ExternalCertificateProvider externalAuthProvider = authProviderConnection.getService();
153 |             return externalAuthProvider.getCertificateMetaData(alias);
154 | 
155 |         } catch (RemoteException | RuntimeException | InterruptedException e) {
156 |             throw new KeyChainException(e);
157 |         }
158 |     }
159 | 
160 |     public static Collection<X509Certificate> toCertificates(@NonNull byte[] bytes) {
161 |         final String BEGINCERT = "-----BEGIN CERTIFICATE-----";
162 |         try {
163 |             Vector<X509Certificate> retCerts = new Vector<>();
164 |             // Java library is broken, although the javadoc says it will extract all certificates from a byte array
165 |             // it only extracts the first one
166 |             String allcerts = new String(bytes, "iso8859-1");
167 |             String[] certstrings = allcerts.split(BEGINCERT);
168 |             for (String certstring: certstrings) {
169 |                 certstring = BEGINCERT + certstring;
170 |                 CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
171 |                 retCerts.addAll((Collection<? extends X509Certificate>) certFactory.generateCertificates(
172 |                         new ByteArrayInputStream((certstring.getBytes("iso8859-1")))));
173 | 
174 |             }
175 |             return retCerts;
176 | 
177 |         } catch (CertificateException e) {
178 |             throw new AssertionError(e);
179 |         } catch (UnsupportedEncodingException e) {
180 |             throw new AssertionError(e);
181 |         }
182 |     }
183 | 
184 |     // adapted form Keychain
185 |     @WorkerThread
186 |     public static ExternalAuthProviderConnection bindToExtAuthProvider(@NonNull Context context, String packagename) throws KeyChainException, InterruptedException {
187 |         ensureNotOnMainThread(context);
188 |         final BlockingQueue<ExternalCertificateProvider> q = new LinkedBlockingQueue<>(1);
189 |         ServiceConnection extAuthServiceConnection = new ServiceConnection() {
190 |             volatile boolean mConnectedAtLeastOnce = false;
191 | 
192 |             @Override
193 |             public void onServiceConnected(ComponentName name, IBinder service) {
194 |                 if (!mConnectedAtLeastOnce) {
195 |                     mConnectedAtLeastOnce = true;
196 |                     try {
197 |                         q.put(ExternalCertificateProvider.Stub.asInterface(service));
198 |                     } catch (InterruptedException e) {
199 |                         // will never happen, since the queue starts with one available slot
200 |                     }
201 |                 }
202 |             }
203 | 
204 |             @Override
205 |             public void onServiceDisconnected(ComponentName name) {
206 |             }
207 |         };
208 |         Intent intent = new Intent(ACTION_CERT_PROVIDER);
209 |         intent.setPackage(packagename);
210 | 
211 |         if (!context.bindService(intent, extAuthServiceConnection, Context.BIND_AUTO_CREATE)) {
212 |             throw new KeyChainException("could not bind to external authticator app: " + packagename);
213 |         }
214 |         return new ExternalAuthProviderConnection(context, extAuthServiceConnection, q.take());
215 |     }
216 | 
217 |     private static void ensureNotOnMainThread(@NonNull Context context) {
218 |         Looper looper = Looper.myLooper();
219 |         if (looper != null && looper == context.getMainLooper()) {
220 |             throw new IllegalStateException(
221 |                     "calling this from your main thread can lead to deadlock");
222 |         }
223 |     }
224 | 
225 |     public static class ExternalAuthProvider {
226 | 
227 |         public String packageName;
228 |         public boolean configurable = false;
229 |         private String label;
230 | 
231 |         @Override
232 |         public String toString() {
233 |             return label;
234 |         }
235 |     }
236 | 
237 |     public static class ExternalAuthProviderConnection implements Closeable {
238 |         private final Context context;
239 |         private final ServiceConnection serviceConnection;
240 |         private final ExternalCertificateProvider service;
241 | 
242 |         protected ExternalAuthProviderConnection(Context context,
243 |                                                  ServiceConnection serviceConnection,
244 |                                                  ExternalCertificateProvider service) {
245 |             this.context = context;
246 |             this.serviceConnection = serviceConnection;
247 |             this.service = service;
248 |         }
249 | 
250 |         @Override
251 |         public void close() {
252 |             context.unbindService(serviceConnection);
253 |         }
254 | 
255 |         public ExternalCertificateProvider getService() {
256 |             return service;
257 |         }
258 |     }
259 | }
260 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ICSOpenVPNApplication.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.annotation.TargetApi;
  9 | import android.app.Application;
 10 | import android.app.NotificationChannel;
 11 | import android.app.NotificationManager;
 12 | import android.content.Context;
 13 | import android.graphics.Color;
 14 | import android.os.Build;
 15 | 
 16 | import android.os.StrictMode;
 17 | import android.provider.Settings;
 18 | 
 19 | // import com.google.android.gms.ads.MobileAds;
 20 | // import com.google.android.gms.ads.initialization.InitializationStatus;
 21 | // import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
 22 | 
 23 | import de.blinkt.openvpn.BuildConfig;
 24 | import de.blinkt.openvpn.R;
 25 | import de.blinkt.openvpn.api.AppRestrictions;
 26 | 
 27 | public class ICSOpenVPNApplication extends Application {
 28 |     private StatusListener mStatus;
 29 | 
 30 |     @Override
 31 |     public void onCreate() {
 32 |         if("robolectric".equals(Build.FINGERPRINT))
 33 |             return;
 34 | 
 35 |         super.onCreate();
 36 |         PRNGFixes.apply();
 37 | 
 38 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
 39 |             createNotificationChannels();
 40 |         mStatus = new StatusListener();
 41 |         mStatus.init(getApplicationContext());
 42 | 
 43 |         if (BuildConfig.BUILD_TYPE.equals("debug"))
 44 |             enableStrictModes();
 45 | 
 46 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
 47 |             AppRestrictions.getInstance(this).checkRestrictions(this);
 48 |         }
 49 |     }
 50 | 
 51 |     private void enableStrictModes() {
 52 |         StrictMode.VmPolicy policy = new StrictMode.VmPolicy.Builder()
 53 |                 .detectAll()
 54 |                 .penaltyLog()
 55 |                 .penaltyDeath()
 56 |                 .build();
 57 |         StrictMode.setVmPolicy(policy);
 58 | 
 59 |     }
 60 | 
 61 |     @TargetApi(Build.VERSION_CODES.O)
 62 |     private void createNotificationChannels() {
 63 |         NotificationManager mNotificationManager =
 64 |                 (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
 65 | 
 66 |         // Background message
 67 |         CharSequence name = getString(R.string.channel_name_background);
 68 |         NotificationChannel mChannel = new NotificationChannel(OpenVPNService.NOTIFICATION_CHANNEL_BG_ID,
 69 |                 name, NotificationManager.IMPORTANCE_MIN);
 70 | 
 71 |         mChannel.setDescription(getString(R.string.channel_description_background));
 72 |         mChannel.enableLights(false);
 73 | 
 74 |         mChannel.setLightColor(Color.DKGRAY);
 75 |         mNotificationManager.createNotificationChannel(mChannel);
 76 | 
 77 |         // Connection status change messages
 78 | 
 79 |         name = getString(R.string.channel_name_status);
 80 |         mChannel = new NotificationChannel(OpenVPNService.NOTIFICATION_CHANNEL_NEWSTATUS_ID,
 81 |                 name, NotificationManager.IMPORTANCE_LOW);
 82 | 
 83 |         mChannel.setDescription(getString(R.string.channel_description_status));
 84 |         mChannel.enableLights(true);
 85 | 
 86 |         mChannel.setLightColor(Color.BLUE);
 87 |         mNotificationManager.createNotificationChannel(mChannel);
 88 | 
 89 | 
 90 |         // Urgent requests, e.g. two factor auth
 91 |         name = getString(R.string.channel_name_userreq);
 92 |         mChannel = new NotificationChannel(OpenVPNService.NOTIFICATION_CHANNEL_USERREQ_ID,
 93 |                 name, NotificationManager.IMPORTANCE_HIGH);
 94 |         mChannel.setDescription(getString(R.string.channel_description_userreq));
 95 |         mChannel.enableVibration(true);
 96 |         mChannel.setLightColor(Color.CYAN);
 97 |         mNotificationManager.createNotificationChannel(mChannel);
 98 |     }
 99 | }
100 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/LogFileHandler.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2015 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.os.Handler;
  9 | import android.os.Looper;
 10 | import android.os.Message;
 11 | 
 12 | import java.io.BufferedInputStream;
 13 | import java.io.File;
 14 | import java.io.FileInputStream;
 15 | import java.io.FileNotFoundException;
 16 | import java.io.FileOutputStream;
 17 | import java.io.IOException;
 18 | import java.io.InputStream;
 19 | import java.io.OutputStream;
 20 | import java.io.UnsupportedEncodingException;
 21 | import java.nio.BufferOverflowException;
 22 | import java.nio.ByteBuffer;
 23 | import java.util.Locale;
 24 | 
 25 | import de.blinkt.openvpn.R;
 26 | 
 27 | /**
 28 |  * Created by arne on 23.01.16.
 29 |  */
 30 | class LogFileHandler extends Handler {
 31 |     static final int TRIM_LOG_FILE = 100;
 32 |     static final int FLUSH_TO_DISK = 101;
 33 |     static final int LOG_INIT = 102;
 34 |     public static final int LOG_MESSAGE = 103;
 35 |     public static final int MAGIC_BYTE = 0x55;
 36 |     protected OutputStream mLogFile;
 37 | 
 38 |     public static final String LOGFILE_NAME = "logcache.dat";
 39 | 
 40 | 
 41 |     public LogFileHandler(Looper looper) {
 42 |         super(looper);
 43 |     }
 44 | 
 45 | 
 46 |     @Override
 47 |     public void handleMessage(Message msg) {
 48 |         try {
 49 |             if (msg.what == LOG_INIT) {
 50 |                 if (mLogFile != null)
 51 |                     throw new RuntimeException("mLogFile not null");
 52 |                 readLogCache((File) msg.obj);
 53 |                 openLogFile((File) msg.obj);
 54 |             } else if (msg.what == LOG_MESSAGE && msg.obj instanceof LogItem) {
 55 |                 // Ignore log messages if not yet initialized
 56 |                 if (mLogFile == null)
 57 |                     return;
 58 |                 writeLogItemToDisk((LogItem) msg.obj);
 59 |             } else if (msg.what == TRIM_LOG_FILE) {
 60 |                 trimLogFile();
 61 |                 for (LogItem li : VpnStatus.getlogbuffer())
 62 |                     writeLogItemToDisk(li);
 63 |             } else if (msg.what == FLUSH_TO_DISK) {
 64 |                 flushToDisk();
 65 |             }
 66 | 
 67 |         } catch (IOException | BufferOverflowException e) {
 68 |             e.printStackTrace();
 69 |             VpnStatus.logError("Error during log cache: " + msg.what);
 70 |             VpnStatus.logException(e);
 71 |         }
 72 | 
 73 |     }
 74 | 
 75 |     private void flushToDisk() throws IOException {
 76 |         mLogFile.flush();
 77 |     }
 78 | 
 79 |     private void trimLogFile() {
 80 |         try {
 81 |             mLogFile.flush();
 82 |             ((FileOutputStream) mLogFile).getChannel().truncate(0);
 83 |         } catch (IOException e) {
 84 |             e.printStackTrace();
 85 |         }
 86 |     }
 87 | 
 88 |     private void writeLogItemToDisk(LogItem li) throws IOException {
 89 | 
 90 |         // We do not really care if the log cache breaks between Android upgrades,
 91 |         // write binary format to disc
 92 | 
 93 |         byte[] liBytes = li.getMarschaledBytes();
 94 | 
 95 |         writeEscapedBytes(liBytes);
 96 |     }
 97 | 
 98 |     public void writeEscapedBytes(byte[] bytes) throws IOException {
 99 |         int magic = 0;
100 |         for (byte b : bytes)
101 |             if (b == MAGIC_BYTE || b == MAGIC_BYTE + 1)
102 |                 magic++;
103 | 
104 |         byte eBytes[] = new byte[bytes.length + magic];
105 | 
106 |         int i = 0;
107 |         for (byte b : bytes) {
108 |             if (b == MAGIC_BYTE || b == MAGIC_BYTE + 1) {
109 |                 eBytes[i++] = MAGIC_BYTE + 1;
110 |                 eBytes[i++] = (byte) (b - MAGIC_BYTE);
111 |             } else {
112 |                 eBytes[i++] = b;
113 |             }
114 |         }
115 | 
116 |         byte[] lenBytes = ByteBuffer.allocate(4).putInt(bytes.length).array();
117 |         synchronized (mLogFile) {
118 |             mLogFile.write(MAGIC_BYTE);
119 |             mLogFile.write(lenBytes);
120 |             mLogFile.write(eBytes);
121 |         }
122 |     }
123 | 
124 |     private void openLogFile(File cacheDir) throws FileNotFoundException {
125 |         File logfile = new File(cacheDir, LOGFILE_NAME);
126 |         mLogFile = new FileOutputStream(logfile);
127 |     }
128 | 
129 |     private void readLogCache(File cacheDir) {
130 |         try {
131 |             File logfile = new File(cacheDir, LOGFILE_NAME);
132 | 
133 | 
134 |             if (!logfile.exists() || !logfile.canRead())
135 |                 return;
136 | 
137 |             FileInputStream log = new FileInputStream(logfile);
138 |             readCacheContents(log);
139 |             log.close();
140 | 
141 |         } catch (java.io.IOException | java.lang.RuntimeException e) {
142 |             VpnStatus.logError("Reading cached logfile failed");
143 |             VpnStatus.logException(e);
144 |             e.printStackTrace();
145 |             // ignore reading file error
146 |         } finally {
147 |             synchronized (VpnStatus.readFileLock) {
148 |                 VpnStatus.readFileLog = true;
149 |                 VpnStatus.readFileLock.notifyAll();
150 |             }
151 |         }
152 |     }
153 | 
154 | 
155 |     protected void readCacheContents(InputStream in) throws IOException {
156 |         BufferedInputStream logFile = new BufferedInputStream(in);
157 | 
158 |         byte[] buf = new byte[16384];
159 |         int read = logFile.read(buf, 0, 5);
160 |         int itemsRead = 0;
161 | 
162 | 
163 |         readloop:
164 |         while (read >= 5) {
165 |             int skipped = 0;
166 |             while (buf[skipped] != MAGIC_BYTE) {
167 |                 skipped++;
168 |                 if (!(logFile.read(buf, skipped + 4, 1) == 1) || skipped + 10 > buf.length) {
169 |                     VpnStatus.logDebug(String.format(Locale.US, "Skipped %d bytes and no a magic byte found", skipped));
170 |                     break readloop;
171 |                 }
172 |             }
173 |             if (skipped > 0)
174 |                 VpnStatus.logDebug(String.format(Locale.US, "Skipped %d bytes before finding a magic byte", skipped));
175 | 
176 |             int len = ByteBuffer.wrap(buf, skipped + 1, 4).asIntBuffer().get();
177 | 
178 |             // Marshalled LogItem
179 |             int pos = 0;
180 |             byte buf2[] = new byte[buf.length];
181 | 
182 |             while (pos < len) {
183 |                 byte b = (byte) logFile.read();
184 |                 if (b == MAGIC_BYTE) {
185 |                     VpnStatus.logDebug(String.format(Locale.US, "Unexpected magic byte found at pos %d, abort current log item", pos));
186 |                     read = logFile.read(buf, 1, 4) + 1;
187 |                     continue readloop;
188 |                 } else if (b == MAGIC_BYTE + 1) {
189 |                     b = (byte) logFile.read();
190 |                     if (b == 0)
191 |                         b = MAGIC_BYTE;
192 |                     else if (b == 1)
193 |                         b = MAGIC_BYTE + 1;
194 |                     else {
195 |                         VpnStatus.logDebug(String.format(Locale.US, "Escaped byte not 0 or 1: %d", b));
196 |                         read = logFile.read(buf, 1, 4) + 1;
197 |                         continue readloop;
198 |                     }
199 |                 }
200 |                 buf2[pos++] = b;
201 |             }
202 | 
203 |             restoreLogItem(buf2, len);
204 | 
205 |             //Next item
206 |             read = logFile.read(buf, 0, 5);
207 |             itemsRead++;
208 |             if (itemsRead > 2 * VpnStatus.MAXLOGENTRIES) {
209 |                 VpnStatus.logError("Too many logentries read from cache, aborting.");
210 |                 read = 0;
211 |             }
212 | 
213 |         }
214 |         VpnStatus.logDebug(R.string.reread_log, itemsRead);
215 |     }
216 | 
217 |     protected void restoreLogItem(byte[] buf, int len) throws UnsupportedEncodingException {
218 | 
219 |         LogItem li = new LogItem(buf, len);
220 |         if (li.verify()) {
221 |             VpnStatus.newLogItem(li, true);
222 |         } else {
223 |             VpnStatus.logError(String.format(Locale.getDefault(),
224 |                     "Could not read log item from file: %d: %s",
225 |                     len, bytesToHex(buf, Math.max(len, 80))));
226 |         }
227 |     }
228 | 
229 |     private final static char[] hexArray = "0123456789ABCDEF".toCharArray();
230 | 
231 |     public static String bytesToHex(byte[] bytes, int len) {
232 |         len = Math.min(bytes.length, len);
233 |         char[] hexChars = new char[len * 2];
234 |         for (int j = 0; j < len; j++) {
235 |             int v = bytes[j] & 0xFF;
236 |             hexChars[j * 2] = hexArray[v >>> 4];
237 |             hexChars[j * 2 + 1] = hexArray[v & 0x0F];
238 |         }
239 |         return new String(hexChars);
240 |     }
241 | 
242 | 
243 | }
244 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/LogItem.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.annotation.SuppressLint;
  9 | import android.content.Context;
 10 | import android.content.pm.PackageInfo;
 11 | import android.content.pm.PackageManager;
 12 | import android.content.pm.Signature;
 13 | import android.os.Parcel;
 14 | import android.os.Parcelable;
 15 | 
 16 | import java.io.ByteArrayInputStream;
 17 | import java.io.UnsupportedEncodingException;
 18 | import java.nio.BufferOverflowException;
 19 | import java.nio.ByteBuffer;
 20 | import java.security.MessageDigest;
 21 | import java.security.NoSuchAlgorithmException;
 22 | import java.security.cert.CertificateException;
 23 | import java.security.cert.CertificateFactory;
 24 | import java.security.cert.X509Certificate;
 25 | import java.util.Arrays;
 26 | import java.util.FormatFlagsConversionMismatchException;
 27 | import java.util.Locale;
 28 | import java.util.UnknownFormatConversionException;
 29 | 
 30 | import de.blinkt.openvpn.R;
 31 | 
 32 | /**
 33 |  * Created by arne on 24.04.16.
 34 |  */
 35 | public class LogItem implements Parcelable {
 36 |     private Object[] mArgs = null;
 37 |     private String mMessage = null;
 38 |     private int mRessourceId;
 39 |     // Default log priority
 40 |     VpnStatus.LogLevel mLevel = VpnStatus.LogLevel.INFO;
 41 |     private long logtime = System.currentTimeMillis();
 42 |     private int mVerbosityLevel = -1;
 43 | 
 44 |     private LogItem(int ressourceId, Object[] args) {
 45 |         mRessourceId = ressourceId;
 46 |         mArgs = args;
 47 |     }
 48 | 
 49 |     public LogItem(VpnStatus.LogLevel level, int verblevel, String message) {
 50 |         mMessage = message;
 51 |         mLevel = level;
 52 |         mVerbosityLevel = verblevel;
 53 |     }
 54 | 
 55 |     @Override
 56 |     public int describeContents() {
 57 |         return 0;
 58 |     }
 59 | 
 60 | 
 61 |     @Override
 62 |     public void writeToParcel(Parcel dest, int flags) {
 63 |         dest.writeArray(mArgs);
 64 |         dest.writeString(mMessage);
 65 |         dest.writeInt(mRessourceId);
 66 |         dest.writeInt(mLevel.getInt());
 67 |         dest.writeInt(mVerbosityLevel);
 68 | 
 69 |         dest.writeLong(logtime);
 70 |     }
 71 | 
 72 |     @Override
 73 |     public boolean equals(Object obj) {
 74 |         if (!(obj instanceof LogItem))
 75 |             return obj.equals(this);
 76 |         LogItem other = (LogItem) obj;
 77 | 
 78 |         return Arrays.equals(mArgs, other.mArgs) &&
 79 |                 ((other.mMessage == null && mMessage == other.mMessage) ||
 80 |                         mMessage.equals(other.mMessage)) &&
 81 |                 mRessourceId == other.mRessourceId &&
 82 |                 ((mLevel == null && other.mLevel == mLevel) ||
 83 |                         other.mLevel.equals(mLevel)) &&
 84 |                 mVerbosityLevel == other.mVerbosityLevel &&
 85 |                 logtime == other.logtime;
 86 | 
 87 | 
 88 |     }
 89 | 
 90 |     public byte[] getMarschaledBytes() throws UnsupportedEncodingException, BufferOverflowException {
 91 |         ByteBuffer bb = ByteBuffer.allocate(16384);
 92 | 
 93 | 
 94 |         bb.put((byte) 0x0);               //version
 95 |         bb.putLong(logtime);              //8
 96 |         bb.putInt(mVerbosityLevel);      //4
 97 |         bb.putInt(mLevel.getInt());
 98 |         bb.putInt(mRessourceId);
 99 |         if (mMessage == null || mMessage.length() == 0) {
100 |             bb.putInt(0);
101 |         } else {
102 |             marschalString(mMessage, bb);
103 |         }
104 |         if (mArgs == null || mArgs.length == 0) {
105 |             bb.putInt(0);
106 |         } else {
107 |             bb.putInt(mArgs.length);
108 |             for (Object o : mArgs) {
109 |                 if (o instanceof String) {
110 |                     bb.putChar('s');
111 |                     marschalString((String) o, bb);
112 |                 } else if (o instanceof Integer) {
113 |                     bb.putChar('i');
114 |                     bb.putInt((Integer) o);
115 |                 } else if (o instanceof Float) {
116 |                     bb.putChar('f');
117 |                     bb.putFloat((Float) o);
118 |                 } else if (o instanceof Double) {
119 |                     bb.putChar('d');
120 |                     bb.putDouble((Double) o);
121 |                 } else if (o instanceof Long) {
122 |                     bb.putChar('l');
123 |                     bb.putLong((Long) o);
124 |                 } else if (o == null) {
125 |                     bb.putChar('0');
126 |                 } else {
127 |                     VpnStatus.logDebug("Unknown object for LogItem marschaling " + o);
128 |                     bb.putChar('s');
129 |                     marschalString(o.toString(), bb);
130 |                 }
131 | 
132 |             }
133 |         }
134 | 
135 |         int pos = bb.position();
136 |         bb.rewind();
137 |         return Arrays.copyOf(bb.array(), pos);
138 | 
139 |     }
140 | 
141 |     public LogItem(byte[] in, int length) throws UnsupportedEncodingException {
142 |         ByteBuffer bb = ByteBuffer.wrap(in, 0, length);
143 |         bb.get(); // ignore version
144 |         logtime = bb.getLong();
145 |         mVerbosityLevel = bb.getInt();
146 |         mLevel = VpnStatus.LogLevel.getEnumByValue(bb.getInt());
147 |         mRessourceId = bb.getInt();
148 |         int len = bb.getInt();
149 |         if (len == 0) {
150 |             mMessage = null;
151 |         } else {
152 |             if (len > bb.remaining())
153 |                 throw new IndexOutOfBoundsException("String length " + len + " is bigger than remaining bytes " + bb.remaining());
154 |             byte[] utf8bytes = new byte[len];
155 |             bb.get(utf8bytes);
156 |             mMessage = new String(utf8bytes, "UTF-8");
157 |         }
158 |         int numArgs = bb.getInt();
159 |         if (numArgs > 30) {
160 |             throw new IndexOutOfBoundsException("Too many arguments for Logitem to unmarschal");
161 |         }
162 |         if (numArgs == 0) {
163 |             mArgs = null;
164 |         } else {
165 |             mArgs = new Object[numArgs];
166 |             for (int i = 0; i < numArgs; i++) {
167 |                 char type = bb.getChar();
168 |                 switch (type) {
169 |                     case 's':
170 |                         mArgs[i] = unmarschalString(bb);
171 |                         break;
172 |                     case 'i':
173 |                         mArgs[i] = bb.getInt();
174 |                         break;
175 |                     case 'd':
176 |                         mArgs[i] = bb.getDouble();
177 |                         break;
178 |                     case 'f':
179 |                         mArgs[i] = bb.getFloat();
180 |                         break;
181 |                     case 'l':
182 |                         mArgs[i] = bb.getLong();
183 |                         break;
184 |                     case '0':
185 |                         mArgs[i] = null;
186 |                         break;
187 |                     default:
188 |                         throw new UnsupportedEncodingException("Unknown format type: " + type);
189 |                 }
190 |             }
191 |         }
192 |         if (bb.hasRemaining())
193 |             throw new UnsupportedEncodingException(bb.remaining() + " bytes left after unmarshaling everything");
194 |     }
195 | 
196 |     private void marschalString(String str, ByteBuffer bb) throws UnsupportedEncodingException {
197 |         byte[] utf8bytes = str.getBytes("UTF-8");
198 |         bb.putInt(utf8bytes.length);
199 |         bb.put(utf8bytes);
200 |     }
201 | 
202 |     private String unmarschalString(ByteBuffer bb) throws UnsupportedEncodingException {
203 |         int len = bb.getInt();
204 |         byte[] utf8bytes = new byte[len];
205 |         bb.get(utf8bytes);
206 |         return new String(utf8bytes, "UTF-8");
207 |     }
208 | 
209 | 
210 |     public LogItem(Parcel in) {
211 |         mArgs = in.readArray(Object.class.getClassLoader());
212 |         mMessage = in.readString();
213 |         mRessourceId = in.readInt();
214 |         mLevel = VpnStatus.LogLevel.getEnumByValue(in.readInt());
215 |         mVerbosityLevel = in.readInt();
216 |         logtime = in.readLong();
217 |     }
218 | 
219 |     public static final Creator<LogItem> CREATOR
220 |             = new Creator<LogItem>() {
221 |         public LogItem createFromParcel(Parcel in) {
222 |             return new LogItem(in);
223 |         }
224 | 
225 |         public LogItem[] newArray(int size) {
226 |             return new LogItem[size];
227 |         }
228 |     };
229 | 
230 |     public LogItem(VpnStatus.LogLevel loglevel, int ressourceId, Object... args) {
231 |         mRessourceId = ressourceId;
232 |         mArgs = args;
233 |         mLevel = loglevel;
234 |     }
235 | 
236 | 
237 |     public LogItem(VpnStatus.LogLevel loglevel, String msg) {
238 |         mLevel = loglevel;
239 |         mMessage = msg;
240 |     }
241 | 
242 | 
243 |     public LogItem(VpnStatus.LogLevel loglevel, int ressourceId) {
244 |         mRessourceId = ressourceId;
245 |         mLevel = loglevel;
246 |     }
247 | 
248 |     public String getString(Context c) {
249 |         try {
250 |             if (mMessage != null) {
251 |                 return mMessage;
252 |             } else {
253 |                 if (c != null) {
254 |                     if (mRessourceId == R.string.mobile_info)
255 |                         return getMobileInfoString(c);
256 |                     if (mArgs == null)
257 |                         return c.getString(mRessourceId);
258 |                     else
259 |                         return c.getString(mRessourceId, mArgs);
260 |                 } else {
261 |                     String str = String.format(Locale.ENGLISH, "Log (no context) resid %d", mRessourceId);
262 |                     if (mArgs != null)
263 |                         str += join("|", mArgs);
264 | 
265 |                     return str;
266 |                 }
267 |             }
268 |         } catch (UnknownFormatConversionException e) {
269 |             if (c != null)
270 |                 throw new UnknownFormatConversionException(e.getLocalizedMessage() + getString(null));
271 |             else
272 |                 throw e;
273 |         } catch (java.util.FormatFlagsConversionMismatchException e) {
274 |             if (c != null)
275 |                 throw new FormatFlagsConversionMismatchException(e.getLocalizedMessage() + getString(null), e.getConversion());
276 |             else
277 |                 throw e;
278 |         }
279 | 
280 |     }
281 | 
282 | 
283 |     // TextUtils.join will cause not macked exeception in tests ....
284 |     public static String join(CharSequence delimiter, Object[] tokens) {
285 |         StringBuilder sb = new StringBuilder();
286 |         boolean firstTime = true;
287 |         for (Object token : tokens) {
288 |             if (firstTime) {
289 |                 firstTime = false;
290 |             } else {
291 |                 sb.append(delimiter);
292 |             }
293 |             sb.append(token);
294 |         }
295 |         return sb.toString();
296 |     }
297 | 
298 | 
299 |     public VpnStatus.LogLevel getLogLevel() {
300 |         return mLevel;
301 |     }
302 | 
303 | 
304 |     @Override
305 |     public String toString() {
306 |         return getString(null);
307 |     }
308 | 
309 |     // The lint is wrong here
310 |     @SuppressLint("StringFormatMatches")
311 |     private String getMobileInfoString(Context c) {
312 |         c.getPackageManager();
313 |         String apksign = "error getting package signature";
314 | 
315 |         String version = "error getting version";
316 |         try {
317 |             @SuppressLint("PackageManagerGetSignatures")
318 |             Signature raw = c.getPackageManager().getPackageInfo(c.getPackageName(), PackageManager.GET_SIGNATURES).signatures[0];
319 |             CertificateFactory cf = CertificateFactory.getInstance("X.509");
320 |             X509Certificate cert = (X509Certificate) cf.generateCertificate(new ByteArrayInputStream(raw.toByteArray()));
321 |             MessageDigest md = MessageDigest.getInstance("SHA-1");
322 |             byte[] der = cert.getEncoded();
323 |             md.update(der);
324 |             byte[] digest = md.digest();
325 | 
326 |             if (Arrays.equals(digest, VpnStatus.officalkey))
327 |                 apksign = c.getString(R.string.official_build);
328 |             else if (Arrays.equals(digest, VpnStatus.officaldebugkey))
329 |                 apksign = c.getString(R.string.debug_build);
330 |             else if (Arrays.equals(digest, VpnStatus.amazonkey))
331 |                 apksign = "amazon version";
332 |             else if (Arrays.equals(digest, VpnStatus.fdroidkey))
333 |                 apksign = "F-Droid built and signed version";
334 |             else
335 |                 apksign = c.getString(R.string.built_by, cert.getSubjectX500Principal().getName());
336 | 
337 |             PackageInfo packageinfo = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
338 |             version = packageinfo.versionName;
339 | 
340 |         } catch (PackageManager.NameNotFoundException | CertificateException |
341 |                 NoSuchAlgorithmException ignored) {
342 |         }
343 | 
344 |         Object[] argsext = Arrays.copyOf(mArgs, mArgs.length);
345 |         argsext[argsext.length - 1] = apksign;
346 |         argsext[argsext.length - 2] = version;
347 | 
348 |         return c.getString(R.string.mobile_info, argsext);
349 | 
350 |     }
351 | 
352 |     public long getLogtime() {
353 |         return logtime;
354 |     }
355 | 
356 | 
357 |     public int getVerbosityLevel() {
358 |         if (mVerbosityLevel == -1) {
359 |             // Hack:
360 |             // For message not from OpenVPN, report the status level as log level
361 |             return mLevel.getInt();
362 |         }
363 |         return mVerbosityLevel;
364 |     }
365 | 
366 |     public boolean verify() {
367 |         if (mLevel == null)
368 |             return false;
369 | 
370 |         if (mMessage == null && mRessourceId == 0)
371 |             return false;
372 | 
373 |         return true;
374 |     }
375 | }
376 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/LollipopDeviceStateListener.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.annotation.TargetApi;
 9 | import android.net.ConnectivityManager;
10 | import android.net.LinkProperties;
11 | import android.net.Network;
12 | import android.net.NetworkCapabilities;
13 | import android.os.Build;
14 | 
15 | /**
16 |  * Created by arne on 26.11.14.
17 |  */
18 | @TargetApi(Build.VERSION_CODES.LOLLIPOP)
19 | public class LollipopDeviceStateListener extends ConnectivityManager.NetworkCallback {
20 | 
21 |     private String mLastConnectedStatus;
22 |     private String mLastLinkProperties;
23 |     private String mLastNetworkCapabilities;
24 | 
25 |     @Override
26 |     public void onAvailable(Network network) {
27 |         super.onAvailable(network);
28 | 
29 |         if (!network.toString().equals(mLastConnectedStatus)) {
30 |             mLastConnectedStatus = network.toString();
31 |             VpnStatus.logDebug("Connected to " + mLastConnectedStatus);
32 |         }
33 |     }
34 | 
35 |     @Override
36 |     public void onLinkPropertiesChanged(Network network, LinkProperties linkProperties) {
37 |         super.onLinkPropertiesChanged(network, linkProperties);
38 | 
39 |         if (!linkProperties.toString().equals(mLastLinkProperties)) {
40 |             mLastLinkProperties = linkProperties.toString();
41 |             VpnStatus.logDebug(String.format("Linkproperties of %s: %s", network, linkProperties));
42 |         }
43 |     }
44 | 
45 |     @Override
46 |     public void onCapabilitiesChanged(Network network, NetworkCapabilities networkCapabilities) {
47 |         super.onCapabilitiesChanged(network, networkCapabilities);
48 |         if (!networkCapabilities.toString().equals(mLastNetworkCapabilities)) {
49 |             mLastNetworkCapabilities = networkCapabilities.toString();
50 |             VpnStatus.logDebug(String.format("Network capabilities of %s: %s", network, networkCapabilities));
51 |         }
52 |     }
53 | }
54 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/NativeUtils.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.os.Build;
 9 | import de.blinkt.openvpn.BuildConfig;
10 | 
11 | import java.security.InvalidKeyException;
12 | 
13 | public class NativeUtils {
14 |     public static native byte[] rsasign(byte[] input, int pkey, boolean pkcs1padding) throws InvalidKeyException;
15 | 
16 |     public static native String[] getIfconfig() throws IllegalArgumentException;
17 | 
18 |     static native void jniclose(int fdint);
19 | 
20 |     public static String getNativeAPI()
21 |     {
22 |         if (isRoboUnitTest())
23 |             return "ROBO";
24 |         else
25 |             return getJNIAPI();
26 |     }
27 | 
28 |     private static native String getJNIAPI();
29 | 
30 |     public static native String getOpenVPN2GitVersion();
31 | 
32 |     public static native String getOpenVPN3GitVersion();
33 | 
34 |     public final static int[] openSSLlengths = {
35 |         16, 64, 256, 1024, 8 * 1024, 16 * 1024
36 |     };
37 | 
38 |     public static native double[] getOpenSSLSpeed(String algorithm, int testnum);
39 | 
40 |     static {
41 |         if (!isRoboUnitTest()) {
42 |             System.loadLibrary("opvpnutil");
43 |             if (Build.VERSION.SDK_INT == Build.VERSION_CODES.JELLY_BEAN)
44 |                 System.loadLibrary("jbcrypto");
45 | 
46 |         }
47 |     }
48 | 
49 |     public static boolean isRoboUnitTest() {
50 |         return "robolectric".equals(Build.FINGERPRINT); }
51 | 
52 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/NetworkSpace.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.os.Build;
  9 | import androidx.annotation.NonNull;
 10 | 
 11 | import java.math.BigInteger;
 12 | import java.net.Inet6Address;
 13 | import java.util.Collection;
 14 | import java.util.Locale;
 15 | import java.util.PriorityQueue;
 16 | import java.util.TreeSet;
 17 | import java.util.Vector;
 18 | 
 19 | import de.blinkt.openvpn.BuildConfig;
 20 | 
 21 | 
 22 | 
 23 | public class NetworkSpace {
 24 | 
 25 |     static void assertTrue(boolean f)
 26 |     {
 27 |         if (!f)
 28 |             throw new IllegalStateException();
 29 |     }
 30 | 
 31 |     static class IpAddress implements Comparable<IpAddress> {
 32 |         private BigInteger netAddress;
 33 |         public int networkMask;
 34 |         private boolean included;
 35 |         private boolean isV4;
 36 |         private BigInteger firstAddress;
 37 |         private BigInteger lastAddress;
 38 | 
 39 | 
 40 |         /**
 41 |          * sorts the networks with following criteria:
 42 |          * 1. compares first 1 of the network
 43 |          * 2. smaller networks are returned as smaller
 44 |          */
 45 |         @Override
 46 |         public int compareTo(@NonNull IpAddress another) {
 47 |             int comp = getFirstAddress().compareTo(another.getFirstAddress());
 48 |             if (comp != 0)
 49 |                 return comp;
 50 | 
 51 | 
 52 |             if (networkMask > another.networkMask)
 53 |                 return -1;
 54 |             else if (another.networkMask == networkMask)
 55 |                 return 0;
 56 |             else
 57 |                 return 1;
 58 |         }
 59 | 
 60 |         /**
 61 |          * Warning ignores the included integer
 62 |          *
 63 |          * @param o the object to compare this instance with.
 64 |          */
 65 |         @Override
 66 |         public boolean equals(Object o) {
 67 |             if (!(o instanceof IpAddress))
 68 |                 return super.equals(o);
 69 | 
 70 | 
 71 |             IpAddress on = (IpAddress) o;
 72 |             return (networkMask == on.networkMask) && on.getFirstAddress().equals(getFirstAddress());
 73 |         }
 74 | 
 75 |         public IpAddress(CIDRIP ip, boolean include) {
 76 |             included = include;
 77 |             netAddress = BigInteger.valueOf(ip.getInt());
 78 |             networkMask = ip.len;
 79 |             isV4 = true;
 80 |         }
 81 | 
 82 |         public IpAddress(Inet6Address address, int mask, boolean include) {
 83 |             networkMask = mask;
 84 |             included = include;
 85 | 
 86 |             int s = 128;
 87 | 
 88 |             netAddress = BigInteger.ZERO;
 89 |             for (byte b : address.getAddress()) {
 90 |                 s -= 8;
 91 |                 netAddress = netAddress.add(BigInteger.valueOf((b & 0xFF)).shiftLeft(s));
 92 |             }
 93 |         }
 94 | 
 95 |         public BigInteger getLastAddress() {
 96 |             if (lastAddress == null)
 97 |                 lastAddress = getMaskedAddress(true);
 98 |             return lastAddress;
 99 |         }
100 | 
101 | 
102 |         public BigInteger getFirstAddress() {
103 |             if (firstAddress == null)
104 |                 firstAddress = getMaskedAddress(false);
105 |             return firstAddress;
106 |         }
107 | 
108 | 
109 |         private BigInteger getMaskedAddress(boolean one) {
110 |             BigInteger numAddress = netAddress;
111 | 
112 |             int numBits;
113 |             if (isV4) {
114 |                 numBits = 32 - networkMask;
115 |             } else {
116 |                 numBits = 128 - networkMask;
117 |             }
118 | 
119 |             for (int i = 0; i < numBits; i++) {
120 |                 if (one)
121 |                     numAddress = numAddress.setBit(i);
122 |                 else
123 |                     numAddress = numAddress.clearBit(i);
124 |             }
125 |             return numAddress;
126 |         }
127 | 
128 | 
129 |         @Override
130 |         public String toString() {
131 |             //String in = included ? "+" : "-";
132 |             if (isV4)
133 |                 return String.format(Locale.US, "%s/%d", getIPv4Address(), networkMask);
134 |             else
135 |                 return String.format(Locale.US, "%s/%d", getIPv6Address(), networkMask);
136 |         }
137 | 
138 |         IpAddress(BigInteger baseAddress, int mask, boolean included, boolean isV4) {
139 |             this.netAddress = baseAddress;
140 |             this.networkMask = mask;
141 |             this.included = included;
142 |             this.isV4 = isV4;
143 |         }
144 | 
145 | 
146 |         public IpAddress[] split() {
147 |             IpAddress firstHalf = new IpAddress(getFirstAddress(), networkMask + 1, included, isV4);
148 |             IpAddress secondHalf = new IpAddress(firstHalf.getLastAddress().add(BigInteger.ONE), networkMask + 1, included, isV4);
149 |             if (BuildConfig.DEBUG)
150 |                 assertTrue(secondHalf.getLastAddress().equals(getLastAddress()));
151 |             return new IpAddress[]{firstHalf, secondHalf};
152 |         }
153 | 
154 |         String getIPv4Address() {
155 |             if (BuildConfig.DEBUG) {
156 |                 assertTrue(isV4);
157 |                 assertTrue(netAddress.longValue() <= 0xffffffffl);
158 |                 assertTrue(netAddress.longValue() >= 0);
159 |             }
160 |             long ip = netAddress.longValue();
161 |             return String.format(Locale.US, "%d.%d.%d.%d", (ip >> 24) % 256, (ip >> 16) % 256, (ip >> 8) % 256, ip % 256);
162 |         }
163 | 
164 |         String getIPv6Address() {
165 |             if (BuildConfig.DEBUG) assertTrue(!isV4);
166 |             BigInteger r = netAddress;
167 | 
168 |             String ipv6str = null;
169 |             boolean lastPart = true;
170 | 
171 |             while (r.compareTo(BigInteger.ZERO) == 1) {
172 | 
173 |                 long part = r.mod(BigInteger.valueOf(0x10000)).longValue();
174 |                 if (ipv6str != null || part != 0) {
175 |                     if (ipv6str == null && !lastPart)
176 |                             ipv6str = ":";
177 | 
178 |                     if (lastPart)
179 |                         ipv6str = String.format(Locale.US, "%x", part, ipv6str);
180 |                     else
181 |                         ipv6str = String.format(Locale.US, "%x:%s", part, ipv6str);
182 |                 }
183 | 
184 |                 r = r.shiftRight(16);
185 |                 lastPart = false;
186 |             }
187 |             if (ipv6str == null)
188 |                 return "::";
189 | 
190 | 
191 |             return ipv6str;
192 |         }
193 | 
194 |         public boolean containsNet(IpAddress network) {
195 |             // this.first >= net.first &&  this.last <= net.last
196 |             BigInteger ourFirst = getFirstAddress();
197 |             BigInteger ourLast = getLastAddress();
198 |             BigInteger netFirst = network.getFirstAddress();
199 |             BigInteger netLast = network.getLastAddress();
200 | 
201 |             boolean a = ourFirst.compareTo(netFirst) != 1;
202 |             boolean b = ourLast.compareTo(netLast) != -1;
203 |             return a && b;
204 | 
205 |         }
206 |     }
207 | 
208 | 
209 |     TreeSet<IpAddress> mIpAddresses = new TreeSet<IpAddress>();
210 | 
211 | 
212 |     public Collection<IpAddress> getNetworks(boolean included) {
213 |         Vector<IpAddress> ips = new Vector<IpAddress>();
214 |         for (IpAddress ip : mIpAddresses) {
215 |             if (ip.included == included)
216 |                 ips.add(ip);
217 |         }
218 |         return ips;
219 |     }
220 | 
221 |     public void clear() {
222 |         mIpAddresses.clear();
223 |     }
224 | 
225 | 
226 |     void addIP(CIDRIP cidrIp, boolean include) {
227 | 
228 |         mIpAddresses.add(new IpAddress(cidrIp, include));
229 |     }
230 | 
231 |     public void addIPSplit(CIDRIP cidrIp, boolean include) {
232 |         IpAddress newIP = new IpAddress(cidrIp, include);
233 |         IpAddress[] splitIps = newIP.split();
234 |         for (IpAddress split : splitIps)
235 |             mIpAddresses.add(split);
236 |     }
237 | 
238 |     void addIPv6(Inet6Address address, int mask, boolean included) {
239 |         mIpAddresses.add(new IpAddress(address, mask, included));
240 |     }
241 | 
242 |     TreeSet<IpAddress> generateIPList() {
243 | 
244 |         PriorityQueue<IpAddress> networks = new PriorityQueue<IpAddress>(mIpAddresses);
245 | 
246 |         TreeSet<IpAddress> ipsDone = new TreeSet<IpAddress>();
247 | 
248 |         IpAddress currentNet = networks.poll();
249 |         if (currentNet == null)
250 |             return ipsDone;
251 | 
252 |         while (currentNet != null) {
253 |             // Check if it and the next of it are compatible
254 |             IpAddress nextNet = networks.poll();
255 | 
256 |             if (BuildConfig.DEBUG) assertTrue(currentNet!=null);
257 |             if (nextNet == null || currentNet.getLastAddress().compareTo(nextNet.getFirstAddress()) == -1) {
258 |                 // Everything good, no overlapping nothing to do
259 |                 ipsDone.add(currentNet);
260 | 
261 |                 currentNet = nextNet;
262 |             } else {
263 |                 // This network is smaller or equal to the next but has the same base address
264 |                 if (currentNet.getFirstAddress().equals(nextNet.getFirstAddress()) && currentNet.networkMask >= nextNet.networkMask) {
265 |                     if (currentNet.included == nextNet.included) {
266 |                         // Included in the next next and same type
267 |                         // Simply forget our current network
268 |                         currentNet = nextNet;
269 |                     } else {
270 |                         // our currentNet is included in next and types differ. Need to split the next network
271 |                         IpAddress[] newNets = nextNet.split();
272 | 
273 | 
274 |                         // TODO: The contains method of the Priority is stupid linear search
275 | 
276 |                         // First add the second half to keep the order in networks
277 |                         if (!networks.contains(newNets[1]))
278 |                             networks.add(newNets[1]);
279 | 
280 |                         if (newNets[0].getLastAddress().equals(currentNet.getLastAddress())) {
281 |                             if (BuildConfig.DEBUG)
282 |                                 assertTrue(newNets[0].networkMask == currentNet.networkMask);
283 |                             // Don't add the lower half that would conflict with currentNet
284 |                         } else {
285 |                             if (!networks.contains(newNets[0]))
286 |                                 networks.add(newNets[0]);
287 |                         }
288 |                         // Keep currentNet as is
289 |                     }
290 |                 } else {
291 |                     if (BuildConfig.DEBUG) {
292 |                         assertTrue(currentNet.networkMask < nextNet.networkMask);
293 |                         assertTrue(nextNet.getFirstAddress().compareTo(currentNet.getFirstAddress()) == 1);
294 |                         assertTrue(currentNet.getLastAddress().compareTo(nextNet.getLastAddress()) != -1);
295 |                     }
296 |                     // This network is bigger than the next and last ip of current >= next
297 | 
298 |                     //noinspection StatementWithEmptyBody
299 |                     if (currentNet.included == nextNet.included) {
300 |                         // Next network is in included in our network with the same type,
301 |                         // simply ignore the next and move on
302 |                     } else {
303 |                         // We need to split our network
304 |                         IpAddress[] newNets = currentNet.split();
305 | 
306 | 
307 |                         if (newNets[1].networkMask == nextNet.networkMask) {
308 |                             if (BuildConfig.DEBUG) {
309 |                                 assertTrue(newNets[1].getFirstAddress().equals(nextNet.getFirstAddress()));
310 |                                 assertTrue(newNets[1].getLastAddress().equals(currentNet.getLastAddress()));
311 |                                 // split second equal the next network, do not add it
312 |                             }
313 |                             networks.add(nextNet);
314 |                         } else {
315 |                             // Add the smaller network first
316 |                             networks.add(newNets[1]);
317 |                             networks.add(nextNet);
318 |                         }
319 |                         currentNet = newNets[0];
320 | 
321 |                     }
322 |                 }
323 |             }
324 | 
325 |         }
326 | 
327 |         return ipsDone;
328 |     }
329 | 
330 |     Collection<IpAddress> getPositiveIPList() {
331 |         TreeSet<IpAddress> ipsSorted = generateIPList();
332 | 
333 |         Vector<IpAddress> ips = new Vector<IpAddress>();
334 |         for (IpAddress ia : ipsSorted) {
335 |             if (ia.included)
336 |                 ips.add(ia);
337 |         }
338 | 
339 |         if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
340 |             // Include postive routes from the original set under < 4.4 since these might overrule the local
341 |             // network but only if no smaller negative route exists
342 |             for (IpAddress origIp : mIpAddresses) {
343 |                 if (!origIp.included)
344 |                     continue;
345 | 
346 |                 // The netspace exists
347 |                 if (ipsSorted.contains(origIp))
348 |                     continue;
349 | 
350 |                 boolean skipIp = false;
351 |                 // If there is any smaller net that is excluded we may not add the positive route back
352 | 
353 |                 for (IpAddress calculatedIp : ipsSorted) {
354 |                     if (!calculatedIp.included && origIp.containsNet(calculatedIp)) {
355 |                         skipIp = true;
356 |                         break;
357 |                     }
358 |                 }
359 |                 if (skipIp)
360 |                     continue;
361 | 
362 |                 // It is safe to include the IP
363 |                 ips.add(origIp);
364 |             }
365 | 
366 |         }
367 | 
368 |         return ips;
369 |     }
370 | 
371 | }
372 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/NetworkUtils.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2018 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.content.Context;
 9 | import android.net.*;
10 | import android.os.Build;
11 | import android.text.TextUtils;
12 | 
13 | import java.net.Inet4Address;
14 | import java.net.Inet6Address;
15 | import java.util.Vector;
16 | 
17 | public class NetworkUtils {
18 | 
19 |     public static Vector<String> getLocalNetworks(Context c, boolean ipv6) {
20 |         Vector<String> nets = new Vector<>();
21 |         ConnectivityManager conn = (ConnectivityManager) c.getSystemService(Context.CONNECTIVITY_SERVICE);
22 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
23 |             Network[] networks = conn.getAllNetworks();
24 |             for (Network network : networks) {
25 |                 NetworkInfo ni = conn.getNetworkInfo(network);
26 |                 LinkProperties li = conn.getLinkProperties(network);
27 | 
28 |                 NetworkCapabilities nc = conn.getNetworkCapabilities(network);
29 | 
30 |                 // Skip VPN networks like ourselves
31 |                 if (nc.hasTransport(NetworkCapabilities.TRANSPORT_VPN))
32 |                     continue;
33 | 
34 |                 // Also skip mobile networks
35 |                 if (nc.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR))
36 |                     continue;
37 | 
38 | 
39 |                 for (LinkAddress la : li.getLinkAddresses()) {
40 |                     if ((la.getAddress() instanceof Inet4Address && !ipv6) ||
41 |                             (la.getAddress() instanceof Inet6Address && ipv6))
42 |                         nets.add(la.toString());
43 |                 }
44 |             }
45 |         } else {
46 |             // Old Android Version, use native utils via ifconfig instead
47 |             // Add local network interfaces
48 |             if (ipv6)
49 |                 return nets;
50 | 
51 |             String[] localRoutes = NativeUtils.getIfconfig();
52 | 
53 |             // The format of mLocalRoutes is kind of broken because I don't really like JNI
54 |             for (int i = 0; i < localRoutes.length; i += 3) {
55 |                 String intf = localRoutes[i];
56 |                 String ipAddr = localRoutes[i + 1];
57 |                 String netMask = localRoutes[i + 2];
58 | 
59 |                 if (intf == null || intf.equals("lo") ||
60 |                         intf.startsWith("tun") || intf.startsWith("rmnet"))
61 |                     continue;
62 | 
63 |                 if (ipAddr == null || netMask == null) {
64 |                     VpnStatus.logError("Local routes are broken?! (Report to author) " + TextUtils.join("|", localRoutes));
65 |                     continue;
66 |                 }
67 |                 nets.add(ipAddr + "/" + CIDRIP.calculateLenFromMask(netMask));
68 | 
69 |             }
70 | 
71 |         }
72 |         return nets;
73 |     }
74 | 
75 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OpenVPNManagement.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | public interface OpenVPNManagement {
 9 |     interface PausedStateCallback {
10 |         boolean shouldBeRunning();
11 |     }
12 | 
13 |     enum pauseReason {
14 |         noNetwork,
15 |         userPause,
16 |         screenOff,
17 |     }
18 | 
19 |     int mBytecountInterval = 2;
20 | 
21 |     void reconnect();
22 | 
23 |     void pause(pauseReason reason);
24 | 
25 |     void resume();
26 | 
27 |     /**
28 |      * @param replaceConnection True if the VPN is connected by a new connection.
29 |      * @return true if there was a process that has been send a stop signal
30 |      */
31 |     boolean stopVPN(boolean replaceConnection);
32 | 
33 |     /*
34 |      * Rebind the interface
35 |      */
36 |     void networkChange(boolean sameNetwork);
37 | 
38 |     void setPauseCallback(PausedStateCallback callback);
39 | 
40 |     /**
41 |      * Send the response to a challenge response
42 |      * @param response  Base64 encoded response
43 |      */
44 |     void sendCRResponse(String response);
45 | }
46 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OpenVPNService.java:
--------------------------------------------------------------------------------
   1 | /*
   2 |  * Copyright (c) 2012-2016 Arne Schwabe
   3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
   4 |  */
   5 | 
   6 | package de.blinkt.openvpn.core;
   7 | 
   8 | import android.Manifest.permission;
   9 | import android.annotation.TargetApi;
  10 | import android.app.Activity;
  11 | import android.app.Notification;
  12 | import android.app.NotificationChannel;
  13 | import android.app.NotificationManager;
  14 | import android.app.PendingIntent;
  15 | import android.app.UiModeManager;
  16 | import android.content.ComponentName;
  17 | import android.content.Context;
  18 | import android.content.Intent;
  19 | import android.content.IntentFilter;
  20 | import android.content.pm.PackageManager;
  21 | import android.content.pm.ShortcutManager;
  22 | import android.content.res.Configuration;
  23 | import android.content.res.Resources;
  24 | import android.graphics.Color;
  25 | import android.net.ConnectivityManager;
  26 | import android.net.VpnService;
  27 | import android.os.Binder;
  28 | import android.os.Build;
  29 | import android.os.Bundle;
  30 | import android.os.Handler;
  31 | import android.os.Handler.Callback;
  32 | import android.os.IBinder;
  33 | import android.os.Message;
  34 | import android.os.ParcelFileDescriptor;
  35 | import android.os.RemoteException;
  36 | import android.system.OsConstants;
  37 | import android.text.TextUtils;
  38 | import android.util.Base64;
  39 | import android.util.Log;
  40 | import android.widget.Toast;
  41 | 
  42 | import androidx.annotation.NonNull;
  43 | import androidx.annotation.RequiresApi;
  44 | import androidx.localbroadcastmanager.content.LocalBroadcastManager;
  45 | 
  46 | import java.io.IOException;
  47 | import java.lang.reflect.InvocationTargetException;
  48 | import java.lang.reflect.Method;
  49 | import java.net.Inet6Address;
  50 | import java.net.InetAddress;
  51 | import java.net.UnknownHostException;
  52 | import java.nio.charset.Charset;
  53 | import java.util.Calendar;
  54 | import java.util.Collection;
  55 | import java.util.Locale;
  56 | import java.util.Objects;
  57 | import java.util.Vector;
  58 | 
  59 | import de.blinkt.openvpn.DisconnectVPNActivity;
  60 | import de.blinkt.openvpn.LaunchVPN;
  61 | import de.blinkt.openvpn.R;
  62 | import de.blinkt.openvpn.VpnProfile;
  63 | import de.blinkt.openvpn.api.ExternalAppDatabase;
  64 | import de.blinkt.openvpn.core.VpnStatus.ByteCountListener;
  65 | import de.blinkt.openvpn.core.VpnStatus.StateListener;
  66 | import de.blinkt.openvpn.utils.TotalTraffic;
  67 | 
  68 | import static de.blinkt.openvpn.core.ConnectionStatus.LEVEL_CONNECTED;
  69 | import static de.blinkt.openvpn.core.ConnectionStatus.LEVEL_WAITING_FOR_USER_INPUT;
  70 | import static de.blinkt.openvpn.core.NetworkSpace.IpAddress;
  71 | 
  72 | public class OpenVPNService extends VpnService implements StateListener, Callback, ByteCountListener, IOpenVPNServiceInternal {
  73 | 
  74 |     private String byteIn, byteOut;
  75 |     private String duration;
  76 | 
  77 |     public static final String START_SERVICE = "de.blinkt.openvpn.START_SERVICE";
  78 |     public static final String START_SERVICE_STICKY = "de.blinkt.openvpn.START_SERVICE_STICKY";
  79 |     public static final String ALWAYS_SHOW_NOTIFICATION = "de.blinkt.openvpn.NOTIFICATION_ALWAYS_VISIBLE";
  80 |     public static final String DISCONNECT_VPN = "de.blinkt.openvpn.DISCONNECT_VPN";
  81 |     public static final String NOTIFICATION_CHANNEL_BG_ID = "openvpn_bg";
  82 |     public static final String NOTIFICATION_CHANNEL_NEWSTATUS_ID = "openvpn_newstat";
  83 |     public static final String NOTIFICATION_CHANNEL_USERREQ_ID = "openvpn_userreq";
  84 | 
  85 |     public static final String VPNSERVICE_TUN = "vpnservice-tun";
  86 |     public final static String ORBOT_PACKAGE_NAME = "org.torproject.android";
  87 |     private static final String PAUSE_VPN = "de.blinkt.openvpn.PAUSE_VPN";
  88 |     private static final String RESUME_VPN = "de.blinkt.openvpn.RESUME_VPN";
  89 | 
  90 |     public static final String EXTRA_CHALLENGE_TXT = "de.blinkt.openvpn.core.CR_TEXT_CHALLENGE";
  91 |     public static final String EXTRA_CHALLENGE_OPENURL = "de.blinkt.openvpn.core.OPENURL_CHALLENGE";
  92 | 
  93 |     private static final int PRIORITY_MIN = -2;
  94 |     private static final int PRIORITY_DEFAULT = 0;
  95 |     private static final int PRIORITY_MAX = 2;
  96 |     private static boolean mNotificationAlwaysVisible = false;
  97 |     private static Class<? extends Activity> mNotificationActivityClass;
  98 |     private final Vector<String> mDnslist = new Vector<>();
  99 |     private final NetworkSpace mRoutes = new NetworkSpace();
 100 |     private final NetworkSpace mRoutesv6 = new NetworkSpace();
 101 |     private final Object mProcessLock = new Object();
 102 |     private String lastChannel;
 103 |     private Thread mProcessThread = null;
 104 |     private VpnProfile mProfile;
 105 |     private String mDomain = null;
 106 |     private CIDRIP mLocalIP = null;
 107 |     private int mMtu;
 108 |     private String mLocalIPv6 = null;
 109 |     private DeviceStateReceiver mDeviceStateReceiver;
 110 |     private boolean mDisplayBytecount = false;
 111 |     private boolean mStarting = false;
 112 |     private long mConnecttime;
 113 |     private OpenVPNManagement mManagement;
 114 |     /*private final IBinder mBinder = new IOpenVPNServiceInternal.Stub() {
 115 | 
 116 |         @Override
 117 |         public boolean protect(int fd) throws RemoteException {
 118 |             return OpenVPNService.this.protect(fd);
 119 |         }
 120 | 
 121 |         @Override
 122 |         public void userPause(boolean shouldbePaused) throws RemoteException {
 123 |             OpenVPNService.this.userPause(shouldbePaused);
 124 |         }
 125 | 
 126 |         @Override
 127 |         public boolean stopVPN(boolean replaceConnection) throws RemoteException {
 128 |             return OpenVPNService.this.stopVPN(replaceConnection);
 129 |         }
 130 | 
 131 |         @Override
 132 |         public void addAllowedExternalApp(String packagename) throws RemoteException {
 133 |             OpenVPNService.this.addAllowedExternalApp(packagename);
 134 |         }
 135 | 
 136 |         @Override
 137 |         public boolean isAllowedExternalApp(String packagename) throws RemoteException {
 138 |             return OpenVPNService.this.isAllowedExternalApp(packagename);
 139 | 
 140 |         }
 141 | 
 142 |         @Override
 143 |         public void challengeResponse(String repsonse) throws RemoteException {
 144 |             OpenVPNService.this.challengeResponse(repsonse);
 145 |         }
 146 | 
 147 | 
 148 |     };*/
 149 | 
 150 |     private final IBinder mBinder = new LocalBinder();
 151 |     private static String state = "";
 152 |     boolean flag = false;
 153 |     private String mLastTunCfg;
 154 |     private String mRemoteGW;
 155 |     private Handler guiHandler;
 156 |     private Toast mlastToast;
 157 |     private Runnable mOpenVPNThread;
 158 | 
 159 |     // From: http://stackoverflow.com/questions/3758606/how-to-convert-byte-size-into-human-readable-format-in-java
 160 |     public static String humanReadableByteCount(long bytes, boolean speed, Resources res) {
 161 |         if (speed)
 162 |             bytes = bytes * 8;
 163 |         int unit = speed ? 1000 : 1024;
 164 | 
 165 | 
 166 |         int exp = Math.max(0, Math.min((int) (Math.log(bytes) / Math.log(unit)), 3));
 167 | 
 168 |         float bytesUnit = (float) (bytes / Math.pow(unit, exp));
 169 | 
 170 |         if (speed)
 171 |             switch (exp) {
 172 |                 case 0:
 173 |                     return res.getString(R.string.bits_per_second, bytesUnit);
 174 |                 case 1:
 175 |                     return res.getString(R.string.kbits_per_second, bytesUnit);
 176 |                 case 2:
 177 |                     return res.getString(R.string.mbits_per_second, bytesUnit);
 178 |                 default:
 179 |                     return res.getString(R.string.gbits_per_second, bytesUnit);
 180 |             }
 181 |         else
 182 |             switch (exp) {
 183 |                 case 0:
 184 |                     return res.getString(R.string.volume_byte, bytesUnit);
 185 |                 case 1:
 186 |                     return res.getString(R.string.volume_kbyte, bytesUnit);
 187 |                 case 2:
 188 |                     return res.getString(R.string.volume_mbyte, bytesUnit);
 189 |                 default:
 190 |                     return res.getString(R.string.volume_gbyte, bytesUnit);
 191 | 
 192 |             }
 193 |     }
 194 | 
 195 |     /**
 196 |      * Sets the activity which should be opened when tapped on the permanent notification tile.
 197 |      *
 198 |      * @param activityClass The activity class to open
 199 |      */
 200 |     public static void setNotificationActivityClass(Class<? extends Activity> activityClass) {
 201 |         mNotificationActivityClass = activityClass;
 202 |     }
 203 | 
 204 |     PendingIntent getContentIntent() {
 205 |         try {
 206 |             if (mNotificationActivityClass != null) {
 207 |                 // Let the configure Button show the Log
 208 |                 Intent intent = new Intent(getBaseContext(), mNotificationActivityClass);
 209 |                 String typeStart = Objects.requireNonNull(
 210 |                         mNotificationActivityClass.getField("TYPE_START").get(null)).toString();
 211 |                 Integer typeFromNotify = Integer.parseInt(Objects.requireNonNull(mNotificationActivityClass.getField("TYPE_FROM_NOTIFY").get(null)).toString());
 212 |                 intent.putExtra(typeStart, typeFromNotify);
 213 |                 intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
 214 |                         Intent.FLAG_ACTIVITY_SINGLE_TOP);
 215 |                 return PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 216 |             }
 217 |         } catch (Exception e) {
 218 |             Log.e(this.getClass().getCanonicalName(), "Build detail intent error", e);
 219 |             e.printStackTrace();
 220 |         }
 221 |         return null;
 222 |     }
 223 | 
 224 |     @Override
 225 |     public void addAllowedExternalApp(String packagename) throws RemoteException {
 226 |         ExternalAppDatabase extapps = new ExternalAppDatabase(OpenVPNService.this);
 227 |         extapps.addApp(packagename);
 228 |     }
 229 | 
 230 |     @Override
 231 |     public boolean isAllowedExternalApp(String packagename) throws RemoteException {
 232 |         ExternalAppDatabase extapps = new ExternalAppDatabase(OpenVPNService.this);
 233 |         return extapps.checkRemoteActionPermission(this, packagename);
 234 |     }
 235 | 
 236 |     @Override
 237 |     public void challengeResponse(String response) throws RemoteException {
 238 |         if (mManagement != null) {
 239 |             String b64response = Base64.encodeToString(response.getBytes(Charset.forName("UTF-8")), Base64.DEFAULT);
 240 |             mManagement.sendCRResponse(b64response);
 241 |         }
 242 |     }
 243 | 
 244 | 
 245 |     @Override
 246 |     public IBinder onBind(Intent intent) {
 247 |         String action = intent.getAction();
 248 |         if (action != null && action.equals(START_SERVICE))
 249 |             return mBinder;
 250 |         else
 251 |             return super.onBind(intent);
 252 |     }
 253 | 
 254 |     @Override
 255 |     public void onRevoke() {
 256 |         VpnStatus.logError(R.string.permission_revoked);
 257 |         mManagement.stopVPN(false);
 258 |         endVpnService();
 259 |     }
 260 | 
 261 |     // Similar to revoke but do not try to stop process
 262 |     public void openvpnStopped() {
 263 |         endVpnService();
 264 |     }
 265 | 
 266 |     public void endVpnService() {
 267 |         synchronized (mProcessLock) {
 268 |             mProcessThread = null;
 269 |         }
 270 |         VpnStatus.removeByteCountListener(this);
 271 |         unregisterDeviceStateReceiver();
 272 |         ProfileManager.setConntectedVpnProfileDisconnected(this);
 273 |         mOpenVPNThread = null;
 274 |         if (!mStarting) {
 275 |             stopForeground(!mNotificationAlwaysVisible);
 276 | 
 277 |             if (!mNotificationAlwaysVisible) {
 278 |                 stopSelf();
 279 |                 VpnStatus.removeStateListener(this);
 280 |             }
 281 |         }
 282 |     }
 283 | 
 284 |     @RequiresApi(Build.VERSION_CODES.O)
 285 |     private String createNotificationChannel(String channelId) {
 286 |         NotificationChannel chan = new NotificationChannel(channelId,
 287 |                 getString(R.string.channel_name_background), NotificationManager.IMPORTANCE_NONE);
 288 |         chan.setLightColor(Color.BLUE);
 289 |         chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
 290 |         NotificationManager service = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
 291 |         service.createNotificationChannel(chan);
 292 |         return channelId;
 293 |     }
 294 | 
 295 |     private void showNotification(final String msg, String tickerText, @NonNull String channel,
 296 |                                   long when, ConnectionStatus status, Intent intent) {
 297 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
 298 |             channel = createNotificationChannel(channel);
 299 |         }
 300 | 
 301 |         NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
 302 |         Notification.Builder nBuilder = new Notification.Builder(this);
 303 | 
 304 |         int priority;
 305 |         if (channel.equals(NOTIFICATION_CHANNEL_BG_ID))
 306 |             priority = PRIORITY_MIN;
 307 |         else if (channel.equals(NOTIFICATION_CHANNEL_USERREQ_ID))
 308 |             priority = PRIORITY_MAX;
 309 |         else
 310 |             priority = PRIORITY_DEFAULT;
 311 | 
 312 |         if (mProfile != null)
 313 |             nBuilder.setContentTitle(getString(R.string.notifcation_title, mProfile.mName));
 314 |         else
 315 |             nBuilder.setContentTitle(getString(R.string.notifcation_title_notconnect));
 316 | 
 317 |         nBuilder.setContentText(msg);
 318 |         nBuilder.setOnlyAlertOnce(true);
 319 |         nBuilder.setOngoing(true);
 320 |         nBuilder.setSmallIcon(R.drawable.ic_notification);
 321 |         if (status == LEVEL_WAITING_FOR_USER_INPUT) {
 322 |             PendingIntent pIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 323 |             nBuilder.setContentIntent(pIntent);
 324 |         } else {
 325 |             PendingIntent contentPendingIntent = getContentIntent();
 326 |             if (contentPendingIntent != null) {
 327 |                 nBuilder.setContentIntent(contentPendingIntent);
 328 |             } else {
 329 |                 nBuilder.setContentIntent(getGraphPendingIntent());
 330 |             }
 331 |         }
 332 | 
 333 |         if (when != 0)
 334 |             nBuilder.setWhen(when);
 335 | 
 336 | 
 337 |         // Try to set the priority available since API 16 (Jellybean)
 338 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
 339 |             jbNotificationExtras(priority, nBuilder);
 340 |             addVpnActionsToNotification(nBuilder);
 341 |         }
 342 | 
 343 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
 344 |             lpNotificationExtras(nBuilder, Notification.CATEGORY_SERVICE);
 345 | 
 346 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
 347 |             //noinspection NewApi
 348 |             nBuilder.setChannelId(channel);
 349 |             if (mProfile != null)
 350 |                 //noinspection NewApi
 351 |                 nBuilder.setShortcutId(mProfile.getUUIDString());
 352 | 
 353 |         }
 354 | 
 355 |         if (tickerText != null && !tickerText.equals(""))
 356 |             nBuilder.setTicker(tickerText);
 357 |         try {
 358 |             Notification notification = nBuilder.build();
 359 | 
 360 |             int notificationId = channel.hashCode();
 361 | 
 362 |             mNotificationManager.notify(notificationId, notification);
 363 | 
 364 |             startForeground(notificationId, notification);
 365 | 
 366 |             if (lastChannel != null && !channel.equals(lastChannel)) {
 367 |                 // Cancel old notification
 368 |                 mNotificationManager.cancel(lastChannel.hashCode());
 369 |             }
 370 |         } catch (Throwable th) {
 371 |             Log.e(getClass().getCanonicalName(), "Error when show notification", th);
 372 |         }
 373 | 
 374 |         // Check if running on a TV
 375 |         if (runningOnAndroidTV() && !(priority < 0))
 376 |             guiHandler.post(new Runnable() {
 377 | 
 378 |                 @Override
 379 |                 public void run() {
 380 | 
 381 |                     if (mlastToast != null)
 382 |                         mlastToast.cancel();
 383 |                     String toastText = String.format(Locale.getDefault(), "%s - %s", mProfile.mName, msg);
 384 |                     mlastToast = Toast.makeText(getBaseContext(), toastText, Toast.LENGTH_SHORT);
 385 |                     mlastToast.show();
 386 |                 }
 387 |             });
 388 |     }
 389 | 
 390 |     @TargetApi(Build.VERSION_CODES.LOLLIPOP)
 391 |     private void lpNotificationExtras(Notification.Builder nbuilder, String category) {
 392 |         nbuilder.setCategory(category);
 393 |         nbuilder.setLocalOnly(true);
 394 | 
 395 |     }
 396 |     private int getIconByConnectionStatus(ConnectionStatus level) {
 397 |         switch (level) {
 398 |             case LEVEL_CONNECTED:
 399 |                 return R.drawable.ic_stat_vpn;
 400 |             case LEVEL_AUTH_FAILED:
 401 |             case LEVEL_NONETWORK:
 402 |             case LEVEL_NOTCONNECTED:
 403 |                 return R.drawable.ic_stat_vpn_offline;
 404 |             case LEVEL_CONNECTING_NO_SERVER_REPLY_YET:
 405 |             case LEVEL_WAITING_FOR_USER_INPUT:
 406 |                 return R.drawable.ic_stat_vpn_outline;
 407 |             case LEVEL_CONNECTING_SERVER_REPLIED:
 408 |                 return R.drawable.ic_stat_vpn_empty_halo;
 409 |             case LEVEL_VPNPAUSED:
 410 |                 return android.R.drawable.ic_media_pause;
 411 |             case UNKNOWN_LEVEL:
 412 |             default:
 413 |                 return R.drawable.ic_stat_vpn;
 414 | 
 415 |         }
 416 |     }
 417 |     private boolean runningOnAndroidTV() {
 418 |         UiModeManager uiModeManager = (UiModeManager) getSystemService(UI_MODE_SERVICE);
 419 |         return uiModeManager.getCurrentModeType() == Configuration.UI_MODE_TYPE_TELEVISION;
 420 |     }
 421 | 
 422 |     @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
 423 |     private void jbNotificationExtras(int priority,
 424 |                                       android.app.Notification.Builder nbuilder) {
 425 |         try {
 426 |             if (priority != 0) {
 427 |                 Method setpriority = nbuilder.getClass().getMethod("setPriority", int.class);
 428 |                 setpriority.invoke(nbuilder, priority);
 429 | 
 430 |                 Method setUsesChronometer = nbuilder.getClass().getMethod("setUsesChronometer", boolean.class);
 431 |                 setUsesChronometer.invoke(nbuilder, true);
 432 | 
 433 |             }
 434 | 
 435 |             //ignore exception
 436 |         } catch (NoSuchMethodException | IllegalArgumentException |
 437 |                 InvocationTargetException | IllegalAccessException e) {
 438 |             VpnStatus.logException(e);
 439 |         }
 440 | 
 441 |     }
 442 | 
 443 |     @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
 444 |     private void addVpnActionsToNotification(Notification.Builder nbuilder) {
 445 |         Intent disconnectVPN = new Intent(this, DisconnectVPNActivity.class);
 446 |         disconnectVPN.setAction(DISCONNECT_VPN);
 447 |         PendingIntent disconnectPendingIntent = PendingIntent.getActivity(this, 0, disconnectVPN, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 448 | 
 449 |         nbuilder.addAction(R.drawable.ic_menu_close_clear_cancel,
 450 |                 getString(R.string.cancel_connection), disconnectPendingIntent);
 451 | 
 452 |         Intent pauseVPN = new Intent(this, OpenVPNService.class);
 453 |         if (mDeviceStateReceiver == null || !mDeviceStateReceiver.isUserPaused()) {
 454 |             pauseVPN.setAction(PAUSE_VPN);
 455 |             PendingIntent pauseVPNPending = PendingIntent.getService(this, 0, pauseVPN, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 456 |             nbuilder.addAction(R.drawable.ic_menu_pause,
 457 |                     getString(R.string.pauseVPN), pauseVPNPending);
 458 | 
 459 |         } else {
 460 |             pauseVPN.setAction(RESUME_VPN);
 461 |             PendingIntent resumeVPNPending = PendingIntent.getService(this, 0, pauseVPN, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 462 |             nbuilder.addAction(R.drawable.ic_menu_play,
 463 |                     getString(R.string.resumevpn), resumeVPNPending);
 464 |         }
 465 |     }
 466 | 
 467 |     PendingIntent getUserInputIntent(String needed) {
 468 |         Intent intent = new Intent(getApplicationContext(), LaunchVPN.class);
 469 |         intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
 470 |         intent.putExtra("need", needed);
 471 |         Bundle b = new Bundle();
 472 |         b.putString("need", needed);
 473 |         PendingIntent pIntent = PendingIntent.getActivity(this, 12, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 474 |         return pIntent;
 475 |     }
 476 | 
 477 |     PendingIntent getGraphPendingIntent() {
 478 |         // Let the configure Button show the Log
 479 | 
 480 | 
 481 |         Intent intent = new Intent();
 482 |         intent.setComponent(new ComponentName(this, getPackageName() + ".view.MainActivity"));
 483 | 
 484 |         intent.putExtra("PAGE", "graph");
 485 |         intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
 486 |         PendingIntent startLW = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
 487 |         return startLW;
 488 |     }
 489 | 
 490 |     synchronized void registerDeviceStateReceiver(OpenVPNManagement magnagement) {
 491 |         // Registers BroadcastReceiver to track network connection changes.
 492 |         IntentFilter filter = new IntentFilter();
 493 |         filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
 494 |         filter.addAction(Intent.ACTION_SCREEN_OFF);
 495 |         filter.addAction(Intent.ACTION_SCREEN_ON);
 496 |         mDeviceStateReceiver = new DeviceStateReceiver(magnagement);
 497 | 
 498 |         // Fetch initial network state
 499 |         mDeviceStateReceiver.networkStateChange(this);
 500 | 
 501 |         registerReceiver(mDeviceStateReceiver, filter);
 502 |         VpnStatus.addByteCountListener(mDeviceStateReceiver);
 503 | 
 504 |         /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
 505 |             addLollipopCMListener(); */
 506 |     }
 507 | 
 508 |     synchronized void unregisterDeviceStateReceiver() {
 509 |         if (mDeviceStateReceiver != null)
 510 |             try {
 511 |                 VpnStatus.removeByteCountListener(mDeviceStateReceiver);
 512 |                 this.unregisterReceiver(mDeviceStateReceiver);
 513 |             } catch (IllegalArgumentException iae) {
 514 |                 // I don't know why  this happens:
 515 |                 // java.lang.IllegalArgumentException: Receiver not registered: de.blinkt.openvpn.NetworkSateReceiver@41a61a10
 516 |                 // Ignore for now ...
 517 |                 iae.printStackTrace();
 518 |             }
 519 |         mDeviceStateReceiver = null;
 520 | 
 521 |         /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
 522 |             removeLollipopCMListener();*/
 523 | 
 524 |     }
 525 | 
 526 |     public void userPause(boolean shouldBePaused) {
 527 |         if (mDeviceStateReceiver != null)
 528 |             mDeviceStateReceiver.userPause(shouldBePaused);
 529 |     }
 530 | 
 531 |     @Override
 532 |     public boolean stopVPN(boolean replaceConnection) throws RemoteException {
 533 |         if (getManagement() != null)
 534 |             return getManagement().stopVPN(replaceConnection);
 535 |         else
 536 |             return false;
 537 |     }
 538 | 
 539 |     @Override
 540 |     public int onStartCommand(Intent intent, int flags, int startId) {
 541 | 
 542 |         if (intent != null && intent.getBooleanExtra(ALWAYS_SHOW_NOTIFICATION, false))
 543 |             mNotificationAlwaysVisible = true;
 544 | 
 545 |         VpnStatus.addStateListener(this);
 546 |         VpnStatus.addByteCountListener(this);
 547 | 
 548 |         guiHandler = new Handler(getMainLooper());
 549 | 
 550 |         if (intent != null && DISCONNECT_VPN.equals(intent.getAction())) {
 551 |             try {
 552 |                 stopVPN(false);
 553 |             } catch (RemoteException e) {
 554 |                 VpnStatus.logException(e);
 555 |             }
 556 |             return START_NOT_STICKY;
 557 |         }
 558 | 
 559 |         if (intent != null && PAUSE_VPN.equals(intent.getAction())) {
 560 |             if (mDeviceStateReceiver != null)
 561 |                 mDeviceStateReceiver.userPause(true);
 562 |             return START_NOT_STICKY;
 563 |         }
 564 | 
 565 |         if (intent != null && RESUME_VPN.equals(intent.getAction())) {
 566 |             if (mDeviceStateReceiver != null)
 567 |                 mDeviceStateReceiver.userPause(false);
 568 |             return START_NOT_STICKY;
 569 |         }
 570 | 
 571 | 
 572 |         if (intent != null && START_SERVICE.equals(intent.getAction()))
 573 |             return START_NOT_STICKY;
 574 |         if (intent != null && START_SERVICE_STICKY.equals(intent.getAction())) {
 575 |             return START_REDELIVER_INTENT;
 576 |         }
 577 | 
 578 |         // Always show notification here to avoid problem with startForeground timeout
 579 |         VpnStatus.logInfo(R.string.building_configration);
 580 |         VpnStatus.updateStateString("VPN_GENERATE_CONFIG", "", R.string.building_configration, ConnectionStatus.LEVEL_START);
 581 |         showNotification(VpnStatus.getLastCleanLogMessage(this),
 582 |                 VpnStatus.getLastCleanLogMessage(this), NOTIFICATION_CHANNEL_NEWSTATUS_ID, 0, ConnectionStatus.LEVEL_START, null);
 583 | 
 584 |         if (intent != null && intent.hasExtra(getPackageName() + ".profileUUID")) {
 585 |             String profileUUID = intent.getStringExtra(getPackageName() + ".profileUUID");
 586 |             int profileVersion = intent.getIntExtra(getPackageName() + ".profileVersion", 0);
 587 |             // Try for 10s to get current version of the profile
 588 |             mProfile = ProfileManager.get(this, profileUUID, profileVersion, 100);
 589 |             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
 590 |                 updateShortCutUsage(mProfile);
 591 |             }
 592 | 
 593 |         } else {
 594 |             /* The intent is null when we are set as always-on or the service has been restarted. */
 595 |             mProfile = ProfileManager.getLastConnectedProfile(this);
 596 |             VpnStatus.logInfo(R.string.service_restarted);
 597 | 
 598 |             /* Got no profile, just stop */
 599 |             if (mProfile == null) {
 600 |                 Log.d("OpenVPN", "Got no last connected profile on null intent. Assuming always on.");
 601 |                 mProfile = ProfileManager.getAlwaysOnVPN(this);
 602 | 
 603 |                 if (mProfile == null) {
 604 |                     stopSelf(startId);
 605 |                     return START_NOT_STICKY;
 606 |                 }
 607 |             }
 608 |             /* Do the asynchronous keychain certificate stuff */
 609 |             mProfile.checkForRestart(this);
 610 |         }
 611 | 
 612 |         if (mProfile == null) {
 613 |             stopSelf(startId);
 614 |             return START_NOT_STICKY;
 615 |         }
 616 | 
 617 | 
 618 |         /* start the OpenVPN process itself in a background thread */
 619 |         new Thread(new Runnable() {
 620 |             @Override
 621 |             public void run() {
 622 |                 startOpenVPN();
 623 |             }
 624 |         }).start();
 625 | 
 626 | 
 627 |         ProfileManager.setConnectedVpnProfile(this, mProfile);
 628 |         VpnStatus.setConnectedVPNProfile(mProfile.getUUIDString());
 629 | 
 630 |         return START_STICKY;
 631 |     }
 632 | 
 633 |     @RequiresApi(Build.VERSION_CODES.N_MR1)
 634 |     private void updateShortCutUsage(VpnProfile profile) {
 635 |         if (profile == null)
 636 |             return;
 637 |         ShortcutManager shortcutManager = getSystemService(ShortcutManager.class);
 638 |         shortcutManager.reportShortcutUsed(profile.getUUIDString());
 639 |     }
 640 | 
 641 |     private void startOpenVPN() {
 642 |         try {
 643 |             mProfile.writeConfigFile(this);
 644 |         } catch (IOException e) {
 645 |             VpnStatus.logException("Error writing config file", e);
 646 |             endVpnService();
 647 |             return;
 648 |         }
 649 |         String nativeLibraryDirectory = getApplicationInfo().nativeLibraryDir;
 650 |         String tmpDir;
 651 |         try {
 652 |             tmpDir = getApplication().getCacheDir().getCanonicalPath();
 653 |         } catch (IOException e) {
 654 |             e.printStackTrace();
 655 |             tmpDir = "/tmp";
 656 |         }
 657 | 
 658 |         // Write OpenVPN binary
 659 |         String[] argv = VPNLaunchHelper.buildOpenvpnArgv(this);
 660 | 
 661 | 
 662 |         // Set a flag that we are starting a new VPN
 663 |         mStarting = true;
 664 |         // Stop the previous session by interrupting the thread.
 665 | 
 666 |         stopOldOpenVPNProcess();
 667 |         // An old running VPN should now be exited
 668 |         mStarting = false;
 669 | 
 670 |         // Start a new session by creating a new thread.
 671 |         boolean useOpenVPN3 = VpnProfile.doUseOpenVPN3(this);
 672 | 
 673 |         // Open the Management Interface
 674 |         if (!useOpenVPN3) {
 675 |             // start a Thread that handles incoming messages of the managment socket
 676 |             OpenVpnManagementThread ovpnManagementThread = new OpenVpnManagementThread(mProfile, this);
 677 |             if (ovpnManagementThread.openManagementInterface(this)) {
 678 |                 Thread mSocketManagerThread = new Thread(ovpnManagementThread, "OpenVPNManagementThread");
 679 |                 mSocketManagerThread.start();
 680 |                 mManagement = ovpnManagementThread;
 681 |                 VpnStatus.logInfo("started Socket Thread");
 682 |             } else {
 683 |                 endVpnService();
 684 |                 return;
 685 |             }
 686 |         }
 687 | 
 688 |         Runnable processThread;
 689 |         if (useOpenVPN3) {
 690 |             OpenVPNManagement mOpenVPN3 = instantiateOpenVPN3Core();
 691 |             processThread = (Runnable) mOpenVPN3;
 692 |             mManagement = mOpenVPN3;
 693 |         } else {
 694 |             processThread = new OpenVPNThread(this, argv, nativeLibraryDirectory, tmpDir);
 695 |             mOpenVPNThread = processThread;
 696 |         }
 697 | 
 698 |         synchronized (mProcessLock) {
 699 |             mProcessThread = new Thread(processThread, "OpenVPNProcessThread");
 700 |             mProcessThread.start();
 701 |         }
 702 | 
 703 |         new Handler(getMainLooper()).post(new Runnable() {
 704 |                                               @Override
 705 |                                               public void run() {
 706 |                                                   if (mDeviceStateReceiver != null)
 707 |                                                       unregisterDeviceStateReceiver();
 708 | 
 709 |                                                   registerDeviceStateReceiver(mManagement);
 710 |                                               }
 711 |                                           }
 712 | 
 713 |         );
 714 |     }
 715 | 
 716 | 
 717 |     private void stopOldOpenVPNProcess() {
 718 |         if (mManagement != null) {
 719 |             if (mOpenVPNThread != null)
 720 |                 ((OpenVPNThread) mOpenVPNThread).setReplaceConnection();
 721 |             if (mManagement.stopVPN(true)) {
 722 |                 // an old was asked to exit, wait 1s
 723 |                 try {
 724 |                     Thread.sleep(1000);
 725 |                 } catch (InterruptedException e) {
 726 |                     //ignore
 727 |                 }
 728 |             }
 729 |         }
 730 | 
 731 |         forceStopOpenVpnProcess();
 732 |     }
 733 | 
 734 |     public void forceStopOpenVpnProcess() {
 735 |         synchronized (mProcessLock) {
 736 |             if (mProcessThread != null) {
 737 |                 mProcessThread.interrupt();
 738 |                 try {
 739 |                     Thread.sleep(1000);
 740 |                 } catch (InterruptedException e) {
 741 |                     //ignore
 742 |                 }
 743 |             }
 744 |         }
 745 |     }
 746 | 
 747 |     private OpenVPNManagement instantiateOpenVPN3Core() {
 748 |         try {
 749 |             Class cl = Class.forName("de.blinkt.openvpn.core.OpenVPNThreadv3");
 750 |             return (OpenVPNManagement) cl.getConstructor(OpenVPNService.class, VpnProfile.class).newInstance(this, mProfile);
 751 |         } catch (IllegalArgumentException | InstantiationException | InvocationTargetException |
 752 |                 NoSuchMethodException | ClassNotFoundException | IllegalAccessException e) {
 753 |             e.printStackTrace();
 754 |         }
 755 |         return null;
 756 |     }
 757 | 
 758 | 
 759 |     @Override
 760 |     public IBinder asBinder() {
 761 |         return mBinder;
 762 |     }
 763 | 
 764 |     @Override
 765 |     public void onCreate() {
 766 |         super.onCreate();
 767 |     }
 768 | 
 769 |     @Override
 770 |     public void onDestroy() {
 771 |         sendMessage("DISCONNECTED");
 772 |         synchronized (mProcessLock) {
 773 |             if (mProcessThread != null) {
 774 |                 mManagement.stopVPN(true);
 775 |             }
 776 |         }
 777 | 
 778 |         if (mDeviceStateReceiver != null) {
 779 |             this.unregisterReceiver(mDeviceStateReceiver);
 780 |         }
 781 |         // Just in case unregister for state
 782 |         VpnStatus.removeStateListener(this);
 783 |         VpnStatus.flushLog();
 784 |     }
 785 | 
 786 |     private String getTunConfigString() {
 787 |         // The format of the string is not important, only that
 788 |         // two identical configurations produce the same result
 789 |         String cfg = "TUNCFG UNQIUE STRING ips:";
 790 | 
 791 |         if (mLocalIP != null)
 792 |             cfg += mLocalIP.toString();
 793 |         if (mLocalIPv6 != null)
 794 |             cfg += mLocalIPv6;
 795 | 
 796 | 
 797 |         cfg += "routes: " + TextUtils.join("|", mRoutes.getNetworks(true)) + TextUtils.join("|", mRoutesv6.getNetworks(true));
 798 |         cfg += "excl. routes:" + TextUtils.join("|", mRoutes.getNetworks(false)) + TextUtils.join("|", mRoutesv6.getNetworks(false));
 799 |         cfg += "dns: " + TextUtils.join("|", mDnslist);
 800 |         cfg += "domain: " + mDomain;
 801 |         cfg += "mtu: " + mMtu;
 802 |         return cfg;
 803 |     }
 804 | 
 805 |     public ParcelFileDescriptor openTun() {
 806 | 
 807 |         //Debug.startMethodTracing(getExternalFilesDir(null).toString() + "/opentun.trace", 40* 1024 * 1024);
 808 | 
 809 |         Builder builder = new Builder();
 810 | 
 811 |         VpnStatus.logInfo(R.string.last_openvpn_tun_config);
 812 | 
 813 |         boolean allowUnsetAF = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && !mProfile.mBlockUnusedAddressFamilies;
 814 |         if (allowUnsetAF) {
 815 |             allowAllAFFamilies(builder);
 816 |         }
 817 | 
 818 |         if (mLocalIP == null && mLocalIPv6 == null) {
 819 |             VpnStatus.logError(getString(R.string.opentun_no_ipaddr));
 820 |             return null;
 821 |         }
 822 | 
 823 |         if (mLocalIP != null) {
 824 |             // OpenVPN3 manages excluded local networks by callback
 825 |             if (!VpnProfile.doUseOpenVPN3(this))
 826 |                 addLocalNetworksToRoutes();
 827 |             try {
 828 |                 builder.addAddress(mLocalIP.mIp, mLocalIP.len);
 829 |             } catch (IllegalArgumentException iae) {
 830 |                 VpnStatus.logError(R.string.dns_add_error, mLocalIP, iae.getLocalizedMessage());
 831 |                 return null;
 832 |             }
 833 |         }
 834 | 
 835 |         if (mLocalIPv6 != null) {
 836 |             String[] ipv6parts = mLocalIPv6.split("/");
 837 |             try {
 838 |                 builder.addAddress(ipv6parts[0], Integer.parseInt(ipv6parts[1]));
 839 |             } catch (IllegalArgumentException iae) {
 840 |                 VpnStatus.logError(R.string.ip_add_error, mLocalIPv6, iae.getLocalizedMessage());
 841 |                 return null;
 842 |             }
 843 | 
 844 |         }
 845 | 
 846 | 
 847 |         for (String dns : mDnslist) {
 848 |             try {
 849 |                 builder.addDnsServer(dns);
 850 |             } catch (IllegalArgumentException iae) {
 851 |                 VpnStatus.logError(R.string.dns_add_error, dns, iae.getLocalizedMessage());
 852 |             }
 853 |         }
 854 | 
 855 |         String release = Build.VERSION.RELEASE;
 856 |         if ((Build.VERSION.SDK_INT == Build.VERSION_CODES.KITKAT && !release.startsWith("4.4.3")
 857 |                 && !release.startsWith("4.4.4") && !release.startsWith("4.4.5") && !release.startsWith("4.4.6"))
 858 |                 && mMtu < 1280) {
 859 |             VpnStatus.logInfo(String.format(Locale.US, "Forcing MTU to 1280 instead of %d to workaround Android Bug #70916", mMtu));
 860 |             builder.setMtu(1280);
 861 |         } else {
 862 |             builder.setMtu(mMtu);
 863 |         }
 864 | 
 865 |         Collection<IpAddress> positiveIPv4Routes = mRoutes.getPositiveIPList();
 866 |         Collection<IpAddress> positiveIPv6Routes = mRoutesv6.getPositiveIPList();
 867 | 
 868 |         if ("samsung".equals(Build.BRAND) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && mDnslist.size() >= 1) {
 869 |             // Check if the first DNS Server is in the VPN range
 870 |             try {
 871 |                 IpAddress dnsServer = new IpAddress(new CIDRIP(mDnslist.get(0), 32), true);
 872 |                 boolean dnsIncluded = false;
 873 |                 for (IpAddress net : positiveIPv4Routes) {
 874 |                     if (net.containsNet(dnsServer)) {
 875 |                         dnsIncluded = true;
 876 |                     }
 877 |                 }
 878 |                 if (!dnsIncluded) {
 879 |                     String samsungwarning = String.format("Warning Samsung Android 5.0+ devices ignore DNS servers outside the VPN range. To enable DNS resolution a route to your DNS Server (%s) has been added.", mDnslist.get(0));
 880 |                     VpnStatus.logWarning(samsungwarning);
 881 |                     positiveIPv4Routes.add(dnsServer);
 882 |                 }
 883 |             } catch (Exception e) {
 884 |                 // If it looks like IPv6 ignore error
 885 |                 if (!mDnslist.get(0).contains(":"))
 886 |                     VpnStatus.logError("Error parsing DNS Server IP: " + mDnslist.get(0));
 887 |             }
 888 |         }
 889 | 
 890 |         IpAddress multicastRange = new IpAddress(new CIDRIP("224.0.0.0", 3), true);
 891 | 
 892 |         for (IpAddress route : positiveIPv4Routes) {
 893 |             try {
 894 | 
 895 |                 if (multicastRange.containsNet(route))
 896 |                     VpnStatus.logDebug(R.string.ignore_multicast_route, route.toString());
 897 |                 else
 898 |                     builder.addRoute(route.getIPv4Address(), route.networkMask);
 899 |             } catch (IllegalArgumentException ia) {
 900 |                 VpnStatus.logError(getString(R.string.route_rejected) + route + " " + ia.getLocalizedMessage());
 901 |             }
 902 |         }
 903 | 
 904 |         for (IpAddress route6 : positiveIPv6Routes) {
 905 |             try {
 906 |                 builder.addRoute(route6.getIPv6Address(), route6.networkMask);
 907 |             } catch (IllegalArgumentException ia) {
 908 |                 VpnStatus.logError(getString(R.string.route_rejected) + route6 + " " + ia.getLocalizedMessage());
 909 |             }
 910 |         }
 911 | 
 912 | 
 913 |         if (mDomain != null)
 914 |             builder.addSearchDomain(mDomain);
 915 | 
 916 |         String ipv4info;
 917 |         String ipv6info;
 918 |         if (allowUnsetAF) {
 919 |             ipv4info = "(not set, allowed)";
 920 |             ipv6info = "(not set, allowed)";
 921 |         } else {
 922 |             ipv4info = "(not set)";
 923 |             ipv6info = "(not set)";
 924 |         }
 925 | 
 926 |         int ipv4len;
 927 |         if (mLocalIP != null) {
 928 |             ipv4len = mLocalIP.len;
 929 |             ipv4info = mLocalIP.mIp;
 930 |         } else {
 931 |             ipv4len = -1;
 932 |         }
 933 | 
 934 |         if (mLocalIPv6 != null) {
 935 |             ipv6info = mLocalIPv6;
 936 |         }
 937 | 
 938 |         if ((!mRoutes.getNetworks(false).isEmpty() || !mRoutesv6.getNetworks(false).isEmpty()) && isLockdownEnabledCompat()) {
 939 |             VpnStatus.logInfo("VPN lockdown enabled (do not allow apps to bypass VPN) enabled. Route exclusion will not allow apps to bypass VPN (e.g. bypass VPN for local networks)");
 940 |         }
 941 |         if (mDomain != null) builder.addSearchDomain(mDomain);
 942 |         VpnStatus.logInfo(R.string.local_ip_info, ipv4info, ipv4len, ipv6info, mMtu);
 943 |         VpnStatus.logInfo(R.string.dns_server_info, TextUtils.join(", ", mDnslist), mDomain);
 944 |         VpnStatus.logInfo(R.string.routes_info_incl, TextUtils.join(", ", mRoutes.getNetworks(true)), TextUtils.join(", ", mRoutesv6.getNetworks(true)));
 945 |         VpnStatus.logInfo(R.string.routes_info_excl, TextUtils.join(", ", mRoutes.getNetworks(false)), TextUtils.join(", ", mRoutesv6.getNetworks(false)));
 946 |         VpnStatus.logDebug(R.string.routes_debug, TextUtils.join(", ", positiveIPv4Routes), TextUtils.join(", ", positiveIPv6Routes));
 947 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
 948 |             setAllowedVpnPackages(builder);
 949 |         }
 950 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
 951 |             // VPN always uses the default network
 952 |             builder.setUnderlyingNetworks(null);
 953 |         }
 954 | 
 955 | 
 956 |         String session = mProfile.mName;
 957 |         if (mLocalIP != null && mLocalIPv6 != null)
 958 |             session = getString(R.string.session_ipv6string, session, mLocalIP, mLocalIPv6);
 959 |         else if (mLocalIP != null)
 960 |             session = getString(R.string.session_ipv4string, session, mLocalIP);
 961 |         else
 962 |             session = getString(R.string.session_ipv4string, session, mLocalIPv6);
 963 | 
 964 |         builder.setSession(session);
 965 | 
 966 |         // No DNS Server, log a warning
 967 |         if (mDnslist.size() == 0)
 968 |             VpnStatus.logInfo(R.string.warn_no_dns);
 969 | 
 970 |         mLastTunCfg = getTunConfigString();
 971 | 
 972 |         // Reset information
 973 |         mDnslist.clear();
 974 |         mRoutes.clear();
 975 |         mRoutesv6.clear();
 976 |         mLocalIP = null;
 977 |         mLocalIPv6 = null;
 978 |         mDomain = null;
 979 | 
 980 |         builder.setConfigureIntent(getGraphPendingIntent());
 981 | 
 982 |         try {
 983 |             //Debug.stopMethodTracing();
 984 |             ParcelFileDescriptor tun = builder.establish();
 985 |             if (tun == null)
 986 |                 throw new NullPointerException("Android establish() method returned null (Really broken network configuration?)");
 987 |             return tun;
 988 |         } catch (Exception e) {
 989 |             VpnStatus.logError(R.string.tun_open_error);
 990 |             VpnStatus.logError(getString(R.string.error) + e.getLocalizedMessage());
 991 |             if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.JELLY_BEAN_MR1) {
 992 |                 VpnStatus.logError(R.string.tun_error_helpful);
 993 |             }
 994 |             return null;
 995 |         }
 996 | 
 997 |     }
 998 | 
 999 |     private boolean isLockdownEnabledCompat() {
1000 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
1001 |             return isLockdownEnabled();
1002 |         } else {
1003 |             /* We cannot determine this, return false */
1004 |             return false;
1005 |         }
1006 | 
1007 |     }
1008 | 
1009 |     @TargetApi(Build.VERSION_CODES.LOLLIPOP)
1010 |     private void allowAllAFFamilies(Builder builder) {
1011 |         builder.allowFamily(OsConstants.AF_INET);
1012 |         builder.allowFamily(OsConstants.AF_INET6);
1013 |     }
1014 | 
1015 |     private void addLocalNetworksToRoutes() {
1016 |         for (String net : NetworkUtils.getLocalNetworks(this, false)) {
1017 |             String[] netparts = net.split("/");
1018 |             String ipAddr = netparts[0];
1019 |             int netMask = Integer.parseInt(netparts[1]);
1020 |             if (ipAddr.equals(mLocalIP.mIp))
1021 |                 continue;
1022 | 
1023 |             if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT && !mProfile.mAllowLocalLAN) {
1024 |                 mRoutes.addIPSplit(new CIDRIP(ipAddr, netMask), true);
1025 | 
1026 |             } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && mProfile.mAllowLocalLAN)
1027 |                 mRoutes.addIP(new CIDRIP(ipAddr, netMask), false);
1028 |         }
1029 | 
1030 |         // IPv6 is Lollipop+ only so we can skip the lower than KITKAT case
1031 |         if (mProfile.mAllowLocalLAN) {
1032 |             for (String net : NetworkUtils.getLocalNetworks(this, true)) {
1033 |                 addRoutev6(net, false);
1034 |             }
1035 |         }
1036 | 
1037 | 
1038 |     }
1039 | 
1040 | 
1041 |     @TargetApi(Build.VERSION_CODES.LOLLIPOP)
1042 |     private void setAllowedVpnPackages(Builder builder) {
1043 |         boolean profileUsesOrBot = false;
1044 | 
1045 |         for (Connection c : mProfile.mConnections) {
1046 |             if (c.mProxyType == Connection.ProxyType.ORBOT)
1047 |                 profileUsesOrBot = true;
1048 |         }
1049 | 
1050 |         if (profileUsesOrBot)
1051 |             VpnStatus.logDebug("VPN Profile uses at least one server entry with Orbot. Setting up VPN so that OrBot is not redirected over VPN.");
1052 | 
1053 | 
1054 |         boolean atLeastOneAllowedApp = false;
1055 | 
1056 |         if (mProfile.mAllowedAppsVpnAreDisallowed && profileUsesOrBot) {
1057 |             try {
1058 |                 builder.addDisallowedApplication(ORBOT_PACKAGE_NAME);
1059 |             } catch (PackageManager.NameNotFoundException e) {
1060 |                 VpnStatus.logDebug("Orbot not installed?");
1061 |             }
1062 |         }
1063 | 
1064 |         for (String pkg : mProfile.mAllowedAppsVpn) {
1065 |             try {
1066 |                 if (mProfile.mAllowedAppsVpnAreDisallowed) {
1067 |                     builder.addDisallowedApplication(pkg);
1068 |                 } else {
1069 |                     if (!(profileUsesOrBot && pkg.equals(ORBOT_PACKAGE_NAME))) {
1070 |                         builder.addAllowedApplication(pkg);
1071 |                         atLeastOneAllowedApp = true;
1072 |                     }
1073 |                 }
1074 |             } catch (PackageManager.NameNotFoundException e) {
1075 |                 mProfile.mAllowedAppsVpn.remove(pkg);
1076 |                 VpnStatus.logInfo(R.string.app_no_longer_exists, pkg);
1077 |             }
1078 |         }
1079 | 
1080 |         if (!mProfile.mAllowedAppsVpnAreDisallowed && !atLeastOneAllowedApp) {
1081 |             VpnStatus.logDebug(R.string.no_allowed_app, getPackageName());
1082 |             try {
1083 |                 builder.addAllowedApplication(getPackageName());
1084 |             } catch (PackageManager.NameNotFoundException e) {
1085 |                 VpnStatus.logError("This should not happen: " + e.getLocalizedMessage());
1086 |             }
1087 |         }
1088 | 
1089 |         if (mProfile.mAllowedAppsVpnAreDisallowed) {
1090 |             VpnStatus.logDebug(R.string.disallowed_vpn_apps_info, TextUtils.join(", ", mProfile.mAllowedAppsVpn));
1091 |         } else {
1092 |             VpnStatus.logDebug(R.string.allowed_vpn_apps_info, TextUtils.join(", ", mProfile.mAllowedAppsVpn));
1093 |         }
1094 | 
1095 |         if (mProfile.mAllowAppVpnBypass) {
1096 |             builder.allowBypass();
1097 |             VpnStatus.logDebug("Apps may bypass VPN");
1098 |         }
1099 |     }
1100 | 
1101 |     public void addDNS(String dns) {
1102 |         mDnslist.add(dns);
1103 |     }
1104 | 
1105 |     public void setDomain(String domain) {
1106 |         if (mDomain == null) {
1107 |             mDomain = domain;
1108 |         }
1109 |     }
1110 | 
1111 |     /**
1112 |      * Route that is always included, used by the v3 core
1113 |      */
1114 |     public void addRoute(CIDRIP route, boolean include) {
1115 |         mRoutes.addIP(route, include);
1116 |     }
1117 | 
1118 |     public void addRoute(String dest, String mask, String gateway, String device) {
1119 |         CIDRIP route = new CIDRIP(dest, mask);
1120 |         boolean include = isAndroidTunDevice(device);
1121 | 
1122 |         IpAddress gatewayIP = new IpAddress(new CIDRIP(gateway, 32), false);
1123 | 
1124 |         if (mLocalIP == null) {
1125 |             VpnStatus.logError("Local IP address unset and received. Neither pushed server config nor local config specifies an IP addresses. Opening tun device is most likely going to fail.");
1126 |             return;
1127 |         }
1128 |         IpAddress localNet = new IpAddress(mLocalIP, true);
1129 |         if (localNet.containsNet(gatewayIP))
1130 |             include = true;
1131 | 
1132 |         if (gateway != null &&
1133 |                 (gateway.equals("255.255.255.255") || gateway.equals(mRemoteGW)))
1134 |             include = true;
1135 | 
1136 | 
1137 |         if (route.len == 32 && !mask.equals("255.255.255.255")) {
1138 |             VpnStatus.logWarning(R.string.route_not_cidr, dest, mask);
1139 |         }
1140 | 
1141 |         if (route.normalise())
1142 |             VpnStatus.logWarning(R.string.route_not_netip, dest, route.len, route.mIp);
1143 | 
1144 |         mRoutes.addIP(route, include);
1145 |     }
1146 | 
1147 |     public void addRoutev6(String network, String device) {
1148 |         // Tun is opened after ROUTE6, no device name may be present
1149 |         boolean included = isAndroidTunDevice(device);
1150 |         addRoutev6(network, included);
1151 |     }
1152 | 
1153 |     public void addRoutev6(String network, boolean included) {
1154 |         String[] v6parts = network.split("/");
1155 | 
1156 |         try {
1157 |             Inet6Address ip = (Inet6Address) InetAddress.getAllByName(v6parts[0])[0];
1158 |             int mask = Integer.parseInt(v6parts[1]);
1159 |             mRoutesv6.addIPv6(ip, mask, included);
1160 | 
1161 |         } catch (UnknownHostException e) {
1162 |             VpnStatus.logException(e);
1163 |         }
1164 | 
1165 | 
1166 |     }
1167 | 
1168 |     private boolean isAndroidTunDevice(String device) {
1169 |         return device != null &&
1170 |                 (device.startsWith("tun") || "(null)".equals(device) || VPNSERVICE_TUN.equals(device));
1171 |     }
1172 | 
1173 |     public void setMtu(int mtu) {
1174 |         mMtu = mtu;
1175 |     }
1176 | 
1177 |     public void setLocalIP(CIDRIP cdrip) {
1178 |         mLocalIP = cdrip;
1179 |     }
1180 | 
1181 |     public void setLocalIP(String local, String netmask, int mtu, String mode) {
1182 |         mLocalIP = new CIDRIP(local, netmask);
1183 |         mMtu = mtu;
1184 |         mRemoteGW = null;
1185 | 
1186 |         long netMaskAsInt = CIDRIP.getInt(netmask);
1187 | 
1188 |         if (mLocalIP.len == 32 && !netmask.equals("255.255.255.255")) {
1189 |             // get the netmask as IP
1190 | 
1191 |             int masklen;
1192 |             long mask;
1193 |             if ("net30".equals(mode)) {
1194 |                 masklen = 30;
1195 |                 mask = 0xfffffffc;
1196 |             } else {
1197 |                 masklen = 31;
1198 |                 mask = 0xfffffffe;
1199 |             }
1200 | 
1201 |             // Netmask is Ip address +/-1, assume net30/p2p with small net
1202 |             if ((netMaskAsInt & mask) == (mLocalIP.getInt() & mask)) {
1203 |                 mLocalIP.len = masklen;
1204 |             } else {
1205 |                 mLocalIP.len = 32;
1206 |                 if (!"p2p".equals(mode))
1207 |                     VpnStatus.logWarning(R.string.ip_not_cidr, local, netmask, mode);
1208 |             }
1209 |         }
1210 |         if (("p2p".equals(mode) && mLocalIP.len < 32) || ("net30".equals(mode) && mLocalIP.len < 30)) {
1211 |             VpnStatus.logWarning(R.string.ip_looks_like_subnet, local, netmask, mode);
1212 |         }
1213 | 
1214 | 
1215 |         /* Workaround for Lollipop, it  does not route traffic to the VPNs own network mask */
1216 |         if (mLocalIP.len <= 31 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
1217 |             CIDRIP interfaceRoute = new CIDRIP(mLocalIP.mIp, mLocalIP.len);
1218 |             interfaceRoute.normalise();
1219 |             addRoute(interfaceRoute, true);
1220 |         }
1221 | 
1222 | 
1223 |         // Configurations are sometimes really broken...
1224 |         mRemoteGW = netmask;
1225 |     }
1226 | 
1227 |     public void setLocalIPv6(String ipv6addr) {
1228 |         mLocalIPv6 = ipv6addr;
1229 |     }
1230 | 
1231 |     @Override
1232 |     public void updateState(String state, String logmessage, int resid, ConnectionStatus level, Intent intent) {
1233 |         // If the process is not running, ignore any state,
1234 |         // Notification should be invisible in this state
1235 | 
1236 |         doSendBroadcast(state, level);
1237 |         if (mProcessThread == null && !mNotificationAlwaysVisible)
1238 |             return;
1239 | 
1240 |         String channel = NOTIFICATION_CHANNEL_NEWSTATUS_ID;
1241 |         // Display byte count only after being connected
1242 | 
1243 |         {
1244 |             if (level == LEVEL_CONNECTED) {
1245 |                 mDisplayBytecount = true;
1246 |                 mConnecttime = System.currentTimeMillis();
1247 |                 if (!runningOnAndroidTV())
1248 |                     channel = NOTIFICATION_CHANNEL_BG_ID;
1249 |             } else {
1250 |                 mDisplayBytecount = false;
1251 |             }
1252 | 
1253 |             // Other notifications are shown,
1254 |             // This also mean we are no longer connected, ignore bytecount messages until next
1255 |             // CONNECTED
1256 |             // Does not work :(
1257 |             String msg = getString(resid);
1258 |             showNotification(VpnStatus.getLastCleanLogMessage(this),
1259 |                     VpnStatus.getLastCleanLogMessage(this), channel, 0, level, intent);
1260 | 
1261 |         }
1262 |     }
1263 | 
1264 |     @Override
1265 |     public void setConnectedVPN(String uuid) {
1266 |     }
1267 | 
1268 |     private void doSendBroadcast(String state, ConnectionStatus level) {
1269 |         Intent vpnstatus = new Intent();
1270 |         vpnstatus.setAction("de.blinkt.openvpn.VPN_STATUS");
1271 |         vpnstatus.putExtra("status", level.toString());
1272 |         vpnstatus.putExtra("detailstatus", state);
1273 |         sendBroadcast(vpnstatus, permission.ACCESS_NETWORK_STATE);
1274 |         sendMessage(state);
1275 |     }
1276 | 
1277 |     long c = Calendar.getInstance().getTimeInMillis();
1278 |     long time;
1279 |     int lastPacketReceive = 0;
1280 |     String seconds = "0", minutes, hours;
1281 | 
1282 |     @Override
1283 |     public void updateByteCount(long in, long out, long diffIn, long diffOut) {
1284 |         TotalTraffic.calcTraffic(this, in, out, diffIn, diffOut);
1285 |         if (mDisplayBytecount) {
1286 |             String netstat = String.format(getString(R.string.statusline_bytecount),
1287 |                     humanReadableByteCount(in, false, getResources()),
1288 |                     humanReadableByteCount(diffIn / OpenVPNManagement.mBytecountInterval, true, getResources()),
1289 |                     humanReadableByteCount(out, false, getResources()),
1290 |                     humanReadableByteCount(diffOut / OpenVPNManagement.mBytecountInterval, true, getResources()));
1291 | 
1292 | 
1293 |             showNotification(netstat, null, NOTIFICATION_CHANNEL_BG_ID, mConnecttime, LEVEL_CONNECTED, null);
1294 |             byteIn = String.format("↓%2$s", getString(R.string.statusline_bytecount),
1295 |                     humanReadableByteCount(in,false, getResources())) + " - " + humanReadableByteCount(diffIn / OpenVPNManagement.mBytecountInterval, false, getResources()) + "/s";
1296 |             byteOut = String.format("↑%2$s", getString(R.string.statusline_bytecount),
1297 |                     humanReadableByteCount(out, false,getResources())) + " - " + humanReadableByteCount(diffOut / OpenVPNManagement.mBytecountInterval, false, getResources()) + "/s";
1298 |             time = Calendar.getInstance().getTimeInMillis() - c;
1299 |             lastPacketReceive = Integer.parseInt(convertTwoDigit((int) (time / 1000) % 60)) - Integer.parseInt(seconds);
1300 |             seconds = convertTwoDigit((int) (time / 1000) % 60);
1301 |             minutes = convertTwoDigit((int) ((time / (1000 * 60)) % 60));
1302 |             hours = convertTwoDigit((int) ((time / (1000 * 60 * 60)) % 24));
1303 |             duration = hours + ":" + minutes + ":" + seconds;
1304 |             lastPacketReceive = checkPacketReceive(lastPacketReceive);
1305 |             sendMessage(duration, String.valueOf(lastPacketReceive), byteIn, byteOut);
1306 |         }
1307 | 
1308 |     }
1309 | 
1310 |     public int checkPacketReceive(int value) {
1311 |         value -= 2;
1312 |         if (value < 0) return 0;
1313 |         else return value;
1314 |     }
1315 |     public String convertTwoDigit(int value) {
1316 |         if (value < 10) return "0" + value;
1317 |         else return value + "";
1318 |     }
1319 | 
1320 |     @Override
1321 |     public boolean handleMessage(Message msg) {
1322 |         Runnable r = msg.getCallback();
1323 |         if (r != null) {
1324 |             r.run();
1325 |             return true;
1326 |         } else {
1327 |             return false;
1328 |         }
1329 |     }
1330 | 
1331 |     public OpenVPNManagement getManagement() {
1332 |         return mManagement;
1333 |     }
1334 | 
1335 |     public String getTunReopenStatus() {
1336 |         String currentConfiguration = getTunConfigString();
1337 |         if (currentConfiguration.equals(mLastTunCfg)) {
1338 |             return "NOACTION";
1339 |         } else {
1340 |             String release = Build.VERSION.RELEASE;
1341 |             if (Build.VERSION.SDK_INT == Build.VERSION_CODES.KITKAT && !release.startsWith("4.4.3")
1342 |                     && !release.startsWith("4.4.4") && !release.startsWith("4.4.5") && !release.startsWith("4.4.6"))
1343 |                 // There will be probably no 4.4.4 or 4.4.5 version, so don't waste effort to do parsing here
1344 |                 return "OPEN_AFTER_CLOSE";
1345 |             else
1346 |                 return "OPEN_BEFORE_CLOSE";
1347 |         }
1348 |     }
1349 | 
1350 |     public void requestInputFromUser(int resid, String needed) {
1351 |         VpnStatus.updateStateString("NEED", "need " + needed, resid, LEVEL_WAITING_FOR_USER_INPUT);
1352 |         showNotification(getString(resid), getString(resid), NOTIFICATION_CHANNEL_NEWSTATUS_ID, 0, LEVEL_WAITING_FOR_USER_INPUT, null);
1353 |     }
1354 | 
1355 | 
1356 |     public void trigger_sso(String info) {
1357 |         String channel = NOTIFICATION_CHANNEL_USERREQ_ID;
1358 |         String method = info.split(":", 2)[0];
1359 | 
1360 |         NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
1361 | 
1362 |         Notification.Builder nbuilder = new Notification.Builder(this);
1363 |         nbuilder.setAutoCancel(true);
1364 |         int icon = android.R.drawable.ic_dialog_info;
1365 |         nbuilder.setSmallIcon(icon);
1366 | 
1367 |         Intent intent;
1368 | 
1369 |         int reason;
1370 |         if (method.equals("CR_TEXT")) {
1371 |             String challenge = info.split(":", 2)[1];
1372 |             reason = R.string.crtext_requested;
1373 |             nbuilder.setContentTitle(getString(reason));
1374 |             nbuilder.setContentText(challenge);
1375 | 
1376 |             intent = new Intent();
1377 |             intent.setComponent(new ComponentName(this, getPackageName() + ".activities.CredentialsPopup"));
1378 | 
1379 |             intent.putExtra(EXTRA_CHALLENGE_TXT, challenge);
1380 | 
1381 |         } else {
1382 |             VpnStatus.logError("Unknown SSO method found: " + method);
1383 |             return;
1384 |         }
1385 | 
1386 |         // updateStateString trigger the notification of the VPN to be refreshed, save this intent
1387 |         // to have that notification also this intent to be set
1388 |         PendingIntent pIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
1389 |         VpnStatus.updateStateString("USER_INPUT", "waiting for user input", reason, LEVEL_WAITING_FOR_USER_INPUT, intent);
1390 |         nbuilder.setContentIntent(pIntent);
1391 | 
1392 | 
1393 |         // Try to set the priority available since API 16 (Jellybean)
1394 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
1395 |             jbNotificationExtras(PRIORITY_MAX, nbuilder);
1396 | 
1397 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
1398 |             lpNotificationExtras(nbuilder, Notification.CATEGORY_STATUS);
1399 | 
1400 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
1401 |             //noinspection NewApi
1402 |             nbuilder.setChannelId(channel);
1403 |         }
1404 | 
1405 |         @SuppressWarnings("deprecation")
1406 |         Notification notification = nbuilder.getNotification();
1407 | 
1408 | 
1409 |         int notificationId = channel.hashCode();
1410 | 
1411 |         mNotificationManager.notify(notificationId, notification);
1412 |     }
1413 | 
1414 |     //sending message to main activity
1415 |     private void sendMessage(String state) {
1416 |         Intent intent = new Intent("connectionState");
1417 |         intent.putExtra("state", state);
1418 |         this.state = state;
1419 |         LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
1420 |     }
1421 |     //sending message to main activity
1422 |     private void sendMessage(String duration, String lastPacketReceive, String byteIn, String byteOut) {
1423 |         Intent intent = new Intent("connectionState");
1424 |         intent.putExtra("duration", duration);
1425 |         intent.putExtra("lastPacketReceive", lastPacketReceive);
1426 |         intent.putExtra("byteIn", byteIn);
1427 |         intent.putExtra("byteOut", byteOut);
1428 |         LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
1429 |     }
1430 |     public class LocalBinder extends Binder {
1431 |         public OpenVPNService getService() {
1432 |             // Return this instance of LocalService so clients can call public methods
1433 |             return OpenVPNService.this;
1434 |         }
1435 |     }
1436 |     public static String getStatus() {//it will be call from mainactivity for get current status
1437 |         return state;
1438 |     }
1439 |     public static void setDefaultStatus() {
1440 |         state = "";
1441 |     }
1442 |     public boolean isConnected() {
1443 |         return flag;
1444 |     }
1445 | }
1446 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OpenVPNStatusService.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.app.PendingIntent;
  9 | import android.app.Service;
 10 | import android.content.Intent;
 11 | import android.os.Build;
 12 | import android.os.Handler;
 13 | import android.os.IBinder;
 14 | import android.os.Message;
 15 | import android.os.ParcelFileDescriptor;
 16 | import android.os.RemoteCallbackList;
 17 | import android.os.RemoteException;
 18 | import androidx.annotation.Nullable;
 19 | import android.util.Pair;
 20 | 
 21 | import java.io.DataOutputStream;
 22 | import java.io.IOException;
 23 | import java.lang.ref.WeakReference;
 24 | 
 25 | /**
 26 |  * Created by arne on 08.11.16.
 27 |  */
 28 | 
 29 | public class OpenVPNStatusService extends Service implements VpnStatus.LogListener, VpnStatus.ByteCountListener, VpnStatus.StateListener {
 30 |     @Nullable
 31 |     @Override
 32 |     public IBinder onBind(Intent intent) {
 33 |         return mBinder;
 34 |     }
 35 | 
 36 | 
 37 |     static final RemoteCallbackList<IStatusCallbacks> mCallbacks =
 38 |             new RemoteCallbackList<>();
 39 | 
 40 |     @Override
 41 |     public void onCreate() {
 42 |         super.onCreate();
 43 |         VpnStatus.addLogListener(this);
 44 |         VpnStatus.addByteCountListener(this);
 45 |         VpnStatus.addStateListener(this);
 46 |         mHandler.setService(this);
 47 | 
 48 |     }
 49 | 
 50 |     @Override
 51 |     public void onDestroy() {
 52 |         super.onDestroy();
 53 | 
 54 |         VpnStatus.removeLogListener(this);
 55 |         VpnStatus.removeByteCountListener(this);
 56 |         VpnStatus.removeStateListener(this);
 57 |         mCallbacks.kill();
 58 | 
 59 |     }
 60 | 
 61 |     private static final IServiceStatus.Stub mBinder = new IServiceStatus.Stub() {
 62 | 
 63 |         @Override
 64 |         public ParcelFileDescriptor registerStatusCallback(IStatusCallbacks cb) throws RemoteException {
 65 |             final LogItem[] logbuffer = VpnStatus.getlogbuffer();
 66 |             if (mLastUpdateMessage != null)
 67 |                 sendUpdate(cb, mLastUpdateMessage);
 68 | 
 69 |             mCallbacks.register(cb);
 70 |             try {
 71 |                 final ParcelFileDescriptor[] pipe = ParcelFileDescriptor.createPipe();
 72 |                 new Thread("pushLogs") {
 73 |                     @Override
 74 |                     public void run() {
 75 |                         DataOutputStream fd = new DataOutputStream(new ParcelFileDescriptor.AutoCloseOutputStream(pipe[1]));
 76 |                         try {
 77 |                             synchronized (VpnStatus.readFileLock) {
 78 |                                 if (!VpnStatus.readFileLog) {
 79 |                                     VpnStatus.readFileLock.wait();
 80 |                                 }
 81 |                             }
 82 |                         } catch (InterruptedException e) {
 83 |                             VpnStatus.logException(e);
 84 |                         }
 85 |                         try {
 86 | 
 87 |                             for (LogItem logItem : logbuffer) {
 88 |                                 byte[] bytes = logItem.getMarschaledBytes();
 89 |                                 fd.writeShort(bytes.length);
 90 |                                 fd.write(bytes);
 91 |                             }
 92 |                             // Mark end
 93 |                             fd.writeShort(0x7fff);
 94 |                             fd.close();
 95 |                         } catch (IOException e) {
 96 |                             e.printStackTrace();
 97 |                         }
 98 | 
 99 |                     }
100 |                 }.start();
101 |                 return pipe[0];
102 |             } catch (IOException e) {
103 |                 e.printStackTrace();
104 |                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1) {
105 |                     throw new RemoteException(e.getMessage());
106 |                 }
107 |                 return null;
108 |             }
109 |         }
110 | 
111 |         @Override
112 |         public void unregisterStatusCallback(IStatusCallbacks cb) throws RemoteException {
113 |             mCallbacks.unregister(cb);
114 |         }
115 | 
116 |         @Override
117 |         public String getLastConnectedVPN() throws RemoteException {
118 |             return VpnStatus.getLastConnectedVPNProfile();
119 |         }
120 | 
121 |         @Override
122 |         public void setCachedPassword(String uuid, int type, String password) {
123 |             PasswordCache.setCachedPassword(uuid, type, password);
124 |         }
125 | 
126 |         @Override
127 |         public TrafficHistory getTrafficHistory() throws RemoteException {
128 |             return VpnStatus.trafficHistory;
129 |         }
130 | 
131 |     };
132 | 
133 |     @Override
134 |     public void newLog(LogItem logItem) {
135 |         Message msg = mHandler.obtainMessage(SEND_NEW_LOGITEM, logItem);
136 |         msg.sendToTarget();
137 |     }
138 | 
139 |     @Override
140 |     public void updateByteCount(long in, long out, long diffIn, long diffOut) {
141 |         Message msg = mHandler.obtainMessage(SEND_NEW_BYTECOUNT, Pair.create(in, out));
142 |         msg.sendToTarget();
143 |     }
144 | 
145 |     static UpdateMessage mLastUpdateMessage;
146 | 
147 |     static class UpdateMessage {
148 |         public String state;
149 |         public String logmessage;
150 |         public ConnectionStatus level;
151 |         public Intent intent;
152 |         int resId;
153 | 
154 |         UpdateMessage(String state, String logmessage, int resId, ConnectionStatus level, Intent intent) {
155 |             this.state = state;
156 |             this.resId = resId;
157 |             this.logmessage = logmessage;
158 |             this.level = level;
159 |             this.intent = intent;
160 |         }
161 |     }
162 | 
163 | 
164 |     @Override
165 |     public void updateState(String state, String logmessage, int localizedResId, ConnectionStatus level, Intent intent) {
166 | 
167 |         mLastUpdateMessage = new UpdateMessage(state, logmessage, localizedResId, level, intent);
168 |         Message msg = mHandler.obtainMessage(SEND_NEW_STATE, mLastUpdateMessage);
169 |         msg.sendToTarget();
170 |     }
171 | 
172 |     @Override
173 |     public void setConnectedVPN(String uuid) {
174 |         Message msg = mHandler.obtainMessage(SEND_NEW_CONNECTED_VPN, uuid);
175 |         msg.sendToTarget();
176 |     }
177 | 
178 |     private static final OpenVPNStatusHandler mHandler = new OpenVPNStatusHandler();
179 | 
180 |     private static final int SEND_NEW_LOGITEM = 100;
181 |     private static final int SEND_NEW_STATE = 101;
182 |     private static final int SEND_NEW_BYTECOUNT = 102;
183 |     private static final int SEND_NEW_CONNECTED_VPN = 103;
184 | 
185 |     private static class OpenVPNStatusHandler extends Handler {
186 |         WeakReference<OpenVPNStatusService> service = null;
187 | 
188 |         private void setService(OpenVPNStatusService statusService) {
189 |             service = new WeakReference<>(statusService);
190 |         }
191 | 
192 |         @Override
193 |         public void handleMessage(Message msg) {
194 | 
195 |             RemoteCallbackList<IStatusCallbacks> callbacks;
196 |             if (service == null || service.get() == null)
197 |                 return;
198 |             callbacks = service.get().mCallbacks;
199 |             // Broadcast to all clients the new value.
200 |             final int N = callbacks.beginBroadcast();
201 |             for (int i = 0; i < N; i++) {
202 | 
203 |                 try {
204 |                     IStatusCallbacks broadcastItem = callbacks.getBroadcastItem(i);
205 | 
206 |                     switch (msg.what) {
207 |                         case SEND_NEW_LOGITEM:
208 |                             broadcastItem.newLogItem((LogItem) msg.obj);
209 |                             break;
210 |                         case SEND_NEW_BYTECOUNT:
211 |                             Pair<Long, Long> inout = (Pair<Long, Long>) msg.obj;
212 |                             broadcastItem.updateByteCount(inout.first, inout.second);
213 |                             break;
214 |                         case SEND_NEW_STATE:
215 |                             sendUpdate(broadcastItem, (UpdateMessage) msg.obj);
216 |                             break;
217 | 
218 |                         case SEND_NEW_CONNECTED_VPN:
219 |                             broadcastItem.connectedVPN((String) msg.obj);
220 |                             break;
221 |                     }
222 |                 } catch (RemoteException e) {
223 |                     // The RemoteCallbackList will take care of removing
224 |                     // the dead object for us.
225 |                 }
226 |             }
227 |             callbacks.finishBroadcast();
228 |         }
229 |     }
230 | 
231 |     private static void sendUpdate(IStatusCallbacks broadcastItem,
232 |                                    UpdateMessage um) throws RemoteException {
233 |         broadcastItem.updateStateString(um.state, um.logmessage, um.resId, um.level, um.intent);
234 |     }
235 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OpenVPNThread.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.annotation.SuppressLint;
  9 | import android.util.Log;
 10 | 
 11 | import java.io.BufferedReader;
 12 | import java.io.BufferedWriter;
 13 | import java.io.FileWriter;
 14 | import java.io.IOException;
 15 | import java.io.InputStream;
 16 | import java.io.InputStreamReader;
 17 | import java.text.SimpleDateFormat;
 18 | import java.util.Collections;
 19 | import java.util.Date;
 20 | import java.util.LinkedList;
 21 | import java.util.Locale;
 22 | import java.util.regex.Matcher;
 23 | import java.util.regex.Pattern;
 24 | 
 25 | import de.blinkt.openvpn.R;
 26 | 
 27 | public class OpenVPNThread implements Runnable {
 28 |     private static final String DUMP_PATH_STRING = "Dump path: ";
 29 |     @SuppressLint("SdCardPath")
 30 |     private static final String BROKEN_PIE_SUPPORT = "/data/data/de.blinkt.openvpn/cache/pievpn";
 31 |     private final static String BROKEN_PIE_SUPPORT2 = "syntax error";
 32 |     private static final String TAG = "OpenVPN";
 33 |     // 1380308330.240114 18000002 Send to HTTP proxy: 'X-Online-Host: bla.blabla.com'
 34 |     private static final Pattern LOG_PATTERN = Pattern.compile("(\\d+).(\\d+) ([0-9a-f])+ (.*)");
 35 |     public static final int M_FATAL = (1 << 4);
 36 |     public static final int M_NONFATAL = (1 << 5);
 37 |     public static final int M_WARN = (1 << 6);
 38 |     public static final int M_DEBUG = (1 << 7);
 39 |     private String[] mArgv;
 40 |     private static Process mProcess;
 41 |     private String mNativeDir;
 42 |     private String mTmpDir;
 43 |     private static OpenVPNService mService;
 44 |     private String mDumpPath;
 45 |     private boolean mBrokenPie = false;
 46 |     private boolean mNoProcessExitStatus = false;
 47 | 
 48 |     public OpenVPNThread(OpenVPNService service, String[] argv, String nativelibdir, String tmpdir) {
 49 |         mArgv = argv;
 50 |         mNativeDir = nativelibdir;
 51 |         mTmpDir = tmpdir;
 52 |         mService = service;
 53 |     }
 54 | 
 55 |     public OpenVPNThread() {
 56 |     }
 57 | 
 58 |     public void stopProcess() {
 59 |         mProcess.destroy();
 60 |     }
 61 | 
 62 |     void setReplaceConnection()
 63 |     {
 64 |         mNoProcessExitStatus=true;
 65 |     }
 66 | 
 67 |     @Override
 68 |     public void run() {
 69 |         try {
 70 |             Log.i(TAG, "Starting openvpn");
 71 |             startOpenVPNThreadArgs(mArgv);
 72 |             Log.i(TAG, "OpenVPN process exited");
 73 |         } catch (Exception e) {
 74 |             VpnStatus.logException("Starting OpenVPN Thread", e);
 75 |             Log.e(TAG, "OpenVPNThread Got " + e.toString());
 76 |         } finally {
 77 |             int exitvalue = 0;
 78 |             try {
 79 |                 if (mProcess != null)
 80 |                     exitvalue = mProcess.waitFor();
 81 |             } catch (IllegalThreadStateException ite) {
 82 |                 VpnStatus.logError("Illegal Thread state: " + ite.getLocalizedMessage());
 83 |             } catch (InterruptedException ie) {
 84 |                 VpnStatus.logError("InterruptedException: " + ie.getLocalizedMessage());
 85 |             }
 86 |             if (exitvalue != 0) {
 87 |                 VpnStatus.logError("Process exited with exit value " + exitvalue);
 88 |                 if (mBrokenPie) {
 89 |                     /* This will probably fail since the NoPIE binary is probably not written */
 90 |                     String[] noPieArgv = VPNLaunchHelper.replacePieWithNoPie(mArgv);
 91 | 
 92 |                     // We are already noPIE, nothing to gain
 93 |                     if (!noPieArgv.equals(mArgv)) {
 94 |                         mArgv = noPieArgv;
 95 |                         VpnStatus.logInfo("PIE Version could not be executed. Trying no PIE version");
 96 |                         run();
 97 |                     }
 98 | 
 99 |                 }
100 | 
101 |             }
102 | 
103 |             if (!mNoProcessExitStatus)
104 |                 VpnStatus.updateStateString("NOPROCESS", "No process running.", R.string.state_noprocess, ConnectionStatus.LEVEL_NOTCONNECTED);
105 | 
106 |             if (mDumpPath != null) {
107 |                 try {
108 |                     BufferedWriter logout = new BufferedWriter(new FileWriter(mDumpPath + ".log"));
109 |                     SimpleDateFormat timeformat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.GERMAN);
110 |                     for (LogItem li : VpnStatus.getlogbuffer()) {
111 |                         String time = timeformat.format(new Date(li.getLogtime()));
112 |                         logout.write(time + " " + li.getString(mService) + "\n");
113 |                     }
114 |                     logout.close();
115 |                     VpnStatus.logError(R.string.minidump_generated);
116 |                 } catch (IOException e) {
117 |                     VpnStatus.logError("Writing minidump log: " + e.getLocalizedMessage());
118 |                 }
119 |             }
120 | 
121 |             if (!mNoProcessExitStatus)
122 |                 mService.openvpnStopped();
123 |             Log.i(TAG, "Exiting");
124 |         }
125 |     }
126 | 
127 |     public static boolean stop(){
128 |         mService.openvpnStopped();
129 |         mProcess.destroy();
130 |         return true;
131 |     }
132 | 
133 |     private void startOpenVPNThreadArgs(String[] argv) {
134 |         LinkedList<String> argvlist = new LinkedList<String>();
135 | 
136 |         Collections.addAll(argvlist, argv);
137 | 
138 |         ProcessBuilder pb = new ProcessBuilder(argvlist);
139 |         // Hack O rama
140 | 
141 |         String lbpath = genLibraryPath(argv, pb);
142 | 
143 |         pb.environment().put("LD_LIBRARY_PATH", lbpath);
144 |         pb.environment().put("TMPDIR", mTmpDir);
145 | 
146 |         pb.redirectErrorStream(true);
147 |         try {
148 |             mProcess = pb.start();
149 |             // Close the output, since we don't need it
150 |             mProcess.getOutputStream().close();
151 |             InputStream in = mProcess.getInputStream();
152 |             BufferedReader br = new BufferedReader(new InputStreamReader(in));
153 | 
154 |             while (true) {
155 |                 String logline = br.readLine();
156 |                 if (logline == null)
157 |                     return;
158 | 
159 |                 if (logline.startsWith(DUMP_PATH_STRING))
160 |                     mDumpPath = logline.substring(DUMP_PATH_STRING.length());
161 | 
162 |                 if (logline.startsWith(BROKEN_PIE_SUPPORT) || logline.contains(BROKEN_PIE_SUPPORT2))
163 |                     mBrokenPie = true;
164 | 
165 |                 Matcher m = LOG_PATTERN.matcher(logline);
166 |                 int logerror = 0;
167 |                 if (m.matches()) {
168 |                     int flags = Integer.parseInt(m.group(3), 16);
169 |                     String msg = m.group(4);
170 |                     int logLevel = flags & 0x0F;
171 | 
172 |                     VpnStatus.LogLevel logStatus = VpnStatus.LogLevel.INFO;
173 | 
174 |                     if ((flags & M_FATAL) != 0)
175 |                         logStatus = VpnStatus.LogLevel.ERROR;
176 |                     else if ((flags & M_NONFATAL) != 0)
177 |                         logStatus = VpnStatus.LogLevel.WARNING;
178 |                     else if ((flags & M_WARN) != 0)
179 |                         logStatus = VpnStatus.LogLevel.WARNING;
180 |                     else if ((flags & M_DEBUG) != 0)
181 |                         logStatus = VpnStatus.LogLevel.VERBOSE;
182 | 
183 |                     if (msg.startsWith("MANAGEMENT: CMD"))
184 |                         logLevel = Math.max(4, logLevel);
185 | 
186 |                     if ((msg.endsWith("md too weak") && msg.startsWith("OpenSSL: error")) || msg.contains("error:140AB18E"))
187 |                         logerror = 1;
188 | 
189 |                     VpnStatus.logMessageOpenVPN(logStatus, logLevel, msg);
190 |                     if (logerror==1)
191 |                         VpnStatus.logError("OpenSSL reported a certificate with a weak hash, please the in app FAQ about weak hashes");
192 | 
193 |                 } else {
194 |                     VpnStatus.logInfo("P:" + logline);
195 |                 }
196 | 
197 |                 if (Thread.interrupted()) {
198 |                     throw new InterruptedException("OpenVpn process was killed form java code");
199 |                 }
200 |             }
201 |         } catch (InterruptedException | IOException e) {
202 |             VpnStatus.logException("Error reading from output of OpenVPN process", e);
203 |             stopProcess();
204 |         }
205 | 
206 | 
207 |     }
208 | 
209 |     private String genLibraryPath(String[] argv, ProcessBuilder pb) {
210 |         // Hack until I find a good way to get the real library path
211 |         String applibpath = argv[0].replaceFirst("/cache/.*
quot;, "/lib");
212 | 
213 |         String lbpath = pb.environment().get("LD_LIBRARY_PATH");
214 |         if (lbpath == null)
215 |             lbpath = applibpath;
216 |         else
217 |             lbpath = applibpath + ":" + lbpath;
218 | 
219 |         if (!applibpath.equals(mNativeDir)) {
220 |             lbpath = mNativeDir + ":" + lbpath;
221 |         }
222 |         return lbpath;
223 |     }
224 | }
225 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OpenVpnManagementThread.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.content.Context;
  9 | import android.content.Intent;
 10 | import android.net.LocalServerSocket;
 11 | import android.net.LocalSocket;
 12 | import android.net.LocalSocketAddress;
 13 | import android.os.Build;
 14 | import android.os.Handler;
 15 | import android.os.ParcelFileDescriptor;
 16 | import androidx.annotation.NonNull;
 17 | import androidx.annotation.RequiresApi;
 18 | import android.system.Os;
 19 | import android.util.Log;
 20 | import de.blinkt.openvpn.R;
 21 | import de.blinkt.openvpn.VpnProfile;
 22 | 
 23 | import java.io.FileDescriptor;
 24 | import java.io.IOException;
 25 | import java.io.InputStream;
 26 | import java.lang.reflect.InvocationTargetException;
 27 | import java.lang.reflect.Method;
 28 | import java.net.InetSocketAddress;
 29 | import java.net.SocketAddress;
 30 | import java.util.*;
 31 | 
 32 | public class OpenVpnManagementThread implements Runnable, OpenVPNManagement {
 33 | 
 34 |     public static final int ORBOT_TIMEOUT_MS = 20 * 1000;
 35 |     private static final String TAG = "openvpn";
 36 |     private static final Vector<OpenVpnManagementThread> active = new Vector<>();
 37 |     private final Handler mResumeHandler;
 38 |     private LocalSocket mSocket;
 39 |     private VpnProfile mProfile;
 40 |     private OpenVPNService mOpenVPNService;
 41 |     private LinkedList<FileDescriptor> mFDList = new LinkedList<>();
 42 |     private LocalServerSocket mServerSocket;
 43 |     private boolean mWaitingForRelease = false;
 44 |     private long mLastHoldRelease = 0;
 45 |     private LocalSocket mServerSocketLocal;
 46 | 
 47 |     private pauseReason lastPauseReason = pauseReason.noNetwork;
 48 |     private PausedStateCallback mPauseCallback;
 49 |     private boolean mShuttingDown;
 50 |     private Runnable mResumeHoldRunnable = () -> {
 51 |         if (shouldBeRunning()) {
 52 |             releaseHoldCmd();
 53 |         }
 54 |     };
 55 |     private Runnable orbotStatusTimeOutRunnable = new Runnable() {
 56 |         @Override
 57 |         public void run() {
 58 |             sendProxyCMD(Connection.ProxyType.SOCKS5, "127.0.0.1", Integer.toString(OrbotHelper.SOCKS_PROXY_PORT_DEFAULT), false);
 59 |             OrbotHelper.get(mOpenVPNService).removeStatusCallback(statusCallback);
 60 | 
 61 |         }
 62 |     };
 63 |     private OrbotHelper.StatusCallback statusCallback = new OrbotHelper.StatusCallback() {
 64 | 
 65 |         @Override
 66 |         public void onStatus(Intent statusIntent) {
 67 |             StringBuilder extras = new StringBuilder();
 68 |             for (String key : statusIntent.getExtras().keySet()) {
 69 |                 Object val = statusIntent.getExtras().get(key);
 70 | 
 71 |                 extras.append(String.format(Locale.ENGLISH, "%s - '%s'", key, val == null ? "null" : val.toString()));
 72 |             }
 73 |             VpnStatus.logDebug("Got Orbot status: " + extras);
 74 |         }
 75 | 
 76 |         @Override
 77 |         public void onNotYetInstalled() {
 78 |             VpnStatus.logDebug("Orbot not yet installed");
 79 |         }
 80 | 
 81 |         @Override
 82 |         public void onOrbotReady(Intent intent, String socksHost, int socksPort) {
 83 |             mResumeHandler.removeCallbacks(orbotStatusTimeOutRunnable);
 84 |             sendProxyCMD(Connection.ProxyType.SOCKS5, socksHost, Integer.toString(socksPort), false);
 85 |             OrbotHelper.get(mOpenVPNService).removeStatusCallback(this);
 86 |         }
 87 | 
 88 |         @Override
 89 |         public void onDisabled(Intent intent) {
 90 |             VpnStatus.logWarning("Orbot integration for external applications is disabled. Waiting %ds before connecting to the default port. Enable external app integration in Orbot or use Socks v5 config instead of Orbot to avoid this delay.");
 91 |         }
 92 |     };
 93 |     private transient Connection mCurrentProxyConnection;
 94 | 
 95 |     public OpenVpnManagementThread(VpnProfile profile, OpenVPNService openVpnService) {
 96 |         mProfile = profile;
 97 |         mOpenVPNService = openVpnService;
 98 |         mResumeHandler = new Handler(openVpnService.getMainLooper());
 99 | 
100 |     }
101 | 
102 |     private static boolean stopOpenVPN() {
103 |         synchronized (active) {
104 |             boolean sendCMD = false;
105 |             for (OpenVpnManagementThread mt : active) {
106 |                 sendCMD = mt.managmentCommand("signal SIGINT\n");
107 |                 try {
108 |                     if (mt.mSocket != null)
109 |                         mt.mSocket.close();
110 |                 } catch (IOException e) {
111 |                     // Ignore close error on already closed socket
112 |                 }
113 |             }
114 |             return sendCMD;
115 |         }
116 |     }
117 | 
118 |     public boolean openManagementInterface(@NonNull Context c) {
119 |         // Could take a while to open connection
120 |         int tries = 8;
121 | 
122 |         String socketName = (c.getCacheDir().getAbsolutePath() + "/" + "mgmtsocket");
123 |         // The mServerSocketLocal is transferred to the LocalServerSocket, ignore warning
124 | 
125 |         mServerSocketLocal = new LocalSocket();
126 | 
127 |         while (tries > 0 && !mServerSocketLocal.isBound()) {
128 |             try {
129 |                 mServerSocketLocal.bind(new LocalSocketAddress(socketName,
130 |                         LocalSocketAddress.Namespace.FILESYSTEM));
131 |             } catch (IOException e) {
132 |                 // wait 300 ms before retrying
133 |                 try {
134 |                     Thread.sleep(300);
135 |                 } catch (InterruptedException ignored) {
136 |                 }
137 | 
138 |             }
139 |             tries--;
140 |         }
141 | 
142 |         try {
143 | 
144 |             mServerSocket = new LocalServerSocket(mServerSocketLocal.getFileDescriptor());
145 |             return true;
146 |         } catch (IOException e) {
147 |             VpnStatus.logException(e);
148 |         }
149 |         return false;
150 | 
151 | 
152 |     }
153 | 
154 |     /**
155 |      * @param cmd command to write to management socket
156 |      * @return true if command have been sent
157 |      */
158 |     public boolean managmentCommand(String cmd) {
159 |         try {
160 |             if (mSocket != null && mSocket.getOutputStream() != null) {
161 |                 mSocket.getOutputStream().write(cmd.getBytes());
162 |                 mSocket.getOutputStream().flush();
163 |                 return true;
164 |             }
165 |         } catch (IOException e) {
166 |             // Ignore socket stack traces
167 |         }
168 |         return false;
169 |     }
170 | 
171 |     @Override
172 |     public void run() {
173 |         byte[] buffer = new byte[2048];
174 |         //	mSocket.setSoTimeout(5); // Setting a timeout cannot be that bad
175 | 
176 |         String pendingInput = "";
177 |         synchronized (active) {
178 |             active.add(this);
179 |         }
180 | 
181 |         try {
182 |             // Wait for a client to connect
183 |             mSocket = mServerSocket.accept();
184 |             InputStream instream = mSocket.getInputStream();
185 | 
186 | 
187 |             // Close the management socket after client connected
188 |             try {
189 |                 mServerSocket.close();
190 |             } catch (IOException e) {
191 |                 VpnStatus.logException(e);
192 |             }
193 | 
194 |             // Closing one of the two sockets also closes the other
195 |             //mServerSocketLocal.close();
196 |             managmentCommand("version 3\n");
197 | 
198 |             while (true) {
199 | 
200 |                 int numbytesread = instream.read(buffer);
201 |                 if (numbytesread == -1)
202 |                     return;
203 | 
204 |                 FileDescriptor[] fds = null;
205 |                 try {
206 |                     fds = mSocket.getAncillaryFileDescriptors();
207 |                 } catch (IOException e) {
208 |                     VpnStatus.logException("Error reading fds from socket", e);
209 |                 }
210 |                 if (fds != null) {
211 |                     Collections.addAll(mFDList, fds);
212 |                 }
213 | 
214 |                 String input = new String(buffer, 0, numbytesread, "UTF-8");
215 | 
216 |                 pendingInput += input;
217 | 
218 |                 pendingInput = processInput(pendingInput);
219 | 
220 | 
221 |             }
222 |         } catch (IOException e) {
223 |             if (!e.getMessage().equals("socket closed") && !e.getMessage().equals("Connection reset by peer"))
224 |                 VpnStatus.logException(e);
225 |         }
226 |         synchronized (active) {
227 |             active.remove(this);
228 |         }
229 |     }
230 | 
231 |     //! Hack O Rama 2000!
232 |     private void protectFileDescriptor(FileDescriptor fd) {
233 |         try {
234 |             Method getInt = FileDescriptor.class.getDeclaredMethod("getInt
quot;);
235 |             int fdint = (Integer) getInt.invoke(fd);
236 | 
237 |             // You can even get more evil by parsing toString() and extract the int from that :)
238 | 
239 |             boolean result = mOpenVPNService.protect(fdint);
240 |             if (!result)
241 |                 VpnStatus.logWarning("Could not protect VPN socket");
242 | 
243 | 
244 |             //ParcelFileDescriptor pfd = ParcelFileDescriptor.fromFd(fdint);
245 |             //pfd.close();
246 |             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
247 |                 fdCloseLollipop(fd);
248 |             } else {
249 |                 NativeUtils.jniclose(fdint);
250 |             }
251 |             return;
252 |         } catch ( NoSuchMethodException | IllegalArgumentException | InvocationTargetException | IllegalAccessException | NullPointerException e) {
253 |             VpnStatus.logException("Failed to retrieve fd from socket (" + fd + ")", e);
254 |         }
255 | 
256 |         Log.d("Openvpn", "Failed to retrieve fd from socket: " + fd);
257 | 
258 |     }
259 | 
260 |     @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
261 |     private void fdCloseLollipop(FileDescriptor fd) {
262 |         try {
263 |             Os.close(fd);
264 |         } catch (Exception e) {
265 |             VpnStatus.logException("Failed to close fd (" + fd + ")", e);
266 |         }
267 |     }
268 | 
269 |     private String processInput(String pendingInput) {
270 | 
271 | 
272 |         while (pendingInput.contains("\n")) {
273 |             String[] tokens = pendingInput.split("\\r?\\n", 2);
274 |             processCommand(tokens[0]);
275 |             if (tokens.length == 1)
276 |                 // No second part, newline was at the end
277 |                 pendingInput = "";
278 |             else
279 |                 pendingInput = tokens[1];
280 |         }
281 |         return pendingInput;
282 |     }
283 | 
284 |     private void processCommand(String command) {
285 |         //Log.i(TAG, "Line from managment" + command);
286 | 
287 |         if (command.startsWith(">") && command.contains(":")) {
288 |             String[] parts = command.split(":", 2);
289 |             String cmd = parts[0].substring(1);
290 |             String argument = parts[1];
291 | 
292 |             switch (cmd) {
293 |                 case "INFO":
294 |                 /* Ignore greeting from management */
295 |                     return;
296 |                 case "PASSWORD":
297 |                     processPWCommand(argument);
298 |                     break;
299 |                 case "HOLD":
300 |                     handleHold(argument);
301 |                     break;
302 |                 case "NEED-OK":
303 |                     processNeedCommand(argument);
304 |                     break;
305 |                 case "BYTECOUNT":
306 |                     processByteCount(argument);
307 |                     break;
308 |                 case "STATE":
309 |                     if (!mShuttingDown)
310 |                         processState(argument);
311 |                     break;
312 |                 case "PROXY":
313 |                     processProxyCMD(argument);
314 |                     break;
315 |                 case "LOG":
316 |                     processLogMessage(argument);
317 |                     break;
318 |                 case "PK_SIGN":
319 |                     processSignCommand(argument);
320 |                     break;
321 |                 case "INFOMSG":
322 |                     processInfoMessage(argument);
323 |                     break;
324 |                 default:
325 |                     VpnStatus.logWarning("MGMT: Got unrecognized command" + command);
326 |                     Log.i(TAG, "Got unrecognized command" + command);
327 |                     break;
328 |             }
329 |         } else if (command.startsWith("SUCCESS:")) {
330 |             /* Ignore this kind of message too */
331 |             return;
332 |         } else if (command.startsWith("PROTECTFD: ")) {
333 |             FileDescriptor fdtoprotect = mFDList.pollFirst();
334 |             if (fdtoprotect != null)
335 |                 protectFileDescriptor(fdtoprotect);
336 |         } else {
337 |             Log.i(TAG, "Got unrecognized line from managment" + command);
338 |             VpnStatus.logWarning("MGMT: Got unrecognized line from management:" + command);
339 |         }
340 |     }
341 | 
342 |     private void processInfoMessage(String info)
343 |     {
344 |         if (info.startsWith("OPEN_URL:") || info.startsWith("CR_TEXT:"))
345 |         {
346 |             mOpenVPNService.trigger_sso(info);
347 |         }
348 |         else
349 |         {
350 |             VpnStatus.logDebug("Info message from server:" + info);
351 |         }
352 |     }
353 | 
354 |     private void processLogMessage(String argument) {
355 |         String[] args = argument.split(",", 4);
356 |         // 0 unix time stamp
357 |         // 1 log level N,I,E etc.
358 |                 /*
359 |                   (b) zero or more message flags in a single string:
360 |           I -- informational
361 |           F -- fatal error
362 |           N -- non-fatal error
363 |           W -- warning
364 |           D -- debug, and
365 |                  */
366 |         // 2 log message
367 | 
368 |         Log.d("OpenVPN", argument);
369 | 
370 |         VpnStatus.LogLevel level;
371 |         switch (args[1]) {
372 |             case "I":
373 |                 level = VpnStatus.LogLevel.INFO;
374 |                 break;
375 |             case "W":
376 |                 level = VpnStatus.LogLevel.WARNING;
377 |                 break;
378 |             case "D":
379 |                 level = VpnStatus.LogLevel.VERBOSE;
380 |                 break;
381 |             case "F":
382 |                 level = VpnStatus.LogLevel.ERROR;
383 |                 break;
384 |             default:
385 |                 level = VpnStatus.LogLevel.INFO;
386 |                 break;
387 |         }
388 | 
389 |         int ovpnlevel = Integer.parseInt(args[2]) & 0x0F;
390 |         String msg = args[3];
391 | 
392 |         if (msg.startsWith("MANAGEMENT: CMD"))
393 |             ovpnlevel = Math.max(4, ovpnlevel);
394 | 
395 |         VpnStatus.logMessageOpenVPN(level, ovpnlevel, msg);
396 |     }
397 | 
398 |     boolean shouldBeRunning() {
399 |         if (mPauseCallback == null)
400 |             return false;
401 |         else
402 |             return mPauseCallback.shouldBeRunning();
403 |     }
404 | 
405 |     private void handleHold(String argument) {
406 |         mWaitingForRelease = true;
407 |         int waittime = Integer.parseInt(argument.split(":")[1]);
408 |         if (shouldBeRunning()) {
409 |             if (waittime > 1)
410 |                 VpnStatus.updateStateString("CONNECTRETRY", String.valueOf(waittime),
411 |                         R.string.state_waitconnectretry, ConnectionStatus.LEVEL_CONNECTING_NO_SERVER_REPLY_YET);
412 |             mResumeHandler.postDelayed(mResumeHoldRunnable, waittime * 1000);
413 |             if (waittime > 5)
414 |                 VpnStatus.logInfo(R.string.state_waitconnectretry, String.valueOf(waittime));
415 |             else
416 |                 VpnStatus.logDebug(R.string.state_waitconnectretry, String.valueOf(waittime));
417 | 
418 |         } else {
419 |             VpnStatus.updateStatePause(lastPauseReason);
420 |         }
421 |     }
422 | 
423 |     private void releaseHoldCmd() {
424 |         mResumeHandler.removeCallbacks(mResumeHoldRunnable);
425 |         if ((System.currentTimeMillis() - mLastHoldRelease) < 5000) {
426 |             try {
427 |                 Thread.sleep(3000);
428 |             } catch (InterruptedException ignored) {
429 |             }
430 | 
431 |         }
432 |         mWaitingForRelease = false;
433 |         mLastHoldRelease = System.currentTimeMillis();
434 |         managmentCommand("hold release\n");
435 |         managmentCommand("bytecount " + mBytecountInterval + "\n");
436 |         managmentCommand("state on\n");
437 |         //managmentCommand("log on all\n");
438 |     }
439 | 
440 |     public void releaseHold() {
441 |         if (mWaitingForRelease)
442 |             releaseHoldCmd();
443 |     }
444 | 
445 |     private void processProxyCMD(String argument) {
446 |         String[] args = argument.split(",", 3);
447 | 
448 |         Connection.ProxyType proxyType = Connection.ProxyType.NONE;
449 | 
450 |         int connectionEntryNumber = Integer.parseInt(args[0]) - 1;
451 |         String proxyport = null;
452 |         String proxyname = null;
453 |         boolean proxyUseAuth = false;
454 | 
455 |         if (mProfile.mConnections.length > connectionEntryNumber) {
456 |             Connection connection = mProfile.mConnections[connectionEntryNumber];
457 |             proxyType = connection.mProxyType;
458 |             proxyname = connection.mProxyName;
459 |             proxyport = connection.mProxyPort;
460 |             proxyUseAuth = connection.mUseProxyAuth;
461 | 
462 |             // Use transient variable to remember http user/password
463 |             mCurrentProxyConnection = connection;
464 | 
465 |         } else {
466 |             VpnStatus.logError(String.format(Locale.ENGLISH, "OpenVPN is asking for a proxy of an unknown connection entry (%d)", connectionEntryNumber));
467 |         }
468 | 
469 |         // atuo detection of proxy
470 |         if (proxyType == Connection.ProxyType.NONE) {
471 |             SocketAddress proxyaddr = ProxyDetection.detectProxy(mProfile);
472 |             if (proxyaddr instanceof InetSocketAddress) {
473 |                 InetSocketAddress isa = (InetSocketAddress) proxyaddr;
474 |                 proxyType = Connection.ProxyType.HTTP;
475 |                 proxyname = isa.getHostName();
476 |                 proxyport = String.valueOf(isa.getPort());
477 |                 proxyUseAuth = false;
478 | 
479 |             }
480 |         }
481 | 
482 | 
483 |         if (args.length >= 2 && proxyType == Connection.ProxyType.HTTP) {
484 |             String proto = args[1];
485 |             if (proto.equals("UDP")) {
486 |                 proxyname = null;
487 |                 VpnStatus.logInfo("Not using an HTTP proxy since the connection uses UDP");
488 |             }
489 |         }
490 | 
491 | 
492 |         if (proxyType == Connection.ProxyType.ORBOT) {
493 |             VpnStatus.updateStateString("WAIT_ORBOT", "Waiting for Orbot to start", R.string.state_waitorbot, ConnectionStatus.LEVEL_CONNECTING_NO_SERVER_REPLY_YET);
494 |             OrbotHelper orbotHelper = OrbotHelper.get(mOpenVPNService);
495 |             if (!orbotHelper.checkTorReceier(mOpenVPNService))
496 |                 VpnStatus.logError("Orbot does not seem to be installed!");
497 | 
498 |             mResumeHandler.postDelayed(orbotStatusTimeOutRunnable, ORBOT_TIMEOUT_MS);
499 |             orbotHelper.addStatusCallback(mOpenVPNService, statusCallback);
500 | 
501 |             orbotHelper.sendOrbotStartAndStatusBroadcast();
502 | 
503 |         } else {
504 |             sendProxyCMD(proxyType, proxyname, proxyport, proxyUseAuth);
505 |         }
506 |     }
507 | 
508 |     private void sendProxyCMD(Connection.ProxyType proxyType, String proxyname, String proxyport, boolean usePwAuth) {
509 |         if (proxyType != Connection.ProxyType.NONE && proxyname != null) {
510 | 
511 |             VpnStatus.logInfo(R.string.using_proxy, proxyname, proxyname);
512 | 
513 |             String pwstr =  usePwAuth ? " auto" : "";
514 | 
515 |             String proxycmd = String.format(Locale.ENGLISH, "proxy %s %s %s%s\n",
516 |                     proxyType == Connection.ProxyType.HTTP ? "HTTP" : "SOCKS",
517 |                     proxyname, proxyport, pwstr);
518 |             managmentCommand(proxycmd);
519 |         } else {
520 |             managmentCommand("proxy NONE\n");
521 |         }
522 |     }
523 | 
524 |     private void processState(String argument) {
525 |         String[] args = argument.split(",", 3);
526 |         String currentstate = args[1];
527 | 
528 |         if (args[2].equals(",,"))
529 |             VpnStatus.updateStateString(currentstate, "");
530 |         else
531 |             VpnStatus.updateStateString(currentstate, args[2]);
532 |     }
533 | 
534 |     private void processByteCount(String argument) {
535 |         //   >BYTECOUNT:{BYTES_IN},{BYTES_OUT}
536 |         int comma = argument.indexOf(',');
537 |         long in = Long.parseLong(argument.substring(0, comma));
538 |         long out = Long.parseLong(argument.substring(comma + 1));
539 | 
540 |         VpnStatus.updateByteCount(in, out);
541 | 
542 |     }
543 | 
544 |     private void processNeedCommand(String argument) {
545 |         int p1 = argument.indexOf('\'');
546 |         int p2 = argument.indexOf('\'', p1 + 1);
547 | 
548 |         String needed = argument.substring(p1 + 1, p2);
549 |         String extra = argument.split(":", 2)[1];
550 | 
551 |         String status = "ok";
552 | 
553 | 
554 |         switch (needed) {
555 |             case "PROTECTFD":
556 |                 FileDescriptor fdtoprotect = mFDList.pollFirst();
557 |                 protectFileDescriptor(fdtoprotect);
558 |                 break;
559 |             case "DNSSERVER":
560 |             case "DNS6SERVER":
561 |                 mOpenVPNService.addDNS(extra);
562 |                 break;
563 |             case "DNSDOMAIN":
564 |                 mOpenVPNService.setDomain(extra);
565 |                 break;
566 |             case "ROUTE": {
567 |                 String[] routeparts = extra.split(" ");
568 | 
569 |             /*
570 |             buf_printf (&out, "%s %s %s dev %s", network, netmask, gateway, rgi->iface);
571 |             else
572 |             buf_printf (&out, "%s %s %s", network, netmask, gateway);
573 |             */
574 | 
575 |                 if (routeparts.length == 5) {
576 |                     //if (BuildConfig.DEBUG)
577 |                     //                assertEquals("dev", routeparts[3]);
578 |                     mOpenVPNService.addRoute(routeparts[0], routeparts[1], routeparts[2], routeparts[4]);
579 |                 } else if (routeparts.length >= 3) {
580 |                     mOpenVPNService.addRoute(routeparts[0], routeparts[1], routeparts[2], null);
581 |                 } else {
582 |                     VpnStatus.logError("Unrecognized ROUTE cmd:" + Arrays.toString(routeparts) + " | " + argument);
583 |                 }
584 | 
585 |                 break;
586 |             }
587 |             case "ROUTE6": {
588 |                 String[] routeparts = extra.split(" ");
589 |                 mOpenVPNService.addRoutev6(routeparts[0], routeparts[1]);
590 |                 break;
591 |             }
592 |             case "IFCONFIG":
593 |                 String[] ifconfigparts = extra.split(" ");
594 |                 int mtu = Integer.parseInt(ifconfigparts[2]);
595 |                 mOpenVPNService.setLocalIP(ifconfigparts[0], ifconfigparts[1], mtu, ifconfigparts[3]);
596 |                 break;
597 |             case "IFCONFIG6":
598 |                 String[] ifconfig6parts = extra.split(" ");
599 |                 mtu = Integer.parseInt(ifconfig6parts[1]);
600 |                 mOpenVPNService.setMtu(mtu);
601 |                 mOpenVPNService.setLocalIPv6(ifconfig6parts[0]);
602 |                 break;
603 |             case "PERSIST_TUN_ACTION":
604 |                 // check if tun cfg stayed the same
605 |                 status = mOpenVPNService.getTunReopenStatus();
606 |                 break;
607 |             case "OPENTUN":
608 |                 if (sendTunFD(needed, extra))
609 |                     return;
610 |                 else
611 |                     status = "cancel";
612 |                 // This not nice or anything but setFileDescriptors accepts only FilDescriptor class :(
613 | 
614 |                 break;
615 |             default:
616 |                 Log.e(TAG, "Unknown needok command " + argument);
617 |                 return;
618 |         }
619 | 
620 |         String cmd = String.format("needok '%s' %s\n", needed, status);
621 |         managmentCommand(cmd);
622 |     }
623 | 
624 |     private boolean sendTunFD(String needed, String extra) {
625 |         if (!extra.equals("tun")) {
626 |             // We only support tun
627 |             VpnStatus.logError(String.format("Device type %s requested, but only tun is possible with the Android API, sorry!", extra));
628 | 
629 |             return false;
630 |         }
631 |         ParcelFileDescriptor pfd = mOpenVPNService.openTun();
632 |         if (pfd == null)
633 |             return false;
634 | 
635 |         Method setInt;
636 |         int fdint = pfd.getFd();
637 |         try {
638 |             setInt = FileDescriptor.class.getDeclaredMethod("setInt
quot;, int.class);
639 |             FileDescriptor fdtosend = new FileDescriptor();
640 | 
641 |             setInt.invoke(fdtosend, fdint);
642 | 
643 |             FileDescriptor[] fds = {fdtosend};
644 |             mSocket.setFileDescriptorsForSend(fds);
645 | 
646 |             // Trigger a send so we can close the fd on our side of the channel
647 |             // The API documentation fails to mention that it will not reset the file descriptor to
648 |             // be send and will happily send the file descriptor on every write ...
649 |             String cmd = String.format("needok '%s' %s\n", needed, "ok");
650 |             managmentCommand(cmd);
651 | 
652 |             // Set the FileDescriptor to null to stop this mad behavior
653 |             mSocket.setFileDescriptorsForSend(null);
654 | 
655 |             pfd.close();
656 | 
657 |             return true;
658 |         } catch (NoSuchMethodException | IllegalArgumentException | InvocationTargetException |
659 |                 IOException | IllegalAccessException exp) {
660 |             VpnStatus.logException("Could not send fd over socket", exp);
661 |         }
662 | 
663 |         return false;
664 |     }
665 | 
666 |     private void processPWCommand(String argument) {
667 |         //argument has the form 	Need 'Private Key' password
668 |         // or  ">PASSWORD:Verification Failed: '%s' ['%s']"
669 |         String needed;
670 | 
671 | 
672 |         try {
673 |             // Ignore Auth token message, already managed by openvpn itself
674 |             if (argument.startsWith("Auth-Token:")) {
675 |                 return;
676 |             }
677 | 
678 |             int p1 = argument.indexOf('\'');
679 |             int p2 = argument.indexOf('\'', p1 + 1);
680 |             needed = argument.substring(p1 + 1, p2);
681 |             if (argument.startsWith("Verification Failed")) {
682 |                 proccessPWFailed(needed, argument.substring(p2 + 1));
683 |                 return;
684 |             }
685 |         } catch (StringIndexOutOfBoundsException sioob) {
686 |             VpnStatus.logError("Could not parse management Password command: " + argument);
687 |             return;
688 |         }
689 | 
690 |         String pw = null;
691 |         String username = null;
692 | 
693 |         if (needed.equals("Private Key")) {
694 |             pw = mProfile.getPasswordPrivateKey();
695 |         } else if (needed.equals("Auth")) {
696 |             pw = mProfile.getPasswordAuth();
697 |             username = mProfile.mUsername;
698 | 
699 |         } else if (needed.equals("HTTP Proxy")) {
700 |             if( mCurrentProxyConnection != null) {
701 |                 pw = mCurrentProxyConnection.mProxyAuthPassword;
702 |                 username = mCurrentProxyConnection.mProxyAuthUser;
703 |             }
704 |         }
705 |         if (pw != null) {
706 |             if (username !=null) {
707 |                 String usercmd = String.format("username '%s' %s\n",
708 |                         needed, VpnProfile.openVpnEscape(username));
709 |                 managmentCommand(usercmd);
710 |             }
711 |             String cmd = String.format("password '%s' %s\n", needed, VpnProfile.openVpnEscape(pw));
712 |             managmentCommand(cmd);
713 |         } else {
714 |             mOpenVPNService.requestInputFromUser(R.string.password, needed);
715 |             VpnStatus.logError(String.format("Openvpn requires Authentication type '%s' but no password/key information available", needed));
716 |         }
717 | 
718 |     }
719 | 
720 |     private void proccessPWFailed(String needed, String args) {
721 |         VpnStatus.updateStateString("AUTH_FAILED", needed + args, R.string.state_auth_failed, ConnectionStatus.LEVEL_AUTH_FAILED);
722 |     }
723 | 
724 |     @Override
725 |     public void networkChange(boolean samenetwork) {
726 |         if (mWaitingForRelease)
727 |             releaseHold();
728 |         else if (samenetwork)
729 |             managmentCommand("network-change samenetwork\n");
730 |         else
731 |             managmentCommand("network-change\n");
732 |     }
733 | 
734 |     @Override
735 |     public void setPauseCallback(PausedStateCallback callback) {
736 |         mPauseCallback = callback;
737 |     }
738 | 
739 |     @Override
740 |     public void sendCRResponse(String response) {
741 |         managmentCommand("cr-response "  + response + "\n");
742 |     }
743 | 
744 |     public void signalusr1() {
745 |         mResumeHandler.removeCallbacks(mResumeHoldRunnable);
746 |         if (!mWaitingForRelease)
747 |             managmentCommand("signal SIGUSR1\n");
748 |         else
749 |             // If signalusr1 is called update the state string
750 |             // if there is another for stopping
751 |             VpnStatus.updateStatePause(lastPauseReason);
752 |     }
753 | 
754 |     public void reconnect() {
755 |         signalusr1();
756 |         releaseHold();
757 |     }
758 | 
759 |     private void processSignCommand(String argument) {
760 | 
761 |         String[] arguments = argument.split(",");
762 | 
763 |         boolean pkcs1padding = arguments[1].equals("RSA_PKCS1_PADDING");
764 |         String signed_string = mProfile.getSignedData(mOpenVPNService, arguments[0], pkcs1padding);
765 | 
766 |         if (signed_string == null) {
767 |             managmentCommand("pk-sig\n");
768 |             managmentCommand("\nEND\n");
769 |             stopOpenVPN();
770 |             return;
771 |         }
772 |         managmentCommand("pk-sig\n");
773 |         managmentCommand(signed_string);
774 |         managmentCommand("\nEND\n");
775 |     }
776 | 
777 |     @Override
778 |     public void pause(pauseReason reason) {
779 |         lastPauseReason = reason;
780 |         signalusr1();
781 |     }
782 | 
783 |     @Override
784 |     public void resume() {
785 |         releaseHold();
786 |         /* Reset the reason why we are disconnected */
787 |         lastPauseReason = pauseReason.noNetwork;
788 |     }
789 | 
790 |     @Override
791 |     public boolean stopVPN(boolean replaceConnection) {
792 |         boolean stopSucceed = stopOpenVPN();
793 |         if (stopSucceed) {
794 |             mShuttingDown = true;
795 | 
796 |         }
797 |         return stopSucceed;
798 |     }
799 | 
800 | }
801 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/OrbotHelper.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2018 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | /*
  7 |  * Portions Copyright 2014-2016 Hans-Christoph Steiner
  8 |  * Portions Copyright 2012-2016 Nathan Freitas
  9 |  * Portions Copyright (c) 2016 CommonsWare, LLC
 10 |  *
 11 |  * Licensed under the Apache License, Version 2.0 (the "License");
 12 |  * you may not use this file except in compliance with the License.
 13 |  * You may obtain a copy of the License at
 14 |  *
 15 |  * http://www.apache.org/licenses/LICENSE-2.0
 16 |  *
 17 |  * Unless required by applicable law or agreed to in writing, software
 18 |  * distributed under the License is distributed on an "AS IS" BASIS,
 19 |  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 20 |  * See the License for the specific language governing permissions and
 21 |  * limitations under the License.
 22 |  */
 23 | 
 24 | 
 25 | package de.blinkt.openvpn.core;
 26 | 
 27 | import android.content.BroadcastReceiver;
 28 | import android.content.ComponentName;
 29 | import android.content.Context;
 30 | import android.content.Intent;
 31 | import android.content.IntentFilter;
 32 | import android.content.pm.PackageManager;
 33 | import android.content.pm.ResolveInfo;
 34 | import android.text.TextUtils;
 35 | 
 36 | import java.util.HashSet;
 37 | import java.util.List;
 38 | import java.util.Set;
 39 | 
 40 | import static de.blinkt.openvpn.core.OpenVPNService.ORBOT_PACKAGE_NAME;
 41 | 
 42 | public class OrbotHelper {
 43 |     //! Based on the class from NetCipher but stripped down and modified for icsopenvpn
 44 | 
 45 |     /**
 46 |      * {@link Intent} send by Orbot with {@code ON/OFF/STARTING/STOPPING} status
 47 |      * included as an {@link #EXTRA_STATUS} {@code String}.  Your app should
 48 |      * always receive {@code ACTION_STATUS Intent}s since any other app could
 49 |      * start Orbot.  Also, user-triggered starts and stops will also cause
 50 |      * {@code ACTION_STATUS Intent}s to be broadcast.
 51 |      */
 52 |     public final static String ACTION_STATUS = "org.torproject.android.intent.action.STATUS";
 53 |     public final static String STATUS_ON = "ON";
 54 |     public final static String STATUS_STARTS_DISABLED = "STARTS_DISABLED";
 55 | 
 56 |     public final static String STATUS_STARTING = "STARTING";
 57 |     public final static String STATUS_STOPPING = "STOPPING";
 58 |     public final static String EXTRA_STATUS = "org.torproject.android.intent.extra.STATUS";
 59 |     /**
 60 |      * A request to Orbot to transparently start Tor services
 61 |      */
 62 |     public final static String ACTION_START = "org.torproject.android.intent.action.START";
 63 |     public final static String EXTRA_PACKAGE_NAME = "org.torproject.android.intent.extra.PACKAGE_NAME";
 64 |     public static final int SOCKS_PROXY_PORT_DEFAULT = 9050;
 65 |     private static OrbotHelper mInstance;
 66 | 
 67 |     String EXTRA_SOCKS_PROXY_HOST = "org.torproject.android.intent.extra.SOCKS_PROXY_HOST";
 68 |     String EXTRA_SOCKS_PROXY_PORT = "org.torproject.android.intent.extra.SOCKS_PROXY_PORT";
 69 |     private Context mContext;
 70 |     private Set<StatusCallback> statusCallbacks = new HashSet<>();
 71 |     private BroadcastReceiver orbotStatusReceiver = new BroadcastReceiver() {
 72 |         @Override
 73 |         public void onReceive(Context c, Intent intent) {
 74 |             if (TextUtils.equals(intent.getAction(),
 75 |                     OrbotHelper.ACTION_STATUS)) {
 76 |                 for (StatusCallback cb : statusCallbacks) {
 77 |                     cb.onStatus(intent);
 78 |                 }
 79 | 
 80 |                 String status = intent.getStringExtra(EXTRA_STATUS);
 81 |                 if (TextUtils.equals(status, STATUS_ON)) {
 82 |                     int socksPort = intent.getIntExtra(EXTRA_SOCKS_PROXY_PORT, SOCKS_PROXY_PORT_DEFAULT);
 83 |                     String socksHost = intent.getStringExtra(EXTRA_SOCKS_PROXY_HOST);
 84 |                     if (TextUtils.isEmpty(socksHost))
 85 |                         socksHost = "127.0.0.1";
 86 |                     for (StatusCallback cb : statusCallbacks) {
 87 |                         cb.onOrbotReady(intent, socksHost, socksPort);
 88 |                     }
 89 |                 } else if (TextUtils.equals(status, STATUS_STARTS_DISABLED)) {
 90 |                     for (StatusCallback cb : statusCallbacks)
 91 |                         cb.onDisabled(intent);
 92 |                 }
 93 | 
 94 |             }
 95 |         }
 96 |     };
 97 | 
 98 |     private OrbotHelper() {
 99 | 
100 |     }
101 | 
102 |     public static OrbotHelper get(OpenVPNService mOpenVPNService) {
103 |         if (mInstance == null)
104 |             mInstance = new OrbotHelper();
105 |         return mInstance;
106 |     }
107 | 
108 |     /**
109 |      * Gets an {@link Intent} for starting Orbot.  Orbot will reply with the
110 |      * current status to the {@code packageName} of the app in the provided
111 |      * {@link Context} (i.e.  {@link Context#getPackageName()}.
112 |      */
113 |     public static Intent getOrbotStartIntent(Context context) {
114 |         Intent intent = new Intent(ACTION_START);
115 |         intent.setPackage(ORBOT_PACKAGE_NAME);
116 |         intent.putExtra(EXTRA_PACKAGE_NAME, context.getPackageName());
117 |         return intent;
118 |     }
119 | 
120 |     public static boolean checkTorReceier(Context c) {
121 |         Intent startOrbot = getOrbotStartIntent(c);
122 |         PackageManager pm = c.getPackageManager();
123 |         Intent result = null;
124 |         List<ResolveInfo> receivers =
125 |                 pm.queryBroadcastReceivers(startOrbot, 0);
126 | 
127 |         return receivers != null && receivers.size() > 0;
128 |     }
129 | 
130 |     /**
131 |      * Adds a StatusCallback to be called when we find out that
132 |      * Orbot is ready. If Orbot is ready for use, your callback
133 |      * will be called with onEnabled() immediately, before this
134 |      * method returns.
135 |      *
136 |      * @param cb a callback
137 |      * @return the singleton, for chaining
138 |      */
139 |     public synchronized OrbotHelper addStatusCallback(Context c, StatusCallback cb) {
140 |         if (statusCallbacks.size() == 0) {
141 |             c.getApplicationContext().registerReceiver(orbotStatusReceiver,
142 |                     new IntentFilter(OrbotHelper.ACTION_STATUS));
143 |             mContext = c.getApplicationContext();
144 |         }
145 |         if (!checkTorReceier(c))
146 |             cb.onNotYetInstalled();
147 |         statusCallbacks.add(cb);
148 |         return (this);
149 |     }
150 | 
151 |     /**
152 |      * Removes an existing registered StatusCallback.
153 |      *
154 |      * @param cb the callback to remove
155 |      * @return the singleton, for chaining
156 |      */
157 |     public synchronized void removeStatusCallback(StatusCallback cb) {
158 |         statusCallbacks.remove(cb);
159 |         if (statusCallbacks.size() == 0)
160 |             mContext.unregisterReceiver(orbotStatusReceiver);
161 |     }
162 | 
163 |     public void sendOrbotStartAndStatusBroadcast() {
164 |         mContext.sendBroadcast(getOrbotStartIntent(mContext));
165 |     }
166 | 
167 |     private void startOrbotService(String action) {
168 |         Intent clearVPNMode = new Intent();
169 |         clearVPNMode.setComponent(new ComponentName(ORBOT_PACKAGE_NAME, ".service.TorService"));
170 |         clearVPNMode.setAction(action);
171 |         mContext.startService(clearVPNMode);
172 |     }
173 | 
174 |     public interface StatusCallback {
175 |         /**
176 |          * Called when Orbot is operational
177 |          *
178 |          * @param statusIntent an Intent containing information about
179 |          *                     Orbot, including proxy ports
180 |          */
181 |         void onStatus(Intent statusIntent);
182 | 
183 | 
184 |         /**
185 |          * Called if Orbot is not yet installed. Usually, you handle
186 |          * this by checking the return value from init() on OrbotInitializer
187 |          * or calling isInstalled() on OrbotInitializer. However, if
188 |          * you have need for it, if a callback is registered before
189 |          * an init() call determines that Orbot is not installed, your
190 |          * callback will be called with onNotYetInstalled().
191 |          */
192 |         void onNotYetInstalled();
193 | 
194 |         void onOrbotReady(Intent intent, String socksHost, int socksPort);
195 | 
196 |         /**
197 |          * Called if Orbot background control is disabled.
198 |          * @param intent the intent delivered
199 |          */
200 |         void onDisabled(Intent intent);
201 |     }
202 | }
203 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/PRNGFixes.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;/*
  7 |  * This software is provided 'as-is', without any express or implied
  8 |  * warranty.  In no event will Google be held liable for any damages
  9 |  * arising from the use of this software.
 10 |  *
 11 |  * Permission is granted to anyone to use this software for any purpose,
 12 |  * including commercial applications, and to alter it and redistribute it
 13 |  * freely, as long as the origin is not misrepresented.
 14 |  */
 15 | 
 16 | import android.os.Build;
 17 | import android.os.Process;
 18 | import android.util.Log;
 19 | 
 20 | import java.io.ByteArrayOutputStream;
 21 | import java.io.DataInputStream;
 22 | import java.io.DataOutputStream;
 23 | import java.io.File;
 24 | import java.io.FileInputStream;
 25 | import java.io.FileOutputStream;
 26 | import java.io.IOException;
 27 | import java.io.OutputStream;
 28 | import java.io.UnsupportedEncodingException;
 29 | import java.security.NoSuchAlgorithmException;
 30 | import java.security.Provider;
 31 | import java.security.SecureRandom;
 32 | import java.security.SecureRandomSpi;
 33 | import java.security.Security;
 34 | 
 35 | /**
 36 |  * Fixes for the output of the default PRNG having low entropy.
 37 |  *
 38 |  * The fixes need to be applied via {@link #apply()} before any use of Java
 39 |  * Cryptography Architecture primitives. A good place to invoke them is in the
 40 |  * application's {@code onCreate}.
 41 |  */
 42 | public final class PRNGFixes {
 43 | 
 44 |     private static final int VERSION_CODE_JELLY_BEAN = 16;
 45 |     private static final int VERSION_CODE_JELLY_BEAN_MR2 = 18;
 46 |     private static final byte[] BUILD_FINGERPRINT_AND_DEVICE_SERIAL =
 47 |             getBuildFingerprintAndDeviceSerial();
 48 | 
 49 |     /** Hidden constructor to prevent instantiation. */
 50 |     private PRNGFixes() {}
 51 | 
 52 |     /**
 53 |      * Applies all fixes.
 54 |      *
 55 |      * @throws SecurityException if a fix is needed but could not be applied.
 56 |      */
 57 |     public static void apply() {
 58 |         applyOpenSSLFix();
 59 |         installLinuxPRNGSecureRandom();
 60 |     }
 61 | 
 62 |     /**
 63 |      * Applies the fix for OpenSSL PRNG having low entropy. Does nothing if the
 64 |      * fix is not needed.
 65 |      *
 66 |      * @throws SecurityException if the fix is needed but could not be applied.
 67 |      */
 68 |     private static void applyOpenSSLFix() throws SecurityException {
 69 |         if ((Build.VERSION.SDK_INT < VERSION_CODE_JELLY_BEAN)
 70 |                 || (Build.VERSION.SDK_INT > VERSION_CODE_JELLY_BEAN_MR2)) {
 71 |             // No need to apply the fix
 72 |             return;
 73 |         }
 74 | 
 75 |         try {
 76 |             // Mix in the device- and invocation-specific seed.
 77 |             Class.forName("org.apache.harmony.xnet.provider.jsse.NativeCrypto")
 78 |                     .getMethod("RAND_seed", byte[].class)
 79 |                     .invoke(null, generateSeed());
 80 | 
 81 |             // Mix output of Linux PRNG into OpenSSL's PRNG
 82 |             int bytesRead = (Integer) Class.forName(
 83 |                     "org.apache.harmony.xnet.provider.jsse.NativeCrypto")
 84 |                     .getMethod("RAND_load_file", String.class, long.class)
 85 |                     .invoke(null, "/dev/urandom", 1024);
 86 |             if (bytesRead != 1024) {
 87 |                 throw new IOException(
 88 |                         "Unexpected number of bytes read from Linux PRNG: "
 89 |                                 + bytesRead);
 90 |             }
 91 |         } catch (Exception e) {
 92 |             throw new SecurityException("Failed to seed OpenSSL PRNG", e);
 93 |         }
 94 |     }
 95 | 
 96 |     /**
 97 |      * Installs a Linux PRNG-backed {@code SecureRandom} implementation as the
 98 |      * default. Does nothing if the implementation is already the default or if
 99 |      * there is not need to install the implementation.
100 |      *
101 |      * @throws SecurityException if the fix is needed but could not be applied.
102 |      */
103 |     private static void installLinuxPRNGSecureRandom()
104 |             throws SecurityException {
105 |         if (Build.VERSION.SDK_INT > VERSION_CODE_JELLY_BEAN_MR2) {
106 |             // No need to apply the fix
107 |             return;
108 |         }
109 | 
110 |         // Install a Linux PRNG-based SecureRandom implementation as the
111 |         // default, if not yet installed.
112 |         Provider[] secureRandomProviders =
113 |                 Security.getProviders("SecureRandom.SHA1PRNG");
114 |         if ((secureRandomProviders == null)
115 |                 || (secureRandomProviders.length < 1)
116 |                 || (!LinuxPRNGSecureRandomProvider.class.equals(
117 |                 secureRandomProviders[0].getClass()))) {
118 |             Security.insertProviderAt(new LinuxPRNGSecureRandomProvider(), 1);
119 |         }
120 | 
121 |         // Assert that new SecureRandom() and
122 |         // SecureRandom.getInstance("SHA1PRNG") return a SecureRandom backed
123 |         // by the Linux PRNG-based SecureRandom implementation.
124 |         SecureRandom rng1 = new SecureRandom();
125 |         if (!LinuxPRNGSecureRandomProvider.class.equals(
126 |                 rng1.getProvider().getClass())) {
127 |             throw new SecurityException(
128 |                     "new SecureRandom() backed by wrong Provider: "
129 |                             + rng1.getProvider().getClass());
130 |         }
131 | 
132 |         SecureRandom rng2;
133 |         try {
134 |             rng2 = SecureRandom.getInstance("SHA1PRNG");
135 |         } catch (NoSuchAlgorithmException e) {
136 |             throw new SecurityException("SHA1PRNG not available", e);
137 |         }
138 |         if (!LinuxPRNGSecureRandomProvider.class.equals(
139 |                 rng2.getProvider().getClass())) {
140 |             throw new SecurityException(
141 |                     "SecureRandom.getInstance(\"SHA1PRNG\") backed by wrong"
142 |                             + " Provider: " + rng2.getProvider().getClass());
143 |         }
144 |     }
145 | 
146 |     /**
147 |      * {@code Provider} of {@code SecureRandom} engines which pass through
148 |      * all requests to the Linux PRNG.
149 |      */
150 |     private static class LinuxPRNGSecureRandomProvider extends Provider {
151 | 
152 |         public LinuxPRNGSecureRandomProvider() {
153 |             super("LinuxPRNG",
154 |                     1.0,
155 |                     "A Linux-specific random number provider that uses"
156 |                             + " /dev/urandom");
157 |             // Although /dev/urandom is not a SHA-1 PRNG, some apps
158 |             // explicitly request a SHA1PRNG SecureRandom and we thus need to
159 |             // prevent them from getting the default implementation whose output
160 |             // may have low entropy.
161 |             put("SecureRandom.SHA1PRNG", LinuxPRNGSecureRandom.class.getName());
162 |             put("SecureRandom.SHA1PRNG ImplementedIn", "Software");
163 |         }
164 |     }
165 | 
166 |     /**
167 |      * {@link SecureRandomSpi} which passes all requests to the Linux PRNG
168 |      * ({@code /dev/urandom}).
169 |      */
170 |     public static class LinuxPRNGSecureRandom extends SecureRandomSpi {
171 | 
172 |         /*
173 |          * IMPLEMENTATION NOTE: Requests to generate bytes and to mix in a seed
174 |          * are passed through to the Linux PRNG (/dev/urandom). Instances of
175 |          * this class seed themselves by mixing in the current time, PID, UID,
176 |          * build fingerprint, and hardware serial number (where available) into
177 |          * Linux PRNG.
178 |          *
179 |          * Concurrency: Read requests to the underlying Linux PRNG are
180 |          * serialized (on sLock) to ensure that multiple threads do not get
181 |          * duplicated PRNG output.
182 |          */
183 | 
184 |         private static final File URANDOM_FILE = new File("/dev/urandom");
185 | 
186 |         private static final Object sLock = new Object();
187 | 
188 |         /**
189 |          * Input stream for reading from Linux PRNG or {@code null} if not yet
190 |          * opened.
191 |          *
192 |          * @GuardedBy("sLock")
193 |          */
194 |         private static DataInputStream sUrandomIn;
195 | 
196 |         /**
197 |          * Output stream for writing to Linux PRNG or {@code null} if not yet
198 |          * opened.
199 |          *
200 |          * @GuardedBy("sLock")
201 |          */
202 |         private static OutputStream sUrandomOut;
203 | 
204 |         /**
205 |          * Whether this engine instance has been seeded. This is needed because
206 |          * each instance needs to seed itself if the client does not explicitly
207 |          * seed it.
208 |          */
209 |         private boolean mSeeded;
210 | 
211 |         @Override
212 |         protected void engineSetSeed(byte[] bytes) {
213 |             try {
214 |                 OutputStream out;
215 |                 synchronized (sLock) {
216 |                     out = getUrandomOutputStream();
217 |                 }
218 |                 out.write(bytes);
219 |                 out.flush();
220 |             } catch (IOException e) {
221 |                 // On a small fraction of devices /dev/urandom is not writable.
222 |                 // Log and ignore.
223 |                 Log.w(PRNGFixes.class.getSimpleName(),
224 |                         "Failed to mix seed into " + URANDOM_FILE);
225 |             } finally {
226 |                 mSeeded = true;
227 |             }
228 |         }
229 | 
230 |         @Override
231 |         protected void engineNextBytes(byte[] bytes) {
232 |             if (!mSeeded) {
233 |                 // Mix in the device- and invocation-specific seed.
234 |                 engineSetSeed(generateSeed());
235 |             }
236 | 
237 |             try {
238 |                 DataInputStream in;
239 |                 synchronized (sLock) {
240 |                     in = getUrandomInputStream();
241 |                 }
242 |                 synchronized (in) {
243 |                     in.readFully(bytes);
244 |                 }
245 |             } catch (IOException e) {
246 |                 throw new SecurityException(
247 |                         "Failed to read from " + URANDOM_FILE, e);
248 |             }
249 |         }
250 | 
251 |         @Override
252 |         protected byte[] engineGenerateSeed(int size) {
253 |             byte[] seed = new byte[size];
254 |             engineNextBytes(seed);
255 |             return seed;
256 |         }
257 | 
258 |         private DataInputStream getUrandomInputStream() {
259 |             synchronized (sLock) {
260 |                 if (sUrandomIn == null) {
261 |                     // NOTE: Consider inserting a BufferedInputStream between
262 |                     // DataInputStream and FileInputStream if you need higher
263 |                     // PRNG output performance and can live with future PRNG
264 |                     // output being pulled into this process prematurely.
265 |                     try {
266 |                         sUrandomIn = new DataInputStream(
267 |                                 new FileInputStream(URANDOM_FILE));
268 |                     } catch (IOException e) {
269 |                         throw new SecurityException("Failed to open "
270 |                                 + URANDOM_FILE + " for reading", e);
271 |                     }
272 |                 }
273 |                 return sUrandomIn;
274 |             }
275 |         }
276 | 
277 |         private OutputStream getUrandomOutputStream() throws IOException {
278 |             synchronized (sLock) {
279 |                 if (sUrandomOut == null) {
280 |                     sUrandomOut = new FileOutputStream(URANDOM_FILE);
281 |                 }
282 |                 return sUrandomOut;
283 |             }
284 |         }
285 |     }
286 | 
287 |     /**
288 |      * Generates a device- and invocation-specific seed to be mixed into the
289 |      * Linux PRNG.
290 |      */
291 |     private static byte[] generateSeed() {
292 |         try {
293 |             ByteArrayOutputStream seedBuffer = new ByteArrayOutputStream();
294 |             DataOutputStream seedBufferOut =
295 |                     new DataOutputStream(seedBuffer);
296 |             seedBufferOut.writeLong(System.currentTimeMillis());
297 |             seedBufferOut.writeLong(System.nanoTime());
298 |             seedBufferOut.writeInt(Process.myPid());
299 |             seedBufferOut.writeInt(Process.myUid());
300 |             seedBufferOut.write(BUILD_FINGERPRINT_AND_DEVICE_SERIAL);
301 |             seedBufferOut.close();
302 |             return seedBuffer.toByteArray();
303 |         } catch (IOException e) {
304 |             throw new SecurityException("Failed to generate seed", e);
305 |         }
306 |     }
307 | 
308 |     /**
309 |      * Gets the hardware serial number of this device.
310 |      *
311 |      * @return serial number or {@code null} if not available.
312 |      */
313 |     private static String getDeviceSerialNumber() {
314 |         // We're using the Reflection API because Build.SERIAL is only available
315 |         // since API Level 9 (Gingerbread, Android 2.3).
316 |         try {
317 |             return (String) Build.class.getField("SERIAL").get(null);
318 |         } catch (Exception ignored) {
319 |             return null;
320 |         }
321 |     }
322 | 
323 |     private static byte[] getBuildFingerprintAndDeviceSerial() {
324 |         StringBuilder result = new StringBuilder();
325 |         String fingerprint = Build.FINGERPRINT;
326 |         if (fingerprint != null) {
327 |             result.append(fingerprint);
328 |         }
329 |         String serial = getDeviceSerialNumber();
330 |         if (serial != null) {
331 |             result.append(serial);
332 |         }
333 |         try {
334 |             return result.toString().getBytes("UTF-8");
335 |         } catch (UnsupportedEncodingException e) {
336 |             throw new RuntimeException("UTF-8 encoding not supported");
337 |         }
338 |     }
339 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/PasswordCache.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import java.util.UUID;
 9 | 
10 | /**
11 |  * Created by arne on 15.12.16.
12 |  */
13 | 
14 | public class PasswordCache {
15 |     public static final int PCKS12ORCERTPASSWORD = 2;
16 |     public static final int AUTHPASSWORD = 3;
17 |     private static PasswordCache mInstance;
18 |     final private UUID mUuid;
19 |     private String mKeyOrPkcs12Password;
20 |     private String mAuthPassword;
21 | 
22 |     private PasswordCache(UUID uuid) {
23 |         mUuid = uuid;
24 |     }
25 | 
26 |     public static PasswordCache getInstance(UUID uuid) {
27 |         if (mInstance == null || !mInstance.mUuid.equals(uuid)) {
28 |             mInstance = new PasswordCache(uuid);
29 |         }
30 |         return mInstance;
31 |     }
32 | 
33 |     public static String getPKCS12orCertificatePassword(UUID uuid, boolean resetPw) {
34 |         String pwcopy = getInstance(uuid).mKeyOrPkcs12Password;
35 |         if (resetPw)
36 |             getInstance(uuid).mKeyOrPkcs12Password = null;
37 |         return pwcopy;
38 |     }
39 | 
40 | 
41 |     public static String getAuthPassword(UUID uuid, boolean resetPW) {
42 |         String pwcopy = getInstance(uuid).mAuthPassword;
43 |         if (resetPW)
44 |             getInstance(uuid).mAuthPassword = null;
45 |         return pwcopy;
46 |     }
47 | 
48 |     public static void setCachedPassword(String uuid, int type, String password) {
49 |         PasswordCache instance = getInstance(UUID.fromString(uuid));
50 |         switch (type) {
51 |             case PCKS12ORCERTPASSWORD:
52 |                 instance.mKeyOrPkcs12Password = password;
53 |                 break;
54 |             case AUTHPASSWORD:
55 |                 instance.mAuthPassword = password;
56 |                 break;
57 |         }
58 |     }
59 | 
60 | 
61 | }
62 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/Preferences.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import android.content.Context;
 9 | import android.content.SharedPreferences;
10 | 
11 | /**
12 |  * Created by arne on 08.01.17.
13 |  */
14 | 
15 | // Until I find a good solution
16 | 
17 | public class Preferences {
18 | 
19 |     static SharedPreferences getSharedPreferencesMulti(String name, Context c) {
20 |         return c.getSharedPreferences(name, Context.MODE_MULTI_PROCESS | Context.MODE_PRIVATE);
21 | 
22 |     }
23 | 
24 | 
25 |     public static SharedPreferences getDefaultSharedPreferences(Context c) {
26 |         return c.getSharedPreferences(c.getPackageName() + "_preferences", Context.MODE_MULTI_PROCESS | Context.MODE_PRIVATE);
27 | 
28 |     }
29 | 
30 | 
31 | }
32 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ProfileManager.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.app.Activity;
  9 | import android.content.Context;
 10 | import android.content.SharedPreferences;
 11 | import android.content.SharedPreferences.Editor;
 12 | 
 13 | import java.io.IOException;
 14 | import java.io.ObjectInputStream;
 15 | import java.io.ObjectOutputStream;
 16 | import java.util.Collection;
 17 | import java.util.HashMap;
 18 | import java.util.HashSet;
 19 | import java.util.Locale;
 20 | import java.util.Set;
 21 | import java.util.UUID;
 22 | 
 23 | import de.blinkt.openvpn.VpnProfile;
 24 | 
 25 | public class ProfileManager {
 26 |     private static final String PREFS_NAME = "VPNList";
 27 | 
 28 |     private static final String LAST_CONNECTED_PROFILE = "lastConnectedProfile";
 29 |     private static final String TEMPORARY_PROFILE_FILENAME = "temporary-vpn-profile";
 30 |     private static ProfileManager instance;
 31 | 
 32 |     private static VpnProfile mLastConnectedVpn = null;
 33 |     private HashMap<String, VpnProfile> profiles = new HashMap<>();
 34 |     private static VpnProfile tmpprofile = null;
 35 | 
 36 | 
 37 |     private static VpnProfile get(String key) {
 38 |         if (tmpprofile != null && tmpprofile.getUUIDString().equals(key))
 39 |             return tmpprofile;
 40 | 
 41 |         if (instance == null)
 42 |             return null;
 43 |         return instance.profiles.get(key);
 44 | 
 45 |     }
 46 | 
 47 | 
 48 |     private ProfileManager() {
 49 |     }
 50 | 
 51 |     private static void checkInstance(Context context) {
 52 |         if (instance == null) {
 53 |             instance = new ProfileManager();
 54 |             instance.loadVPNList(context);
 55 |         }
 56 |     }
 57 | 
 58 |     synchronized public static ProfileManager getInstance(Context context) {
 59 |         checkInstance(context);
 60 |         return instance;
 61 |     }
 62 | 
 63 |     public static void setConntectedVpnProfileDisconnected(Context c) {
 64 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(c);
 65 |         Editor prefsedit = prefs.edit();
 66 |         prefsedit.putString(LAST_CONNECTED_PROFILE, null);
 67 |         prefsedit.apply();
 68 | 
 69 |     }
 70 | 
 71 |     /**
 72 |      * Sets the profile that is connected (to connect if the service restarts)
 73 |      */
 74 |     public static void setConnectedVpnProfile(Context c, VpnProfile connectedProfile) {
 75 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(c);
 76 |         Editor prefsedit = prefs.edit();
 77 | 
 78 |         prefsedit.putString(LAST_CONNECTED_PROFILE, connectedProfile.getUUIDString());
 79 |         prefsedit.apply();
 80 |         mLastConnectedVpn = connectedProfile;
 81 | 
 82 |     }
 83 | 
 84 |     /**
 85 |      * Returns the profile that was last connected (to connect if the service restarts)
 86 |      */
 87 |     public static VpnProfile getLastConnectedProfile(Context c) {
 88 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(c);
 89 | 
 90 |         String lastConnectedProfile = prefs.getString(LAST_CONNECTED_PROFILE, null);
 91 |         if (lastConnectedProfile != null)
 92 |             return get(c, lastConnectedProfile);
 93 |         else
 94 |             return null;
 95 |     }
 96 | 
 97 | 
 98 |     public Collection<VpnProfile> getProfiles() {
 99 |         return profiles.values();
100 |     }
101 | 
102 |     public VpnProfile getProfileByName(String name) {
103 |         for (VpnProfile vpnp : profiles.values()) {
104 |             if (vpnp.getName().equals(name)) {
105 |                 return vpnp;
106 |             }
107 |         }
108 |         return null;
109 |     }
110 | 
111 |     public void saveProfileList(Context context) {
112 |         SharedPreferences sharedprefs = Preferences.getSharedPreferencesMulti(PREFS_NAME, context);
113 |         Editor editor = sharedprefs.edit();
114 |         editor.putStringSet("vpnlist", profiles.keySet());
115 | 
116 |         // For reasing I do not understand at all
117 |         // Android saves my prefs file only one time
118 |         // if I remove the debug code below :(
119 |         int counter = sharedprefs.getInt("counter", 0);
120 |         editor.putInt("counter", counter + 1);
121 |         editor.apply();
122 | 
123 |     }
124 | 
125 |     public void addProfile(VpnProfile profile) {
126 |         profiles.put(profile.getUUID().toString(), profile);
127 | 
128 |     }
129 | 
130 |     public static void setTemporaryProfile(Context c, VpnProfile tmp) {
131 |         tmp.mTemporaryProfile = true;
132 |         ProfileManager.tmpprofile = tmp;
133 |         saveProfile(c, tmp, true, true);
134 |     }
135 | 
136 |     public static boolean isTempProfile() {
137 |         return mLastConnectedVpn != null && mLastConnectedVpn  == tmpprofile;
138 |     }
139 | 
140 |     public void saveProfile(Context context, VpnProfile profile) {
141 |         saveProfile(context, profile, true, false);
142 |     }
143 | 
144 |     private static void saveProfile(Context context, VpnProfile profile, boolean updateVersion, boolean isTemporary) {
145 | 
146 |         if (updateVersion)
147 |             profile.mVersion += 1;
148 |         ObjectOutputStream vpnFile;
149 | 
150 |         String filename = profile.getUUID().toString() + ".vp";
151 |         if (isTemporary)
152 |             filename = TEMPORARY_PROFILE_FILENAME + ".vp";
153 | 
154 |         try {
155 |             vpnFile = new ObjectOutputStream(context.openFileOutput(filename, Activity.MODE_PRIVATE));
156 | 
157 |             vpnFile.writeObject(profile);
158 |             vpnFile.flush();
159 |             vpnFile.close();
160 |         } catch (IOException e) {
161 |             VpnStatus.logException("saving VPN profile", e);
162 |             throw new RuntimeException(e);
163 |         }
164 |     }
165 | 
166 | 
167 |     private void loadVPNList(Context context) {
168 |         profiles = new HashMap<>();
169 |         SharedPreferences listpref = Preferences.getSharedPreferencesMulti(PREFS_NAME, context);
170 |         Set<String> vlist = listpref.getStringSet("vpnlist", null);
171 |         if (vlist == null) {
172 |             vlist = new HashSet<>();
173 |         }
174 |         // Always try to load the temporary profile
175 |         vlist.add(TEMPORARY_PROFILE_FILENAME);
176 | 
177 |         for (String vpnentry : vlist) {
178 |             ObjectInputStream vpnfile=null;
179 |             try {
180 |                  vpnfile = new ObjectInputStream(context.openFileInput(vpnentry + ".vp"));
181 |                 VpnProfile vp = ((VpnProfile) vpnfile.readObject());
182 | 
183 |                 // Sanity check
184 |                 if (vp == null || vp.mName == null || vp.getUUID() == null)
185 |                     continue;
186 | 
187 |                 vp.upgradeProfile();
188 |                 if (vpnentry.equals(TEMPORARY_PROFILE_FILENAME)) {
189 |                     tmpprofile = vp;
190 |                 } else {
191 |                     profiles.put(vp.getUUID().toString(), vp);
192 |                 }
193 | 
194 | 
195 |             } catch (IOException | ClassNotFoundException e) {
196 |                 if (!vpnentry.equals(TEMPORARY_PROFILE_FILENAME))
197 |                     VpnStatus.logException("Loading VPN List", e);
198 |             } finally {
199 |                 if (vpnfile!=null) {
200 |                     try {
201 |                         vpnfile.close();
202 |                     } catch (IOException e) {
203 |                         e.printStackTrace();
204 |                     }
205 |                 }
206 |             }
207 |         }
208 |     }
209 | 
210 | 
211 |     public void removeProfile(Context context, VpnProfile profile) {
212 |         String vpnentry = profile.getUUID().toString();
213 |         profiles.remove(vpnentry);
214 |         saveProfileList(context);
215 |         context.deleteFile(vpnentry + ".vp");
216 |         if (mLastConnectedVpn == profile)
217 |             mLastConnectedVpn = null;
218 | 
219 |     }
220 | 
221 |     public static VpnProfile get(Context context, String profileUUID) {
222 |         return get(context, profileUUID, 0, 10);
223 |     }
224 | 
225 |     public static VpnProfile get(Context context, String profileUUID, int version, int tries) {
226 |         checkInstance(context);
227 |         VpnProfile profile = get(profileUUID);
228 |         int tried = 0;
229 |         while ((profile == null || profile.mVersion < version) && (tried++ < tries)) {
230 |             try {
231 |                 Thread.sleep(100);
232 |             } catch (InterruptedException ignored) {
233 |             }
234 |             instance.loadVPNList(context);
235 |             profile = get(profileUUID);
236 |             int ver = profile == null ? -1 : profile.mVersion;
237 |         }
238 | 
239 |         if (tried > 5)
240 | 
241 |         {
242 |             int ver = profile == null ? -1 : profile.mVersion;
243 |             VpnStatus.logError(String.format(Locale.US, "Used x %d tries to get current version (%d/%d) of the profile", tried, ver, version));
244 |         }
245 |         return profile;
246 |     }
247 | 
248 |     public static VpnProfile getLastConnectedVpn() {
249 |         return mLastConnectedVpn;
250 |     }
251 | 
252 |     public static VpnProfile getAlwaysOnVPN(Context context) {
253 |         checkInstance(context);
254 |         SharedPreferences prefs = Preferences.getDefaultSharedPreferences(context);
255 | 
256 |         String uuid = prefs.getString("alwaysOnVpn", null);
257 |         return get(uuid);
258 | 
259 |     }
260 | 
261 |     public static void updateLRU(Context c, VpnProfile profile) {
262 |         profile.mLastUsed = System.currentTimeMillis();
263 |         // LRU does not change the profile, no need for the service to refresh
264 |         if (profile!=tmpprofile)
265 |             saveProfile(c, profile, false, false);
266 |     }
267 | }
268 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/ProxyDetection.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package de.blinkt.openvpn.core;
 7 | 
 8 | import java.net.InetSocketAddress;
 9 | import java.net.MalformedURLException;
10 | import java.net.Proxy;
11 | import java.net.ProxySelector;
12 | import java.net.SocketAddress;
13 | import java.net.URISyntaxException;
14 | import java.net.URL;
15 | import java.util.List;
16 | 
17 | import de.blinkt.openvpn.R;
18 | import de.blinkt.openvpn.VpnProfile;
19 | 
20 | public class ProxyDetection {
21 | 	static SocketAddress detectProxy(VpnProfile vp) {
22 | 		// Construct a new url with https as protocol
23 | 		try {
24 | 			URL url = new URL(String.format("https://%s:%s",vp.mServerName,vp.mServerPort));
25 | 			Proxy proxy = getFirstProxy(url);
26 | 
27 | 			if(proxy==null)
28 | 				return null;
29 | 			SocketAddress addr = proxy.address();
30 | 			if (addr instanceof InetSocketAddress) {
31 | 				return addr; 
32 | 			}
33 | 			
34 | 		} catch (MalformedURLException e) {
35 | 			VpnStatus.logError(R.string.getproxy_error, e.getLocalizedMessage());
36 | 		} catch (URISyntaxException e) {
37 | 			VpnStatus.logError(R.string.getproxy_error, e.getLocalizedMessage());
38 | 		}
39 | 		return null;
40 | 	}
41 | 
42 | 	static Proxy getFirstProxy(URL url) throws URISyntaxException {
43 | 		System.setProperty("java.net.useSystemProxies", "true");
44 | 
45 | 		List<Proxy> proxylist = ProxySelector.getDefault().select(url.toURI());
46 | 
47 | 
48 | 		if (proxylist != null) {
49 | 			for (Proxy proxy: proxylist) {
50 | 				SocketAddress addr = proxy.address();
51 | 
52 | 				if (addr != null) {
53 | 					return proxy;
54 | 				}
55 | 			}
56 | 
57 | 		}
58 | 		return null;
59 | 	}
60 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/StatusListener.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.app.PendingIntent;
  9 | import android.content.ComponentName;
 10 | import android.content.Context;
 11 | import android.content.Intent;
 12 | import android.content.ServiceConnection;
 13 | import android.os.IBinder;
 14 | import android.os.ParcelFileDescriptor;
 15 | import android.os.RemoteException;
 16 | import android.util.Log;
 17 | import de.blinkt.openvpn.BuildConfig;
 18 | import de.blinkt.openvpn.core.VpnStatus.LogLevel;
 19 | 
 20 | import java.io.DataInputStream;
 21 | import java.io.File;
 22 | import java.io.IOException;
 23 | 
 24 | /**
 25 |  * Created by arne on 09.11.16.
 26 |  */
 27 | 
 28 | public class StatusListener implements VpnStatus.LogListener {
 29 |     private File mCacheDir;
 30 |     private Context mContext;
 31 |     private IStatusCallbacks mCallback = new IStatusCallbacks.Stub() {
 32 |         @Override
 33 |         public void newLogItem(LogItem item) throws RemoteException {
 34 |             VpnStatus.newLogItem(item);
 35 |         }
 36 | 
 37 |         @Override
 38 |         public void updateStateString(String state, String msg, int resid, ConnectionStatus
 39 |                 level, Intent intent) throws RemoteException {
 40 |             VpnStatus.updateStateString(state, msg, resid, level, intent);
 41 |         }
 42 | 
 43 |         @Override
 44 |         public void updateByteCount(long inBytes, long outBytes) throws RemoteException {
 45 |             VpnStatus.updateByteCount(inBytes, outBytes);
 46 |         }
 47 | 
 48 |         @Override
 49 |         public void connectedVPN(String uuid) throws RemoteException {
 50 |             VpnStatus.setConnectedVPNProfile(uuid);
 51 |         }
 52 |     };
 53 |     private ServiceConnection mConnection = new ServiceConnection() {
 54 | 
 55 | 
 56 |         @Override
 57 |         public void onServiceConnected(ComponentName className,
 58 |                                        IBinder service) {
 59 |             // We've bound to LocalService, cast the IBinder and get LocalService instance
 60 |             IServiceStatus serviceStatus = IServiceStatus.Stub.asInterface(service);
 61 |             try {
 62 |                 /* Check if this a local service ... */
 63 |                 if (service.queryLocalInterface("de.blinkt.openvpn.core.IServiceStatus") == null) {
 64 |                     // Not a local service
 65 |                     VpnStatus.setConnectedVPNProfile(serviceStatus.getLastConnectedVPN());
 66 |                     VpnStatus.setTrafficHistory(serviceStatus.getTrafficHistory());
 67 |                     ParcelFileDescriptor pfd = serviceStatus.registerStatusCallback(mCallback);
 68 |                     DataInputStream fd = new DataInputStream(new ParcelFileDescriptor.AutoCloseInputStream(pfd));
 69 | 
 70 |                     short len = fd.readShort();
 71 |                     byte[] buf = new byte[65336];
 72 |                     while (len != 0x7fff) {
 73 |                         fd.readFully(buf, 0, len);
 74 |                         LogItem logitem = new LogItem(buf, len);
 75 |                         VpnStatus.newLogItem(logitem, false);
 76 |                         len = fd.readShort();
 77 |                     }
 78 |                     fd.close();
 79 | 
 80 | 
 81 |                 } else {
 82 |                     VpnStatus.initLogCache(mCacheDir);
 83 |                     /* Set up logging to Logcat with a context) */
 84 | 
 85 |                     if (BuildConfig.DEBUG) {
 86 |                         VpnStatus.addLogListener(StatusListener.this);
 87 |                     }
 88 | 
 89 | 
 90 |                 }
 91 | 
 92 |             } catch (RemoteException | IOException e) {
 93 |                 e.printStackTrace();
 94 |                 VpnStatus.logException(e);
 95 |             }
 96 |         }
 97 | 
 98 |         @Override
 99 |         public void onServiceDisconnected(ComponentName arg0) {
100 |             VpnStatus.removeLogListener(StatusListener.this);
101 |         }
102 | 
103 |     };
104 | 
105 |     void init(Context c) {
106 | 
107 |         Intent intent = new Intent(c, OpenVPNStatusService.class);
108 |         intent.setAction(OpenVPNService.START_SERVICE);
109 |         mCacheDir = c.getCacheDir();
110 | 
111 |         c.bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
112 |         this.mContext = c;
113 | 
114 |     }
115 | 
116 |     @Override
117 |     public void newLog(LogItem logItem) {
118 |         switch (logItem.getLogLevel()) {
119 |             case INFO:
120 |                 Log.i("OpenVPN", logItem.getString(mContext));
121 |                 break;
122 |             case DEBUG:
123 |                 Log.d("OpenVPN", logItem.getString(mContext));
124 |                 break;
125 |             case ERROR:
126 |                 Log.e("OpenVPN", logItem.getString(mContext));
127 |                 break;
128 |             case VERBOSE:
129 |                 Log.v("OpenVPN", logItem.getString(mContext));
130 |                 break;
131 |             case WARNING:
132 |             default:
133 |                 Log.w("OpenVPN", logItem.getString(mContext));
134 |                 break;
135 |         }
136 | 
137 |     }
138 | }
139 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/TrafficHistory.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2017 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.os.Parcel;
  9 | import android.os.Parcelable;
 10 | 
 11 | import java.util.HashSet;
 12 | import java.util.LinkedList;
 13 | import java.util.Vector;
 14 | 
 15 | import static java.lang.Math.max;
 16 | 
 17 | /**
 18 |  * Created by arne on 23.05.17.
 19 |  */
 20 | 
 21 | public class TrafficHistory implements Parcelable {
 22 | 
 23 |     public static final long PERIODS_TO_KEEP = 5;
 24 |     public static final int TIME_PERIOD_MINTUES = 60 * 1000;
 25 |     public static final int TIME_PERIOD_HOURS = 3600 * 1000;
 26 |     private LinkedList<TrafficDatapoint> trafficHistorySeconds = new LinkedList<>();
 27 |     private LinkedList<TrafficDatapoint> trafficHistoryMinutes = new LinkedList<>();
 28 |     private LinkedList<TrafficDatapoint> trafficHistoryHours = new LinkedList<>();
 29 | 
 30 |     private TrafficDatapoint lastSecondUsedForMinute;
 31 |     private TrafficDatapoint lastMinuteUsedForHours;
 32 | 
 33 |     public TrafficHistory() {
 34 | 
 35 |     }
 36 | 
 37 |     protected TrafficHistory(Parcel in) {
 38 |         in.readList(trafficHistorySeconds, getClass().getClassLoader());
 39 |         in.readList(trafficHistoryMinutes, getClass().getClassLoader());
 40 |         in.readList(trafficHistoryHours, getClass().getClassLoader());
 41 |         lastSecondUsedForMinute = in.readParcelable(getClass().getClassLoader());
 42 |         lastMinuteUsedForHours = in.readParcelable(getClass().getClassLoader());
 43 |     }
 44 | 
 45 |     public static final Creator<TrafficHistory> CREATOR = new Creator<TrafficHistory>() {
 46 |         @Override
 47 |         public TrafficHistory createFromParcel(Parcel in) {
 48 |             return new TrafficHistory(in);
 49 |         }
 50 | 
 51 |         @Override
 52 |         public TrafficHistory[] newArray(int size) {
 53 |             return new TrafficHistory[size];
 54 |         }
 55 |     };
 56 | 
 57 |     public LastDiff getLastDiff(TrafficDatapoint tdp) {
 58 | 
 59 |         TrafficDatapoint lasttdp;
 60 | 
 61 | 
 62 |         if (trafficHistorySeconds.size() == 0)
 63 |             lasttdp = new TrafficDatapoint(0, 0, System.currentTimeMillis());
 64 | 
 65 |         else
 66 |             lasttdp = trafficHistorySeconds.getLast();
 67 | 
 68 |         if (tdp == null) {
 69 |             tdp = lasttdp;
 70 |             if (trafficHistorySeconds.size() < 2)
 71 |                 lasttdp = tdp;
 72 |             else {
 73 |                 trafficHistorySeconds.descendingIterator().next();
 74 |                 tdp = trafficHistorySeconds.descendingIterator().next();
 75 |             }
 76 |         }
 77 | 
 78 |         return new LastDiff(lasttdp, tdp);
 79 |     }
 80 | 
 81 |     @Override
 82 |     public int describeContents() {
 83 |         return 0;
 84 |     }
 85 | 
 86 |     @Override
 87 |     public void writeToParcel(Parcel dest, int flags) {
 88 |         dest.writeList(trafficHistorySeconds);
 89 |         dest.writeList(trafficHistoryMinutes);
 90 |         dest.writeList(trafficHistoryHours);
 91 |         dest.writeParcelable(lastSecondUsedForMinute, 0);
 92 |         dest.writeParcelable(lastMinuteUsedForHours, 0);
 93 | 
 94 |     }
 95 | 
 96 |     public LinkedList<TrafficDatapoint> getHours() {
 97 |         return trafficHistoryHours;
 98 |     }
 99 | 
100 |     public LinkedList<TrafficDatapoint> getMinutes() {
101 |         return trafficHistoryMinutes;
102 |     }
103 | 
104 |     public LinkedList<TrafficDatapoint> getSeconds() {
105 |         return trafficHistorySeconds;
106 |     }
107 | 
108 |     public static LinkedList<TrafficDatapoint> getDummyList() {
109 |         LinkedList<TrafficDatapoint> list = new LinkedList<>();
110 |         list.add(new TrafficDatapoint(0, 0, System.currentTimeMillis()));
111 |         return list;
112 |     }
113 | 
114 | 
115 |     public static class TrafficDatapoint implements Parcelable {
116 |         private TrafficDatapoint(long inBytes, long outBytes, long timestamp) {
117 |             this.in = inBytes;
118 |             this.out = outBytes;
119 |             this.timestamp = timestamp;
120 |         }
121 | 
122 |         public final long timestamp;
123 |         public final long in;
124 |         public final long out;
125 | 
126 |         private TrafficDatapoint(Parcel in) {
127 |             timestamp = in.readLong();
128 |             this.in = in.readLong();
129 |             out = in.readLong();
130 |         }
131 | 
132 |         public static final Creator<TrafficDatapoint> CREATOR = new Creator<TrafficDatapoint>() {
133 |             @Override
134 |             public TrafficDatapoint createFromParcel(Parcel in) {
135 |                 return new TrafficDatapoint(in);
136 |             }
137 | 
138 |             @Override
139 |             public TrafficDatapoint[] newArray(int size) {
140 |                 return new TrafficDatapoint[size];
141 |             }
142 |         };
143 | 
144 |         @Override
145 |         public int describeContents() {
146 |             return 0;
147 |         }
148 | 
149 |         @Override
150 |         public void writeToParcel(Parcel dest, int flags) {
151 |             dest.writeLong(timestamp);
152 |             dest.writeLong(in);
153 |             dest.writeLong(out);
154 |         }
155 |     }
156 | 
157 |     LastDiff add(long in, long out) {
158 |         TrafficDatapoint tdp = new TrafficDatapoint(in, out, System.currentTimeMillis());
159 | 
160 |         LastDiff diff = getLastDiff(tdp);
161 |         addDataPoint(tdp);
162 |         return diff;
163 |     }
164 | 
165 |     private void addDataPoint(TrafficDatapoint tdp) {
166 |         trafficHistorySeconds.add(tdp);
167 | 
168 |         if (lastSecondUsedForMinute == null) {
169 |             lastSecondUsedForMinute = new TrafficDatapoint(0, 0, 0);
170 |             lastMinuteUsedForHours = new TrafficDatapoint(0, 0, 0);
171 |         }
172 | 
173 |         removeAndAverage(tdp, true);
174 |     }
175 | 
176 |     private void removeAndAverage(TrafficDatapoint newTdp, boolean seconds) {
177 |         HashSet<TrafficDatapoint> toRemove = new HashSet<>();
178 |         Vector<TrafficDatapoint> toAverage = new Vector<>();
179 | 
180 |         long timePeriod;
181 |         LinkedList<TrafficDatapoint> tpList, nextList;
182 |         TrafficDatapoint lastTsPeriod;
183 | 
184 |         if (seconds) {
185 |             timePeriod = TIME_PERIOD_MINTUES;
186 |             tpList = trafficHistorySeconds;
187 |             nextList = trafficHistoryMinutes;
188 |             lastTsPeriod = lastSecondUsedForMinute;
189 |         } else {
190 |             timePeriod = TIME_PERIOD_HOURS;
191 |             tpList = trafficHistoryMinutes;
192 |             nextList = trafficHistoryHours;
193 |             lastTsPeriod = lastMinuteUsedForHours;
194 |         }
195 | 
196 |         if (newTdp.timestamp / timePeriod > (lastTsPeriod.timestamp / timePeriod)) {
197 |             nextList.add(newTdp);
198 | 
199 |             if (seconds) {
200 |                 lastSecondUsedForMinute = newTdp;
201 |                 removeAndAverage(newTdp, false);
202 |             } else
203 |                 lastMinuteUsedForHours = newTdp;
204 | 
205 |             for (TrafficDatapoint tph : tpList) {
206 |                 // List is iteratered from oldest to newest, remembert first one that we did not
207 |                 if ((newTdp.timestamp - tph.timestamp) / timePeriod >= PERIODS_TO_KEEP)
208 |                     toRemove.add(tph);
209 |             }
210 |             tpList.removeAll(toRemove);
211 |         }
212 |     }
213 | 
214 |     static class LastDiff {
215 | 
216 |         final private TrafficDatapoint tdp;
217 |         final private TrafficDatapoint lasttdp;
218 | 
219 |         private LastDiff(TrafficDatapoint lasttdp, TrafficDatapoint tdp) {
220 |             this.lasttdp = lasttdp;
221 |             this.tdp = tdp;
222 |         }
223 | 
224 |         public long getDiffOut() {
225 |             return max(0, tdp.out - lasttdp.out);
226 |         }
227 | 
228 |         public long getDiffIn() {
229 |             return max(0, tdp.in - lasttdp.in);
230 |         }
231 | 
232 |         public long getIn() {
233 |             return tdp.in;
234 |         }
235 | 
236 |         public long getOut() {
237 |             return tdp.out;
238 |         }
239 | 
240 |     }
241 | 
242 | 
243 | }


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/VPNLaunchHelper.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.annotation.TargetApi;
  9 | import android.content.Context;
 10 | import android.content.Intent;
 11 | import android.os.Build;
 12 | 
 13 | import java.io.File;
 14 | import java.io.FileOutputStream;
 15 | import java.io.IOException;
 16 | import java.io.InputStream;
 17 | import java.util.Arrays;
 18 | import java.util.Vector;
 19 | 
 20 | import de.blinkt.openvpn.R;
 21 | import de.blinkt.openvpn.VpnProfile;
 22 | 
 23 | public class VPNLaunchHelper {
 24 |     private static final String MININONPIEVPN = "nopie_openvpn";
 25 |     private static final String MINIPIEVPN = "pie_openvpn";
 26 |     private static final String OVPNCONFIGFILE = "android.conf";
 27 | 
 28 | 
 29 |     private static String writeMiniVPN(Context context) {
 30 |         String nativeAPI = NativeUtils.getNativeAPI();
 31 |         /* Q does not allow executing binaries written in temp directory anymore */
 32 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
 33 |             return new File(context.getApplicationInfo().nativeLibraryDir, "libovpnexec.so").getPath();
 34 |         String[] abis;
 35 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
 36 |             abis = getSupportedABIsLollipop();
 37 |         else
 38 |             //noinspection deprecation
 39 |             abis = new String[]{Build.CPU_ABI, Build.CPU_ABI2};
 40 | 
 41 |         if (!nativeAPI.equals(abis[0])) {
 42 |             VpnStatus.logWarning(R.string.abi_mismatch, Arrays.toString(abis), nativeAPI);
 43 |             abis = new String[]{nativeAPI};
 44 |         }
 45 | 
 46 |         for (String abi : abis) {
 47 | 
 48 |             File vpnExecutable = new File(context.getCacheDir(), "c_" + getMiniVPNExecutableName() + "." + abi);
 49 |             if ((vpnExecutable.exists() && vpnExecutable.canExecute()) || writeMiniVPNBinary(context, abi, vpnExecutable)) {
 50 |                 return vpnExecutable.getPath();
 51 |             }
 52 |         }
 53 | 
 54 |         throw new RuntimeException("Cannot find any execulte for this device's ABIs " + abis.toString());
 55 |     }
 56 | 
 57 |     @TargetApi(Build.VERSION_CODES.LOLLIPOP)
 58 |     private static String[] getSupportedABIsLollipop() {
 59 |         return Build.SUPPORTED_ABIS;
 60 |     }
 61 | 
 62 |     private static String getMiniVPNExecutableName() {
 63 |         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
 64 |             return MINIPIEVPN;
 65 |         else
 66 |             return MININONPIEVPN;
 67 |     }
 68 | 
 69 | 
 70 |     public static String[] replacePieWithNoPie(String[] mArgv) {
 71 |         mArgv[0] = mArgv[0].replace(MINIPIEVPN, MININONPIEVPN);
 72 |         return mArgv;
 73 |     }
 74 | 
 75 | 
 76 |     static String[] buildOpenvpnArgv(Context c) {
 77 |         Vector<String> args = new Vector<>();
 78 | 
 79 |         String binaryName = writeMiniVPN(c);
 80 |         // Add fixed paramenters
 81 |         //args.add("/data/data/de.blinkt.openvpn/lib/openvpn");
 82 |         if (binaryName == null) {
 83 |             VpnStatus.logError("Error writing minivpn binary");
 84 |             return null;
 85 |         }
 86 | 
 87 |         args.add(binaryName);
 88 | 
 89 |         args.add("--config");
 90 |         args.add(getConfigFilePath(c));
 91 | 
 92 |         return args.toArray(new String[args.size()]);
 93 |     }
 94 | 
 95 |     private static boolean writeMiniVPNBinary(Context context, String abi, File mvpnout) {
 96 |         try {
 97 |             InputStream mvpn;
 98 | 
 99 |             try {
100 |                 mvpn = context.getAssets().open(getMiniVPNExecutableName() + "." + abi);
101 |             } catch (IOException errabi) {
102 |                 VpnStatus.logInfo("Failed getting assets for archicture " + abi);
103 |                 return false;
104 |             }
105 | 
106 | 
107 |             FileOutputStream fout = new FileOutputStream(mvpnout);
108 | 
109 |             byte buf[] = new byte[4096];
110 | 
111 |             int lenread = mvpn.read(buf);
112 |             while (lenread > 0) {
113 |                 fout.write(buf, 0, lenread);
114 |                 lenread = mvpn.read(buf);
115 |             }
116 |             fout.close();
117 | 
118 |             if (!mvpnout.setExecutable(true)) {
119 |                 VpnStatus.logError("Failed to make OpenVPN executable");
120 |                 return false;
121 |             }
122 | 
123 | 
124 |             return true;
125 |         } catch (IOException e) {
126 |             VpnStatus.logException(e);
127 |             return false;
128 |         }
129 | 
130 |     }
131 | 
132 | 
133 |     public static void startOpenVpn(VpnProfile startprofile, Context context) {
134 |         Intent startVPN = startprofile.prepareStartService(context);
135 |         if (startVPN != null) {
136 |             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
137 |                 //noinspection NewApi
138 |                 context.startForegroundService(startVPN);
139 |             else
140 |                 context.startService(startVPN);
141 | 
142 |         }
143 |     }
144 | 
145 | 
146 |     public static String getConfigFilePath(Context context) {
147 |         return context.getCacheDir().getAbsolutePath() + "/" + OVPNCONFIGFILE;
148 |     }
149 | 
150 | }
151 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/VpnStatus.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.app.PendingIntent;
  9 | import android.content.Context;
 10 | import android.content.Intent;
 11 | import android.os.Build;
 12 | import android.os.HandlerThread;
 13 | import android.os.Message;
 14 | 
 15 | import java.io.File;
 16 | import java.io.PrintWriter;
 17 | import java.io.StringWriter;
 18 | import java.util.LinkedList;
 19 | import java.util.Locale;
 20 | import java.util.Vector;
 21 | 
 22 | import de.blinkt.openvpn.R;
 23 | 
 24 | public class VpnStatus {
 25 | 
 26 | 
 27 |     private static final LinkedList<LogItem> logbuffer;
 28 | 
 29 |     private static Vector<LogListener> logListener;
 30 |     private static Vector<StateListener> stateListener;
 31 |     private static Vector<ByteCountListener> byteCountListener;
 32 | 
 33 |     private static String mLaststatemsg = "";
 34 | 
 35 |     private static String mLaststate = "NOPROCESS";
 36 | 
 37 |     private static int mLastStateresid = R.string.state_noprocess;
 38 | 
 39 |     private static Intent mLastIntent = null;
 40 | 
 41 |     private static HandlerThread mHandlerThread;
 42 | 
 43 |     private static String mLastConnectedVPNUUID;
 44 |     static boolean readFileLog =false;
 45 |     final static java.lang.Object readFileLock = new Object();
 46 | 
 47 | 
 48 |     public static TrafficHistory trafficHistory;
 49 | 
 50 | 
 51 |     public static void logException(LogLevel ll, String context, Exception e) {
 52 |         StringWriter sw = new StringWriter();
 53 |         e.printStackTrace(new PrintWriter(sw));
 54 |         LogItem li;
 55 |         if (context != null) {
 56 |             li = new LogItem(ll, R.string.unhandled_exception_context, e.getMessage(), sw.toString(), context);
 57 |         } else {
 58 |             li = new LogItem(ll, R.string.unhandled_exception, e.getMessage(), sw.toString());
 59 |         }
 60 |         newLogItem(li);
 61 |     }
 62 | 
 63 |     public static void logException(Exception e) {
 64 |         logException(LogLevel.ERROR, null, e);
 65 |     }
 66 | 
 67 |     public static void logException(String context, Exception e) {
 68 |         logException(LogLevel.ERROR, context, e);
 69 |     }
 70 | 
 71 |     static final int MAXLOGENTRIES = 1000;
 72 | 
 73 |     public static boolean isVPNActive() {
 74 |         return mLastLevel != ConnectionStatus.LEVEL_AUTH_FAILED && !(mLastLevel == ConnectionStatus.LEVEL_NOTCONNECTED);
 75 |     }
 76 | 
 77 |     public static String getLastCleanLogMessage(Context c) {
 78 |         String message = mLaststatemsg;
 79 |         switch (mLastLevel) {
 80 |             case LEVEL_CONNECTED:
 81 |                 String[] parts = mLaststatemsg.split(",");
 82 |                 /*
 83 |                    (a) the integer unix date/time,
 84 |                    (b) the state name,
 85 |                    0 (c) optional descriptive string (used mostly on RECONNECTING
 86 |                     and EXITING to show the reason for the disconnect),
 87 | 
 88 |                     1 (d) optional TUN/TAP local IPv4 address
 89 |                    2 (e) optional address of remote server,
 90 |                    3 (f) optional port of remote server,
 91 |                    4 (g) optional local address,
 92 |                    5 (h) optional local port, and
 93 |                    6 (i) optional TUN/TAP local IPv6 address.
 94 | */
 95 |                 // Return only the assigned IP addresses in the UI
 96 |                 if (parts.length >= 7)
 97 |                     message = String.format(Locale.US, "%s %s", parts[1], parts[6]);
 98 |                 break;
 99 |         }
100 | 
101 |         while (message.endsWith(","))
102 |             message = message.substring(0, message.length() - 1);
103 | 
104 |         String status = mLaststate;
105 |         if (status.equals("NOPROCESS"))
106 |             return message;
107 | 
108 |         if (mLastStateresid == R.string.state_waitconnectretry) {
109 |             return c.getString(R.string.state_waitconnectretry, mLaststatemsg);
110 |         }
111 | 
112 |         String prefix = c.getString(mLastStateresid);
113 |         if (mLastStateresid == R.string.unknown_state)
114 |             message = status + message;
115 |         if (message.length() > 0)
116 |             prefix += ": ";
117 | 
118 |         return prefix + message;
119 | 
120 |     }
121 | 
122 |     public static void initLogCache(File cacheDir) {
123 |         mHandlerThread = new HandlerThread("LogFileWriter", Thread.MIN_PRIORITY);
124 |         mHandlerThread.start();
125 |         mLogFileHandler = new LogFileHandler(mHandlerThread.getLooper());
126 | 
127 | 
128 |         Message m = mLogFileHandler.obtainMessage(LogFileHandler.LOG_INIT, cacheDir);
129 |         mLogFileHandler.sendMessage(m);
130 | 
131 |     }
132 | 
133 |     public static void flushLog() {
134 |         if (mLogFileHandler!=null)
135 |             mLogFileHandler.sendEmptyMessage(LogFileHandler.FLUSH_TO_DISK);
136 |     }
137 | 
138 |     public static void setConnectedVPNProfile(String uuid) {
139 |         mLastConnectedVPNUUID = uuid;
140 |         for (StateListener sl: stateListener)
141 |             sl.setConnectedVPN(uuid);
142 |     }
143 | 
144 | 
145 |     public static String getLastConnectedVPNProfile()
146 |     {
147 |         return mLastConnectedVPNUUID;
148 |     }
149 | 
150 |     public static void setTrafficHistory(TrafficHistory trafficHistory) {
151 |         VpnStatus.trafficHistory = trafficHistory;
152 |     }
153 | 
154 | 
155 |     public enum LogLevel {
156 |         INFO(2),
157 |         ERROR(-2),
158 |         WARNING(1),
159 |         VERBOSE(3),
160 |         DEBUG(4);
161 | 
162 |         protected int mValue;
163 | 
164 |         LogLevel(int value) {
165 |             mValue = value;
166 |         }
167 | 
168 |         public int getInt() {
169 |             return mValue;
170 |         }
171 | 
172 |         public static LogLevel getEnumByValue(int value) {
173 |             switch (value) {
174 |                 case 2:
175 |                     return INFO;
176 |                 case -2:
177 |                     return ERROR;
178 |                 case 1:
179 |                     return WARNING;
180 |                 case 3:
181 |                     return VERBOSE;
182 |                 case 4:
183 |                     return DEBUG;
184 | 
185 |                 default:
186 |                     return null;
187 |             }
188 |         }
189 |     }
190 | 
191 |     // keytool -printcert -jarfile de.blinkt.openvpn_85.apk
192 |     static final byte[] officalkey = {-58, -42, -44, -106, 90, -88, -87, -88, -52, -124, 84, 117, 66, 79, -112, -111, -46, 86, -37, 109};
193 |     static final byte[] officaldebugkey = {-99, -69, 45, 71, 114, -116, 82, 66, -99, -122, 50, -70, -56, -111, 98, -35, -65, 105, 82, 43};
194 |     static final byte[] amazonkey = {-116, -115, -118, -89, -116, -112, 120, 55, 79, -8, -119, -23, 106, -114, -85, -56, -4, 105, 26, -57};
195 |     static final byte[] fdroidkey = {-92, 111, -42, -46, 123, -96, -60, 79, -27, -31, 49, 103, 11, -54, -68, -27, 17, 2, 121, 104};
196 | 
197 | 
198 |     private static ConnectionStatus mLastLevel = ConnectionStatus.LEVEL_NOTCONNECTED;
199 | 
200 |     private static LogFileHandler mLogFileHandler;
201 | 
202 |     static {
203 |         logbuffer = new LinkedList<>();
204 |         logListener = new Vector<>();
205 |         stateListener = new Vector<>();
206 |         byteCountListener = new Vector<>();
207 |         trafficHistory = new TrafficHistory();
208 | 
209 |         logInformation();
210 | 
211 |     }
212 | 
213 | 
214 |     public interface LogListener {
215 |         void newLog(LogItem logItem);
216 |     }
217 | 
218 |     public interface StateListener {
219 |         void updateState(String state, String logmessage, int localizedResId, ConnectionStatus level, Intent Intent);
220 | 
221 |         void setConnectedVPN(String uuid);
222 |     }
223 | 
224 |     public interface ByteCountListener {
225 |         void updateByteCount(long in, long out, long diffIn, long diffOut);
226 |     }
227 | 
228 |     public synchronized static void logMessage(LogLevel level, String prefix, String message) {
229 |         newLogItem(new LogItem(level, prefix + message));
230 | 
231 |     }
232 | 
233 |     public synchronized static void clearLog() {
234 |         logbuffer.clear();
235 |         logInformation();
236 |         if (mLogFileHandler != null)
237 |             mLogFileHandler.sendEmptyMessage(LogFileHandler.TRIM_LOG_FILE);
238 |     }
239 | 
240 |     private static void logInformation() {
241 |         String nativeAPI;
242 |         try {
243 |             nativeAPI = NativeUtils.getNativeAPI();
244 |         } catch (UnsatisfiedLinkError ignore) {
245 |             nativeAPI = "error";
246 |         }
247 | 
248 |         logInfo(R.string.mobile_info, Build.MODEL, Build.BOARD, Build.BRAND, Build.VERSION.SDK_INT,
249 |                 nativeAPI, Build.VERSION.RELEASE, Build.ID, Build.FINGERPRINT, "", "");
250 |     }
251 | 
252 |     public synchronized static void addLogListener(LogListener ll) {
253 |         logListener.add(ll);
254 |     }
255 | 
256 |     public synchronized static void removeLogListener(LogListener ll) {
257 |         logListener.remove(ll);
258 |     }
259 | 
260 |     public synchronized static void addByteCountListener(ByteCountListener bcl) {
261 |         TrafficHistory.LastDiff diff = trafficHistory.getLastDiff(null);
262 |         bcl.updateByteCount(diff.getIn(), diff.getOut(), diff.getDiffIn(),diff.getDiffOut());
263 |         byteCountListener.add(bcl);
264 |     }
265 | 
266 |     public synchronized static void removeByteCountListener(ByteCountListener bcl) {
267 |         byteCountListener.remove(bcl);
268 |     }
269 | 
270 | 
271 |     public synchronized static void addStateListener(StateListener sl) {
272 |         if (!stateListener.contains(sl)) {
273 |             stateListener.add(sl);
274 |             if (mLaststate != null)
275 |                 sl.updateState(mLaststate, mLaststatemsg, mLastStateresid, mLastLevel, mLastIntent);
276 |         }
277 |     }
278 | 
279 |     private static int getLocalizedState(String state) {
280 |         switch (state) {
281 |             case "CONNECTING":
282 |                 return R.string.state_connecting;
283 |             case "WAIT":
284 |                 return R.string.state_wait;
285 |             case "AUTH":
286 |                 return R.string.state_auth;
287 |             case "GET_CONFIG":
288 |                 return R.string.state_get_config;
289 |             case "ASSIGN_IP":
290 |                 return R.string.state_assign_ip;
291 |             case "ADD_ROUTES":
292 |                 return R.string.state_add_routes;
293 |             case "CONNECTED":
294 |                 return R.string.state_connected;
295 |             case "DISCONNECTED":
296 |                 return R.string.state_disconnected;
297 |             case "RECONNECTING":
298 |                 return R.string.state_reconnecting;
299 |             case "EXITING":
300 |                 return R.string.state_exiting;
301 |             case "RESOLVE":
302 |                 return R.string.state_resolve;
303 |             case "TCP_CONNECT":
304 |                 return R.string.state_tcp_connect;
305 |             case "AUTH_PENDING":
306 |                 return R.string.state_auth_pending;
307 |             default:
308 |                 return R.string.unknown_state;
309 |         }
310 | 
311 |     }
312 | 
313 |     public static void updateStatePause(OpenVPNManagement.pauseReason pauseReason) {
314 |         switch (pauseReason) {
315 |             case noNetwork:
316 |                 VpnStatus.updateStateString("NONETWORK", "", R.string.state_nonetwork, ConnectionStatus.LEVEL_NONETWORK);
317 |                 break;
318 |             case screenOff:
319 |                 VpnStatus.updateStateString("SCREENOFF", "", R.string.state_screenoff, ConnectionStatus.LEVEL_VPNPAUSED);
320 |                 break;
321 |             case userPause:
322 |                 VpnStatus.updateStateString("USERPAUSE", "", R.string.state_userpause, ConnectionStatus.LEVEL_VPNPAUSED);
323 |                 break;
324 |         }
325 | 
326 |     }
327 | 
328 |     private static ConnectionStatus getLevel(String state) {
329 |         String[] noreplyet = {"CONNECTING", "WAIT", "RECONNECTING", "RESOLVE", "TCP_CONNECT"};
330 |         String[] reply = {"AUTH", "GET_CONFIG", "ASSIGN_IP", "ADD_ROUTES", "AUTH_PENDING"};
331 |         String[] connected = {"CONNECTED"};
332 |         String[] notconnected = {"DISCONNECTED", "EXITING"};
333 | 
334 |         for (String x : noreplyet)
335 |             if (state.equals(x))
336 |                 return ConnectionStatus.LEVEL_CONNECTING_NO_SERVER_REPLY_YET;
337 | 
338 |         for (String x : reply)
339 |             if (state.equals(x))
340 |                 return ConnectionStatus.LEVEL_CONNECTING_SERVER_REPLIED;
341 | 
342 |         for (String x : connected)
343 |             if (state.equals(x))
344 |                 return ConnectionStatus.LEVEL_CONNECTED;
345 | 
346 |         for (String x : notconnected)
347 |             if (state.equals(x))
348 |                 return ConnectionStatus.LEVEL_NOTCONNECTED;
349 | 
350 |         return ConnectionStatus.UNKNOWN_LEVEL;
351 | 
352 |     }
353 | 
354 | 
355 |     public synchronized static void removeStateListener(StateListener sl) {
356 |         stateListener.remove(sl);
357 |     }
358 | 
359 | 
360 |     synchronized public static LogItem[] getlogbuffer() {
361 | 
362 |         // The stoned way of java to return an array from a vector
363 |         // brought to you by eclipse auto complete
364 |         return logbuffer.toArray(new LogItem[logbuffer.size()]);
365 | 
366 |     }
367 | 
368 |     static void updateStateString(String state, String msg) {
369 |         // We want to skip announcing that we are trying to get the configuration since
370 |         // this is just polling until the user input has finished.be
371 |         if (mLastLevel == ConnectionStatus.LEVEL_WAITING_FOR_USER_INPUT && state.equals("GET_CONFIG"))
372 |             return;
373 |         int rid = getLocalizedState(state);
374 |         ConnectionStatus level = getLevel(state);
375 |         updateStateString(state, msg, rid, level);
376 |     }
377 | 
378 |     public synchronized static void updateStateString(String state, String msg, int resid, ConnectionStatus level)
379 |     {
380 |         updateStateString(state, msg, resid, level, null);
381 |     }
382 | 
383 |     public synchronized static void updateStateString(String state, String msg, int resid, ConnectionStatus level, Intent intent) {
384 |         // Workound for OpenVPN doing AUTH and wait and being connected
385 |         // Simply ignore these state
386 |         if (mLastLevel == ConnectionStatus.LEVEL_CONNECTED &&
387 |                 (state.equals("WAIT") || state.equals("AUTH"))) {
388 |             newLogItem(new LogItem((LogLevel.DEBUG), String.format("Ignoring OpenVPN Status in CONNECTED state (%s->%s): %s", state, level.toString(), msg)));
389 |             return;
390 |         }
391 | 
392 |         mLaststate = state;
393 |         mLaststatemsg = msg;
394 |         mLastStateresid = resid;
395 |         mLastLevel = level;
396 |         mLastIntent = intent;
397 | 
398 | 
399 |         for (StateListener sl : stateListener) {
400 |             sl.updateState(state, msg, resid, level, intent);
401 |         }
402 |         //newLogItem(new LogItem((LogLevel.DEBUG), String.format("New OpenVPN Status (%s->%s): %s",state,level.toString(),msg)));
403 |     }
404 | 
405 |     public static void logInfo(String message) {
406 |         newLogItem(new LogItem(LogLevel.INFO, message));
407 |     }
408 | 
409 |     public static void logDebug(String message) {
410 |         newLogItem(new LogItem(LogLevel.DEBUG, message));
411 |     }
412 | 
413 |     public static void logInfo(int resourceId, Object... args) {
414 |         newLogItem(new LogItem(LogLevel.INFO, resourceId, args));
415 |     }
416 | 
417 |     public static void logDebug(int resourceId, Object... args) {
418 |         newLogItem(new LogItem(LogLevel.DEBUG, resourceId, args));
419 |     }
420 | 
421 |     static void newLogItem(LogItem logItem) {
422 |         newLogItem(logItem, false);
423 |     }
424 | 
425 | 
426 |     synchronized static void newLogItem(LogItem logItem, boolean cachedLine) {
427 |         if (cachedLine) {
428 |             logbuffer.addFirst(logItem);
429 |         } else {
430 |             logbuffer.addLast(logItem);
431 |             if (mLogFileHandler != null) {
432 |                 Message m = mLogFileHandler.obtainMessage(LogFileHandler.LOG_MESSAGE, logItem);
433 |                 mLogFileHandler.sendMessage(m);
434 |             }
435 |         }
436 | 
437 |         if (logbuffer.size() > MAXLOGENTRIES + MAXLOGENTRIES / 2) {
438 |             while (logbuffer.size() > MAXLOGENTRIES)
439 |                 logbuffer.removeFirst();
440 |             if (mLogFileHandler != null)
441 |                 mLogFileHandler.sendMessage(mLogFileHandler.obtainMessage(LogFileHandler.TRIM_LOG_FILE));
442 |         }
443 | 
444 |         for (LogListener ll : logListener) {
445 |             ll.newLog(logItem);
446 |         }
447 |     }
448 | 
449 | 
450 |     public static void logError(String msg) {
451 |         newLogItem(new LogItem(LogLevel.ERROR, msg));
452 | 
453 |     }
454 | 
455 |     public static void logWarning(int resourceId, Object... args) {
456 |         newLogItem(new LogItem(LogLevel.WARNING, resourceId, args));
457 |     }
458 | 
459 |     public static void logWarning(String msg) {
460 |         newLogItem(new LogItem(LogLevel.WARNING, msg));
461 |     }
462 | 
463 | 
464 |     public static void logError(int resourceId) {
465 |         newLogItem(new LogItem(LogLevel.ERROR, resourceId));
466 |     }
467 | 
468 |     public static void logError(int resourceId, Object... args) {
469 |         newLogItem(new LogItem(LogLevel.ERROR, resourceId, args));
470 |     }
471 | 
472 |     public static void logMessageOpenVPN(LogLevel level, int ovpnlevel, String message) {
473 |         newLogItem(new LogItem(level, ovpnlevel, message));
474 | 
475 |     }
476 | 
477 | 
478 |     public static synchronized void updateByteCount(long in, long out) {
479 |         TrafficHistory.LastDiff diff = trafficHistory.add(in, out);
480 | 
481 |         for (ByteCountListener bcl : byteCountListener) {
482 |             bcl.updateByteCount(in, out, diff.getDiffIn(), diff.getDiffOut());
483 |         }
484 |     }
485 | }
486 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/core/X509Utils.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package de.blinkt.openvpn.core;
  7 | 
  8 | import android.annotation.SuppressLint;
  9 | import android.content.Context;
 10 | import android.content.res.Resources;
 11 | import android.text.TextUtils;
 12 | 
 13 | import de.blinkt.openvpn.R;
 14 | import de.blinkt.openvpn.VpnProfile;
 15 | import org.spongycastle.util.io.pem.PemObject;
 16 | import org.spongycastle.util.io.pem.PemReader;
 17 | 
 18 | 
 19 | import javax.security.auth.x500.X500Principal;
 20 | import java.io.*;
 21 | import java.lang.reflect.InvocationTargetException;
 22 | import java.lang.reflect.Method;
 23 | import java.security.cert.Certificate;
 24 | import java.security.cert.CertificateException;
 25 | import java.security.cert.CertificateExpiredException;
 26 | import java.security.cert.CertificateFactory;
 27 | import java.security.cert.CertificateNotYetValidException;
 28 | import java.security.cert.X509Certificate;
 29 | import java.util.ArrayList;
 30 | import java.util.Date;
 31 | import java.util.Hashtable;
 32 | import java.util.Vector;
 33 | 
 34 | public class X509Utils {
 35 | 	public static Certificate[] getCertificatesFromFile(String certfilename) throws FileNotFoundException, CertificateException {
 36 | 		CertificateFactory certFact = CertificateFactory.getInstance("X.509");
 37 | 
 38 |         Vector<Certificate> certificates = new Vector<>();
 39 | 		if(VpnProfile.isEmbedded(certfilename)) {
 40 |             int subIndex = certfilename.indexOf("-----BEGIN CERTIFICATE-----");
 41 |             do {
 42 |                 // The java certifcate reader is ... kind of stupid
 43 |                 // It does NOT ignore chars before the --BEGIN ...
 44 | 
 45 |                 subIndex = Math.max(0, subIndex);
 46 |                 InputStream inStream = new ByteArrayInputStream(certfilename.substring(subIndex).getBytes());
 47 |                 certificates.add(certFact.generateCertificate(inStream));
 48 | 
 49 |                 subIndex = certfilename.indexOf("-----BEGIN CERTIFICATE-----", subIndex+1);
 50 |             } while (subIndex > 0);
 51 |             return certificates.toArray(new Certificate[certificates.size()]);
 52 |         } else {
 53 | 			InputStream inStream = new FileInputStream(certfilename);
 54 |             return new Certificate[] {certFact.generateCertificate(inStream)};
 55 |         }
 56 | 
 57 | 
 58 | 	}
 59 | 
 60 | 	public static PemObject readPemObjectFromFile (String keyfilename) throws IOException {
 61 | 
 62 | 		Reader inStream;
 63 | 
 64 | 		if(VpnProfile.isEmbedded(keyfilename))
 65 | 			inStream = new StringReader(VpnProfile.getEmbeddedContent(keyfilename));
 66 | 		else 
 67 | 			inStream = new FileReader(new File(keyfilename));
 68 | 
 69 | 		PemReader pr = new PemReader(inStream);
 70 | 		PemObject r = pr.readPemObject();
 71 | 		pr.close();
 72 | 		return r;
 73 | 	}
 74 | 
 75 | 
 76 | 
 77 | 
 78 | 	public static String getCertificateFriendlyName (Context c, String filename) {
 79 | 		if(!TextUtils.isEmpty(filename)) {
 80 | 			try {
 81 | 				X509Certificate cert = (X509Certificate) getCertificatesFromFile(filename)[0];
 82 |                 String friendlycn = getCertificateFriendlyName(cert);
 83 |                 friendlycn = getCertificateValidityString(cert, c.getResources()) + friendlycn;
 84 |                 return friendlycn;
 85 | 
 86 | 			} catch (Exception e) {
 87 | 				VpnStatus.logError("Could not read certificate" + e.getLocalizedMessage());
 88 | 			}
 89 | 		}
 90 | 		return c.getString(R.string.cannotparsecert);
 91 | 	}
 92 | 
 93 |     public static String getCertificateValidityString(X509Certificate cert, Resources res) {
 94 |         try {
 95 |             cert.checkValidity();
 96 |         } catch (CertificateExpiredException ce) {
 97 |             return "EXPIRED: ";
 98 |         } catch (CertificateNotYetValidException cny) {
 99 |             return "NOT YET VALID: ";
100 |         }
101 | 
102 |         Date certNotAfter = cert.getNotAfter();
103 |         Date now = new Date();
104 |         long timeLeft = certNotAfter.getTime() - now.getTime(); // Time left in ms
105 | 
106 |         // More than 72h left, display days
107 |         // More than 3 months display months
108 |         if (timeLeft > 90l* 24 * 3600 * 1000) {
109 |             long months = getMonthsDifference(now, certNotAfter);
110 |             return res.getQuantityString(R.plurals.months_left, (int) months, months);
111 |         } else if (timeLeft > 72 * 3600 * 1000) {
112 |             long days = timeLeft / (24 * 3600 * 1000);
113 |             return res.getQuantityString(R.plurals.days_left, (int) days, days);
114 |         } else {
115 |             long hours = timeLeft / (3600 * 1000);
116 | 
117 |             return res.getQuantityString(R.plurals.hours_left, (int)hours, hours);
118 |         }
119 |     }
120 | 
121 |     public static int getMonthsDifference(Date date1, Date date2) {
122 |         int m1 = date1.getYear() * 12 + date1.getMonth();
123 |         int m2 = date2.getYear() * 12 + date2.getMonth();
124 |         return m2 - m1 + 1;
125 |     }
126 | 
127 |     public static String getCertificateFriendlyName(X509Certificate cert) {
128 |         X500Principal principal = cert.getSubjectX500Principal();
129 |         byte[] encodedSubject = principal.getEncoded();
130 |         String friendlyName=null;
131 | 
132 |         /* Hack so we do not have to ship a whole Spongy/bouncycastle */
133 |         Exception exp=null;
134 |         try {
135 |             @SuppressLint("PrivateApi") Class X509NameClass = Class.forName("com.android.org.bouncycastle.asn1.x509.X509Name");
136 |             Method getInstance = X509NameClass.getMethod("getInstance",Object.class);
137 | 
138 |             Hashtable defaultSymbols = (Hashtable) X509NameClass.getField("DefaultSymbols").get(X509NameClass);
139 | 
140 |             if (!defaultSymbols.containsKey("1.2.840.113549.1.9.1"))
141 |                 defaultSymbols.put("1.2.840.113549.1.9.1","eMail");
142 | 
143 |             Object subjectName = getInstance.invoke(X509NameClass, encodedSubject);
144 | 
145 |             Method toString = X509NameClass.getMethod("toString",boolean.class,Hashtable.class);
146 | 
147 |             friendlyName= (String) toString.invoke(subjectName,true,defaultSymbols);
148 |                     
149 |         } catch (ClassNotFoundException e) {
150 |             exp =e ;
151 |         } catch (NoSuchMethodException e) {
152 |             exp =e;
153 |         } catch (InvocationTargetException e) {
154 |             exp =e;
155 |         } catch (IllegalAccessException e) {
156 |             exp =e;
157 |         } catch (NoSuchFieldException e) {
158 |             exp =e;
159 |         }
160 |         if (exp!=null)
161 |             VpnStatus.logException("Getting X509 Name from certificate", exp);
162 | 
163 |         /* Fallback if the reflection method did not work */
164 |         if(friendlyName==null)
165 |             friendlyName = principal.getName();
166 | 
167 | 
168 |         // Really evil hack to decode email address
169 |         // See: http://code.google.com/p/android/issues/detail?id=21531
170 | 
171 |         String[] parts = friendlyName.split(",");
172 |         for (int i=0;i<parts.length;i++){
173 |             String part = parts[i];
174 |             if (part.startsWith("1.2.840.113549.1.9.1=#16")) {
175 |                 parts[i] = "email=" + ia5decode(part.replace("1.2.840.113549.1.9.1=#16", ""));
176 |             }
177 |         }
178 |         friendlyName = TextUtils.join(",", parts);
179 |         return friendlyName;
180 |     }
181 | 
182 |     public static boolean isPrintableChar(char c) {
183 |         Character.UnicodeBlock block = Character.UnicodeBlock.of( c );
184 |         return (!Character.isISOControl(c)) &&
185 |                 block != null &&
186 |                 block != Character.UnicodeBlock.SPECIALS;
187 |     }
188 | 
189 |     private static String ia5decode(String ia5string) {
190 |         String d = "";
191 |         for (int i=1;i<ia5string.length();i=i+2) {
192 |             String hexstr = ia5string.substring(i-1,i+1);
193 |             char c = (char) Integer.parseInt(hexstr,16);
194 |             if (isPrintableChar(c)) {
195 |                 d+=c;
196 |             } else if (i==1 && (c==0x12 || c==0x1b)) {
197 |                 ;   // ignore
198 |             } else {
199 |                 d += "\\x" + hexstr;
200 |             }
201 |         }
202 |         return d;
203 |     }
204 | 
205 | 
206 | }
207 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/utils/PropertiesService.java:
--------------------------------------------------------------------------------
 1 | package de.blinkt.openvpn.utils;
 2 | 
 3 | import android.content.Context;
 4 | import android.content.SharedPreferences;
 5 | import android.preference.PreferenceManager;
 6 | 
 7 | 
 8 | public class PropertiesService {
 9 | 
10 |     private static final String DOWNLOADED_DATA_KEY = "downloaded_data";
11 |     private static final String UPLOADED_DATA_KEY = "uploaded_data";
12 |     private static SharedPreferences prefs;
13 | 
14 |     private synchronized static SharedPreferences getPrefs(Context context) {
15 |         if (prefs == null) {
16 |             prefs = PreferenceManager.getDefaultSharedPreferences(context);
17 |         }
18 |         return prefs;
19 |     }
20 | 
21 |     public static long getDownloaded(Context context) {
22 |         return getPrefs(context).getLong(DOWNLOADED_DATA_KEY, 0);
23 |     }
24 | 
25 |     public static void setDownloaded(Context context, long count) {
26 |         getPrefs(context).edit().putLong(DOWNLOADED_DATA_KEY, count).apply();
27 |     }
28 | 
29 |     public static long getUploaded(Context context) {
30 |         return getPrefs(context).getLong(UPLOADED_DATA_KEY, 0);
31 |     }
32 | 
33 |     public static void setUploaded(Context context, long count) {
34 |         getPrefs(context).edit().putLong(UPLOADED_DATA_KEY, count).apply();
35 |     }
36 | }
37 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/de/blinkt/openvpn/utils/TotalTraffic.java:
--------------------------------------------------------------------------------
 1 | package de.blinkt.openvpn.utils;
 2 | 
 3 | import android.content.Context;
 4 | import android.content.Intent;
 5 | 
 6 | import java.util.ArrayList;
 7 | import java.util.List;
 8 | 
 9 | import de.blinkt.openvpn.core.OpenVPNService;
10 | 
11 | public class TotalTraffic {
12 | 
13 |     public static final String TRAFFIC_ACTION = "traffic_action";
14 | 
15 |     public static final String DOWNLOAD_ALL = "download_all";
16 |     public static final String DOWNLOAD_SESSION = "download_session";
17 |     public static final String UPLOAD_ALL = "upload_all";
18 |     public static final String UPLOAD_SESSION = "upload_session";
19 | 
20 |     public static long inTotal;
21 |     public static long outTotal;
22 | 
23 | 
24 |     public static void calcTraffic(Context context, long in, long out, long diffIn, long diffOut) {
25 |         List<String> totalTraffic = getTotalTraffic(context, diffIn, diffOut);
26 | 
27 |         Intent traffic = new Intent();
28 |         traffic.setAction(TRAFFIC_ACTION);
29 |         traffic.putExtra(DOWNLOAD_ALL, totalTraffic.get(0));
30 |         traffic.putExtra(DOWNLOAD_SESSION, OpenVPNService.humanReadableByteCount(in, false, context.getResources()));
31 |         traffic.putExtra(UPLOAD_ALL, totalTraffic.get(1));
32 |         traffic.putExtra(UPLOAD_SESSION, OpenVPNService.humanReadableByteCount(out, false, context.getResources()));
33 | 
34 |         context.sendBroadcast(traffic);
35 |     }
36 | 
37 |     public static List<String> getTotalTraffic(Context context) {
38 |         return getTotalTraffic(context, 0, 0);
39 |     }
40 | 
41 |     public static List<String> getTotalTraffic(Context context, long in, long out) {
42 |         List<String> totalTraffic = new ArrayList<String>();
43 | 
44 |         if (inTotal == 0)
45 |             inTotal = PropertiesService.getDownloaded(context);
46 | 
47 |         if (outTotal == 0)
48 |             outTotal = PropertiesService.getUploaded(context);
49 | 
50 |         inTotal = inTotal + in;
51 |         outTotal = outTotal + out;
52 | 
53 |         totalTraffic.add(OpenVPNService.humanReadableByteCount(inTotal, false, context.getResources()));
54 |         totalTraffic.add(OpenVPNService.humanReadableByteCount(outTotal, false, context.getResources()));
55 | 
56 |         return totalTraffic;
57 |     }
58 | 
59 |     public static void saveTotal(Context context) {
60 |         if (inTotal != 0)
61 |             PropertiesService.setDownloaded(context, inTotal);
62 | 
63 |         if (outTotal != 0)
64 |             PropertiesService.setUploaded(context, outTotal);
65 |     }
66 | 
67 |     public static void clearTotal(Context context) {
68 |         inTotal = 0;
69 |         PropertiesService.setDownloaded(context, inTotal);
70 |         outTotal = 0;
71 |         PropertiesService.setUploaded(context, outTotal);
72 |     }
73 | 
74 | }
75 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/encoders/Base64.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.encoders;
 7 | 
 8 | import java.io.ByteArrayOutputStream;
 9 | import java.io.IOException;
10 | import java.io.OutputStream;
11 | 
12 | public class Base64 {
13 |     private static final Encoder encoder = new Base64Encoder();
14 | 
15 |     /**
16 |      * encode the input data producing a base 64 encoded byte array.
17 |      *
18 |      * @return a byte array containing the base 64 encoded data.
19 |      */
20 |     public static byte[] encode(byte[] data) {
21 |         int len = (data.length + 2) / 3 * 4;
22 |         ByteArrayOutputStream bOut = new ByteArrayOutputStream(len);
23 | 
24 |         try {
25 |             encoder.encode(data, 0, data.length, bOut);
26 |         } catch (IOException e) {
27 |             throw new RuntimeException("exception encoding base64 string: " + e);
28 |         }
29 | 
30 |         return bOut.toByteArray();
31 |     }
32 | 
33 |     /**
34 |      * Encode the byte data to base 64 writing it to the given output stream.
35 |      *
36 |      * @return the number of bytes produced.
37 |      */
38 |     public static int encode(byte[] data, OutputStream out) throws IOException {
39 |         return encoder.encode(data, 0, data.length, out);
40 |     }
41 | 
42 |     /**
43 |      * Encode the byte data to base 64 writing it to the given output stream.
44 |      *
45 |      * @return the number of bytes produced.
46 |      */
47 |     public static int encode(byte[] data, int off, int length, OutputStream out) throws IOException {
48 |         return encoder.encode(data, off, length, out);
49 |     }
50 | 
51 |     /**
52 |      * decode the base 64 encoded input data. It is assumed the input data is valid.
53 |      *
54 |      * @return a byte array representing the decoded data.
55 |      */
56 |     public static byte[] decode(byte[] data) {
57 |         int len = data.length / 4 * 3;
58 |         ByteArrayOutputStream bOut = new ByteArrayOutputStream(len);
59 | 
60 |         try {
61 |             encoder.decode(data, 0, data.length, bOut);
62 |         } catch (IOException e) {
63 |             throw new RuntimeException("exception decoding base64 string: " + e);
64 |         }
65 | 
66 |         return bOut.toByteArray();
67 |     }
68 | 
69 |     /**
70 |      * decode the base 64 encoded String data - whitespace will be ignored.
71 |      *
72 |      * @return a byte array representing the decoded data.
73 |      */
74 |     public static byte[] decode(String data) {
75 |         int len = data.length() / 4 * 3;
76 |         ByteArrayOutputStream bOut = new ByteArrayOutputStream(len);
77 | 
78 |         try {
79 |             encoder.decode(data, bOut);
80 |         } catch (IOException e) {
81 |             throw new RuntimeException("exception decoding base64 string: " + e);
82 |         }
83 | 
84 |         return bOut.toByteArray();
85 |     }
86 | 
87 |     /**
88 |      * decode the base 64 encoded String data writing it to the given output stream,
89 |      * whitespace characters will be ignored.
90 |      *
91 |      * @return the number of bytes produced.
92 |      */
93 |     public static int decode(String data, OutputStream out) throws IOException {
94 |         return encoder.decode(data, out);
95 |     }
96 | }
97 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/encoders/Base64Encoder.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package org.spongycastle.util.encoders;
  7 | 
  8 | import java.io.IOException;
  9 | import java.io.OutputStream;
 10 | 
 11 | public class Base64Encoder implements Encoder {
 12 |     protected final byte[] encodingTable = {(byte) 'A', (byte) 'B', (byte) 'C', (byte) 'D', (byte) 'E', (byte) 'F', (byte) 'G', (byte) 'H', (byte) 'I', (byte) 'J', (byte) 'K', (byte) 'L', (byte) 'M', (byte) 'N', (byte) 'O', (byte) 'P', (byte) 'Q', (byte) 'R', (byte) 'S', (byte) 'T', (byte) 'U', (byte) 'V', (byte) 'W', (byte) 'X', (byte) 'Y', (byte) 'Z', (byte) 'a', (byte) 'b', (byte) 'c', (byte) 'd', (byte) 'e', (byte) 'f', (byte) 'g', (byte) 'h', (byte) 'i', (byte) 'j', (byte) 'k', (byte) 'l', (byte) 'm', (byte) 'n', (byte) 'o', (byte) 'p', (byte) 'q', (byte) 'r', (byte) 's', (byte) 't', (byte) 'u', (byte) 'v', (byte) 'w', (byte) 'x', (byte) 'y', (byte) 'z', (byte) '0', (byte) '1', (byte) '2', (byte) '3', (byte) '4', (byte) '5', (byte) '6', (byte) '7', (byte) '8', (byte) '9', (byte) '+', (byte) '/'};
 13 | 
 14 |     protected byte padding = (byte) '=';
 15 | 
 16 |     /*
 17 |      * set up the decoding table.
 18 |      */
 19 |     protected final byte[] decodingTable = new byte[128];
 20 | 
 21 |     protected void initialiseDecodingTable() {
 22 |         for (int i = 0; i < encodingTable.length; i++) {
 23 |             decodingTable[encodingTable[i]] = (byte) i;
 24 |         }
 25 |     }
 26 | 
 27 |     public Base64Encoder() {
 28 |         initialiseDecodingTable();
 29 |     }
 30 | 
 31 |     /**
 32 |      * encode the input data producing a base 64 output stream.
 33 |      *
 34 |      * @return the number of bytes produced.
 35 |      */
 36 |     public int encode(byte[] data, int off, int length, OutputStream out) throws IOException {
 37 |         int modulus = length % 3;
 38 |         int dataLength = (length - modulus);
 39 |         int a1, a2, a3;
 40 | 
 41 |         for (int i = off; i < off + dataLength; i += 3) {
 42 |             a1 = data[i] & 0xff;
 43 |             a2 = data[i + 1] & 0xff;
 44 |             a3 = data[i + 2] & 0xff;
 45 | 
 46 |             out.write(encodingTable[(a1 >>> 2) & 0x3f]);
 47 |             out.write(encodingTable[((a1 << 4) | (a2 >>> 4)) & 0x3f]);
 48 |             out.write(encodingTable[((a2 << 2) | (a3 >>> 6)) & 0x3f]);
 49 |             out.write(encodingTable[a3 & 0x3f]);
 50 |         }
 51 | 
 52 |         /*
 53 |          * process the tail end.
 54 |          */
 55 |         int b1, b2, b3;
 56 |         int d1, d2;
 57 | 
 58 |         switch (modulus) {
 59 |             case 0:        /* nothing left to do */
 60 |                 break;
 61 |             case 1:
 62 |                 d1 = data[off + dataLength] & 0xff;
 63 |                 b1 = (d1 >>> 2) & 0x3f;
 64 |                 b2 = (d1 << 4) & 0x3f;
 65 | 
 66 |                 out.write(encodingTable[b1]);
 67 |                 out.write(encodingTable[b2]);
 68 |                 out.write(padding);
 69 |                 out.write(padding);
 70 |                 break;
 71 |             case 2:
 72 |                 d1 = data[off + dataLength] & 0xff;
 73 |                 d2 = data[off + dataLength + 1] & 0xff;
 74 | 
 75 |                 b1 = (d1 >>> 2) & 0x3f;
 76 |                 b2 = ((d1 << 4) | (d2 >>> 4)) & 0x3f;
 77 |                 b3 = (d2 << 2) & 0x3f;
 78 | 
 79 |                 out.write(encodingTable[b1]);
 80 |                 out.write(encodingTable[b2]);
 81 |                 out.write(encodingTable[b3]);
 82 |                 out.write(padding);
 83 |                 break;
 84 |         }
 85 | 
 86 |         return (dataLength / 3) * 4 + ((modulus == 0) ? 0 : 4);
 87 |     }
 88 | 
 89 |     private boolean ignore(char c) {
 90 |         return (c == '\n' || c == '\r' || c == '\t' || c == ' ');
 91 |     }
 92 | 
 93 |     /**
 94 |      * decode the base 64 encoded byte data writing it to the given output stream,
 95 |      * whitespace characters will be ignored.
 96 |      *
 97 |      * @return the number of bytes produced.
 98 |      */
 99 |     public int decode(byte[] data, int off, int length, OutputStream out) throws IOException {
100 |         byte b1, b2, b3, b4;
101 |         int outLen = 0;
102 | 
103 |         int end = off + length;
104 | 
105 |         while (end > off) {
106 |             if (!ignore((char) data[end - 1])) {
107 |                 break;
108 |             }
109 | 
110 |             end--;
111 |         }
112 | 
113 |         int i = off;
114 |         int finish = end - 4;
115 | 
116 |         i = nextI(data, i, finish);
117 | 
118 |         while (i < finish) {
119 |             b1 = decodingTable[data[i++]];
120 | 
121 |             i = nextI(data, i, finish);
122 | 
123 |             b2 = decodingTable[data[i++]];
124 | 
125 |             i = nextI(data, i, finish);
126 | 
127 |             b3 = decodingTable[data[i++]];
128 | 
129 |             i = nextI(data, i, finish);
130 | 
131 |             b4 = decodingTable[data[i++]];
132 | 
133 |             out.write((b1 << 2) | (b2 >> 4));
134 |             out.write((b2 << 4) | (b3 >> 2));
135 |             out.write((b3 << 6) | b4);
136 | 
137 |             outLen += 3;
138 | 
139 |             i = nextI(data, i, finish);
140 |         }
141 | 
142 |         outLen += decodeLastBlock(out, (char) data[end - 4], (char) data[end - 3], (char) data[end - 2], (char) data[end - 1]);
143 | 
144 |         return outLen;
145 |     }
146 | 
147 |     private int nextI(byte[] data, int i, int finish) {
148 |         while ((i < finish) && ignore((char) data[i])) {
149 |             i++;
150 |         }
151 |         return i;
152 |     }
153 | 
154 |     /**
155 |      * decode the base 64 encoded String data writing it to the given output stream,
156 |      * whitespace characters will be ignored.
157 |      *
158 |      * @return the number of bytes produced.
159 |      */
160 |     public int decode(String data, OutputStream out) throws IOException {
161 |         byte b1, b2, b3, b4;
162 |         int length = 0;
163 | 
164 |         int end = data.length();
165 | 
166 |         while (end > 0) {
167 |             if (!ignore(data.charAt(end - 1))) {
168 |                 break;
169 |             }
170 | 
171 |             end--;
172 |         }
173 | 
174 |         int i = 0;
175 |         int finish = end - 4;
176 | 
177 |         i = nextI(data, i, finish);
178 | 
179 |         while (i < finish) {
180 |             b1 = decodingTable[data.charAt(i++)];
181 | 
182 |             i = nextI(data, i, finish);
183 | 
184 |             b2 = decodingTable[data.charAt(i++)];
185 | 
186 |             i = nextI(data, i, finish);
187 | 
188 |             b3 = decodingTable[data.charAt(i++)];
189 | 
190 |             i = nextI(data, i, finish);
191 | 
192 |             b4 = decodingTable[data.charAt(i++)];
193 | 
194 |             out.write((b1 << 2) | (b2 >> 4));
195 |             out.write((b2 << 4) | (b3 >> 2));
196 |             out.write((b3 << 6) | b4);
197 | 
198 |             length += 3;
199 | 
200 |             i = nextI(data, i, finish);
201 |         }
202 | 
203 |         length += decodeLastBlock(out, data.charAt(end - 4), data.charAt(end - 3), data.charAt(end - 2), data.charAt(end - 1));
204 | 
205 |         return length;
206 |     }
207 | 
208 |     private int decodeLastBlock(OutputStream out, char c1, char c2, char c3, char c4) throws IOException {
209 |         byte b1, b2, b3, b4;
210 | 
211 |         if (c3 == padding) {
212 |             b1 = decodingTable[c1];
213 |             b2 = decodingTable[c2];
214 | 
215 |             out.write((b1 << 2) | (b2 >> 4));
216 | 
217 |             return 1;
218 |         } else if (c4 == padding) {
219 |             b1 = decodingTable[c1];
220 |             b2 = decodingTable[c2];
221 |             b3 = decodingTable[c3];
222 | 
223 |             out.write((b1 << 2) | (b2 >> 4));
224 |             out.write((b2 << 4) | (b3 >> 2));
225 | 
226 |             return 2;
227 |         } else {
228 |             b1 = decodingTable[c1];
229 |             b2 = decodingTable[c2];
230 |             b3 = decodingTable[c3];
231 |             b4 = decodingTable[c4];
232 | 
233 |             out.write((b1 << 2) | (b2 >> 4));
234 |             out.write((b2 << 4) | (b3 >> 2));
235 |             out.write((b3 << 6) | b4);
236 | 
237 |             return 3;
238 |         }
239 |     }
240 | 
241 |     private int nextI(String data, int i, int finish) {
242 |         while ((i < finish) && ignore(data.charAt(i))) {
243 |             i++;
244 |         }
245 |         return i;
246 |     }
247 | }
248 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/encoders/Encoder.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.encoders;
 7 | 
 8 | import java.io.IOException;
 9 | import java.io.OutputStream;
10 | 
11 | /**
12 |  * Encode and decode byte arrays (typically from binary to 7-bit ASCII 
13 |  * encodings).
14 |  */
15 | public interface Encoder
16 | {
17 |     int encode(byte[] data, int off, int length, OutputStream out) throws IOException;
18 |     
19 |     int decode(byte[] data, int off, int length, OutputStream out) throws IOException;
20 | 
21 |     int decode(String data, OutputStream out) throws IOException;
22 | }
23 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemGenerationException.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.io.pem;
 7 | 
 8 | import java.io.IOException;
 9 | 
10 | @SuppressWarnings("serial")
11 | public class PemGenerationException
12 |     extends IOException
13 | {
14 |     private Throwable cause;
15 | 
16 |     public PemGenerationException(String message, Throwable cause)
17 |     {
18 |         super(message);
19 |         this.cause = cause;
20 |     }
21 | 
22 |     public PemGenerationException(String message)
23 |     {
24 |         super(message);
25 |     }
26 | 
27 |     public Throwable getCause()
28 |     {
29 |         return cause;
30 |     }
31 | }
32 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemHeader.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.io.pem;
 7 | 
 8 | public class PemHeader
 9 | {
10 |     private String name;
11 |     private String value;
12 | 
13 |     public PemHeader(String name, String value)
14 |     {
15 |         this.name = name;
16 |         this.value = value;
17 |     }
18 | 
19 |     public String getName()
20 |     {
21 |         return name;
22 |     }
23 | 
24 |     public String getValue()
25 |     {
26 |         return value;
27 |     }
28 | 
29 |     public int hashCode()
30 |     {
31 |         return getHashCode(this.name) + 31 * getHashCode(this.value);    
32 |     }
33 | 
34 |     public boolean equals(Object o)
35 |     {
36 |         if (!(o instanceof PemHeader))
37 |         {
38 |             return false;
39 |         }
40 | 
41 |         PemHeader other = (PemHeader)o;
42 | 
43 |         return other == this || (isEqual(this.name, other.name) && isEqual(this.value, other.value));
44 |     }
45 | 
46 |     private int getHashCode(String s)
47 |     {
48 |         if (s == null)
49 |         {
50 |             return 1;
51 |         }
52 | 
53 |         return s.hashCode();
54 |     }
55 | 
56 |     private boolean isEqual(String s1, String s2)
57 |     {
58 |         if (s1 == s2)
59 |         {
60 |             return true;
61 |         }
62 | 
63 |         if (s1 == null || s2 == null)
64 |         {
65 |             return false;
66 |         }
67 | 
68 |         return s1.equals(s2);
69 |     }
70 | 
71 | }
72 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemObject.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.io.pem;
 7 | 
 8 | import java.util.ArrayList;
 9 | import java.util.Collections;
10 | import java.util.List;
11 | 
12 | @SuppressWarnings("all")
13 | public class PemObject
14 |     implements PemObjectGenerator
15 | {
16 | 	private static final List EMPTY_LIST = Collections.unmodifiableList(new ArrayList());
17 | 
18 |     private String type;
19 |     private List   headers;
20 |     private byte[] content;
21 | 
22 |     /**
23 |      * Generic constructor for object without headers.
24 |      *
25 |      * @param type pem object type.
26 |      * @param content the binary content of the object.
27 |      */
28 |     public PemObject(String type, byte[] content)
29 |     {
30 |         this(type, EMPTY_LIST, content);
31 |     }
32 | 
33 |     /**
34 |      * Generic constructor for object with headers.
35 |      *
36 |      * @param type pem object type.
37 |      * @param headers a list of PemHeader objects.
38 |      * @param content the binary content of the object.
39 |      */
40 |     public PemObject(String type, List headers, byte[] content)
41 |     {
42 |         this.type = type;
43 |         this.headers = Collections.unmodifiableList(headers);
44 |         this.content = content;
45 |     }
46 | 
47 |     public String getType()
48 |     {
49 |         return type;
50 |     }
51 | 
52 |     public List getHeaders()
53 |     {
54 |         return headers;
55 |     }
56 | 
57 |     public byte[] getContent()
58 |     {
59 |         return content;
60 |     }
61 | 
62 |     public PemObject generate()
63 |         throws PemGenerationException
64 |     {
65 |         return this;
66 |     }
67 | }
68 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemObjectGenerator.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.io.pem;
 7 | 
 8 | public interface PemObjectGenerator
 9 | {
10 |     PemObject generate()
11 |         throws PemGenerationException;
12 | }
13 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemReader.java:
--------------------------------------------------------------------------------
 1 | /*
 2 |  * Copyright (c) 2012-2016 Arne Schwabe
 3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |  */
 5 | 
 6 | package org.spongycastle.util.io.pem;
 7 | 
 8 | import java.io.BufferedReader;
 9 | import java.io.IOException;
10 | import java.io.Reader;
11 | import java.util.ArrayList;
12 | import java.util.List;
13 | 
14 | import org.spongycastle.util.encoders.Base64;
15 | 
16 | public class PemReader extends BufferedReader {
17 |     private static final String BEGIN = "-----BEGIN ";
18 |     private static final String END = "-----END ";
19 | 
20 |     public PemReader(Reader reader) {
21 |         super(reader);
22 |     }
23 | 
24 |     public PemObject readPemObject() throws IOException {
25 |         String line = readLine();
26 | 
27 |         while (line != null && !line.startsWith(BEGIN)) {
28 |             line = readLine();
29 |         }
30 | 
31 |         if (line != null) {
32 |             line = line.substring(BEGIN.length());
33 |             int index = line.indexOf('-');
34 |             String type = line.substring(0, index);
35 | 
36 |             if (index > 0) {
37 |                 return loadObject(type);
38 |             }
39 |         }
40 | 
41 |         return null;
42 |     }
43 | 
44 |     private PemObject loadObject(String type) throws IOException {
45 |         String line;
46 |         String endMarker = END + type;
47 |         StringBuilder buf = new StringBuilder();
48 |         List headers = new ArrayList();
49 | 
50 |         while ((line = readLine()) != null) {
51 |             if (line.indexOf(":") >= 0) {
52 |                 int index = line.indexOf(':');
53 |                 String hdr = line.substring(0, index);
54 |                 String value = line.substring(index + 1).trim();
55 | 
56 |                 headers.add(new PemHeader(hdr, value));
57 | 
58 |                 continue;
59 |             }
60 | 
61 |             if (line.indexOf(endMarker) != -1) {
62 |                 break;
63 |             }
64 | 
65 |             buf.append(line.trim());
66 |         }
67 | 
68 |         if (line == null) {
69 |             throw new IOException(endMarker + " not found");
70 |         }
71 | 
72 |         return new PemObject(type, headers, Base64.decode(buf.toString()));
73 |     }
74 | 
75 | }
76 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/java/org/spongycastle/util/io/pem/PemWriter.java:
--------------------------------------------------------------------------------
  1 | /*
  2 |  * Copyright (c) 2012-2016 Arne Schwabe
  3 |  * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |  */
  5 | 
  6 | package org.spongycastle.util.io.pem;
  7 | 
  8 | import java.io.BufferedWriter;
  9 | import java.io.IOException;
 10 | import java.io.Writer;
 11 | import java.util.Iterator;
 12 | 
 13 | import org.spongycastle.util.encoders.Base64;
 14 | 
 15 | /**
 16 |  * A generic PEM writer, based on RFC 1421
 17 |  */
 18 | @SuppressWarnings("all")
 19 | public class PemWriter
 20 |     extends BufferedWriter
 21 | {
 22 |     private static final int LINE_LENGTH = 64;
 23 | 
 24 |     private final int nlLength;
 25 |     private char[]  buf = new char[LINE_LENGTH];
 26 | 
 27 |     /**
 28 |      * Base constructor.
 29 |      *
 30 |      * @param out output stream to use.
 31 |      */
 32 |     public PemWriter(Writer out)
 33 |     {
 34 |         super(out);
 35 | 
 36 |         String nl = System.getProperty("line.separator");
 37 |         if (nl != null)
 38 |         {
 39 |             nlLength = nl.length();
 40 |         }
 41 |         else
 42 |         {
 43 |             nlLength = 2;
 44 |         }
 45 |     }
 46 | 
 47 |     /**
 48 |      * Return the number of bytes or characters required to contain the
 49 |      * passed in object if it is PEM encoded.
 50 |      *
 51 |      * @param obj pem object to be output
 52 |      * @return an estimate of the number of bytes
 53 |      */
 54 |     public int getOutputSize(PemObject obj)
 55 |     {
 56 |         // BEGIN and END boundaries.
 57 |         int size = (2 * (obj.getType().length() + 10 + nlLength)) + 6 + 4;
 58 | 
 59 |         if (!obj.getHeaders().isEmpty())
 60 |         {
 61 |             for (Iterator it = obj.getHeaders().iterator(); it.hasNext();)
 62 |             {
 63 |                 PemHeader hdr = (PemHeader)it.next();
 64 | 
 65 |                 size += hdr.getName().length() + ": ".length() + hdr.getValue().length() + nlLength;
 66 |             }
 67 | 
 68 |             size += nlLength;
 69 |         }
 70 | 
 71 |         // base64 encoding
 72 |         int dataLen = ((obj.getContent().length + 2) / 3) * 4;
 73 |         
 74 |         size += dataLen + (((dataLen + LINE_LENGTH - 1) / LINE_LENGTH) * nlLength);
 75 | 
 76 |         return size;
 77 |     }
 78 |     
 79 |     public void writeObject(PemObjectGenerator objGen)
 80 |         throws IOException
 81 |     {
 82 |         PemObject obj = objGen.generate();
 83 | 
 84 |         writePreEncapsulationBoundary(obj.getType());
 85 | 
 86 |         if (!obj.getHeaders().isEmpty())
 87 |         {
 88 |             for (Iterator it = obj.getHeaders().iterator(); it.hasNext();)
 89 |             {
 90 |                 PemHeader hdr = (PemHeader)it.next();
 91 | 
 92 |                 this.write(hdr.getName());
 93 |                 this.write(": ");
 94 |                 this.write(hdr.getValue());
 95 |                 this.newLine();
 96 |             }
 97 | 
 98 |             this.newLine();
 99 |         }
100 |         
101 |         writeEncoded(obj.getContent());
102 |         writePostEncapsulationBoundary(obj.getType());
103 |     }
104 | 
105 |     private void writeEncoded(byte[] bytes)
106 |         throws IOException
107 |     {
108 |         bytes = Base64.encode(bytes);
109 | 
110 |         for (int i = 0; i < bytes.length; i += buf.length)
111 |         {
112 |             int index = 0;
113 | 
114 |             while (index != buf.length)
115 |             {
116 |                 if ((i + index) >= bytes.length)
117 |                 {
118 |                     break;
119 |                 }
120 |                 buf[index] = (char)bytes[i + index];
121 |                 index++;
122 |             }
123 |             this.write(buf, 0, index);
124 |             this.newLine();
125 |         }
126 |     }
127 | 
128 |     private void writePreEncapsulationBoundary(
129 |         String type)
130 |         throws IOException
131 |     {
132 |         this.write("-----BEGIN " + type + "-----");
133 |         this.newLine();
134 |     }
135 | 
136 |     private void writePostEncapsulationBoundary(
137 |         String type)
138 |         throws IOException
139 |     {
140 |         this.write("-----END " + type + "-----");
141 |         this.newLine();
142 |     }
143 | }
144 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/arm64-v8a/libjbcrypto.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/arm64-v8a/libjbcrypto.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/arm64-v8a/libopenvpn.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/arm64-v8a/libopenvpn.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/arm64-v8a/libopvpnutil.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/arm64-v8a/libopvpnutil.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/arm64-v8a/libovpnexec.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/arm64-v8a/libovpnexec.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/armeabi-v7a/libjbcrypto.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/armeabi-v7a/libjbcrypto.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/armeabi-v7a/libopenvpn.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/armeabi-v7a/libopenvpn.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/armeabi-v7a/libopvpnutil.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/armeabi-v7a/libopvpnutil.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/armeabi-v7a/libovpnexec.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/armeabi-v7a/libovpnexec.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86/libjbcrypto.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86/libjbcrypto.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86/libopenvpn.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86/libopenvpn.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86/libopvpnutil.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86/libopvpnutil.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86/libovpnexec.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86/libovpnexec.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86_64/libjbcrypto.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86_64/libjbcrypto.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86_64/libopenvpn.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86_64/libopenvpn.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86_64/libopvpnutil.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86_64/libopvpnutil.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/jniLibs/x86_64/libovpnexec.so:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/jniLibs/x86_64/libovpnexec.so


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_archive.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_archive.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_copy_holo_light.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_copy_holo_light.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_log.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_menu_log.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_quick.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_quick.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_empty_halo.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_empty_halo.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_offline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_offline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_outline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/ic_stat_vpn_outline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-hdpi/vpn_item_settings.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-hdpi/vpn_item_settings.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_archive.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_archive.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_copy_holo_light.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_copy_holo_light.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_log.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_menu_log.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_quick.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_quick.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_empty_halo.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_empty_halo.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_offline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_offline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_outline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/ic_stat_vpn_outline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-mdpi/vpn_item_settings.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-mdpi/vpn_item_settings.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_archive.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_archive.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_copy_holo_light.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_copy_holo_light.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_log.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_menu_log.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_quick.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_quick.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_empty_halo.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_empty_halo.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_offline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_offline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_outline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/ic_stat_vpn_outline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xhdpi/vpn_item_settings.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xhdpi/vpn_item_settings.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_menu_copy_holo_light.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_menu_copy_holo_light.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_menu_log.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_menu_log.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_quick.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_quick.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_empty_halo.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_empty_halo.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_offline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_offline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_outline.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable-xxhdpi/ic_stat_vpn_outline.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/drawable/ic_notification.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/master/android/vpnLib/src/main/res/drawable/ic_notification.png


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/layout/api_confirm.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!-- Copyright (C) 2011 The Android Open Source Project
 3 | 
 4 |      Licensed under the Apache License, Version 2.0 (the "License");
 5 |      you may not use this file except in compliance with the License.
 6 |      You may obtain a copy of the License at
 7 | 
 8 |           http://www.apache.org/licenses/LICENSE-2.0
 9 | 
10 |      Unless required by applicable law or agreed to in writing, software
11 |      distributed under the License is distributed on an "AS IS" BASIS,
12 |      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
13 |      implied.
14 |      See the License for the specific language governing permissions and
15 |      limitations under the License.
16 | -->
17 | 
18 | <ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
19 |             xmlns:tools="http://schemas.android.com/tools"
20 |         android:layout_width="match_parent"
21 |         android:layout_height="wrap_content">
22 |     <LinearLayout android:layout_width="match_parent"
23 |             android:layout_height="wrap_content"
24 |             android:orientation="vertical"
25 |             android:padding="20dp">
26 | 
27 |         <LinearLayout android:layout_width="match_parent"
28 |                 android:layout_height="wrap_content"
29 |                 android:orientation="horizontal"
30 |                 tools:ignore="UseCompoundDrawables"
31 |                 android:gravity="center_vertical">
32 | 
33 |             <ImageView android:id="@+id/icon"
34 |                     android:contentDescription="@string/permission_icon_app"
35 |                     android:layout_width="@android:dimen/app_icon_size"
36 |                     android:layout_height="@android:dimen/app_icon_size"
37 |                     android:paddingRight="5dp"/>
38 | 
39 |             <TextView android:id="@+id/prompt"
40 |                     android:layout_width="fill_parent"
41 |                     android:layout_height="wrap_content"
42 |                     android:textSize="18sp"/>
43 |         </LinearLayout>
44 | 
45 |         <TextView android:id="@+id/warning"
46 |                 android:layout_width="fill_parent"
47 |                 android:layout_height="wrap_content"
48 |                 android:paddingTop="5dp"
49 |                 android:paddingBottom="5dp"
50 |                 android:text="@string/remote_warning"
51 |                 android:textSize="18sp"/>
52 | 
53 |         <CheckBox android:id="@+id/check"
54 |                 android:layout_width="fill_parent"
55 |                 android:layout_height="wrap_content"
56 |                 android:text="@string/remote_trust"
57 |                 android:textSize="20sp"
58 |                 android:checked="false"/>
59 |     </LinearLayout>
60 | </ScrollView>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/layout/import_as_config.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | 
 3 | <!--
 4 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 5 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 6 |   -->
 7 | 
 8 | <LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
 9 |     android:layout_width="match_parent"
10 |     android:padding="20dp"
11 |     android:layout_height="match_parent"
12 |     android:orientation="vertical">
13 | 
14 |     <EditText
15 |         android:id="@+id/as_servername"
16 |         android:layout_width="match_parent"
17 |         android:layout_height="wrap_content"
18 |         android:layout_marginLeft="4dp"
19 |         android:layout_marginTop="4dp"
20 |         android:layout_marginRight="4dp"
21 |         android:layout_marginBottom="4dp"
22 |         android:hint="@string/as_servername"
23 |         android:inputType="textUri" />
24 | 
25 |     <EditText
26 |         android:id="@+id/username"
27 |         android:layout_width="match_parent"
28 |         android:layout_height="wrap_content"
29 |         android:layout_marginLeft="4dp"
30 |         android:layout_marginTop="8dp"
31 |         android:layout_marginRight="4dp"
32 |         android:layout_marginBottom="4dp"
33 |         android:hint="@string/auth_username"
34 |         android:inputType="textEmailAddress" />
35 | 
36 |     <EditText
37 |         android:id="@+id/password"
38 |         android:layout_width="match_parent"
39 |         android:layout_height="wrap_content"
40 |         android:layout_marginLeft="4dp"
41 |         android:layout_marginTop="4dp"
42 |         android:layout_marginRight="4dp"
43 |         android:layout_marginBottom="4dp"
44 |         android:hint="@string/password"
45 |         android:inputType="textPassword" />
46 | 
47 |     <CheckBox
48 |         android:id="@+id/request_autologin"
49 |         android:layout_width="match_parent"
50 |         android:layout_height="wrap_content"
51 |         android:layout_marginLeft="4dp"
52 |         android:layout_marginTop="4dp"
53 |         android:layout_marginRight="4dp"
54 |         android:layout_marginBottom="16dp"
55 |         android:text="@string/request_autologin" />
56 | 
57 | </LinearLayout>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/layout/launchvpn.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
 8 |     android:orientation="vertical" android:layout_width="match_parent"
 9 |     android:layout_height="match_parent">
10 |     <ProgressBar
11 |         android:layout_gravity="center"
12 |         style="?android:attr/progressBarStyleLarge"
13 |         android:layout_width="wrap_content"
14 |         android:layout_height="wrap_content" />
15 | </FrameLayout>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/layout/userpass.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | 
 3 | <!--
 4 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 5 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 6 |   -->
 7 | 
 8 | <LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
 9 |               android:orientation="vertical"
10 |               android:layout_width="match_parent"
11 |               android:layout_height="match_parent">
12 | 
13 |     <EditText
14 |             android:id="@+id/username"
15 |             android:inputType="textEmailAddress"
16 |             android:layout_width="match_parent"
17 |             android:layout_height="wrap_content"
18 |             android:layout_marginTop="8dp"
19 |             android:layout_marginLeft="4dp"
20 |             android:layout_marginRight="4dp"
21 |             android:layout_marginBottom="4dp"
22 |             android:hint="@string/auth_username" />
23 |     <EditText
24 |             android:id="@+id/password"
25 |             android:inputType="textPassword"
26 |             android:layout_width="match_parent"
27 |             android:layout_height="wrap_content"
28 |             android:layout_marginTop="4dp"
29 |             android:layout_marginLeft="4dp"
30 |             android:layout_marginRight="4dp"
31 |             android:layout_marginBottom="4dp"
32 |             android:hint="@string/password"/>
33 |     <CheckBox
34 |             android:id="@+id/show_password"
35 |             android:layout_width="match_parent"
36 |             android:layout_height="wrap_content"
37 |             android:layout_marginTop="4dp"
38 |             android:layout_marginLeft="4dp"
39 |             android:text="@string/show_password"
40 |             android:layout_marginRight="4dp"
41 |             />
42 | 
43 |     <CheckBox
44 |             android:id="@+id/save_password"
45 |             android:layout_width="match_parent"
46 |             android:layout_height="wrap_content"
47 |             android:layout_marginTop="4dp"
48 |             android:layout_marginLeft="4dp"
49 |             android:text="@string/save_password"
50 |             android:layout_marginRight="4dp"
51 |             android:layout_marginBottom="16dp"/>
52 | 
53 | 
54 | </LinearLayout>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values-sw600dp/dimens.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 |     <bool name="logSildersAlwaysVisible">true</bool>
 9 | 
10 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values-sw600dp/styles.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 | 
 9 |     <dimen name="stdpadding">16dp</dimen>
10 | 
11 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values-v29/bools.xml:
--------------------------------------------------------------------------------
1 | <?xml version="1.0" encoding="utf-8"?>
2 | <!--
3 |   ~ Copyright (c) 2012-2019 Arne Schwabe
4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
5 |   -->
6 | 
7 | <resources>
8 |     <bool name="supportFileScheme">false</bool>
9 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/arrays.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 | 	<!--  Keep the order the same as the TYPE_ constants in VPNProfile -->
 9 |     <string-array name="vpn_types">
10 |         <item>Certificates</item>
11 |         <item>PKCS12 File</item>
12 |         <item>Android Certificate</item>
13 |         <item>Username/Password</item>
14 |         <item>Static Keys</item>
15 |         <item>User/PW + Certificates</item>
16 |         <item>User/PW + PKCS12 </item>
17 |         <item>User/PW + Android</item>
18 |         <item>External Auth Provider</item>
19 |     </string-array>
20 |     <string-array name="tls_directions_entries">
21 |         <item translatable="false">0</item>
22 |         <item translatable="false">1</item>
23 |         <item>Unspecified</item>
24 |         <item>Encryption (--tls-crypt)</item>
25 |         <item>TLS Crypt V2</item>
26 |     </string-array>
27 |     <string-array name="crm_entries">
28 |         <item>No reconnection retries</item>
29 |         <item>One reconnection retry</item>
30 |         <item>Five reconnection retries</item>
31 |         <item>Fifty reconnection retries</item>
32 |         <item>Unlimited reconnection retries</item>
33 |     </string-array>
34 |     <string-array name="auth_retry_type">
35 |         <item>Disconnect, forget password</item>
36 |         <item>Disconnect, keep password</item>
37 |         <item>Ignore, retry</item>
38 |     </string-array>
39 | </resources>
40 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/attrs.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | 
 3 | <!--
 4 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 5 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 6 |   -->
 7 | 
 8 | <resources>
 9 |      <declare-styleable name="FileSelectLayout">
10 |        <attr name="fileTitle" format="string|reference" />
11 |       <attr name="certificate" format="boolean" />
12 | <!--     <attr name="taskid" format="integer" /> -->
13 |        <attr name="showClear" format="boolean" />
14 |    </declare-styleable>
15 | 
16 |     <declare-styleable name="PagerSlidingTabStrip">
17 |         <attr name="pstsIndicatorColor" format="color" />
18 |         <attr name="pstsUnderlineColor" format="color" />
19 |         <attr name="pstsDividerColor" format="color" />
20 |         <attr name="pstsDividerWidth" format="dimension" />
21 |         <attr name="pstsIndicatorHeight" format="dimension" />
22 |         <attr name="pstsUnderlineHeight" format="dimension" />
23 |         <attr name="pstsDividerPadding" format="dimension" />
24 |         <attr name="pstsTabPaddingLeftRight" format="dimension" />
25 |         <attr name="pstsScrollOffset" format="dimension" />
26 |         <attr name="pstsTabBackground" format="reference" />
27 |         <attr name="pstsShouldExpand" format="boolean" />
28 |         <attr name="pstsTextAllCaps" format="boolean" />
29 |         <attr name="pstsPaddingMiddle" format="boolean" />
30 |         <attr name="pstsTextStyle">
31 |             <flag name="normal" value="0x0" />
32 |             <flag name="bold" value="0x1" />
33 |             <flag name="italic" value="0x2" />
34 |         </attr>
35 |         <attr name="pstsTextSelectedStyle">
36 |             <flag name="normal" value="0x0" />
37 |             <flag name="bold" value="0x1" />
38 |             <flag name="italic" value="0x2" />
39 |         </attr>
40 |         <attr name="pstsTextAlpha" format="float" />
41 |         <attr name="pstsTextSelectedAlpha" format="float" />
42 |     </declare-styleable>
43 | </resources>
44 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/bools.xml:
--------------------------------------------------------------------------------
1 | <?xml version="1.0" encoding="utf-8"?>
2 | <!--
3 |   ~ Copyright (c) 2012-2019 Arne Schwabe
4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
5 |   -->
6 | 
7 | <resources>
8 |     <bool name="supportFileScheme">true</bool>
9 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/colours.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 |     <!-- Indigo -->
 9 |     <!-- OpenVPN colours #203155, #C66D0D -->
10 |     <color name="primary">#3F51B5</color>      <!--500-->
11 |     <color name="primary_dark">#303F9F</color> <!--700-->
12 |     <color name="accent">#FFA726</color>       <!-- Orange 400 -->
13 |     <color name="gelb">#ffff00</color>
14 |     <color name="rot">#ff0000</color>
15 | 
16 |     <color name="switchbar">@android:color/darker_gray</color>
17 | 
18 | 
19 |     <color name="background_tab_pressed">#1AFFFFFF</color>
20 | 
21 | 
22 |     <color name="dataIn">#ff0000</color>
23 |     <color name="dataOut">#0000ff</color>
24 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/dimens.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 |     <dimen name="paddingItemsSidebarLog">20dp</dimen>
 9 |     <dimen name="stdpadding">8dp</dimen>
10 |     <bool name="logSildersAlwaysVisible">false</bool>
11 | 
12 |     <dimen name="diameter">48dp</dimen>
13 |     <dimen name="elevation_low">1dp</dimen>
14 |     <dimen name="elevation_high">4dp</dimen>
15 |     <dimen name="add_button_margin">16dp</dimen>
16 |     <dimen name="add_button_margin_topfab">96dp</dimen>
17 |     <dimen name="round_button_diameter">56dp</dimen>
18 |     <dimen name="switchbar_pad">16dp</dimen>
19 |     <dimen name="vpn_setting_padding">16dp</dimen>
20 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/ic_launcher_background.xml:
--------------------------------------------------------------------------------
1 | <?xml version="1.0" encoding="utf-8"?>
2 | <resources>
3 |     <color name="ic_launcher_background">#C0FDD9</color>
4 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/plurals.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8" ?>
 2 | <resources>
 3 |     <plurals name="months_left">
 4 |         <item quantity="one">One month left</item>
 5 |         <item quantity="other">%d months left</item>
 6 |     </plurals>
 7 |     <plurals name="days_left">
 8 |         <item quantity="one">One day left</item>
 9 |         <item quantity="other">%d days left</item>
10 |     </plurals>
11 |     <plurals name="hours_left">
12 |         <item quantity="one">One hour left</item>
13 |         <item quantity="other">%d hours left</item>
14 |     </plurals>
15 |     <plurals name="minutes_left">
16 |         <item quantity="one">One minute left</item>
17 |         <item quantity="other">%d minutes left</item>
18 |     </plurals>
19 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/refs.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <resources>
 8 |     <drawable name="ic_menu_close_clear_cancel">@android:drawable/ic_menu_close_clear_cancel</drawable>
 9 |     <drawable name="ic_menu_play">@android:drawable/ic_media_play</drawable>
10 |     <drawable name="ic_menu_pause">@android:drawable/ic_media_pause</drawable>
11 |     <!--<drawable name="ic_menu_share">@android:drawable/ic_menu_share </drawable>
12 |     <drawable name="ic_menu_save">@android:drawable/ic_menu_save</drawable>
13 |     <drawable name="ic_menu_view">@android:drawable/ic_menu_view</drawable>
14 |     <drawable name="ic_menu_delete">@android:drawable/ic_menu_delete</drawable>
15 |     <drawable name="ic_menu_edit">@android:drawable/ic_menu_edit</drawable>
16 |     <drawable name="ic_menu_import">@drawable/ic_menu_archive</drawable>
17 |     <drawable name="vpn_item_edit">@drawable/vpn_item_settings </drawable>
18 |     <drawable name="ic_menu_add">@android:drawable/ic_menu_add</drawable>
19 |     <drawable name="ic_dialog_alert">@android:drawable/ic_dialog_alert</drawable>
20 |     <drawable name="ic_menu_add_grey">@android:drawable/ic_menu_add</drawable>
21 |     <drawable name="ic_menu_import_grey">@drawable/ic_menu_archive</drawable>
22 |     <drawable name="ic_menu_delete_grey">@android:drawable/ic_menu_delete</drawable>
23 |     <drawable name="ic_menu_copy">@drawable/ic_menu_copy_holo_light</drawable>
24 |     <drawable name="ic_receipt">@drawable/ic_menu_log</drawable>-->
25 | 
26 | 
27 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/strings.xml:
--------------------------------------------------------------------------------
  1 | <?xml version="1.0" encoding="utf-8"?> <!--
  2 |   ~ Copyright (c) 2012-2016 Arne Schwabe
  3 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
  4 |   -->
  5 | <resources>
  6 |     <string name="app">OpenVPN for Android</string>
  7 |     <string name="address">Server Address:</string>
  8 |     <string name="port">Server Port:</string>
  9 |     <string name="location">Location</string>
 10 |     <string name="cant_read_folder">Unable to read directory</string>
 11 |     <string name="select">Select</string>
 12 |     <string name="cancel">Cancel</string>
 13 |     <string name="no_data">No Data</string>
 14 |     <string name="useLZO">LZO Compression</string>
 15 |     <string name="client_no_certificate">No Certificate</string>
 16 |     <string name="client_certificate_title">Client Certificate</string>
 17 |     <string name="client_key_title">Client Certificate Key</string>
 18 |     <string name="client_pkcs12_title">PKCS12 File</string>
 19 |     <string name="ca_title">CA Certificate</string>
 20 |     <string name="no_certificate">You must select a certificate</string>
 21 |     <string name="copyright_guicode">Source code and issue tracker available at https://github.com/schwabe/ics-openvpn/</string>
 22 |     <string name="copyright_others">This program uses the following components; see the source code for full details on the licenses</string>
 23 |     <string name="about">About</string>
 24 |     <string name="vpn_list_title">Profiles</string>
 25 |     <string name="vpn_type">Type</string>
 26 |     <string name="pkcs12pwquery">PKCS12 Password</string>
 27 |     <string name="file_select">Select…</string>
 28 |     <string name="file_nothing_selected">You must select a file</string>
 29 |     <string name="useTLSAuth">Use TLS Authentication</string>
 30 |     <string name="tls_direction">TLS Direction</string>
 31 |     <string name="ipv6_dialog_tile">Enter IPv6 Address/Netmask in CIDR Format (e.g. 2000:dd::23/64)</string>
 32 |     <string name="ipv4_dialog_title">Enter IPv4 Address/Netmask in CIDR Format (e.g. 1.2.3.4/24)</string>
 33 |     <string name="ipv4_address">IPv4 Address</string>
 34 |     <string name="ipv6_address">IPv6 Address</string>
 35 |     <string name="custom_option_warning">Enter custom OpenVPN options. Use with caution. Also note that many of the tun related OpenVPN settings cannot be supported by design of the VPNSettings. If you think an important option is missing contact the author</string>
 36 |     <string name="auth_username">Username</string>
 37 |     <string name="auth_pwquery">Password</string>
 38 |     <string name="static_keys_info">For the static configuration the TLS Auth Keys will be used as static keys</string>
 39 |     <string name="configure_the_vpn">Configure the VPN</string>
 40 |     <string name="menu_add_profile">Add Profile</string>
 41 |     <string name="add_profile_name_prompt">Enter a name identifying the new Profile</string>
 42 |     <string name="duplicate_profile_name">Please enter a unique Profile Name</string>
 43 |     <string name="profilename">Profile Name</string>
 44 |     <string name="no_keystore_cert_selected">You must select a User certificate</string>
 45 |     <string name="no_ca_cert_selected">You must select a CA certificate</string>
 46 |     <string name="no_error_found">No error found</string>
 47 |     <string name="config_error_found">Error in Configuration</string>
 48 |     <string name="ipv4_format_error">Error parsing the IPv4 address</string>
 49 |     <string name="custom_route_format_error">Error parsing the custom routes</string>
 50 |     <string name="pw_query_hint">(leave empty to query on demand)</string>
 51 |     <string name="vpn_shortcut">OpenVPN Shortcut</string>
 52 |     <string name="vpn_launch_title">Connecting to VPN…</string>
 53 |     <string name="shortcut_profile_notfound">Profile specified in shortcut not found</string>
 54 |     <string name="random_host_prefix">Random Host Prefix</string>
 55 |     <string name="random_host_summary">Adds 6 random chars in front of hostname</string>
 56 |     <string name="custom_config_title">Enable Custom Options</string>
 57 |     <string name="custom_config_summary">Specify custom options. Use with care!</string>
 58 |     <string name="route_rejected">Route rejected by Android</string>
 59 |     <string name="cancel_connection">Disconnect</string>
 60 |     <string name="cancel_connection_long">Disconnect VPN</string>
 61 |     <string name="clear_log">clear log</string>
 62 |     <string name="title_cancel">Cancel Confirmation</string>
 63 |     <string name="cancel_connection_query">Disconnect the connected VPN/cancel the connection attempt?</string>
 64 |     <string name="remove_vpn">Remove VPN</string>
 65 |     <string name="check_remote_tlscert">Checks whether the server uses a certificate with TLS Server extensions (--remote-cert-tls server)</string>
 66 |     <string name="check_remote_tlscert_title">Expect TLS server certificate</string>
 67 |     <string name="remote_tlscn_check_summary">Checks the Remote Server Certificate Subject DN</string>
 68 |     <string name="remote_tlscn_check_title">Certificate Hostname Check</string>
 69 |     <string name="enter_tlscn_dialog">Specify the check used to verify the remote certificate DN (e.g. C=DE, L=Paderborn, OU=Avian IP Carriers, CN=openvpn.blinkt.de)\n\nSpecify the complete DN or the RDN (openvpn.blinkt.de in the example) or an RDN prefix for verification.\n\nWhen using RDN prefix \"Server\" matches \"Server-1\" and \"Server-2\"\n\nLeaving the text field empty will check the RDN against the server hostname.\n\nFor more details see the OpenVPN 2.3.1+ manpage under —verify-x509-name</string>
 70 |     <string name="enter_tlscn_title">Remote certificate subject</string>
 71 |     <string name="tls_key_auth">Enables the TLS Key Authentication</string>
 72 |     <string name="tls_auth_file">TLS Auth File</string>
 73 |     <string name="pull_on_summary">Requests IP addresses, routes and timing options from the server.</string>
 74 |     <string name="pull_off_summary">No information is requested from the server. Settings need to be specified below.</string>
 75 |     <string name="use_pull">Pull Settings</string>
 76 |     <string name="dns">DNS</string>
 77 |     <string name="override_dns">Override DNS Settings by Server</string>
 78 |     <string name="dns_override_summary">Use your own DNS Servers</string>
 79 |     <string name="searchdomain">searchDomain</string>
 80 |     <string name="dns1_summary">DNS Server to be used.</string>
 81 |     <string name="dns_server">DNS Server</string>
 82 |     <string name="secondary_dns_message">Secondary DNS Server used if the normal DNS Server cannot be reached.</string>
 83 |     <string name="backup_dns">Backup DNS Server</string>
 84 |     <string name="ignored_pushed_routes">Ignore pushed routes</string>
 85 |     <string name="ignore_routes_summary">Ignore routes pushed by the server.</string>
 86 |     <string name="default_route_summary">Redirects all Traffic over the VPN</string>
 87 |     <string name="use_default_title">Use default Route</string>
 88 |     <string name="custom_route_message">Enter custom routes. Only enter destination in CIDR format. \"10.0.0.0/8 2002::/16\" would direct the networks 10.0.0.0/8 and 2002::/16 over the VPN.</string>
 89 |     <string name="custom_route_message_excluded">Routes that should NOT be routed over the VPN. Use the same syntax as for included routes.</string>
 90 |     <string name="custom_routes_title">Custom Routes</string>
 91 |     <string name="custom_routes_title_excluded">Excluded Networks</string>
 92 |     <string name="log_verbosity_level">Log verbosity level</string>
 93 |     <string name="float_summary">Allows authenticated packets from any IP</string>
 94 |     <string name="float_title">Allow floating server</string>
 95 |     <string name="custom_options_title">Custom Options</string>
 96 |     <string name="edit_vpn">Edit VPN Settings</string>
 97 |     <string name="remove_vpn_query">Remove the VPN Profile \'%s\'?</string>
 98 |     <string name="tun_error_helpful">On some custom ICS images the permission on /dev/tun might be wrong, or the tun module might be missing completely. For CM9 images try the fix ownership option under general settings</string>
 99 |     <string name="tun_open_error">Failed to open the tun interface</string>
100 |     <string name="error">"Error: "</string>
101 |     <string name="clear">Clear</string>
102 |     <string name="last_openvpn_tun_config">Opening tun interface:</string>
103 |     <string name="local_ip_info">Local IPv4: %1$s/%2$d IPv6: %3$s MTU: %4$d</string>
104 |     <string name="dns_server_info">DNS Server: %1$s, Domain: %2$s</string>
105 |     <string name="routes_info_incl">Routes: %1$s %2$s</string>
106 |     <string name="routes_info_excl">Routes excluded: %1$s %2$s</string>
107 |     <string name="routes_debug">VpnService routes installed: %1$s %2$s</string>
108 |     <string name="ip_not_cidr">Got interface information %1$s and %2$s, assuming second address is peer address of remote. Using /32 netmask for local IP. Mode given by OpenVPN is \"%3$s\".</string>
109 |     <string name="route_not_cidr">Cannot make sense of %1$s and %2$s as IP route with CIDR netmask, using /32 as netmask.</string>
110 |     <string name="route_not_netip">Corrected route %1$s/%2$s to %3$s/%2$s</string>
111 |     <string name="keychain_access">Cannot access the Android Keychain Certificates. This can be caused by a firmware upgrade or by restoring a backup of the app/app settings. Please edit the VPN and reselect the certificate under basic settings to recreate the permission to access the certificate.</string>
112 |     <string name="version_info">%1$s %2$s</string>
113 |     <string name="send_logfile">Send log file</string>
114 |     <string name="send">Send</string>
115 |     <string name="ics_openvpn_log_file">ICS OpenVPN log file</string>
116 |     <string name="copied_entry">Copied log entry to clip board</string>
117 |     <string name="tap_mode">Tap Mode</string>
118 |     <string name="faq_tap_mode">Tap Mode is not possible with the non root VPN API. Therefore this application cannot provide tap support</string>
119 |     <string name="tap_faq2">Again? Are you kidding? No, tap mode is really not supported and sending more mail asking if it will be supported will not help.</string>
120 |     <string name="tap_faq3">A third time? Actually, one could write a tap emulator based on tun that would add layer2 information on send and strip layer2 information on receive. But this tap emulator would also have to implement ARP and possibly a DHCP client. I am not aware of anybody doing any work in this direction. Contact me if you want to start coding on this.</string>
121 |     <string name="faq">FAQ</string>
122 |     <string name="copying_log_entries">Copying log entries</string>
123 |     <string name="faq_copying">To copy a single log entry press and hold on the log entry. To copy/send the whole log use the Send Log option. Use the hardware menu button, if the button is not visible in the GUI.</string>
124 |     <string name="faq_shortcut">Shortcut to start</string>
125 |     <string name="faq_howto_shortcut">You can place a shortcut to start OpenVPN on your desktop. Depending on your homescreen program you will have to add either a shortcut or a widget.</string>
126 |     <string name="no_vpn_support_image">Your image does not support the VPNService API, sorry :(</string>
127 |     <string name="encryption">Encryption</string>
128 |     <string name="cipher_dialog_title">Enter encryption method</string>
129 |     <string name="chipher_dialog_message">Enter the encryption cipher algorithm used by OpenVPN. Leave empty to use default cipher.</string>
130 |     <string name="auth_dialog_message">Enter the authentication digest used for OpenVPN. Leave empty to use default digest.</string>
131 |     <string name="settings_auth">Authentication/Encryption</string>
132 |     <string name="file_explorer_tab">File Explorer</string>
133 |     <string name="inline_file_tab">Inline File</string>
134 |     <string name="error_importing_file">Error importing File</string>
135 |     <string name="import_error_message">Could not import File from filesystem</string>
136 |     <string name="inline_file_data">[[Inline file data]]</string>
137 |     <string name="opentun_no_ipaddr">Refusing to open tun device without IP information</string>
138 |     <string name="menu_import">Import Profile from ovpn file</string>
139 |     <string name="menu_import_short">Import</string>
140 |     <string name="import_content_resolve_error">Could not read profile to import</string>
141 |     <string name="error_reading_config_file">Error reading config file</string>
142 |     <string name="add_profile">add Profile</string>
143 |     <string name="import_could_not_open">Could not find file %1$s mentioned in the imported config file</string>
144 |     <string name="importing_config">Importing config file from source %1$s</string>
145 |     <string name="import_warning_custom_options">Your configuration had a few configuration options that are not mapped to UI configurations. These options were added as custom configuration options. The custom configuration is displayed below:</string>
146 |     <string name="import_done">Done reading config file.</string>
147 |     <string name="nobind_summary">Do not bind to local address and port</string>
148 |     <string name="no_bind">No local binding</string>
149 |     <string name="import_configuration_file">Import configuration file</string>
150 |     <string name="faq_security_title">Security considerations</string>
151 |     <string name="faq_security">"As OpenVPN is security sensitive a few notes about security are sensible. All data on the sdcard is inherently insecure. Every app can read it (for example this program requires no special sd card rights). The data of this application can only be read by the application itself. By using the import option for cacert/cert/key in the file dialog the data is stored in the VPN profile. The VPN profiles are only accessible by this application. (Do not forget to delete the copies on the sd card afterwards). Even though accessible only by this application the data is still unencrypted. By rooting the telephone or other exploits it may be possible to retrieve the data. Saved passwords are stored in plain text as well. For pkcs12 files it is highly recommended that you import them into the android keystore."</string>
152 |     <string name="import_vpn">Import</string>
153 |     <string name="broken_image_cert_title">Error showing certificate selection</string>
154 |     <string name="broken_image_cert">Got an exception trying to show the Android 4.0+ certificate selection dialog. This should never happen as this a standard feature of Android 4.0+. Maybe your Android ROM support for certificate storage is broken</string>
155 |     <string name="ipv4">IPv4</string>
156 |     <string name="ipv6">IPv6</string>
157 |     <string name="speed_waiting">Waiting for state message…</string>
158 |     <string name="converted_profile">imported profile</string>
159 |     <string name="converted_profile_i">imported profile %d</string>
160 |     <string name="broken_images">Broken Images</string>
161 |     <string name="broken_images_faq">&lt;p&gt;Official HTC images are known to have a strange routing problem causing traffic not to flow through the tunnel (See also &lt;a href="https://github.com/schwabe/ics-openvpn/issues/18"&gt;Issue 18&lt;/a&gt; in the bug tracker.)&lt;/p&gt;&lt;p&gt;Older official SONY images from Xperia Arc S and Xperia Ray have been reported to be missing the VPNService completely from the image. (See also &lt;a href="https://github.com/schwabe/ics-openvpn/issues/29"&gt;Issue 29&lt;/a&gt; in the bug tracker.)&lt;/p&gt;&lt;p&gt;On custom build images the tun module might be missing or the rights of /dev/tun might be wrong. Some CM9 images need the "Fix ownership" option under "Device specific hacks" enabled.&lt;/p&gt;&lt;p&gt;Most importantly: If your device has a broken Android image, report it to your vendor. The more people who report an issue to the vendor, the more likely they are to fix it.&lt;/p&gt;</string>
162 |     <string name="pkcs12_file_encryption_key">PKCS12 File Encryption Key</string>
163 |     <string name="private_key_password">Private Key Password</string>
164 |     <string name="password">Password</string>
165 |     <string name="file_icon">file icon</string>
166 |     <string name="tls_authentication">TLS Authentication/Encryption</string>
167 |     <string name="generated_config">Generated Config</string>
168 |     <string name="generalsettings">Settings</string>
169 |     <string name="owner_fix_summary">Tries to set the owner of /dev/tun to system. Some CM9 images need this to make the VPNService API work. Requires root.</string>
170 |     <string name="owner_fix">Fix ownership of /dev/tun</string>
171 |     <string name="generated_config_summary">Shows the generated OpenVPN Configuration File</string>
172 |     <string name="edit_profile_title">Editing \"%s\"</string>
173 |     <string name="building_configration">Building configuration…</string>
174 |     <string name="netchange_summary">Turning this option on will force a reconnect if the network state is changed (e.g. WiFi to/from mobile)</string>
175 |     <string name="netchange">Reconnect on network change</string>
176 |     <string name="netstatus">Network Status: %s</string>
177 |     <string name="extracahint">The CA cert is usually returned from the Android keystore. Specify a separate certificate if you get certificate verification errors.</string>
178 |     <string name="select_file">Select</string>
179 |     <string name="keychain_nocacert">No CA Certificate returned while reading from Android keystore. Authentication will probably fail.</string>
180 |     <string name="show_log_summary">Shows the log window on connect. The log window can always be accessed from the notification status.</string>
181 |     <string name="show_log_window">Show log window</string>
182 |     <string name="mobile_info">%10$s %9$s running on %3$s %1$s (%2$s), Android %6$s (%7$s) API %4$d, ABI %5$s, (%8$s)</string>
183 |     <string name="error_rsa_sign">Error signing with Android keystore key %1$s: %2$s</string>
184 |     <string name="error_extapp_sign">Error signing with external authenticator app (%3$s): %1$s: %2$s</string>
185 |     <string name="faq_system_dialogs">The VPN connection warning telling you that this app can intercept all traffic is imposed by the system to prevent abuse of the VPNService API.\nThe VPN connection notification (The key symbol) is also imposed by the Android system to signal an ongoing VPN connection. On some images this notification plays a sound.\nAndroid introduced these system dialogs for your own safety and made sure that they cannot be circumvented. (On some images this unfortunately includes a notification sound)</string>
186 |     <string name="faq_system_dialogs_title">Connection warning and notification sound</string>
187 |     <string name="translationby">English translation by Arne Schwabe&lt;arne@rfc2549.org&gt;</string>
188 |     <string name="ipdns">IP and DNS</string>
189 |     <string name="basic">Basic</string>
190 |     <string name="routing">Routing</string>
191 |     <string name="obscure">Obscure OpenVPN Settings. Normally not needed.</string>
192 |     <string name="advanced">Advanced</string>
193 |     <string name="export_config_title">ICS Openvpn Config</string>
194 |     <string name="warn_no_dns">No DNS servers being used. Name resolution may not work. Consider setting custom DNS Servers. Please also note that Android will keep using your proxy settings specified for your mobile/Wi-Fi connection when no DNS servers are set.</string>
195 |     <string name="dns_add_error">Could not add DNS Server \"%1$s\", rejected by the system: %2$s</string>
196 |     <string name="ip_add_error">Could not configure IP Address \"%1$s\", rejected by the system: %2$s</string>
197 |     <string name="faq_howto">&lt;p&gt;Get a working config (tested on your computer or download from your provider/organisation)&lt;/p&gt;&lt;p&gt;If it is a single file with no extra pem/pkcs12 files you can email the file yourself and open the attachment. If you have multiple files put them on your sd card.&lt;/p&gt;&lt;p&gt;Click on the email attachment/Use the folder icon in the vpn list to import the config file&lt;/p&gt;&lt;p&gt;If there are errors about missing files put the missing files on your sd card.&lt;/p&gt;&lt;p&gt;Click on the save symbol to add the imported VPN to your VPN list&lt;/p&gt;&lt;p&gt;Connect the VPN by clicking on the name of the VPN&lt;/p&gt;&lt;p&gt;If there are error or warnings in the log try to understand the warnings/error and try to fix them&lt;/p&gt; </string>
198 |     <string name="faq_howto_title">Quick Start</string>
199 |     <string name="setting_loadtun_summary">Try to load the tun.ko kernel module before trying to connect. Needs rooted devices.</string>
200 |     <string name="setting_loadtun">Load tun module</string>
201 |     <string name="importpkcs12fromconfig">Import PKCS12 from configuration into Android Keystore</string>
202 |     <string name="getproxy_error">Error getting proxy settings: %s</string>
203 |     <string name="using_proxy">Using proxy %1$s %2$s</string>
204 |     <string name="use_system_proxy">Use system proxy</string>
205 |     <string name="use_system_proxy_summary">Use the system wide configuration for HTTP/HTTPS proxies to connect.</string>
206 |     <string name="onbootrestartsummary">OpenVPN will connect the specified VPN if it was active on system boot. Please read the connection warning FAQ before using this option on Android &lt; 5.0.</string>
207 |     <string name="onbootrestart">Connect on boot</string>
208 |     <string name="ignore">Ignore</string>
209 |     <string name="restart">Restart</string>
210 |     <string name="restart_vpn_after_change">Configuration changes are applied after restarting the VPN. (Re)start the VPN now?</string>
211 |     <string name="configuration_changed">Configuration changed</string>
212 |     <string name="log_no_last_vpn">Could not determine last connected profile for editing</string>
213 |     <string name="faq_duplicate_notification_title">Duplicate notifications</string>
214 |     <string name="faq_duplicate_notification">If Android is under system memory (RAM) pressure, apps and service which are not needed at the moment are removed from active memory. This terminates an ongoing VPN connection. To ensure that the connection/OpenVPN survives the service runs with higher priority. To run with higher priority the application must display a notification. The key notification icon is imposed by the system as described in the previous FAQ entry. It does not count as app notification for purpose of running with higher priority.</string>
215 |     <string name="no_vpn_profiles_defined">No VPN profiles defined.</string>
216 |     <string name="add_new_vpn_hint">Use the &lt;img src=\"ic_menu_add\"/&gt; icon to add a new VPN</string>
217 |     <string name="vpn_import_hint">Use the &lt;img src=\"ic_menu_archive\"/&gt; icon to import an existing (.ovpn or .conf) profile from your sdcard.</string>
218 |     <string name="faq_hint">Be sure to also check out the FAQ. There is a quick start guide.</string>
219 |     <string name="faq_routing_title">Routing/Interface Configuration</string>
220 |     <string name="faq_routing">The Routing and interface configuration is not done via traditional ifconfig/route commands but by using the VPNService API. This results in a different routing configuration than on other OSes. \nThe configuration of the VPN tunnel consists of the IP address and the networks that should be routed over this interface. Especially, no peer partner address or gateway address is needed or required. Special routes to reach the VPN Server (for example added when using redirect-gateway) are not needed either. The application will consequently ignore these settings when importing a configuration. The app ensures with the VPNService API that the connection to the server is not routed through the VPN tunnel.\nThe VPNService API does not allow specifying networks that should not be routed via the VPN. As a workaround the app tries to detect networks that should not be routed over tunnel (e.g. route x.x.x.x y.y.y.y net_gateway) and calculates a set of routes that excludes this routes to emulate the behaviour of other platforms. The log windows shows the configuration of the VPNService upon establishing a connection.\nBehind the scenes: Android 4.4+ does use policy routing. Using route/ifconfig will not show the installed routes. Instead use ip rule, iptables -t mangle -L</string>
221 |     <string name="persisttun_summary">Do not fallback to no VPN connection when OpenVPN is reconnecting.</string>
222 |     <string name="persistent_tun_title">Persistent tun</string>
223 |     <string name="openvpn_log">OpenVPN Log</string>
224 |     <string name="import_config">Import OpenVPN configuration</string>
225 |     <string name="battery_consumption_title">Battery consumption</string>
226 |     <string name="baterry_consumption">In my personal tests the main reason for high battery consumption of OpenVPN are the keepalive packets. Most OpenVPN servers have a configuration directive like \'keepalive 10 60\' which causes the client and server to exchange keepalive packets every ten seconds. &lt;p&gt; While these packets are small and do not use much traffic, they keep the mobile radio network busy and increase the energy consumption. (See also &lt;a href="https://developer.android.com/training/efficient-downloads/efficient-network-access.html#RadioStateMachine"&gt;The Radio State Machine | Android Developers&lt;/a&gt;) &lt;p&gt; This keepalive setting cannot be changed on the client. Only the system administrator of the OpenVPN can change the setting. &lt;p&gt; Unfortunately using a keepalive larger than 60 seconds with UDP can cause some NAT gateways to drop the connection due to an inactivity timeout. Using TCP with a long keep alive timeout works, but tunneling TCP over TCP performs extremely poorly on connections with high packet loss. (See &lt;a href="http://sites.inka.de/bigred/devel/tcp-tcp.html"&gt;Why TCP Over TCP Is A Bad Idea&lt;/a&gt;)</string>
227 |     <string name="faq_tethering">The Android Tethering feature (over WiFi, USB or Bluetooth) and the VPNService API (used by this program) do not work together. For more details see the &lt;a href=\"https://github.com/schwabe/ics-openvpn/issues/34\">issue #34&lt;/a></string>
228 |     <string name="vpn_tethering_title">VPN and Tethering</string>
229 |     <string name="connection_retries">Connection retries</string>
230 |     <string name="reconnection_settings">Reconnection settings</string>
231 |     <string name="connectretrymessage">Number of seconds to wait between connection attempts.</string>
232 |     <string name="connectretrywait">Seconds between connections</string>
233 |     <string name="minidump_generated">OpenVPN crashed unexpectedly. Please consider using the send Minidump option in the main menu</string>
234 |     <string name="send_minidump">Send Minidump to developer</string>
235 |     <string name="send_minidump_summary">Sends debugging information about last crash to developer</string>
236 |     <string name="notifcation_title">OpenVPN - %s</string>
237 |     <string name="session_ipv4string">%1$s - %2$s</string>
238 |     <string name="session_ipv6string">%1$s - %3$s, %2$s</string>
239 |     <string name="state_connecting">Connecting</string>
240 |     <string name="state_wait">Waiting for server reply</string>
241 |     <string name="state_auth">Authenticating</string>
242 |     <string name="state_get_config">Getting client configuration</string>
243 |     <string name="state_assign_ip">Assigning IP addresses</string>
244 |     <string name="state_add_routes">Adding routes</string>
245 |     <string name="state_connected">Connected</string>
246 |     <string name="state_disconnected">Disconnect</string>
247 |     <string name="state_reconnecting">Reconnecting</string>
248 |     <string name="state_exiting">Exiting</string>
249 |     <string name="state_noprocess">Not running</string>
250 |     <string name="state_resolve">Resolving host names</string>
251 |     <string name="state_tcp_connect">Connecting (TCP)</string>
252 |     <string name="state_auth_failed">Authentication failed</string>
253 |     <string name="state_nonetwork">Waiting for usable network</string>
254 |     <string name="state_waitorbot">Waiting for Orbot to start</string>
255 |     <string name="statusline_bytecount">↓%2$s %1$s - ↑%4$s %3$s</string>
256 |     <string name="notifcation_title_notconnect">Not connected</string>
257 |     <string name="start_vpn_title">Connecting to VPN %s</string>
258 |     <string name="start_vpn_ticker">Connecting to VPN %s</string>
259 |     <string name="jelly_keystore_alphanumeric_bug">Some versions of Android 4.1 have problems if the name of the keystore certificate contains non alphanumeric characters (like spaces, underscores or dashes). Try to reimport the certificate without special characters</string>
260 |     <string name="encryption_cipher">Encryption cipher</string>
261 |     <string name="packet_auth">Packet authentication</string>
262 |     <string name="auth_dialog_title">Enter packet authentication method</string>
263 |     <string name="built_by">built by %s</string>
264 |     <string name="debug_build">debug build</string>
265 |     <string name="official_build">official build</string>
266 |     <string name="make_selection_inline">Copy into profile</string>
267 |     <string name="crashdump">Crashdump</string>
268 |     <string name="add">Add</string>
269 |     <string name="send_config">Send config file</string>
270 |     <string name="complete_dn">Complete DN</string>
271 |     <string name="remotetlsnote">Your imported configuration used the old DEPRECATED tls-remote option which uses a different DN format.</string>
272 |     <string name="rdn">RDN (common name)</string>
273 |     <string name="rdn_prefix">RDN prefix</string>
274 |     <string name="tls_remote_deprecated">tls-remote (DEPRECATED)</string>
275 |     <string name="help_translate">You can help translating by visiting https://crowdin.net/project/ics-openvpn/invite</string>
276 |     <string name="prompt">%1$s attempts to control %2$s</string>
277 |     <string name="remote_warning">By proceeding, you are giving the application permission to completely control OpenVPN for Android and to intercept all network traffic.<b>Do NOT accept unless you trust the application.</b> Otherwise, you run the risk of having your data compromised by malicious software."</string>
278 |     <string name="remote_trust">I trust this application.</string>
279 |     <string name="no_external_app_allowed">No app allowed to use external API</string>
280 |     <string name="allowed_apps">Allowed apps: %s</string>
281 |     <string name="clearappsdialog">Clear list of allowed external apps?\nCurrent list of allowed apps:\n\n%s</string>
282 |     <string name="screenoff_summary">Pause VPN when screen is off and less than 64 kB transferred data in 60s. When the \"Persistent Tun\" option is enabled pausing the VPN will leave your device with NO network connectivity. Without the \"Persistent Tun\" option the device will have no VPN connection/protection.</string>
283 |     <string name="screenoff_title">Pause VPN connection after screen off</string>
284 |     <string name="screenoff_pause">Pausing connection in screen off state: less than %1$s in %2$ss</string>
285 |     <string name="screen_nopersistenttun">Warning: Persistent tun not enabled for this VPN. Traffic will use the normal Internet connection when the screen is off.</string>
286 |     <string name="save_password">Save Password</string>
287 |     <string name="pauseVPN">Pause VPN</string>
288 |     <string name="resumevpn">Resume VPN</string>
289 |     <string name="state_userpause">VPN pause requested by user</string>
290 |     <string name="state_screenoff">VPN paused - screen off</string>
291 |     <string name="device_specific">Device specifics Hacks</string>
292 |     <string name="cannotparsecert">Cannot display certificate information</string>
293 |     <string name="appbehaviour">Application behaviour</string>
294 |     <string name="vpnbehaviour">VPN behaviour</string>
295 |     <string name="allow_vpn_changes">Allow changes to VPN Profiles</string>
296 |     <string name="hwkeychain">Hardware Keystore:</string>
297 |     <string name="permission_icon_app">Icon of app trying to use OpenVPN for Android</string>
298 |     <string name="faq_vpndialog43">"Starting with Android 4.3 the VPN confirmation is guarded against \"overlaying apps\". This results in the dialog not reacting to touch input. If you have an app that uses overlays it may cause this behaviour. If you find an offending app contact the author of the app. This problem affect all VPN applications on Android 4.3 and later. See also &lt;a href=\"https://github.com/schwabe/ics-openvpn/issues/185\">Issue 185&lt;a> for additional details"</string>
299 |     <string name="faq_vpndialog43_title">Vpn Confirmation Dialog</string>
300 |     <string name="donatePlayStore">Alternatively you can send me a donation with the Play Store:</string>
301 |     <string name="thanks_for_donation">Thanks for donating %s!</string>
302 |     <string name="logCleared">Log cleared.</string>
303 |     <string name="show_password">Show password</string>
304 |     <string name="keyChainAccessError">KeyChain Access error: %s</string>
305 |     <string name="timestamp_short">Short</string>
306 |     <string name="timestamp_iso">ISO</string>
307 |     <string name="timestamps">Timestamps</string>
308 |     <string name="timestamps_none">None</string>
309 |     <string name="uploaded_data">Upload</string>
310 |     <string name="downloaded_data">Download</string>
311 |     <string name="vpn_status">Vpn Status</string>
312 |     <string name="logview_options">View options</string>
313 |     <string name="unhandled_exception">Unhandled exception: %1$s\n\n%2$s</string>
314 |     <string name="unhandled_exception_context">%3$s: %1$s\n\n%2$s</string>
315 |     <string name="faq_system_dialog_xposed">If you have rooted your Android device you can install the &lt;a href=\"http://xposed.info/\"&gt;Xposed framework&lt;/a&gt; and the &lt;a href=\"http://repo.xposed.info/module/de.blinkt.vpndialogxposed\"&gt;VPN Dialog confirm module&lt;/a&gt; at your own risk"</string>
316 |     <string name="full_licenses">Full licenses</string>
317 |     <string name="blocklocal_summary">Networks directly connected to the local interfaces will not be routed over the VPN. Deselecting this option will redirect all traffic indented for local networks to the VPN.</string>
318 |     <string name="blocklocal_title">Bypass VPN for local networks</string>
319 |     <string name="userpw_file">Username/Password file</string>
320 |     <string name="imported_from_file">[Imported from: %s]</string>
321 |     <string name="files_missing_hint">Some files could not be found. Please select the files to import the profile:</string>
322 |     <string name="openvpn_is_no_free_vpn">To use this app you need a VPN provider/VPN gateway supporting OpenVPN (often provided by your employer). Check out https://community.openvpn.net/ for more information on OpenVPN and how to setup your own OpenVPN server.</string>
323 |     <string name="import_log">Import log:</string>
324 |     <string name="ip_looks_like_subnet">Vpn topology \"%3$s\" specified but ifconfig %1$s %2$s looks more like an IP address with a network mask. Assuming \"subnet\" topology.</string>
325 |     <string name="mssfix_invalid_value">The MSS override value has to be a integer between 0 and 9000</string>
326 |     <string name="mtu_invalid_value">The MTU override value has to be a integer between 64 and 9000</string>
327 |     <string name="mssfix_value_dialog">Announce to TCP sessions running over the tunnel that they should limit their send packet sizes such that after OpenVPN has encapsulated them, the resulting UDP packet size that OpenVPN sends to its peer will not exceed this number of bytes. (default is 1450)</string>
328 |     <string name="mssfix_checkbox">Override MSS value of TCP payload</string>
329 |     <string name="mssfix_dialogtitle">Set MSS of TCP payload</string>
330 |     <string name="client_behaviour">Client behaviour</string>
331 |     <string name="clear_external_apps">Clear allowed external apps</string>
332 |     <string name="loading">Loading…</string>
333 |     <string name="allowed_vpn_apps_info">Allowed VPN apps: %1$s</string>
334 |     <string name="disallowed_vpn_apps_info">Disallowed VPN apps: %1$s</string>
335 |     <string name="app_no_longer_exists">Package %s is no longer installed, removing it from app allow/disallow list</string>
336 |     <string name="vpn_disallow_radio">VPN is used for all apps but exclude selected</string>
337 |     <string name="vpn_allow_radio">VPN is used for only for selected apps</string>
338 |     <string name="vpn_allow_bypass">Allow apps to bypass the VPN</string>
339 |     <string name="query_delete_remote">Remove remote server entry?</string>
340 |     <string name="keep">Keep</string>
341 |     <string name="delete">Delete</string>
342 |     <string name="add_remote">Add new remote</string>
343 |     <string name="remote_random">Use connection entries in random order on connect</string>
344 |     <string name="remote_no_server_selected">You need to define and enable at least one remote server.</string>
345 |     <string name="server_list">Server List</string>
346 |     <string name="vpn_allowed_apps">Allowed Apps</string>
347 |     <string name="advanced_settings">Advanced Settings</string>
348 |     <string name="payload_options">Payload options</string>
349 |     <string name="tls_settings">TLS Settings</string>
350 |     <string name="no_remote_defined">No remote defined</string>
351 |     <string name="duplicate_vpn">Duplicate VPN profile</string>
352 |     <string name="duplicate_profile_title">Duplicating profile: %s</string>
353 |     <string name="show_log">Show log</string>
354 |     <string name="faq_android_clients">Multiple OpenVPN clients for Android exist. The most common ones are OpenVPN for Android (this client), OpenVPN Connect and OpenVPN Settings.&lt;p&gt;The clients can be grouped into two groups: OpenVPN for Android and OpenVPN Connect use the official VPNService API (Android 4.0+) and require no root and OpenVPN Settings which uses root.&lt;p&gt;OpenVPN for Android is an open source client and developed by Arne Schwabe.  It is targeted at more advanced users and offers many settings and the ability to import profiles from files and to configure/change profiles inside the app. The client is based on the community version of OpenVPN. It is based on the OpenVPN 2.x source code. This client can be seen as the semi officially client of the community. &lt;p&gt;OpenVPN Connect is non open source client that is developed by OpenVPN Technologies, Inc. The client is indented to be general use client and more targeted at the average user and allows the import of OpenVPN profiles. This client is based on the OpenVPN C++ reimplementation of the OpenVPN protocol (This was required to allow OpenVPN Technologies, Inc to publish an iOS OpenVPN app). This client is the official client of the OpenVPN technologies &lt;p&gt; OpenVPN Settings is the oldest of the clients and also a UI for the open source OpenVPN. In contrast to OpenVPN  for Android it requires root and does not use the VPNService API. It does not depend on Android 4.0+</string>
355 |     <string name="faq_androids_clients_title">Differences between the OpenVPN Android clients</string>
356 |     <string name="ignore_multicast_route">Ignoring multicast route: %s</string>
357 |     <string name="ab_only_cidr">Android supports only CIDR routes to the VPN. Since non-CIDR routes are almost never used, OpenVPN for Android will use a /32 for routes that are not CIDR and issue a warning.</string>
358 |     <string name="ab_tethering_44">Tethering works while the VPN is active. The tethered connection will NOT use the VPN.</string>
359 |     <string name="ab_kitkat_mss">Early KitKat version set the wrong MSS value on TCP connections (#61948). Try to enable the mssfix option to workaround this bug.</string>
360 |     <string name="ab_proxy">Android will keep using your proxy settings specified for the mobile/Wi-Fi connection when no DNS servers are set. OpenVPN for Android will warn you about this in the log.<p>When a VPN sets a DNS server Android will not use a proxy. There is no API to set a proxy for a VPN connection.</p></string>
361 |     <string name="ab_lollipop_reinstall">VPN apps may stop working when uninstalled and reinstalled again. For details see #80074</string>
362 |     <string name="ab_not_route_to_vpn">The configured client IP and the IPs in its network mask are not routed to the VPN. OpenVPN works around this bug by explicitly adding a route that corrosponds to the client IP and its netmask</string>
363 |     <string name="ab_persist_tun">Opening a tun device while another tun device is active, which is used for persist-tun support, crashes the VPNServices on the device. A reboot is required to make VPN work again. OpenVPN for Android tries to avoid reopening the tun device and if really needed first closes the current TUN before opening the new TUN device to avoid to crash. This may lead to a short window where packets are sent over the non-VPN connection. Even with this workaround the VPNServices sometimes crashes and requires a reboot of the device.</string>
364 |     <string name="ab_secondary_users">VPN does not work at all for secondary users.</string>
365 |     <string name="ab_kitkat_reconnect">"Multiple users report that the mobile connection/mobile data connection is frequently dropped while using the VPN app. The behaviour seems to affect only some mobile provider/device combination and so far no cause/workaround for the bug could be identified. "</string>
366 |     <string name="ab_vpn_reachability_44">Only destination can be reached over the VPN that are reachable without VPN. IPv6 VPNs does not work at all.</string>
367 |     <string name="ab_only_cidr_title">Non CIDR Routes</string>
368 |     <string name="ab_proxy_title">Proxy behaviour for VPNs</string>
369 |     <string name="ab_lollipop_reinstall_title">Reinstalling VPN apps</string>
370 |     <string name="version_upto">%s and earlier</string>
371 |     <string name="copy_of_profile">Copy of %s</string>
372 |     <string name="ab_not_route_to_vpn_title">Route to the configured IP address</string>
373 |     <string name="ab_kitkat_mss_title">Wrong MSS value for VPN connection</string>
374 |     <string name="ab_secondary_users_title">Secondary tablet users</string>
375 |     <string name="custom_connection_options_warng">Specify custom connection specific options. Use with care</string>
376 |     <string name="custom_connection_options">Custom Options</string>
377 |     <string name="remove_connection_entry">Remove connection entry</string>
378 |     <string name="ab_kitkat_reconnect_title">Random disconnects from mobile network</string>
379 |     <string name="ab_vpn_reachability_44_title">Remote networks not reachable</string>
380 |     <string name="ab_persist_tun_title">Persist tun mode</string>
381 |     <string name="version_and_later">%s and later</string>
382 |     <string name="tls_cipher_alert_title">Connections fails with SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure</string>
383 |     <string name="tls_cipher_alert">Newer OpenVPN for Android versions (0.6.29/March 2015) use a more secure default for the allowed cipher suites (tls-cipher \"DEFAULT:!EXP:!PSK:!SRP:!kRSA\"). Unfortunately, omitting the less secure cipher suites and export cipher suites, especially the omission of cipher suites that do not support Perfect Forward Secrecy (Diffie-Hellman) causes some problems. This usually caused by an well-intentioned but poorly executed attempt to strengthen TLS security by setting tls-cipher on the server or some embedded OSes with stripped down SSL (e.g. MikroTik).\nTo solve this problem the problem, set the tls-cipher settings on the server to reasonable default like tls-cipher \"DEFAULT:!EXP:!PSK:!SRP:!kRSA\". To work around the problem on the client add the custom option tls-cipher DEFAULT on the Android client.</string>
384 |     <string name="message_no_user_edit">This profile has been added from an external app (%s) and has been marked as not user editable.</string>
385 |     <string name="crl_file">Certificate Revocation List</string>
386 |     <string name="service_restarted">Restarting OpenVPN Service (App crashed probably crashed or killed for memory pressure)</string>
387 |     <string name="import_config_error">Importing the config yielded an error, cannot save it</string>
388 |     <string name="Search">Search</string>
389 |     <string name="lastdumpdate">(Last dump is %1$d:%2$dh old (%3$s))</string>
390 |     <string name="clear_log_on_connect">Clear log on new connection</string>
391 |     <string name="connect_timeout">Connect Timeout</string>
392 |     <string name="no_allowed_app">No allowed app added. Adding ourselves (%s) to have at least one app in the allowed app list to not allow all apps</string>
393 |     <string name="query_permissions_sdcard">OpenVPN for Android can try to discover the missing file(s) on the sdcard automatically. Tap this message start the permission request.</string>
394 |     <string name="protocol">Protocol</string>
395 |     <string name="enabled_connection_entry">Enabled</string>
396 |     <string name="abi_mismatch">Preferred native ABI precedence of this device (%1$s) and ABI reported by native libraries (%2$s) mismatch</string>
397 |     <string name="permission_revoked">VPN permission revoked by OS (e.g. other VPN program started), stopping VPN</string>
398 |     <string name="pushpeerinfo">Push Peer info</string>
399 |     <string name="pushpeerinfosummary">Send extra information to the server, e.g. SSL version and Android version</string>
400 |     <string name="pw_request_dialog_title">Need %1$s</string>
401 |     <string name="pw_request_dialog_prompt">Please enter the password for profile %1$s</string>
402 |     <string name="menu_use_inline_data">Use inline data</string>
403 |     <string name="export_config_chooser_title">Export configuration file</string>
404 |     <string name="missing_tlsauth">tls-auth file is missing</string>
405 |     <string name="missing_certificates">Missing user certificate or user certifcate key file</string>
406 |     <string name="missing_ca_certificate">Missing CA certificate</string>
407 |     <string name="crl_title">Certifcate Revoke List (optional)</string>
408 |     <string name="reread_log">Reread (%d) log items from log cache file</string>
409 |     <string name="samsung_broken">Even though Samsung phones are among the most selling Android phones, Samsung\'s firmware are also among the most buggy Android firmwares. The bugs are not limited to the VPN operation on these devices but many of them can be workarounded. In the following some of these bugs are described.\n\nDNS does not work unless the DNS server in the VPN range.\n\nOn many Samsung 5.x devices the allowed/disallowed apps feature does not work.\nOn Samsung 6.x VPN is reported not to work unless the VPN app is exempted from Powersave features.</string>
410 |     <string name="samsung_broken_title">Samsung phones</string>
411 |     <string name="novpn_selected">No VPN selected.</string>
412 |     <string name="defaultvpn">Default VPN</string>
413 |     <string name="defaultvpnsummary">VPN used in places where a default VPN needed. These are currently on boot, for Always-On and the Quick Settings Tile.</string>
414 |     <string name="vpnselected">Currently selected VPN: \'%s\'</string>
415 |     <string name="reconnect">Reconnect</string>
416 |     <string name="qs_title">Toggle VPN</string>
417 |     <string name="qs_connect">Connect to %s</string>
418 |     <string name="qs_disconnect">Disconnect %s</string>
419 |     <string name="connectretrymaxmessage">Enter the maximum time between connection attempts. OpenVPN will slowly raise its waiting time after an unsuccessful connection attempt up to this value. Defaults to 300s.</string>
420 |     <string name="connectretrymaxtitle">Maximum time between connection attempts</string>
421 |     <string name="state_waitconnectretry">Waiting %ss seconds between connection attempt</string>
422 |     <string name="nought_alwayson_warning"><![CDATA[If you did not get a VPN confirmation dialog, you have \"Always on VPN\" enabled for another app. In that case only that app is allowed to connect to a VPN. Check under Settings-> Networks more .. -> VPNS]]></string>
423 |     <string name="management_socket_closed">Connection to OpenVPN closed (%s)</string>
424 |     <string name="change_sorting">Change sorting</string>
425 |     <string name="sort">Sort</string>
426 |     <string name="sorted_lru">Profiles sorted by last recently used</string>
427 |     <string name="sorted_az">Profiles sorted by name</string>
428 |     <string name="deprecated_tls_remote">Config uses option tls-remote that was deprecated in 2.3 and finally removed in 2.4</string>
429 |     <string name="auth_failed_behaviour">Behaviour on AUTH_FAILED</string>
430 |     <string name="graph">Graph</string>
431 |     <string name="use_logarithmic_scale">Use logarithmic scale</string>
432 |     <string name="notenoughdata">Not enough data</string>
433 |     <string name="avghour">Average per hour</string>
434 |     <string name="avgmin">Average per minute</string>
435 |     <string name="last5minutes">Last 5 minutes</string>
436 |     <string name="data_in">In</string>
437 |     <string name="data_out">Out</string>
438 |     <string name="bits_per_second">%.0f bit/s</string>
439 |     <string name="kbits_per_second">%.1f kbit/s</string>
440 |     <string name="mbits_per_second">%.1f Mbit/s</string>
441 |     <string name="gbits_per_second">%.1f Gbit/s</string>
442 |     <string name="weakmd">&lt;p>Starting with OpenSSL version 1.1, OpenSSL rejects weak signatures in certificates like
443 |         MD5.&lt;/p>&lt;p>&lt;b>MD5 signatures are completely insecure and should not be used anymore.&lt;/b> MD5
444 |         collisions can be created in &lt;a
445 |         href="https://natmchugh.blogspot.de/2015/02/create-your-own-md5-collisions.html">few hours at a minimal cost.&lt;/a>.
446 |         You should update the VPN certificates as soon as possible.&lt;/p>&lt;p>Unfortunately, older easy-rsa
447 |         distributions included the config option "default_md md5". If you are using an old easy-rsa version, update to
448 |         the &lt;a href="https://github.com/OpenVPN/easy-rsa/releases">latest version&lt;/a>) or change md5 to sha256 and
449 |         regenerate your certificates.&lt;/p>&lt;p>If you really want to use old and broken certificates use the custom
450 |         configuration option tls-cipher "DEFAULT:@SECLEVEL=0" under advanced configuration or as additional line in your
451 |         imported configuration&lt;/p>
452 |     </string>
453 |     <string name="volume_byte">%.0f B</string>
454 |     <string name="volume_kbyte">%.1f kB</string>
455 |     <string name="volume_mbyte">%.1f MB</string>
456 |     <string name="volume_gbyte">%.1f GB</string>
457 |     <string name="channel_name_background">Connection statistics</string>
458 |     <string name="channel_description_background">Ongoing statistics of the established OpenVPN connection</string>
459 |     <string name="channel_name_status">Connection status change</string>
460 |     <string name="channel_description_status">Status changes of the OpenVPN connection (Connecting, authenticating,…)</string>
461 |     <string name="weakmd_title">Weak (MD5) hashes in certificate signature (SSL_CTX_use_certificate md too weak)</string>
462 |     <string name="title_activity_open_sslspeed">OpenSSL Speed Test</string>
463 |     <string name="openssl_cipher_name">OpenSSL cipher names</string>
464 |     <string name="osslspeedtest">OpenSSL Crypto Speed test</string>
465 |     <string name="openssl_error">OpenSSL returned an error</string>
466 |     <string name="running_test">Running test…</string>
467 |     <string name="test_algoirhtms">Test selected algorithms</string>
468 |     <string name="all_app_prompt">An external app tries to control %s. The app requesting access cannot be determined. Allowing this app grants ALL apps access.</string>
469 |     <string name="openvpn3_nostatickeys">The OpenVPN 3 C++ implementation does not support static keys. Please change to OpenVPN 2.x under general settings.</string>
470 |     <string name="openvpn3_pkcs12">Using PKCS12 files directly with OpenVPN 3 C++ implementation is not supported. Please import the pkcs12 files into the Android keystore or change to OpenVPN 2.x under general settings.</string>
471 |     <string name="proxy">Proxy</string>
472 |     <string name="Use_no_proxy">None</string>
473 |     <string name="tor_orbot">Tor (Orbot)</string>
474 |     <string name="openvpn3_socksproxy">OpenVPN 3 C++ implementation does not support connecting via Socks proxy</string>
475 |     <string name="no_orbotfound">Orbot application cannot be found. Please install Orbot or use manual Socks v5 integration.</string>
476 |     <string name="faq_remote_api_title">Remote API</string>
477 |     <string name="faq_remote_api">OpenVPN for Android supports two remote APIs, a sophisticated API using AIDL (remoteEXample in the git repository) and a simple one using Intents. &lt;p>Examples using adb shell and the intents. Replace profilname with your profile name&lt;p>&lt;p> adb shell am start-activity -a android.intent.action.MAIN de.blinkt.openvpn/.api.DisconnectVPN&lt;p> adb shell am start-activity -a android.intent.action.MAIN -e de.blinkt.openvpn.api.profileName Blinkt de.blinkt.openvpn/.api.ConnectVPN</string>
478 |     <string name="enableproxyauth">Enable Proxy Authentication</string>
479 |     <string name="error_orbot_and_proxy_options">Cannot use extra http-proxy-option statement and Orbot integration at the same time</string>
480 |     <string name="info_from_server">Info from server: \'%s\'</string>
481 |     <string name="channel_name_userreq">User interaction required</string>
482 |     <string name="channel_description_userreq">OpenVPN connection requires a user input, e.g. two factor
483 |         authentification
484 |     </string>
485 |     <string name="openurl_requested">Open URL to continue VPN authentication</string>
486 |     <string name="crtext_requested">Answer challenge to continue VPN authentication</string>
487 |     <string name="state_auth_pending">Authentication pending</string>
488 |     <string name="external_authenticator">External Authenticator</string>
489 |     <string name="configure">Configure</string>
490 |     <string name="extauth_not_configured">External Authneticator not configured</string>
491 |     <string name="faq_killswitch_title">Block non VPN connection (\"Killswitch\")</string>
492 |     <string name="faq_killswitch">It is often desired to block connections without VPN. Other apps often use markting terms like \"Killswitch\" or \"Seamless tunnel\" for this feature. OpenVPN and this app offer persist-tun, a feature to implement this functionality.&lt;p>The problem with all these methods offered by apps is that they can only provide best effort and are no complete solutions. On boot, app crashing and other corner cases the app cannot ensure that this block of non VPN connection works. Thus giving the user a false sense of security.&lt;p>The &lt;b>only&lt;/b> reliable way to ensure non VPN connections are blocked is to use Android 8.0 or later and use the \"block connections without VPN\" setting that can be found under Settings > Network &amp; Internet > Advanced/VPN > OpenVPN for Android > Enable Always ON VPN, Enable Block Connections without VPN</string>
493 |     <string name="summary_block_address_families">This option instructs Android to not allow protocols (IPv4/IPv6) if the VPN does not set any IPv4 or IPv6 addresses.</string>
494 |     <string name="title_block_address_families">Block IPv6 (or IPv4) if not used by the VPN</string>
495 |     <string name="install_keychain">Install new certificate</string>
496 |     <string name="as_servername">AS servername</string>
497 |     <string name="request_autologin">Request autologin profile</string>
498 |     <string name="import_from_as">Import Profile from Access Server</string>
499 |     <string name="no_default_vpn_set">Default VPN not set. Please set the Default VPN before enabling this option.</string>
500 |     <string name="internal_web_view">Internal WebView</string>
501 | 
502 | </resources>
503 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/styles.xml:
--------------------------------------------------------------------------------
1 | <?xml version="1.0" encoding="utf-8"?>
2 | <resources>
3 |     <style name="blinkt.baseTheme" parent="android:Theme.DeviceDefault.Light" />
4 |     <style name="blinkt" parent="blinkt.baseTheme" />
5 | 
6 |     <style name="blinkt.dialog" parent="android:Theme.DeviceDefault.Light.Dialog" />
7 | </resources>


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/values/untranslatable.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?><!--
 2 |   ~ Copyright (c) 2012-2016 Arne Schwabe
 3 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 4 |   -->
 5 | 
 6 | <resources>
 7 | 
 8 |     <string name="copyright_blinktgui" translatable="false">Copyright 2012–2018 Arne Schwabe &lt;arne@rfc2549.org>
 9 |     </string>
10 |     <string name="copyright_logo" translatable="false">App Logo design by Helen Beierling
11 |         &lt;helbeierling@t-online.de>
12 |     </string>
13 | 
14 |     <string name="opevpn_copyright" translatable="false">Copyright © 2002–2010 OpenVPN Technologies, Inc. &lt;sales@openvpn.net>\n
15 | 
16 |         "OpenVPN" is a trademark of OpenVPN Technologies, Inc.\n
17 |     </string>
18 |     <string name="defaultserver" translatable="false">openvpn.uni-paderborn.de</string>
19 |     <string name="defaultport" translatable="false">1194</string>
20 |     <string name="copyright_file_dialog" translatable="false">File Dialog based on work by Alexander Ponomarev</string>
21 |     <string name="lzo_copyright" translatable="false">Copyright © 1996 – 2011 Markus Franz Xaver Johannes Oberhumer
22 |     </string>
23 |     <string name="copyright_openssl" translatable="false">This product includes software developed by the OpenSSL
24 |         Project for use in the OpenSSL Toolkit\n
25 |         Copyright © 1998-2008 The OpenSSL Project. All rights reserved.\n\n
26 |         This product includes cryptographic software written by Eric Young (eay@cryptsoft.com)\n
27 |         Copyright © 1995-1998 Eric Young (eay@cryptsoft.com) All rights reserved.
28 |     </string>
29 |     <string name="openvpn" translatable="false">OpenVPN</string>
30 |     <string name="file_dialog" translatable="false">File Dialog</string>
31 |     <string name="lzo" translatable="false">LZO</string>
32 |     <string name="openssl" translatable="false">OpenSSL</string>
33 |     <string name="unknown_state" translatable="false">Unknown state</string>
34 |     <string name="permission_description">Allows another app to control OpenVPN</string>
35 |     <string name="bouncy_castle" translatable="false">Bouncy Castle Crypto APIs</string>
36 |     <string name="copyright_bouncycastle" translatable="false">Copyright © 2000–2012 The Legion Of The Bouncy Castle
37 |         (http://www.bouncycastle.org)
38 |     </string>
39 | 
40 |     <string-array name="tls_directions_values" translatable="false">
41 |         <item>0</item>
42 |         <item>1</item>
43 |         <item></item>
44 |         <item>tls-crypt</item>
45 |         <item>tls-crypt-v2</item>
46 |     </string-array>
47 |     <string-array name="crm_values" translatable="false">
48 |         <item>1</item>
49 |         <item>2</item>
50 |         <item>5</item>
51 |         <item>50</item>
52 |         <item>-1</item>
53 |     </string-array>
54 |     <string name="crash_toast_text">OpenVPN for Android crashed, crash reported</string>
55 | 
56 |     <!-- These strings should not be visible to the user -->
57 |     <string name="state_user_vpn_permission" translatable="false">Waiting for user permission to use VPN API</string>
58 |     <string name="state_user_vpn_password" translatable="false">Waiting for user VPN password</string>
59 |     <string name="state_user_vpn_password_cancelled" translatable="false">VPN password input dialog cancelled</string>
60 |     <string name="state_user_vpn_permission_cancelled" translatable="false">VPN API permission dialog cancelled</string>
61 |     <string name="default_cipherlist_test" translatable="false">aes-256-gcm bf-cbc sha1</string>
62 | 
63 |     <!-- APP restriction strings -->
64 |     <string name="apprest_uuid_desc">Unique UUID that identifies the profile (example:
65 |         0E910C15–9A85-4DD9-AE0D-E6862392E638). Generate using uuidgen or similar tools
66 |     </string>
67 |     <string name="apprest_uuid">UUID</string>
68 |     <string name="apprest_ovpn_desc">Content of the OpenVPN configuration file. These files are usually have the extension .ovpn (sometimes also .conf) and are plain text multi line configuration files. If your MDM does not support multiline configuration entries, you can also use a base64 encoded string here. A text file can be converted to base64 using openssl base64 -A -in</string>
69 |     <string name="apprest_ovpn">Config</string>
70 |     <string name="apprest_name_desc">Name of the VPN profile</string>
71 |     <string name="apprest_name">Name</string>
72 |     <string name="apprest_vpnlist">List of VPN configurations</string>
73 |     <string name="apprest_vpnconf">VPN configuration</string>
74 |     <string name="apprest_ver">Version of the managed configuration schema (Currently always 1)</string>
75 | 
76 | </resources>
77 | 


--------------------------------------------------------------------------------
/android/vpnLib/src/main/res/xml/app_restrictions.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!--
 3 |   ~ Copyright (c) 2012-2018 Arne Schwabe
 4 |   ~ Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 5 |   -->
 6 | 
 7 | <restrictions xmlns:tools="http://schemas.android.com/tools" xmlns:android="http://schemas.android.com/apk/res/android"
 8 |               tools:targetApi="lollipop">
 9 | 
10 |     <restriction
11 | 
12 |             android:key="version"
13 |             android:title="@string/apprest_ver"
14 |             android:restrictionType="string"
15 |             android:defaultValue="1"
16 |     />
17 | 
18 |     <restriction
19 |             android:key="vpn_configuration_list"
20 |             android:title="@string/apprest_vpnlist"
21 |             android:restrictionType="bundle_array">
22 | 
23 |         <restriction
24 |                 android:title="@string/apprest_vpnconf"
25 |                 android:key="vpn_configuration"
26 |                 android:restrictionType="bundle">
27 | 
28 |             <restriction
29 |                     android:key="uuid"
30 |                     android:restrictionType="string"
31 |                     android:description="@string/apprest_uuid_desc"
32 |                     android:title="@string/apprest_uuid"
33 |             />
34 | 
35 |             <restriction
36 |                     android:key="name"
37 |                     android:restrictionType="string"
38 |                     android:title="@string/apprest_name"
39 |                     android:description="@string/apprest_name_desc"
40 | 
41 |             />
42 | 
43 |             <restriction
44 |                     android:key="ovpn"
45 |                     android:title="@string/apprest_ovpn"
46 |                     android:description="@string/apprest_ovpn_desc"
47 |                     android:restrictionType="string"/>
48 | 
49 |             <!--
50 |             <restriction
51 |                     android:key="ovpn_list"
52 |                     android:title="@string/apprest_ovpn_list"
53 |                     android:describition="@string/apprest_ovpn_list_esc"
54 |                     android:restrictionType="bundle_array">
55 |                 <restriction
56 |                         android:key="ovpn_configline"
57 |                         android:title="@string/apprest_ovpn"
58 |                         android:description="@string/apprest_ovpn_desc"
59 |                         android:restrictionType="string"/>
60 |             </restriction>
61 |             -->
62 |         </restriction>
63 |     </restriction>
64 | </restrictions>


--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
/android/app/src/main/java/com/harshRajpurohit/freeVpn/MainActivity.java:
--------------------------------------------------------------------------------
  1 | package com.harshRajpurohit.freeVpn;
  2 | 
  3 | import android.content.BroadcastReceiver;
  4 | import android.content.Context;
  5 | import android.content.Intent;
  6 | import android.content.IntentFilter;
  7 | import android.net.ConnectivityManager;
  8 | import android.net.NetworkInfo;
  9 | import android.net.VpnService;
 10 | import android.os.Bundle;
 11 | import android.os.RemoteException;
 12 | import android.provider.Settings;
 13 | import android.util.Log;
 14 | import android.widget.Toast;
 15 | 
 16 | import androidx.annotation.NonNull;
 17 | import androidx.annotation.Nullable;
 18 | import androidx.localbroadcastmanager.content.LocalBroadcastManager;
 19 | import androidx.multidex.MultiDex;
 20 | 
 21 | import org.json.JSONObject;
 22 | 
 23 | import java.io.IOException;
 24 | import java.io.StringReader;
 25 | import java.util.ArrayList;
 26 | 
 27 | import de.blinkt.openvpn.VpnProfile;
 28 | import de.blinkt.openvpn.core.ConfigParser;
 29 | import de.blinkt.openvpn.core.OpenVPNService;
 30 | import de.blinkt.openvpn.core.OpenVPNThread;
 31 | import de.blinkt.openvpn.core.ProfileManager;
 32 | import de.blinkt.openvpn.core.VPNLaunchHelper;
 33 | import io.flutter.embedding.android.FlutterActivity;
 34 | import io.flutter.embedding.engine.FlutterEngine;
 35 | import io.flutter.plugin.common.EventChannel;
 36 | import io.flutter.plugin.common.MethodChannel;
 37 | 
 38 | 
 39 | public class MainActivity extends FlutterActivity {
 40 |     private MethodChannel vpnControlMethod;
 41 |     private EventChannel vpnControlEvent;
 42 |     private EventChannel vpnStatusEvent;
 43 |     private EventChannel.EventSink vpnStageSink;
 44 |     private EventChannel.EventSink vpnStatusSink;
 45 | 
 46 |     private static final String EVENT_CHANNEL_VPN_STAGE = "vpnStage";
 47 |     private static final String EVENT_CHANNEL_VPN_STATUS = "vpnStatus";
 48 |     private static final String METHOD_CHANNEL_VPN_CONTROL = "vpnControl";
 49 |     private static final int VPN_REQUEST_ID = 1;
 50 |     private static final String TAG = "VPN";
 51 | 
 52 |     private VpnProfile vpnProfile;
 53 | 
 54 |     private String config = "",
 55 |             username = "",
 56 |             password = "",
 57 |             name = "",
 58 |             dns1 = VpnProfile.DEFAULT_DNS1,
 59 |             dns2 = VpnProfile.DEFAULT_DNS2;
 60 | 
 61 |     private ArrayList<String> bypassPackages;
 62 | 
 63 |     private boolean attached = true;
 64 | 
 65 |     private JSONObject localJson;
 66 | 
 67 |     @Override
 68 |     public void finish() {
 69 |         vpnControlEvent.setStreamHandler(null);
 70 |         vpnControlMethod.setMethodCallHandler(null);
 71 |         vpnStatusEvent.setStreamHandler(null);
 72 |         super.finish();
 73 |     }
 74 | 
 75 |     @Override
 76 |     protected void attachBaseContext(Context newBase) {
 77 |         super.attachBaseContext(newBase);
 78 |         MultiDex.install(this);
 79 |     }
 80 | 
 81 |     @Override
 82 |     public void onDetachedFromWindow() {
 83 |         attached = false;
 84 |         super.onDetachedFromWindow();
 85 |     }
 86 | 
 87 |     @Override
 88 |     protected void onCreate(@Nullable Bundle savedInstanceState) {
 89 |         LocalBroadcastManager.getInstance(this).registerReceiver(new BroadcastReceiver() {
 90 |             @Override
 91 |             public void onReceive(Context context, Intent intent) {
 92 |                 String stage = intent.getStringExtra("state");
 93 |                 if (stage != null) setStage(stage);
 94 | 
 95 |                 if (vpnStatusSink != null) {
 96 |                     try {
 97 |                         String duration = intent.getStringExtra("duration");
 98 |                         String lastPacketReceive = intent.getStringExtra("lastPacketReceive");
 99 |                         String byteIn = intent.getStringExtra("byteIn");
100 |                         String byteOut = intent.getStringExtra("byteOut");
101 | 
102 |                         if (duration == null) duration = "00:00:00";
103 |                         if (lastPacketReceive == null) lastPacketReceive = "0";
104 |                         if (byteIn == null) byteIn = " ";
105 |                         if (byteOut == null) byteOut = " ";
106 | 
107 |                         JSONObject jsonObject = new JSONObject();
108 |                         jsonObject.put("duration", duration);
109 |                         jsonObject.put("last_packet_receive", lastPacketReceive);
110 |                         jsonObject.put("byte_in", byteIn);
111 |                         jsonObject.put("byte_out", byteOut);
112 | 
113 |                         localJson = jsonObject;
114 | 
115 |                         if (attached) vpnStatusSink.success(jsonObject.toString());
116 |                     } catch (Exception e) {
117 |                         e.printStackTrace();
118 |                     }
119 |                 }
120 |             }
121 |         }, new IntentFilter("connectionState"));
122 |         super.onCreate(savedInstanceState);
123 |     }
124 | 
125 |     @Override
126 |     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
127 |         super.configureFlutterEngine(flutterEngine);
128 |         vpnControlEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STAGE);
129 |         vpnControlEvent.setStreamHandler(new EventChannel.StreamHandler() {
130 |             @Override
131 |             public void onListen(Object arguments, EventChannel.EventSink events) {
132 |                 vpnStageSink = events;
133 |             }
134 | 
135 |             @Override
136 |             public void onCancel(Object arguments) {
137 |                 vpnStageSink.endOfStream();
138 |             }
139 |         });
140 | 
141 |         vpnStatusEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STATUS);
142 |         vpnStatusEvent.setStreamHandler(new EventChannel.StreamHandler() {
143 |             @Override
144 |             public void onListen(Object arguments, EventChannel.EventSink events) {
145 |                 vpnStatusSink = events;
146 |             }
147 | 
148 |             @Override
149 |             public void onCancel(Object arguments) {
150 | 
151 |             }
152 |         });
153 | 
154 |         vpnControlMethod = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL_VPN_CONTROL);
155 |         vpnControlMethod.setMethodCallHandler((call, result) -> {
156 |             switch (call.method) {
157 |                 case "stop":
158 |                     OpenVPNThread.stop();
159 |                     setStage("disconnected");
160 |                     break;
161 |                 case "start":
162 |                     config = call.argument("config");
163 |                     name = call.argument("country");
164 |                     username = call.argument("username");
165 |                     password = call.argument("password");
166 | 
167 |                     if (call.argument("dns1") != null) dns1 = call.argument("dns1");
168 |                     if (call.argument("dns2") != null) dns2 = call.argument("dns2");
169 | 
170 |                     bypassPackages = call.argument("bypass_packages");
171 | 
172 |                     if (config == null || name == null) {
173 |                         Log.e(TAG, "Config not valid!");
174 |                         return;
175 |                     }
176 | 
177 |                     prepareVPN();
178 |                     break;
179 |                 case "refresh":
180 |                     updateVPNStages();
181 |                     break;
182 |                 case "refresh_status":
183 |                     updateVPNStatus();
184 |                     break;
185 |                 case "stage":
186 |                     result.success(OpenVPNService.getStatus());
187 |                     break;
188 |                 case "kill_switch":
189 |                     if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
190 |                         Intent intent = new Intent(Settings.ACTION_VPN_SETTINGS);
191 |                         startActivity(intent);
192 |                     }
193 |                     break;
194 |             }
195 |         });
196 | 
197 |     }
198 | 
199 |     private void prepareVPN() {
200 |         if (isConnected()) {
201 |             setStage("prepare");
202 | 
203 |             try {
204 |                 ConfigParser configParser = new ConfigParser();
205 |                 configParser.parseConfig(new StringReader(config));
206 |                 vpnProfile = configParser.convertProfile();
207 |             } catch (IOException e) {
208 |                 e.printStackTrace();
209 |             } catch (ConfigParser.ConfigParseError configParseError) {
210 |                 configParseError.printStackTrace();
211 |             }
212 | 
213 |             Intent vpnIntent = VpnService.prepare(this);
214 |             if (vpnIntent != null) startActivityForResult(vpnIntent, VPN_REQUEST_ID);
215 |             else startVPN();
216 |         } else {
217 |             setStage("nonetwork");
218 |         }
219 |     }
220 | 
221 |     private void startVPN() {
222 |         try {
223 |             setStage("connecting");
224 | 
225 |             if (vpnProfile.checkProfile(this) != de.blinkt.openvpn.R.string.no_error_found) {
226 |                 throw new RemoteException(getString(vpnProfile.checkProfile(this)));
227 |             }
228 |             vpnProfile.mName = name;
229 |             vpnProfile.mProfileCreator = getPackageName();
230 |             vpnProfile.mUsername = username;
231 |             vpnProfile.mPassword = password;
232 |             vpnProfile.mDNS1 = dns1;
233 |             vpnProfile.mDNS2 = dns2;
234 | 
235 |             if (dns1 != null && dns2 != null) {
236 |                 vpnProfile.mOverrideDNS = true;
237 |             }
238 | 
239 |             if (bypassPackages != null && bypassPackages.size() > 0) {
240 |                 vpnProfile.mAllowedAppsVpn.addAll(bypassPackages);
241 |                 vpnProfile.mAllowAppVpnBypass = true;
242 |             }
243 | 
244 |             ProfileManager.setTemporaryProfile(this, vpnProfile);
245 |             VPNLaunchHelper.startOpenVpn(vpnProfile, this);
246 |         } catch (RemoteException e) {
247 |             setStage("disconnected");
248 |             e.printStackTrace();
249 |         }
250 |     }
251 | 
252 | 
253 |     private void updateVPNStages() {
254 |         setStage(OpenVPNService.getStatus());
255 |     }
256 | 
257 |     private void updateVPNStatus() {
258 |         if (attached) vpnStatusSink.success(localJson.toString());
259 |     }
260 | 
261 | 
262 |     private boolean isConnected() {
263 |         ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
264 |         NetworkInfo nInfo = cm.getActiveNetworkInfo();
265 | 
266 |         return nInfo != null && nInfo.isConnectedOrConnecting();
267 |     }
268 | 
269 |     @Override
270 |     protected void onActivityResult(int requestCode, int resultCode, Intent data) {
271 |         if (requestCode == VPN_REQUEST_ID) {
272 |             if (resultCode == RESULT_OK) {
273 |                 startVPN();
274 |             } else {
275 |                 setStage("denied");
276 |                 Toast.makeText(this, "Permission is denied!", Toast.LENGTH_SHORT).show();
277 |             }
278 |         }
279 |         super.onActivityResult(requestCode, resultCode, data);
280 |     }
281 | 
282 | 
283 |     private void setStage(String stage) {
284 |         switch (stage.toUpperCase()) {
285 |             case "CONNECTED":
286 |                 if (vpnStageSink != null && attached) vpnStageSink.success("connected");
287 |                 break;
288 |             case "DISCONNECTED":
289 |                 if (vpnStageSink != null && attached) vpnStageSink.success("disconnected");
290 |                 break;
291 |             case "WAIT":
292 |                 if (vpnStageSink != null && attached) vpnStageSink.success("wait_connection");
293 |                 break;
294 |             case "AUTH":
295 |                 if (vpnStageSink != null && attached) vpnStageSink.success("authenticating");
296 |                 break;
297 |             case "RECONNECTING":
298 |                 if (vpnStageSink != null && attached) vpnStageSink.success("reconnect");
299 |                 break;
300 |             case "NONETWORK":
301 |                 if (vpnStageSink != null && attached) vpnStageSink.success("no_connection");
302 |                 break;
303 |             case "CONNECTING":
304 |                 if (vpnStageSink != null && attached) vpnStageSink.success("connecting");
305 |                 break;
306 |             case "PREPARE":
307 |                 if (vpnStageSink != null && attached) vpnStageSink.success("prepare");
308 |                 break;
309 |             case "DENIED":
310 |                 if (vpnStageSink != null && attached) vpnStageSink.success("denied");
311 |                 break;
312 |         }
313 |     }
314 | }
315 | 


--------------------------------------------------------------------------------
/android/app/src/main/res/drawable/launch_background.xml:
--------------------------------------------------------------------------------
 1 | <?xml version="1.0" encoding="utf-8"?>
 2 | <!-- Modify this file to customize your launch splash screen -->
 3 | <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
 4 |     <item android:drawable="@android:color/white" />
 5 | 
 6 |     <!-- You can insert your own image assets here -->
 7 |     <!-- <item>
 8 |         <bitmap
 9 |             android:gravity="center"
10 |             android:src="@mipmap/launch_image" />
11 |     </item> -->
12 | </layer-list>
13 | 


--------------------------------------------------------------------------------
/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml:
--------------------------------------------------------------------------------
1 | <?xml version="1.0" encoding="utf-8"?>
2 | <adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
3 |     <background android:drawable="@color/ic_launcher_background"/>
4 |     <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
5 | </adaptive-icon>


--------------------------------------------------------------------------------
/android/app/src/debug/AndroidManifest.xml:
--------------------------------------------------------------------------------
1 | <manifest xmlns:android="http://schemas.android.com/apk/res/android">
2 |     <!-- Flutter needs it to communicate with the running application
3 |          to allow setting breakpoints, to provide hot reload, etc.
4 |     -->
5 |     <uses-permission android:name="android.permission.INTERNET"/>
6 | </manifest>
7 | 


--------------------------------------------------------------------------------
/android/app/src/main/AndroidManifest.xml:
--------------------------------------------------------------------------------
 1 | <manifest xmlns:android="http://schemas.android.com/apk/res/android"
 2 |     xmlns:tools="http://schemas.android.com/tools">
 3 | 
 4 |     <uses-permission android:name="android.permission.INTERNET" />
 5 |     <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
 6 |     <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
 7 |     <uses-permission android:name="android.permission.WAKE_LOCK" />
 8 | 
 9 |     <!-- Ads Permission for Android 12 or higher -->
10 |     <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
11 |     
12 |     
13 |     <application
14 |         android:name="${applicationName}"
15 |         android:label="Free VPN"
16 |         android:icon="@mipmap/ic_launcher"
17 |         tools:ignore="AllowBackup">
18 |         
19 |         <!-- For Ads -->
20 |         <meta-data
21 |             android:name="com.google.android.gms.ads.APPLICATION_ID"
22 |             android:value="ca-app-pub-3940256099942544~3347511713"/>
23 | 
24 |         <!-- Disable Impeller -->
25 |         <meta-data
26 |             android:name="io.flutter.embedding.android.EnableImpeller"
27 |             android:value="false" />  
28 |         
29 |         <activity
30 |             android:name=".MainActivity"
31 |             android:launchMode="singleTop"
32 |             android:exported="true"
33 |             android:theme="@style/LaunchTheme"
34 |             android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
35 |             android:hardwareAccelerated="true"
36 |             android:windowSoftInputMode="adjustResize">
37 | 
38 |             <meta-data
39 |               android:name="io.flutter.embedding.android.NormalTheme"
40 |               android:resource="@style/NormalTheme"/>
41 |        
42 |             <intent-filter>
43 |                 <action android:name="android.intent.action.MAIN"/>
44 |                 <category android:name="android.intent.category.LAUNCHER"/>
45 |             </intent-filter>
46 |         </activity>
47 | 
48 |         <meta-data
49 |             android:name="flutterEmbedding"
50 |             android:value="2" />
51 | 
52 |         <activity
53 |             android:name="de.blinkt.openvpn.DisconnectVPNActivity"
54 |             android:excludeFromRecents="true"
55 |             android:noHistory="true"
56 |             android:exported="false"
57 |             android:taskAffinity=".DisconnectVPN"
58 |             android:theme="@style/blinkt.dialog" />
59 |             
60 |         <service
61 |             android:name="de.blinkt.openvpn.core.OpenVPNService"
62 |             android:exported="true"
63 |             android:permission="android.permission.BIND_VPN_SERVICE">
64 |             <intent-filter>
65 |                 <action android:name="android.net.VpnService" />
66 |             </intent-filter>
67 |         </service>
68 |     </application>
69 | </manifest>
70 | 

└── android
    ├── gradle.properties
    └── gradle
        └── wrapper
            └── gradle-wrapper.properties


/android/gradle.properties:
--------------------------------------------------------------------------------
1 | org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
2 | android.useAndroidX=true
3 | android.enableJetifier=true
4 | android.defaults.buildfeatures.aidl=true
5 | 
6 | # android.bundle.enableUncompressedNativeLibs = false
7 | #android.enableR8=true
8 | 


--------------------------------------------------------------------------------
/android/gradle/wrapper/gradle-wrapper.properties:
--------------------------------------------------------------------------------
1 | distributionBase=GRADLE_USER_HOME
2 | distributionPath=wrapper/dists
3 | zipStoreBase=GRADLE_USER_HOME
4 | zipStorePath=wrapper/dists
5 | distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
6 | 


--------------------------------------------------------------------------------