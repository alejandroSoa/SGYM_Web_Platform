import 'package:flutter/material.dart';
import 'dart:html' as html;

class SubscriptionWebView extends StatelessWidget {
  final String subscriptionUrl;

  const SubscriptionWebView({
    super.key,
    required this.subscriptionUrl,
  });

  void _openSubscriptionPage(BuildContext context) {
    html.window.open(subscriptionUrl, '_blank');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción - SGym'),
        backgroundColor: const Color(0xFF7012DA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_new, size: 64, color: Color(0xFF7012DA)),
            const SizedBox(height: 24),
            const Text(
              'Haz clic en el botón para abrir la página de suscripción en una nueva pestaña.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFF7012DA)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir Suscripción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7012DA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _openSubscriptionPage(context),
            ),
          ],
        ),
      ),
    );
  }
}
