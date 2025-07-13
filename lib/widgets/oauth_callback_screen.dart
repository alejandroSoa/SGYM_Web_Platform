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
    final uri = Uri.base;
    print('URI base: $uri');
    print('Query parameters: ${uri.queryParameters}');

    // Extraer el token de los parámetros de la query
    String? token = uri.queryParameters['access_token'];
    String? refreshToken = uri.queryParameters['refresh_token'];

    if (token != null && token.isNotEmpty) {
      await UserService.setToken(token);
      //await UserService.fetchUser();
      await InitializationService.markFirstTimeDone();

      final userData = await UserService.fetchUser();
      if (userData != null && userData is List && userData.isNotEmpty) {
        final user = userData[0];
        await UserService.setUser(user.toJson());

        final profile = await ProfileService.fetchProfile();
        if (profile != null) {
          await ProfileService.setProfile(profile);
        }
        print('Perfil guardado: ${profile?.toJson()}');
        print('Usuario guardado: ${user.toJson()}');
      }

      html.window.history.replaceState(
        null, 
        'OAuth Redirect', 
        html.window.location.pathname
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
