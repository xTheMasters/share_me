import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_me/share_me.dart';

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
  void shareMe(String url) async {
    final String urlImage = url;
    final byteData =
        await NetworkAssetBundle(Uri.parse(urlImage)).load(urlImage);

    final imageData = byteData.buffer.asUint8List();
    final name = urlImage.split('/').last;
    const mimeType = 'image/jpeg';
    XFile.fromData(imageData, name: name, mimeType: mimeType);
    ShareMe.file(
      name: name,
      mimeType: mimeType,
      imageData: imageData,
    );
  }

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
                onPressed: () {
                  shareMe('https://themonstersapp.com/images/bg-static.jpg');
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
