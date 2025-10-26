NtInputLog(20833): VRI[MainActivity] : mView handled = true, motion action=ACTION_UP
D/NtInputLog(20833): VRI[MainActivity] : finishInputEvent, motion action=ACTION_UP

Error: Couldn't resolve the package 'flutter_speed_test_plus' in 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart'.
lib/features/speedtest/domain/speedtest_controller.dart:5:8: Error: Not found: 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart'
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
       ^
lib/services/speedtest/speedtest_service.dart:5:8: Error: Not found: 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart'
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
       ^
lib/features/speedtest/domain/speedtest_controller.dart:22:16: Error: Type 'TestResult' not found.
double _toMbps(TestResult result) {
               ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:13:9: Error: Type 'FlutterInternetSpeedTest' not found.
  final FlutterInternetSpeedTest _tester;
        ^^^^^^^^^^^^^^^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:8:31: Error: Type 'FlutterInternetSpeedTest' not found.
  SpeedTestService({Dio? dio, FlutterInternetSpeedTest? tester})
                              ^^^^^^^^^^^^^^^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:25:28: Error: Type 'TestResult' not found.
    required void Function(TestResult download, TestResult upload) onCompleted,
                           ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:25:49: Error: Type 'TestResult' not found.
    required void Function(TestResult download, TestResult upload) onCompleted,
                                                ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:27:19: Error: Type 'TestResult' not found.
    void Function(TestResult data)? onDownloadComplete,
                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:28:19: Error: Type 'TestResult' not found.
    void Function(TestResult data)? onUploadComplete,
                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:29:35: Error: Type 'TestResult' not found.
    void Function(double percent, TestResult data)? onProgress,
                                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:31:19: Error: Type 'Client' not found.
    void Function(Client? client)? onDefaultServerSelectionDone,
                  ^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:22:16: Error: 'TestResult' isn't a type.
double _toMbps(TestResult result) {
               ^^^^^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:25:10: Error: Undefined name 'SpeedUnit'.
    case SpeedUnit.mbps:
         ^^^^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:27:10: Error: Undefined name 'SpeedUnit'.
    case SpeedUnit.kbps:
         ^^^^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:22:8: Error: A non-null value must be returned since the return type 'double' doesn't allow     
null.
double _toMbps(TestResult result) {
       ^
lib/features/speedtest/domain/speedtest_controller.dart:106:18: Error: Not a constant expression.
            case TestType.download:
                 ^^^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:109:18: Error: Not a constant expression.
            case TestType.upload:
                 ^^^^^^^^
lib/features/speedtest/domain/speedtest_controller.dart:105:24: Error: The getter 'type' isn't defined for the type 'Object?'.
 - 'Object' is from 'dart:core'.
Try correcting the name to the name of an existing getter, or defining a getter or field named 'type'.
          switch (data.type) {
                       ^^^^
lib/services/speedtest/speedtest_service.dart:8:31: Error: 'FlutterInternetSpeedTest' isn't a type.
  SpeedTestService({Dio? dio, FlutterInternetSpeedTest? tester})
                              ^^^^^^^^^^^^^^^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:10:29: Error: Method not found: 'FlutterInternetSpeedTest'.
        _tester = tester ?? FlutterInternetSpeedTest();
                            ^^^^^^^^^^^^^^^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:13:9: Error: 'FlutterInternetSpeedTest' isn't a type.
  final FlutterInternetSpeedTest _tester;
        ^^^^^^^^^^^^^^^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:25:28: Error: 'TestResult' isn't a type.
    required void Function(TestResult download, TestResult upload) onCompleted,
                           ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:25:49: Error: 'TestResult' isn't a type.
    required void Function(TestResult download, TestResult upload) onCompleted,
                                                ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:27:19: Error: 'TestResult' isn't a type.
    void Function(TestResult data)? onDownloadComplete,
                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:28:19: Error: 'TestResult' isn't a type.
    void Function(TestResult data)? onUploadComplete,
                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:29:35: Error: 'TestResult' isn't a type.
    void Function(double percent, TestResult data)? onProgress,
                                  ^^^^^^^^^^
lib/services/speedtest/speedtest_service.dart:31:19: Error: 'Client' isn't a type.
    void Function(Client? client)? onDefaultServerSelectionDone,
                  ^^^^^^
Performing hot restart...                                               
Restarted application in 819ms.
Try again after fixing the above error(s).
Lost connection to device.
PS D:\Projects\hivpn> "

Here I am providing you the code from someone else who have the proper logic of implementing how this VPN and everything is currently working in their application. Okay, so make sure to take a good look into their code. They have implemented Firebase also I guess, but we don't need it, I specify you. We will implement Google AdMob, but we don't need Firebase I guess. But see how they have used the VPN Gates API to properly set up and all the required information that they have shown like IP address, host, country, ping, download speed, upload speed, and country flags and everything. See all that information that they have added and how they have added and how we can integrate it into our code base to create the proper detailed application. Like we have very nice and detailed UI right now. We just need to improve it, not UI, but the functionality we need to integrate it from that code base. So study this given code base in detail and then I want you to create a very nice implementation. Like I want you to incorporate all of this logic, all of this API calls, and all of this thing that is required to build the application into our app. Okay, so that we will be able to publish this application and our VPN services and everything should be running. Okay, make sure to add proper permissions and everything in the Android main XML file and everything wherever required. Okay, so that user can give us permission for everything. Please implement everything in detail without breaking the current code base. Thank you very much. keep the ui as we have okay dont change our change just add more details annd informations and all from the given codebase incorporate all the logic into our codebase: Make sure to remove any kind of static data that we have in our app that because I guess the Mumbai and New York survey that we are displaying is currently static completely so I want you to remove those things and make sure to implement the API structure and everything and output and all the data points the property as I have given you this reference code base similarly as they have implemented I don't want you to copy their UI but I want you to copy their all of the information that they are displaying we should be able to display that information and integrate it properly into our UI OK and make sure that we are also calling the API we are use the high went flutter hive for everything use HTTP for calling and get X and everything that is required please use everything so that we are able to integrate this properly add proper permissions into our Android XML file so that we are able to call the you know user for the permissions and make sure the app doesn't crash as ads work properly and all thank you.
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
 9 |     @-- Ads Permission for Android 12 or higher --
10 |     <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
11 |     
12 |     
13 |     <application
14 |         android:name="${applicationName}"
15 |         android:label="Free VPN"
16 |         android:icon="@mipmap/ic_launcher"
17 |         tools:ignore="AllowBackup">
18 |         
19 |         @-- For Ads --
20 |         <meta-data
21 |             android:name="com.google.android.gms.ads.APPLICATION_ID"
22 |             android:value="ca-app-pub-3940256099942544~3347511713"/>
23 | 
24 |         @-- Disable Impeller --
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


--------------------------------------------------------------------------------
/android/app/src/main/ic_launcher-playstore.png:
--------------------------------------------------------------------------------
https://raw.githubusercontent.com/HarshAndroid/FreeVPN-App-Flutter/f2f78106c6e57122e55d5ecc4e6f3959ad753529/android/app/src/main/ic_launcher-playstore.png


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
2. let me tell you that still server lo cations are not visible make sure you are studying properly and implementing it is saying failed to load servers no vpn servers found. ? why is it ? this is the url http://www.vpngate.net/api/iphone/ for both the android and iphone okay you just need to request from this url to get the proepr informaiton okay to immplement things ,└── lib 
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

# Comprehensive VPN Implementation Guide: Integrating VPN Gate API into Flutter App

## Table of Contents
1. [Overview](#overview)
2. [VPN Gate API Analysis](#vpn-gate-api-analysis)
3. [Reference Codebase Analysis](#reference-codebase-analysis)
4. [Implementation Plan](#implementation-plan)
5. [Step-by-Step Implementation](#step-by-step-implementation)
6. [Testing and Validation](#testing-and-validation)
7. [Troubleshooting](#troubleshooting)
8. [Conclusion](#conclusion)

## Overview

This document provides a comprehensive guide to implementing VPN functionality using the VPN Gate API into your existing Flutter codebase. The implementation will include:
- Fetching VPN server data from VPN Gate API
- Processing and displaying server information
- Connecting to selected VPN servers
- Managing VPN connection states
- Displaying connection statistics

## VPN Gate API Analysis

### What is VPN Gate?

VPN Gate is a free VPN service provided by the Academic Community Project. It provides:
- Free VPN servers from around the world
- OpenVPN protocol support
- Public API for accessing server information
- No user registration required

### VPN Gate API Endpoint

The reference codebase uses the following endpoint:
```
http://www.vpngate.net/api/iphone/
```

This endpoint returns data in a CSV format with specific formatting requirements.

### API Response Format

The API response consists of:
1. A header line starting with `#`
2. CSV data with server information
3. A footer line starting with `*`

Example response structure:
```
#HostName,IP,Ping,Speed,CountryLong,CountryShort,NumVpnSessions,OpenVPN_ConfigData_Base64
vpn1.example.com,192.168.1.1,120,50000000,Japan,JP,5,SGVsbG8gV29ybGQ=
vpn2.example.com,192.168.1.2,80,30000000,United States,US,10,QW5vdGhlciBTZXJ2ZXI=
*
```

### Data Fields Explanation

| Field | Description | Example |
|-------|-------------|---------|
| HostName | Server hostname | vpn1.example.com |
| IP | Server IP address | 192.168.1.1 |
| Ping | Response time in ms | 120 |
| Speed | Server speed in bps | 50000000 |
| CountryLong | Full country name | Japan |
| CountryShort | Country code (2 letters) | JP |
| NumVpnSessions | Number of active sessions | 5 |
| OpenVPN_ConfigData_Base64 | Base64 encoded OpenVPN config | SGVsbG8gV29ybGQ= |

## Reference Codebase Analysis

### Key Components

The reference codebase implements VPN functionality through several key components:

#### 1. API Service (`/lib/apis/apis.dart`)

This component handles:
- Fetching data from VPN Gate API
- Parsing CSV response
- Converting to JSON format
- Error handling

Key methods:
- `getVPNServers()`: Fetches and processes VPN server data
- `getIPDetails()`: Gets current IP information

#### 2. Data Models

The reference codebase uses several models to represent VPN data:

##### `Vpn` Model (`/lib/models/vpn.dart`)
```dart
class Vpn {
  late final String hostname;
  late final String ip;
  late final String ping;
  late final int speed;
  late final String countryLong;
  late final String countryShort;
  late final int numVpnSessions;
  late final String openVPNConfigDataBase64;
  
  // Constructor and fromJson method
}
```

##### `VpnConfig` Model (`/lib/models/vpn_config.dart`)
```dart
class VpnConfig {
  final String country;
  final String username;
  final String password;
  final String config;
}
```

##### `VpnStatus` Model (`/lib/models/vpn_status.dart`)
```dart
class VpnStatus {
  String? duration;
  String? lastPacketReceive;
  String? byteIn;
  String? byteOut;
}
```

#### 3. Controllers

The reference codebase uses GetX for state management:

##### `HomeController` (`/lib/controllers/home_controller.dart`)
- Manages VPN connection state
- Handles connect/disconnect functionality
- Updates UI based on connection status

##### `LocationController` (`/lib/controllers/location_controller.dart`)
- Manages VPN server list
- Handles server selection
- Refreshes server data

#### 4. VPN Engine (`/lib/services/vpn_engine.dart`)

This component handles:
- Communication with native VPN service
- Starting and stopping VPN connections
- Monitoring connection status
- Providing connection statistics

#### 5. Native Android Service

The reference codebase includes a native Android service that:
- Implements OpenVPN protocol
- Manages VPN tunnel
- Handles connection lifecycle
- Provides status updates

### Data Flow

1. **Server Data Retrieval**:
   ```
   LocationController.getVpnData() → APIs.getVPNServers() → VPN Gate API → CSV Response → JSON Processing → Vpn Models
   ```

2. **VPN Connection**:
   ```
   User Action → HomeController.connectToVpn() → VpnEngine.startVpn() → Native VPN Service → OpenVPN Connection
   ```

3. **Status Updates**:
   ```
   Native VPN Service → Event Channel → VpnEngine → HomeController → UI Updates
   ```

## Implementation Plan

### Phase 1: API Integration

1. Create API service to fetch VPN server data
2. Implement CSV parsing logic
3. Create data models for VPN information
4. Add error handling and logging

### Phase 2: UI Components

1. Create server list screen
2. Implement server selection UI
3. Add connection status indicators
4. Create network information display

### Phase 3: VPN Engine

1. Implement Flutter platform channels
2. Create native Android VPN service
3. Add connection management logic
4. Implement status monitoring

### Phase 4: Integration

1. Integrate all components
2. Implement state management
3. Add user preferences
4. Implement ad integration

## Step-by-Step Implementation

### Step 1: Update Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core dependencies
  get: ^4.6.5
  http: ^1.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.0.15
  
  # CSV parsing for VPN Gate API
  csv: ^5.0.2
  
  # UI dependencies
  lottie: ^2.6.0
  
  # AdMob
  google_mobile_ads: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

### Step 2: Create API Service

Create `/lib/apis/apis.dart`:

```dart
import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/ip_details.dart';
import '../models/vpn.dart';

class APIs {
  // Fetch VPN servers from VPN Gate API
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = [];
    
    try {
      // Make HTTP request to VPN Gate API
      final res = await get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      
      // Extract CSV data from response (remove header and footer)
      final csvString = res.body.split("#")[1].replaceAll('*', '');
      
      // Parse CSV data
      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];
      
      // Convert CSV rows to VPN objects
      for (int i = 1; i < list.length - 1; ++i) {
        Map<String, dynamic> tempJson = {};
        
        for (int j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }
        vpnList.add(Vpn.fromJson(tempJson));
      }
    } catch (e) {
      // Handle errors
      MyDialogs.error(msg: e.toString());
      log('\ngetVPNServersE: $e');
    }
    
    // Shuffle the list for random server selection
    vpnList.shuffle();
    
    // Cache the VPN list locally
    if (vpnList.isNotEmpty) Pref.vpnList = vpnList;
    
    return vpnList;
  }

  // Get IP details using IP-API
  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'));
      final data = jsonDecode(res.body);
      log(data.toString());
      ipData.value = IPDetails.fromJson(data);
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetIPDetailsE: $e');
    }
  }
}
```

### Step 3: Create Data Models

Create `/lib/models/vpn.dart`:

```dart
class Vpn {
  late final String hostname;
  late final String ip;
  late final String ping;
  late final int speed;
  late final String countryLong;
  late final String countryShort;
  late final int numVpnSessions;
  late final String openVPNConfigDataBase64;

  Vpn({
    required this.hostname,
    required this.ip,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.numVpnSessions,
    required this.openVPNConfigDataBase64});

  Vpn.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping'].toString();
    speed = json['Speed'] ?? 0;
    countryLong = json['CountryLong'] ?? '';
    countryShort = json['CountryShort'] ?? '';
    numVpnSessions = json['NumVpnSessions'] ?? 0;
    openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['CountryLong'] = countryLong;
    data['CountryShort'] = countryShort;
    data['NumVpnSessions'] = numVpnSessions;
    data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
    return data;
  }
}
```

Create `/lib/models/vpn_config.dart`:

```dart
class VpnConfig {
  VpnConfig({
    required this.country,
    required this.username,
    required this.password,
    required this.config,
  });

  final String country;
  final String username;
  final String password;
  final String config;
}
```

Create `/lib/models/vpn_status.dart`:

```dart
class VpnStatus {
  VpnStatus({this.duration, this.lastPacketReceive, this.byteIn, this.byteOut});

  String? duration;
  String? lastPacketReceive;
  String? byteIn;
  String? byteOut;

  factory VpnStatus.fromJson(Map<String, dynamic> json) => VpnStatus(
        duration: json['duration'],
        lastPacketReceive: json['last_packet_receive'],
        byteIn: json['byte_in'],
        byteOut: json['byte_out'],
      );

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'last_packet_receive': lastPacketReceive,
        'byte_in': byteIn,
        'byte_out': byteOut
      };
}
```

Create `/lib/models/ip_details.dart`:

```dart
class IPDetails {
  late final String country;
  late final String regionName;
  late final String city;
  late final String zip;
  late final String timezone;
  late final String isp;
  late final String query;

  IPDetails({
    required this.country,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.timezone,
    required this.isp,
    required this.query,
  });

  IPDetails.fromJson(Map<String, dynamic> json) {
    country = json['country'] ?? '';
    regionName = json['regionName'] ?? '';
    city = json['city'] ?? '';
    zip = json['zip'] ?? ' - - - - ';
    timezone = json['timezone'] ?? 'Unknown';
    isp = json['isp'] ?? 'Unknown';
    query = json['query'] ?? 'Not available';
  }
}
```

Create `/lib/models/network_data.dart`:

```dart
import 'package:flutter/material.dart';

class NetworkData {
  String title, subtitle;
  Icon icon;

  NetworkData(
      {required this.title, required this.subtitle, required this.icon});
}
```

### Step 4: Create Controllers

Create `/lib/controllers/home_controller.dart`:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpers/ad_helper.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() async {
    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      // Decode Base64 config
      final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

      // Show interstitial ad and then connect to VPN
      AdHelper.showInterstitialAd(onComplete: () async {
        await VpnEngine.startVpn(vpnConfig);
      });
    } else {
      await VpnEngine.stopVpn();
    }
  }

  // VPN button color based on connection state
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.blue;
      case VpnEngine.vpnConnected:
        return Colors.green;
      default:
        return Colors.orangeAccent;
    }
  }

  // VPN button text based on connection state
  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';
      case VpnEngine.vpnConnected:
        return 'Disconnect';
      default:
        return 'Connecting...';
    }
  }
}
```

Create `/lib/controllers/location_controller.dart`:

```dart
import 'package:get/get.dart';
import '../apis/apis.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';

class LocationController extends GetxController {
  List<Vpn> vpnList = Pref.vpnList;
  final RxBool isLoading = false.obs;

  Future<void> getVpnData() async {
    isLoading.value = true;
    vpnList.clear();
    vpnList = await APIs.getVPNServers();
    isLoading.value = false;
  }
}
```

Create `/lib/controllers/native_ad_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdController extends GetxController {
  NativeAd? ad;
  final adLoaded = false.obs;
}
```

### Step 5: Create VPN Engine

Create `/lib/services/vpn_engine.dart`:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vpn_config.dart';
import '../models/vpn_status.dart';

class VpnEngine {
  // Channel names for native communication
  static const String _eventChannelVpnStage = "vpnStage";
  static const String _eventChannelVpnStatus = "vpnStatus";
  static const String _methodChannelVpnControl = "vpnControl";

  // Snapshot of VPN connection stage
  static Stream<String> vpnStageSnapshot() =>
      EventChannel(_eventChannelVpnStage).receiveBroadcastStream().cast();

  // Snapshot of VPN connection status
  static Stream<VpnStatus?> vpnStatusSnapshot() =>
      EventChannel(_eventChannelVpnStatus)
          .receiveBroadcastStream()
          .map((event) => VpnStatus.fromJson(jsonDecode(event)))
          .cast();

  // Start VPN connection
  static Future<void> startVpn(VpnConfig vpnConfig) async {
    return MethodChannel(_methodChannelVpnControl).invokeMethod(
      "start",
      {
        "config": vpnConfig.config,
        "country": vpnConfig.country,
        "username": vpnConfig.username,
        "password": vpnConfig.password,
      },
    );
  }

  // Stop VPN connection
  static Future<void> stopVpn() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("stop");

  // Open VPN settings
  static Future<void> openKillSwitch() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("kill_switch");

  // Refresh VPN connection
  static Future<void> refreshStage() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("refresh");

  // Get current VPN stage
  static Future<String?> stage() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("stage");

  // Check if VPN is connected
  static Future<bool> isConnected() =>
      stage().then((value) => value?.toLowerCase() == "connected");

  // VPN connection states
  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
}
```

### Step 6: Create Helper Classes

Create `/lib/helpers/ad_helper.dart`:

```dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/native_ad_controller.dart';
import 'config.dart';
import 'my_dialogs.dart';

class AdHelper {
  // Initialize AdMob SDK
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  // Interstitial Ad variables
  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  // Native Ad variables
  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  // *****************Interstitial Ad******************

  // Preload interstitial ad
  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Ad listener
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  // Reset interstitial ad
  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  // Show interstitial ad
  static void showInterstitialAd({required VoidCallback onComplete}) {
    log('Interstitial Ad Id: ${Config.interstitialAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Ad listener
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            onComplete();
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          Get.back();
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          onComplete();
        },
      ),
    );
  }

  // *****************Native Ad******************

  // Preload native ad
  static void precacheNativeAd() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAd = NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small))
      ..load();
  }

  // Reset native ad
  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  // Load native ad
  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded && _nativeAd != null) {
      adController.adLoaded.value = true;
      return _nativeAd;
    }

    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAd();
            precacheNativeAd();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small))
      ..load();
  }

  // *****************Rewarded Ad******************

  // Show rewarded ad
  static void showRewardedAd({required VoidCallback onComplete}) {
    log('Rewarded Ad Id: ${Config.rewardedAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back();

          // Reward listener
          ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            onComplete();
          });
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }
}
```

Create `/lib/helpers/config.dart`:

```dart
class Config {
  // Ad unit IDs (replace with your actual AdMob IDs)
  static const String interstitialAd = "ca-app-pub-3940256099942544/1033173712"; // Test ID
  static const String nativeAd = "ca-app-pub-3940256099942544/2247696110"; // Test ID
  static const String rewardedAd = "ca-app-pub-3940256099942544/5224354917"; // Test ID

  // Flag to hide ads (for premium version or testing)
  static bool hideAds = false;

  // App configuration
  static const String appName = "VPN App";
  static const String appVersion = "1.0.0";
}
```

Create `/lib/helpers/my_dialogs.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs {
  static success({required String msg}) {
    Get.snackbar('Success', msg,
        colorText: Colors.white, backgroundColor: Colors.green.withOpacity(.9));
  }

  static error({required String msg}) {
    Get.snackbar('Error', msg,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(.9));
  }

  static info({required String msg}) {
    Get.snackbar('Info', msg, colorText: Colors.white);
  }

  static showProgress() {
    Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}
```

Create `/lib/helpers/pref.dart`:

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vpn.dart';

class Pref {
  static late Box _box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('data');
  }

  // For storing theme data
  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  static set isDarkMode(bool v) => _box.put('isDarkMode', v);

  // For storing single selected VPN details
  static Vpn get vpn => Vpn.fromJson(jsonDecode(_box.get('vpn') ?? '{}'));
  static set vpn(Vpn v) => _box.put('vpn', jsonEncode(v));

  // For storing VPN servers details
  static List<Vpn> get vpnList {
    List<Vpn> temp = [];
    final data = jsonDecode(_box.get('vpnList') ?? '[]');

    for (var i in data) temp.add(Vpn.fromJson(i));

    return temp;
  }

  static set vpnList(List<Vpn> v) => _box.put('vpnList', jsonEncode(v));
}
```

### Step 7: Create UI Components

Create `/lib/screens/home_screen.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import '../widgets/watch_ad_dialog.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    // Add listener to update VPN state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      // App bar
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text(Config.appName),
        actions: [
          IconButton(
              onPressed: () {
                // Theme toggle with ad
                if (Config.hideAds) {
                  Get.changeThemeMode(
                      Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  Pref.isDarkMode = !Pref.isDarkMode;
                  return;
                }

                Get.dialog(WatchAdDialog(onComplete: () {
                  // Watch ad to gain reward
                  AdHelper.showRewardedAd(onComplete: () {
                    Get.changeThemeMode(
                        Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                    Pref.isDarkMode = !Pref.isDarkMode;
                  });
                }));
              },
              icon: Icon(
                Icons.brightness_medium,
                size: 26,
              )),
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => NetworkTestScreen()),
              icon: Icon(
                CupertinoIcons.info,
                size: 27,
              )),
        ],
      ),

      bottomNavigationBar: _changeLocation(context),

      // Body
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // VPN button
          Obx(() => _vpnButton()),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Country flag
                HomeCard(
                    title: _controller.vpn.value.countryLong.isEmpty
                        ? 'Country'
                        : _controller.vpn.value.countryLong,
                    subtitle: 'FREE',
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: _controller.vpn.value.countryLong.isEmpty
                          ? Icon(Icons.vpn_lock_rounded,
                              size: 30, color: Colors.white)
                          : null,
                      backgroundImage: _controller.vpn.value.countryLong.isEmpty
                          ? null
                          : AssetImage(
                              'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                    )),

                // Ping time
                HomeCard(
                    title: _controller.vpn.value.countryLong.isEmpty
                        ? '100 ms'
                        : '${_controller.vpn.value.ping} ms',
                    subtitle: 'PING',
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.equalizer_rounded,
                          size: 30, color: Colors.white),
                    )),
              ],
            ),
          ),

          StreamBuilder<VpnStatus?>(
              initialData: VpnStatus(),
              stream: VpnEngine.vpnStatusSnapshot(),
              builder: (context, snapshot) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Download
                      HomeCard(
                          title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                          subtitle: 'DOWNLOAD',
                          icon: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.lightGreen,
                            child: Icon(Icons.arrow_downward_rounded,
                                size: 30, color: Colors.white),
                          )),

                      // Upload
                      HomeCard(
                          title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                          subtitle: 'UPLOAD',
                          icon: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.arrow_upward_rounded,
                                size: 30, color: Colors.white),
                          )),
                    ],
                  ))
        ],
      ),
    );
  }

  // VPN button widget
  Widget _vpnButton() => Column(
        children: [
          // Button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Icon(
                          Icons.power_settings_new,
                          size: 28,
                          color: Colors.white,
                        ),

                        SizedBox(height: 4),

                        // Text
                        Text(
                          _controller.getButtonText,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Connection status label
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.value.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),

          // Count down timer
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  // Bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              color: Theme.of(context).bottomNav,
              padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
              height: 60,
              child: Row(
                children: [
                  // Icon
                  Icon(CupertinoIcons.globe, color: Colors.white, size: 28),

                  // For adding some space
                  SizedBox(width: 10),

                  // Text
                  Text(
                    'Change Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),

                  // For covering available spacing
                  Spacer(),

                  // Icon
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.keyboard_arrow_right_rounded,
                        color: Colors.blue, size: 26),
                  )
                ],
              )),
        ),
      ));
}
```

Create `/lib/screens/location_screen.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
      () => Scaffold(
        // App bar
        appBar: AppBar(
          title: Text('VPN Locations (${_controller.vpnList.length})'),
        ),

        bottomNavigationBar:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,

        // Refresh button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: FloatingActionButton(
              onPressed: () => _controller.getVpnData(),
              child: Icon(CupertinoIcons.refresh)),
        ),

        body: _controller.isLoading.value
            ? _loadingWidget()
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : _vpnData(),
      ),
    );
  }

  _vpnData() => ListView.builder(
      itemCount: _controller.vpnList.length,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
          top: mq.height * .015,
          bottom: mq.height * .1,
          left: mq.width * .04,
          right: mq.width * .04),
      itemBuilder: (ctx, i) => VpnCard(vpn: _controller.vpnList[i]));

  _loadingWidget() => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            LottieBuilder.asset('assets/lottie/loading.json',
                width: mq.width * .7),

            // Text
            Text(
              'Loading VPNs... 😌',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      );

  _noVPNFound() => Center(
        child: Text(
          'VPNs Not Found! 😔',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      );
}
```

Create `/lib/screens/network_test_screen.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../apis/apis.dart';
import '../main.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../widgets/network_card.dart';

