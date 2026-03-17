import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/providers/super_admin_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, CommunityProvider>(
          create: (context) => CommunityProvider(Provider.of<UserProvider>(context, listen: false)),
          update: (context, userProvider, communityProvider) => communityProvider!..update(userProvider),
        ),
        ChangeNotifierProvider(create: (context) => SuperAdminProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
