import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_entry_screen.dart';
import 'screens/explore_filter_screen.dart';
import 'screens/my_screen.dart';
import 'screens/my_profile_edit_screen.dart';
import 'screens/my_interests_edit_screen.dart';
import 'screens/my_notification_settings_screen.dart';
import 'screens/my_terms_screen.dart';
import 'screens/my_withdrawal_screen.dart';
import 'screens/saved_policies_screen.dart';
import 'screens/policy_detail_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: kIsWeb, // 웹에서만 활성화
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Yuno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF111317),
        primaryColor: Colors.white,
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(
          selectedInterests: [],
          profileData: {},
        ),
        '/explore': (context) => ExploreEntryScreen(),
        '/explore_filter': (context) => ExploreFilterScreen(),
        '/saved': (context) => SavedPoliciesScreen(),
        '/my': (context) => MyScreen(),
        '/my_profile_edit': (context) => MyProfileEditScreen(),
        '/my_interests_edit': (context) => MyInterestsEditScreen(),
        '/my_notification_settings': (context) => MyNotificationSettingsScreen(),
        '/my_terms': (context) => MyTermsScreen(),
        '/my_withdrawal': (context) => MyWithdrawalScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/policy_detail') {
          final policyId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => PolicyDetailScreen(policyId: policyId),
          );
        }
        return null;
      },
    );
  }
}