class NetworkTestScreen extends StatelessWidget {
  const NetworkTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);

    return Scaffold(
      appBar: AppBar(title: Text('Network Test Screen')),

      // Refresh button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
            onPressed: () {
              ipData.value = IPDetails.fromJson({});
              APIs.getIPDetails(ipData: ipData);
            },
            child: Icon(CupertinoIcons.refresh)),
      ),

      body: Obx(
        () => ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
                left: mq.width * .04,
                right: mq.width * .04,
                top: mq.height * .01,
                bottom: mq.height * .1),
            children: [
              // IP
              NetworkCard(
                  data: NetworkData(
                      title: 'IP Address',
                      subtitle: ipData.value.query,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.blue))),

              // ISP
              NetworkCard(
                  data: NetworkData(
                      title: 'Internet Provider',
                      subtitle: ipData.value.isp,
                      icon: Icon(Icons.business, color: Colors.orange))),

              // Location
              NetworkCard(
                  data: NetworkData(
                      title: 'Location',
                      subtitle: ipData.value.country.isEmpty
                          ? 'Fetching ...'
                          : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                      icon: Icon(CupertinoIcons.location, color: Colors.pink))),

              // Pin code
              NetworkCard(
                  data: NetworkData(
                      title: 'Pin-code',
                      subtitle: ipData.value.zip,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.cyan))),

              // Timezone
              NetworkCard(
                  data: NetworkData(
                      title: 'Timezone',
                      subtitle: ipData.value.timezone,
                      icon: Icon(CupertinoIcons.time, color: Colors.green))),
            ]),
      ),
    );
  }
}
```

Create `/lib/screens/splash_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      // Exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();

      // Navigate to home
      Get.off(() => HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // App logo
          Positioned(
              left: mq.width * .3,
              top: mq.height * .2,
              width: mq.width * .4,
              child: Image.asset('assets/images/logo.png')),

          // Label
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                'MADE WITH ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).lightText, letterSpacing: 1),
              ))
        ],
      ),
    );
  }
}
```

### Step 8: Create Widgets

Create `/lib/widgets/count_down_timer.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final bool startTimer;

  const CountDownTimer({super.key, required this.startTimer});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  Duration _duration = Duration();
  Timer? _timer;

  _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
    });
  }

  _stopTimer() {
    setState(() {
      _timer?.cancel();
      _timer = null;
      _duration = Duration();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null || !widget.startTimer)
      widget.startTimer ? _startTimer() : _stopTimer();

    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigit(_duration.inMinutes.remainder(60));
    final seconds = twoDigit(_duration.inSeconds.remainder(60));
    final hours = twoDigit(_duration.inHours.remainder(60));

    return Text('$hours: $minutes: $seconds', style: TextStyle(fontSize: 22));
  }
}
```

Create `/lib/widgets/home_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../main.dart';

