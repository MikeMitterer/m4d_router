// @TestOn("browser")
// integration
@TestOn("browser")
library test.integration.browser_onenter;

import 'package:test/test.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_router/router.dart';

// import 'package:logging/logging.dart';

import 'config.dart';

main() async {
    // final Logger _logger = new Logger("test.integration.browser");

    configLogging(show: Level.INFO);

    final router  = new Router();

    test('onEnter should be called for link', () {

        final callback = expectAsync1((final RouteEnterEvent event) {
            expect(event, isNotNull);
            expect(event.route.title, "Cats");
        });

        final onEnter = expectAsync1((final RouteEnterEvent event) {
            expect(event.path,"/#/cats");
        });

        router.addRoute(name: "Cats", path: new ReactPattern("/cats"), enter: callback);

        router.onEnter.listen(onEnter);

        listenAnd(router,() => router.go("Cats"));
    });

}

// - Helper --------------------------------------------------------------------------------------

