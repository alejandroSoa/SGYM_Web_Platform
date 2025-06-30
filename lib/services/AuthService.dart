import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
    static Future<void> authenticateWithOAuth() async {
      const redirectUri = 'http://localhost:55409/#/oauth-callback';
      final authUrl = Uri.http(
        '143.110.150.81',
        '/oauth/login',
        {
          'redirect_uri': redirectUri,
          'response_type': 'token',
        },
      );

      if (!await launchUrl(authUrl, mode: LaunchMode.platformDefault)) {
        throw 'No se pudo abrir la URL de autenticación';
      }
    }
}