// Card to represent status in home screen
class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget icon;

  const HomeCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: mq.width * .45,
        child: Column(
          children: [
            // Icon
            icon,

            // For adding some space
            const SizedBox(height: 6),

            // Title
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            // For adding some space
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                  color: Theme.of(context).lightText,
                  fontWeight: FontWeight.w500,
                  fontSize: 12),
            ),
          ],
        ));
  }
}
```

Create `/lib/widgets/network_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/network_data.dart';

class NetworkCard extends StatelessWidget {
  final NetworkData data;

  const NetworkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: mq.height * .01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

            // Flag
            leading: Icon(data.icon.icon,
                color: data.icon.color, size: data.icon.size ?? 28),

            // Title
            title: Text(data.title),

            // Subtitle
            subtitle: Text(data.subtitle),
          ),
        ));
  }
}
```

Create `/lib/widgets/vpn_card.dart`:

```dart
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../services/vpn_engine.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: mq.height * .01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            controller.vpn.value = vpn;
            Pref.vpn = vpn;
            Get.back();

            if (controller.vpnState.value == VpnEngine.vpnConnected) {
              VpnEngine.stopVpn();
              Future.delayed(
                  Duration(seconds: 2), () => controller.connectToVpn());
            } else {
              controller.connectToVpn();
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

            // Flag
            leading: Container(
              padding: EdgeInsets.all(.5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(5)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                    'assets/flags/${vpn.countryShort.toLowerCase()}.png',
                    height: 40,
                    width: mq.width * .15,
                    fit: BoxFit.cover),
              ),
            ),

            // Title
            title: Text(vpn.countryLong),

            // Subtitle
            subtitle: Row(
              children: [
                Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
                SizedBox(width: 4),
                Text(_formatBytes(vpn.speed, 1), style: TextStyle(fontSize: 13))
              ],
            ),

            // Trailing
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vpn.numVpnSessions.toString(),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).lightText)),
                SizedBox(width: 4),
                Icon(CupertinoIcons.person_3, color: Colors.blue),
              ],
            ),
          ),
        ));
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
```

Create `/lib/widgets/watch_ad_dialog.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdDialog extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialog({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Change Theme'),
      content: Text('Watch an Ad to Change App Theme.'),
      actions: [
        CupertinoDialogAction(
            isDefaultAction: true,
            textStyle: TextStyle(color: Colors.green),
            child: Text('Watch Ad'),
            onPressed: () {
              Get.back();
              onComplete();
            }),
      ],
    );
  }
}
```

### Step 9: Update Main App

Update `/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';

