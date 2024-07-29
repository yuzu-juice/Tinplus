import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('アカウント設定'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // アカウント設定ページへの遷移をここに実装
            },
          ),
          ListTile(
            title: const Text('通知設定'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // 通知設定ページへの遷移をここに実装
            },
          ),
          ListTile(
            title: const Text('プライバシーポリシー'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // プライバシーポリシーページへの遷移をここに実装
            },
          ),
          ListTile(
            title: const Text('アプリについて'),
            leading: const Icon(Icons.info),
            onTap: () {
              // アプリ情報ページへの遷移をここに実装
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('ログアウト'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
