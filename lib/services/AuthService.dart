import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class AuthService {
    static Future<void> authenticateWithOAuth() async {
      const redirectUri = 'http://localhost:60359/#/oauth-callback';
      final authUrl = Uri.http(
        '143.110.150.81',
        '/oauth/login',
        {
          'redirect_uri': redirectUri,
          'response_type': 'token',
        },
      );

      print(['Data', html.window.location.href = authUrl.toString()]);
    }
}