// Global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Initialize Hive for local storage
  await Pref.initializeHive();

  // Initialize AdMob
  await AdHelper.initAds();

  // For setting orientation to portrait only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Config.appName,
      home: SplashScreen(),

      // Theme
      theme: ThemeData(
        appBarTheme: AppBarTheme(centerTitle: true, elevation: 3),
        useMaterial3: false,
      ),

      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Dark theme
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: false,
          appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),

      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.blue;
}
```

### Step 10: Update Android Manifest

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.vpn_app">

    <!-- Internet permission for VPN and API calls -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Network state permission for connectivity checks -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- VPN service permission -->
    <uses-permission android:name="android.permission.BIND_VPN_SERVICE" />

    <!-- Foreground service permission for VPN service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    <!-- Notification permission for Android 13+ -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Wake lock permission to keep CPU awake -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="VPN App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- VPN Service Declaration -->
        <service
            android:name=".services.VpnService"
            android:permission="android.permission.BIND_VPN_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.net.VpnService"/>
            </intent-filter>
        </service>

        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### Step 11: Create Native Android VPN Service

Create `android/app/src/main/kotlin/com/example/vpn_app/services/VpnService.kt`:

```kotlin
package com.example.vpn_app.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat
import de.blinkt.openvpn.OpenVpnApi
import de.blinkt.openvpn.core.OpenVPNService
import de.blinkt.openvpn.core.VpnStatus
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class VpnService : OpenVPNService() {
    private var vpnInterface: ParcelFileDescriptor? = null

    companion object {
        private const val NOTIFICATION_CHANNEL_ID = "vpn_service_channel"
        private const val NOTIFICATION_ID = 1
        private const val ACTION_DISCONNECT = "disconnect"

        private var eventChannel: EventChannel.EventSink? = null
        private var statusEventChannel: EventChannel.EventSink? = null
        private var methodChannel: MethodChannel.MethodCallHandler? = null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())

        // Initialize VPN status listener
        VpnStatus.addStateListener(object : VpnStatus.StateListener {
            override fun updateState(
                state: String,
                logmessage: String,
                localizedResId: Int,
                level: VpnStatus.ConnectionStatus?,
                intent: Intent?
            ) {
                eventChannel?.success(state)

                // Send status data
                val statusData = mapOf(
                    "duration" to VpnStatus.getLastConnectedTime(),
                    "last_packet_receive" to VpnStatus.getLastPacketReceive(),
                    "byte_in" to VpnStatus.getByteIn(),
                    "byte_out" to VpnStatus.getByteOut()
                )
                statusEventChannel?.success(statusData)
            }

            override fun setConnectedVPN(uuid: String) {
                // Connected
            }
        })
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "VPN Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        val disconnectIntent = Intent(this, VpnService::class.java).apply {
            action = ACTION_DISCONNECT
        }

        val disconnectPendingIntent = PendingIntent.getService(
            this, 0, disconnectIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("VPN Service")
            .setContentText("VPN is running")
            .setSmallIcon(R.drawable.ic_notification)
            .addAction(R.drawable.ic_disconnect, "Disconnect", disconnectPendingIntent)
            .build()
    }

    fun startVpn(config: String, country: String, username: String, password: String) {
        try {
            // Stop any existing VPN connection
            stopVpn()

            // Start new VPN connection
            OpenVpnApi.startVpn(
                this,
                config,
                country,
                username,
                password
            )

            // Update notification
            val notification = createNotification()
            notificationManager.notify(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            Log.e("VpnService", "Error starting VPN: ${e.message}")
            eventChannel?.success("error")
        }
    }

    fun stopVpn() {
        try {
            OpenVpnApi.stopVpn(this)
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e("VpnService", "Error stopping VPN: ${e.message}")
        }
    }

    fun refreshStage() {
        // Refresh VPN connection stage
        val state = VpnStatus.getConnectionStatus()
        eventChannel?.success(state.state.name.lowercase())
    }

    fun getStage(): String? {
        return VpnStatus.getConnectionStatus().state.name.lowercase()
    }

    // Static methods for Flutter integration
    fun setEventChannel(sink: EventChannel.EventSink) {
        eventChannel = sink
    }

    fun setStatusEventChannel(sink: EventChannel.EventSink) {
        statusEventChannel = sink
    }

    fun setMethodChannel(handler: MethodChannel.MethodCallHandler) {
        methodChannel = handler
    }
}
```

### Step 12: Create Flutter Plugin

Create `android/app/src/main/kotlin/com/example/vpn_app/VpnPlugin.kt`:

```kotlin
package com.example.vpn_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.annotation.NonNull
import de.blinkt.openvpn.core.VpnStatus
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VpnPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var statusEventChannel: EventChannel

    private var context: Context? = null
    private var vpnService: VpnService? = null
    private var isBound = false

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as VpnService.LocalBinder
            vpnService = binder.getService()
            isBound = true
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            isBound = false
            vpnService = null
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "vpnControl"
        )
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "vpnStage"
        )
        eventChannel.setStreamHandler(this)

        statusEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "vpnStatus"
        )
        statusEventChannel.setStreamHandler(this)

        // Initialize VPN status
        VpnStatus.initLogCache(flutterPluginBinding.applicationContext.cacheDir)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "start" -> {
                val config = call.argument<String>("config") ?: ""
                val country = call.argument<String>("country") ?: ""
                val username = call.argument<String>("username") ?: ""
                val password = call.argument<String>("password") ?: ""

                startVpnService()
                vpnService?.startVpn(config, country, username, password)
                result.success(null)
            }
            "stop" -> {
                vpnService?.stopVpn()
                result.success(null)
            }
            "refresh" -> {
                vpnService?.refreshStage()
                result.success(null)
            }
            "stage" -> {
                result.success(vpnService?.getStage())
            }
            "kill_switch" -> {
                // Open kill switch settings
                val intent = Intent(android.provider.Settings.ACTION_VPN_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context?.startActivity(intent)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        statusEventChannel.setStreamHandler(null)

        if (isBound) {
            context?.unbindService(serviceConnection)
            isBound = false
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            when (arguments as String) {
                "vpnStage" -> {
                    vpnService?.setEventChannel(events)
                }
                "vpnStatus" -> {
                    vpnService?.setStatusEventChannel(events)
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        when (arguments as String) {
            "vpnStage" -> {
                vpnService?.setEventChannel(null)
            }
            "vpnStatus" -> {
                vpnService?.setStatusEventChannel(null)
            }
        }
    }

    private fun startVpnService() {
        if (!isBound) {
            val intent = Intent(context, VpnService::class.java)
            context?.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
            context?.startService(intent)
        }
    }
}
```

### Step 13: Update Android Build Configuration

Update `android/app/build.gradle`:

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // OpenVPN Android
    implementation 'de.blinkt.openvpn:openvpn:3.0.0'
    
    // AdMob
    implementation 'com.google.android.gms:play-services-ads:22.4.0'
}
```

### Step 14: Add Required Assets

1. Create `assets/flags/` directory and add country flag images
2. Create `assets/images/` directory and add your app logo
3. Create `assets/lottie/` directory and add a loading animation

## Testing and Validation

### Testing VPN Functionality

1. **Server Data Retrieval**:
   - Open the app and navigate to the location screen
   - Verify that VPN servers are loaded from the API
   - Check that server information is displayed correctly

2. **VPN Connection**:
   - Select a VPN server from the list
   - Tap the connect button on the home screen
   - Verify that the VPN connection is established
   - Check that connection status is updated correctly

3. **VPN Disconnection**:
   - While connected, tap the disconnect button
   - Verify that the VPN connection is terminated
   - Check that connection status is updated correctly

4. **Network Information**:
   - Navigate to the network test screen
   - Verify that IP address and location information is displayed
   - Check that information updates when VPN is connected/disconnected

### Testing Ad Integration

1. **Interstitial Ads**:
   - Trigger an interstitial ad by connecting to VPN
   - Verify that the ad displays correctly
   - Check that the app continues to function after the ad

2. **Native Ads**:
   - Navigate to the location screen
   - Verify that native ads are displayed at the bottom
   - Check that ads load correctly

3. **Rewarded Ads**:
   - Attempt to change the app theme
   - Verify that the rewarded ad dialog appears
   - Check that the theme changes after watching the ad

## Troubleshooting

### Common Issues and Solutions

1. **VPN Connection Fails**:
   - Check that the VPN service is properly declared in AndroidManifest.xml
   - Verify that the OpenVPN library is correctly included in build.gradle
   - Ensure that the VPN configuration is correctly decoded from Base64

2. **Server List Not Loading**:
   - Check internet connectivity
   - Verify that the VPN Gate API endpoint is accessible
   - Ensure that CSV parsing is working correctly

3. **Ads Not Displaying**:
   - Verify that AdMob is properly initialized
   - Check that ad unit IDs are correct
   - Ensure that the app is properly configured for AdMob

4. **UI Issues**:
   - Check that all required assets are included
   - Verify that theme switching works correctly
   - Ensure that all screens are properly navigated

## Conclusion

This comprehensive implementation guide provides all the necessary components to integrate VPN functionality using the VPN Gate API into your Flutter app. The implementation includes:

1. **API Integration**: Fetching and processing VPN server data from VPN Gate
2. **UI Components**: Displaying server information and connection status
3. **VPN Engine**: Managing VPN connections through native Android service
4. **Ad Integration**: Implementing AdMob for monetization
5. **State Management**: Using GetX for efficient state management

By following this guide, you can create a fully functional VPN app with server selection, connection management, and network information display. The implementation maintains your existing UI structure while adding the VPN functionality from the reference codebase.


also for the speedtest drop the previous ideea that we had using ndt7 use this flutter library using async and all to show the data in realtimme and all and also after that:flutter_speed_test_plus 1.0.10 copy "flutter_speed_test_plus: ^1.0.10" to clipboard
Published 11 months ago
SDKFlutterPlatformAndroidiOS
9
Readme
Changelog
Example
Installing
Versions
Scores
Flutter Internet Speed Test Plus 
A Flutter plugin designed to measure internet download and upload speeds using widely recognized services, such as Fast.com (as the default) and Ookla's Speedtest.

Features 
Test download and upload speeds.
Default support for Fast.com API.
Option to use custom test server URLs.
Progress tracking and multiple callbacks.
Works on iOS and Android.
Screenshot 
speedTest

Getting Started 
Add the plugin to your pubspec.yaml file:

dependencies:

flutter_speed_test_plus: ^latest_version

Basic Usage 
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void startSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: true, // true by default, uses Fast.com API
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download complete: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload complete: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Test cancelled');
    },
  );
}
Advanced Usage 
You can customize the test by providing your own server URLs and file size:

