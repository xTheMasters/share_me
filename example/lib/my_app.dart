import 'package:flutter/material.dart';
import 'package:share_me_example/share_me.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DMTraining',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              maintainState: false,
              builder: (_) => const ShareMeApp(),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}
