import 'package:flutter/material.dart';
import 'package:share_me/share_me.dart';

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
          child: ElevatedButton(
            onPressed: () {
              ShareMe.system(
                title: 'Title',
                url: 'https://themonstersapp.com/',
                description: 'Descripcion',
                subject: 'Subjet',
              );
            },
            child: const Text('Share'),
          ),
        ),
      ),
    );
  }
}