import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void startCustomSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: false, // Use custom server instead of Fast.com
    downloadTestServer: 'https://your-download-server.com/testfile', // Custom download server URL
    uploadTestServer: 'https://your-upload-server.com/upload', // Custom upload server URL
    fileSize: 20, // File size in MB for testing (default is 10MB)
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download complete: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload complete: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Test cancelled');
    },
  );
}
Configuration Options 
Default Server URLs 
If no custom server URLs are provided, the plugin will use the following default URLs:

Download Servers: https://fast.com/

Upload Servers: https://fast.com/

Custom Options 
You can override the default settings with custom values:

Server URLs: Specify your own downloadTestServer and uploadTestServer.
File Size: Set the fileSize parameter (in MB) for the test. The default is 10 MB.
Callback Descriptions 
Here’s a list of all available callbacks for handling test progress and results:

onStarted: Called when the speed test starts.
onCompleted: Called with final download and upload speeds.
onProgress: Called with the test progress percentage and intermediate results.
onError: Called if an error occurs during the test.
onDefaultServerSelectionInProgress: Triggered during server selection (when useFastApi is true).
onDefaultServerSelectionDone: Triggered when server selection is complete (when useFastApi is true).
onDownloadComplete: Called when the download test is completed.
onUploadComplete: Called when the upload test is completed.
onCancel: Triggered if the test is cancelled.
Supported Platforms 
iOS
Android
Full Example 
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void runFullSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: true, // Use Fast.com by default
    downloadTestServer: 'https://mycustomdownloadserver.com/testfile',
    uploadTestServer: 'https://mycustomuploadserver.com/upload',
    fileSize: 50, // File size in MB
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download completed: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload completed: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Speed test cancelled');
    },
  );
}
9
likes
130
points
2.41k
downloads
Publisher
unverified uploader

