// @TestOn("browser")
// integration
@TestOn("browser")
library test.integration.browser_gotourl;

import 'package:test/test.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_router/router.dart';

// import 'package:logging/logging.dart';

import 'config.dart';

main() async {
    // final Logger _logger = new Logger("test.integration.browser");

    configLogging(show: Level.INFO);

    final router  = new Router();
    test('gotoUrl should receive params', () {

        final callback = expectAsync2((final RouteEnterEvent event,void onError(final Exception exception)) {
            expect(event, isNotNull);
            expect(event.route.title, "Specific cat");
            expect(event.params.first, "Grumpy cat");
        });

        final pattern = new ReactPattern(r'/cats/(\w+)');
        router.addRoute(name: "Specific cat", path: pattern,
            enter: callback);

        listenAnd(router,() => router.gotoUrl(pattern,[ "Grumpy cat"]));
    });
}


