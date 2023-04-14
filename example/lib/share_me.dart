import 'package:flutter/material.dart';
import 'package:share_me/share_me.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

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
                  http.Response response = await http.get(Uri.parse(
                      'https://content-cocina.lecturas.com/medio/2018/07/19/macedonia-con-almendras_6515aca7_800x800.jpg'));
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