Weekly Downloads
2024.11.28 - 2025.10.23
Metadata
A Flutter plugin to test internet download and upload speed.

Repository (GitHub)
View/report issues

Documentation
API reference

License
MIT (license)

Dependencies
connectivity_plus, flutter, http, logger, plugin_platform_interface, tuple_dart

More
Packages that depend on flutter_speed_test_plus

Packages that implement flutter_speed_test_plus




and use radial gaugae or if you can then create a custome speed idicatior using :
flutter_speed_test_plus 1.0.10 copy "flutter_speed_test_plus: ^1.0.10" to clipboard
Published 11 months ago
SDKFlutterPlatformAndroidiOS
9
Readme
Changelog
Example
Installing
Versions
Scores
Flutter Internet Speed Test Plus 
A Flutter plugin designed to measure internet download and upload speeds using widely recognized services, such as Fast.com (as the default) and Ookla's Speedtest.

Features 
Test download and upload speeds.
Default support for Fast.com API.
Option to use custom test server URLs.
Progress tracking and multiple callbacks.
Works on iOS and Android.
Screenshot 
speedTest

Getting Started 
Add the plugin to your pubspec.yaml file:

dependencies:

flutter_speed_test_plus: ^latest_version

Basic Usage 
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void startSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: true, // true by default, uses Fast.com API
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download complete: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload complete: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Test cancelled');
    },
  );
}
Advanced Usage 
You can customize the test by providing your own server URLs and file size:

