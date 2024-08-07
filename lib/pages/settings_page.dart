import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      safePrint('Could not log out ☠️: $e');
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('ログアウト'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => logout(context),
          ),
          ListTile(
            title: const Text('利用規約'),
            leading: const Icon(Icons.description),
            onTap: () =>
                _launchURL('https://harvestful.tokyo/tinplus/term_of_use.html'),
          ),
          ListTile(
            title: const Text('プライバシーポリシー'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () => _launchURL(
                'https://harvestful.tokyo/tinplus/privacy_policy.html'),
          ),
        ],
      ),
    );
  }
}
