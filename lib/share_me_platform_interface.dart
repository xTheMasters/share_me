import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'share_me_method_channel.dart';

abstract class ShareMePlatform extends PlatformInterface {
  /// Constructs a ShareMePlatform.
  ShareMePlatform() : super(token: _token);

  static final Object _token = Object();

  static ShareMePlatform _instance = MethodChannelShareMe();

  /// The default instance of [ShareMePlatform] to use.
  ///
  /// Defaults to [MethodChannelShareMe].
  static ShareMePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShareMePlatform] when
  /// they register themselves.
  static set instance(ShareMePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
