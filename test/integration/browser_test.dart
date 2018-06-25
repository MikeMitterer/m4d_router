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

        test('go should route to cats', () {

            final callback = expectAsync1((final RouteEnterEvent event) {
                expect(event, isNotNull);
                expect(event.route.title, "Cats");
            });

            router.addRoute(name: "Cats", path: "/cats",enter: callback);
            _listenAnd(router,() => router.go("Cats"));
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

        test('gotoPath should fetch params', () {

            final callback = expectAsync1((final RouteEnterEvent event) {
                expect(event, isNotNull);
                expect(event.route.title, "Specific cat");
                expect(event.params.first, "Grumpy cat");
            });

            // % - accepts e.g. %20 (space)
            final pattern = new ReactPattern(r'/cats/([\w%]+)');
            router.addRoute(name: "Specific cat", path: pattern,
                enter: callback);

            _listenAnd(router,() => router.gotoPath(Uri.encodeFull("/#/cats/Grumpy cat")));
        });

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

            _listenAnd(router,() => router.go("Cats"));
        });

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
        },skip: true);

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
