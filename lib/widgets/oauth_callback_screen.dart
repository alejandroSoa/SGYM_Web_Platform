import 'package:flutter/material.dart';
import 'package:sgym/services/InitializationService.dart';
import 'package:sgym/services/ProfileService.dart';
import '../services/UserService.dart';
import '../main.dart';
import 'dart:html' as html;

class OAuthCallbackScreen extends StatefulWidget {
  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

Future<void> _handleRedirect() async {
  final fullUrl = html.window.location.href;
  print('Full URL: $fullUrl');

  // Sacar solo la parte antes del #
  final uriBeforeHash = fullUrl.split('#').first;
  final uri = Uri.parse(uriBeforeHash);

  String? token = uri.queryParameters['access_token'];
  String? refreshToken = uri.queryParameters['refresh_token'];

  print('Access token: $token');
  print('Refresh token: $refreshToken');

  if (token != null && token.isNotEmpty) {
    await UserService.setToken(token);
    await InitializationService.markFirstTimeDone();

    final userData = await UserService.fetchUser();
    if (userData != null && userData.isNotEmpty) {
      await UserService.setUser(userData);

      final profile = await ProfileService.fetchProfile();
      if (profile != null) {
        await ProfileService.setProfile(profile);
      }
    }

    // Limpiar la URL
    html.window.history.replaceState(
      null,
      'OAuth Redirect',
      html.window.location.pathname,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainLayout()),
      );
    }
  } else {
    print("No se encontró el token en la redirección.");
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