import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void startCustomSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: false, // Use custom server instead of Fast.com
    downloadTestServer: 'https://your-download-server.com/testfile', // Custom download server URL
    uploadTestServer: 'https://your-upload-server.com/upload', // Custom upload server URL
    fileSize: 20, // File size in MB for testing (default is 10MB)
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download complete: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload complete: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Test cancelled');
    },
  );
}
Configuration Options 
Default Server URLs 
If no custom server URLs are provided, the plugin will use the following default URLs:

Download Servers: https://fast.com/

Upload Servers: https://fast.com/

Custom Options 
You can override the default settings with custom values:

Server URLs: Specify your own downloadTestServer and uploadTestServer.
File Size: Set the fileSize parameter (in MB) for the test. The default is 10 MB.
Callback Descriptions 
Here’s a list of all available callbacks for handling test progress and results:

onStarted: Called when the speed test starts.
onCompleted: Called with final download and upload speeds.
onProgress: Called with the test progress percentage and intermediate results.
onError: Called if an error occurs during the test.
onDefaultServerSelectionInProgress: Triggered during server selection (when useFastApi is true).
onDefaultServerSelectionDone: Triggered when server selection is complete (when useFastApi is true).
onDownloadComplete: Called when the download test is completed.
onUploadComplete: Called when the upload test is completed.
onCancel: Triggered if the test is cancelled.
Supported Platforms 
iOS
Android
Full Example 
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

