// @TestOn("browser")
// integration
@TestOn("browser")
library test.integration.browser;

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

    group('browser', () {
        setUp(() {
            router.downgrade();
        });

        test('gotoUrl should receive params', () {

            final callback = expectAsync1((final RouteEnterEvent event) {
                expect(event, isNotNull);
                expect(event.route.title, "Specific cat");
                expect(event.params.first, "Grumpy cat");
            });

            final pattern = new ReactPattern(r'/cats/(\w+)');
            router.addRoute(name: "Specific cat", path: pattern,
                enter: callback);

            _listenAnd(router,() => router.gotoUrl(pattern,[ "Grumpy cat"]));
        });
    });
    // End of 'browser' group
}

// - Helper --------------------------------------------------------------------------------------

/// Wraps RouteNotFoundException
void _listenAnd(final Router router, void callback()) {
    try {
        router.listen();
    } on RouteNotFoundException catch(exception) {
        expect(exception.message, startsWith("No handler found for /"));
        callback();
    }
}
