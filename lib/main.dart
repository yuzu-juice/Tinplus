import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/record_page.dart' as record_page;
import 'pages/graph_page.dart';
import 'pages/report_page.dart' as report_page;
import 'pages/settings_page.dart'; // 追加
import 'services/conversation_repository.dart';
import 'services/shared_prefs_service.dart';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'amplify_outputs.dart';
import 'auth/custom_resolvers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAmplify();
  final sharedPrefsService = SharedPrefsService();
  final conversationRepository = ConversationRepository(sharedPrefsService);
  await conversationRepository.loadData();

  runApp(
    Provider<ConversationRepository>(
      create: (_) => conversationRepository,
      child: const MyApp(),
    ),
  );
}

Future<void> configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured Amplify 🎉');
  } on Exception catch (e) {
    safePrint('Could not configure Amplify ☠️: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      stringResolver: stringResolver,
      child: MaterialApp(
        title: 'Tinplus🔥',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'sans-serif',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.teal,
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.grey,
          ),
        ),
        builder: Authenticator.builder(),
        home: Consumer<ConversationRepository>(
          builder: (context, repository, _) => HomePage(repository: repository),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final ConversationRepository repository;

  const HomePage({super.key, required this.repository});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tinplus🔥')),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          record_page.RecordPage(repository: widget.repository),
          const GraphPage(),
          report_page.ReportPage(repository: widget.repository),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '記録する'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'レポート'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
