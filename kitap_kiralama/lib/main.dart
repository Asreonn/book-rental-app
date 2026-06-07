import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kitap_kiralama/app/admin_app.dart';
import 'package:kitap_kiralama/app/app_config.dart';
import 'package:kitap_kiralama/app/book_store_app.dart';
import 'package:kitap_kiralama/firebase_options.dart';
import 'package:kitap_kiralama/screens/auth_page.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kitap Dukkani',
      theme: buildAppTheme(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppPalette.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final User? user = snap.data;
          if (user == null) {
            return const AuthPage();
          }
          if (user.email == kAdminEmail) {
            return const AdminApp();
          }
          return const BookStoreApp();
        },
      ),
    );
  }
}
