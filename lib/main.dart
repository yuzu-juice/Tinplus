import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/conversation_repository.dart';
import 'services/shared_prefs_service.dart';
import 'pages/home_page.dart';

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
