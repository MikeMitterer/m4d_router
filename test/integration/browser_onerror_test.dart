// @TestOn("browser")
// integration
@TestOn("browser")
library test.integration.browser_onerror;

import 'package:test/test.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_router/router.dart';
import 'package:m4d_router/exceptions.dart';

// import 'package:logging/logging.dart';

main() async {
    // final Logger _logger = new Logger("test.integration.browser");

    configLogging(show: Level.INFO);
    //await saveDefaultCredentials();

    final router  = new Router();

    test('onError should be called for root', () {

        final callback = expectAsync1((final RouteEnterEvent event) {
            expect(event, isNotNull);
            expect(event.route.title, "Cats");
        });

        final onError = expectAsync1((final RouteErrorEvent event) {
            expect((event.exception as RouteNotFoundException).message,
                startsWith("No handler found for /"));
        });

        router.addRoute(name: "Cats", path: new ReactPattern("/cats"), enter: callback);

        router.onError.listen(onError);

        router.listen(); // no route defined for / - calls onError
        router.go("Cats");
    });
}

// - Helper --------------------------------------------------------------------------------------

