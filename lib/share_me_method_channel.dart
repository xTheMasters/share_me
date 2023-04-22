import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'share_me_platform_interface.dart';

/// An implementation of [ShareMePlatform] that uses method channels.
class MethodChannelShareMe extends ShareMePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('share_me');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
