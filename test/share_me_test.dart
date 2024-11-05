import 'package:flutter_test/flutter_test.dart';
import 'package:share_me/share_me.dart';
import 'package:share_me/share_me_platform_interface.dart';
import 'package:share_me/share_me_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockShareMePlatform
    with MockPlatformInterfaceMixin
    implements ShareMePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ShareMePlatform initialPlatform = ShareMePlatform.instance;

  test('$MethodChannelShareMe is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelShareMe>());
  });

  test('getPlatformVersion', () async {
    ShareMe shareMePlugin = ShareMe();
    MockShareMePlatform fakePlatform = MockShareMePlatform();
    ShareMePlatform.instance = fakePlatform;

    expect(await shareMePlugin.getPlatformVersion(), '42');
  });
}
