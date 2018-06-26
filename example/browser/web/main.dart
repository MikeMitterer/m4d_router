import 'dart:html' as dom;
import 'package:m4d_router/router.dart';
import 'package:console_log_handler/console_log_handler.dart';

final Logger _logger = new Logger('router.example.browser');

void main() {
    final router = new Router();

    configLogging(show: Level.INFO);
    _configRouter(router);

    dom.querySelector('#output').text = 'Your Dart app is running.';
}

void _configRouter(final Router router ) {

    router
        ..addRoute(name: "Test I", path: new UrlPattern('/#/test'),
            enter: (final RouteEnterEvent event) {
                _log(event.route.title);
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                _showImage("https://upload.wikimedia.org/wikipedia/commons/1/11/Test-Logo.svg");
            })

        ..addRoute(name: 'Cats', path: new ReactPattern('/cats'),
            enter: (final RouteEnterEvent event) {
                _log(event.route.title);
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                _showImage("https://i1.wp.com/www.oxygen.ie/wp-content/uploads/2016/11/main_1500.jpg?resize=750%2C400");
            })

        ..addRoute(name: 'Specific cat', path: new ReactPattern(r'/cats/([\w%]+)'),
            enter: (final RouteEnterEvent event) {
                _log("${event.route.title}: ${event.params.join(",")}");
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                if(event.params.first.toLowerCase() == "grumpy cat") {
                    _showImage("https://pbs.twimg.com/media/CsW0pmxUsAAuvEN.jpg");
                } else {
                    _showImage("https://catzone-tcwebsites.netdna-ssl.com/wp-content/uploads/2014/09/453768-cats-cute.jpg");
                }
            })

        ..addRoute(name: "Google for cats", path: new ReactPattern('/google'),
            enter: (final RouteEnterEvent event) {
                _log(event.route.title);
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                _showImage("https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Chrome_icon_%28September_2014%29.svg");
            })
    ;

    // optional
    router.onEnter.listen((final RouteEnterEvent event) {
        _logger.info("RoutEvent ${event.route.title} -> ${event.route.urlPattern.pattern}");
    });

    // optional
    router.onError.listen((final RouteErrorEvent event) {
        _logger.info("RouteErrorEvent ${event.exception}");
    });

    router.listen(); // Start listening
}

void _log(final String logMessage) {
    final logElement = dom.querySelector("#log") as dom.UListElement;
    logElement.append(new dom.LIElement()..text = logMessage);
}

void _showImage(final String url) {
    final img = dom.querySelector("img") as dom.ImageElement;
    img.src = url;
}