import 'package:patrol_axe/patrol_axe.dart';

import 'common.dart';

void main() {
  patrol('patrol_axe native extension ping', ($) async {
    await createApp($);

    final ping = await $.axe.ping();
    expect(ping.native, isTrue);
    expect(ping.extension, 'patrol_axe');
    expect(ping.platform, 'android');

    final scan = await $.axe.scan(scanName: 'e2e-poc');
    expect(scan.native, isTrue);
    expect(scan.extension, 'patrol_axe');
  });
}