void runFullSpeedTest() {
  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
    useFastApi: true, // Use Fast.com by default
    downloadTestServer: 'https://mycustomdownloadserver.com/testfile',
    uploadTestServer: 'https://mycustomuploadserver.com/upload',
    fileSize: 50, // File size in MB
    onStarted: () {
      print('Speed test started');
    },
    onCompleted: (TestResult download, TestResult upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (double percent, TestResult data) {
      print('Progress: $percent%');
    },
    onError: (String errorMessage, String speedTestError) {
      print('Error: $errorMessage');
    },
    onDownloadComplete: (TestResult data) {
      print('Download completed: ${data.speed} Mbps');
    },
    onUploadComplete: (TestResult data) {
      print('Upload completed: ${data.speed} Mbps');
    },
    onCancel: () {
      print('Speed test cancelled');
    },
  );
}
9
likes
130
points
2.41k
downloads
Publisher
unverified uploader

Weekly Downloads
2024.11.28 - 2025.10.23
Metadata
A Flutter plugin to test internet download and upload speed.

Repository (GitHub)
View/report issues

Documentation
API reference

License
MIT (license)

Dependencies
connectivity_plus, flutter, http, logger, plugin_platform_interface, tuple_dart

More
Packages that depend on flutter_speed_test_plus

Packages that implement flutter_speed_test_plus