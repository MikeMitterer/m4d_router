// @TestOn("browser")
// integration
@TestOn("browser")
library test.integration.browser;

import 'package:test/test.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_router/router.dart';

// import 'package:logging/logging.dart';

import 'config.dart';

main() async {
    // final Logger _logger = new Logger("test.integration.browser");

    configLogging(show: Level.INFO);

    final router  = new Router();

    test('go should route to cats', () {

        final callback = expectAsync1((final RouteEnterEvent event) {
            expect(event, isNotNull);
            expect(event.route.title, "Cats");
        });

        router.addRoute(name: "Cats", path: "/cats",enter: callback);
        listenAnd(router,() => router.go("Cats"));
    });

}

