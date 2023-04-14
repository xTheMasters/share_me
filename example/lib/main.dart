import 'package:flutter/material.dart';
import 'package:share_me/share_me.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShareMe Example',
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

class ShareMeApp extends StatefulWidget {
  const ShareMeApp({Key? key}) : super(key: key);

  @override
  State<ShareMeApp> createState() => _ShareMeAppState();
}

class _ShareMeAppState extends State<ShareMeApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text('ShareMeApp Plugin example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  ShareMe.system(
                    title: 'Title',
                    url: 'https://themonstersapp.com/',
                    description: 'Descripcion',
                    subject: 'Subjet',
                  );
                },
                child: const Text('Share'),
              ),
              ElevatedButton(
                onPressed: () async {
                  http.Response response = await http.get(
                    Uri.parse(
                      'https://themonstersapp.com/images/bg-static.jpg',
                    ),
                  );
                  if (response.statusCode == 200) {
                    Uint8List imageData = response.bodyBytes;
                    await ShareMe.file(
                      file: imageData,
                      title: 'Compartir imagen de ejemplo',
                    );
                  }
                },
                child: const Text('Share Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
