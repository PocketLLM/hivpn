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