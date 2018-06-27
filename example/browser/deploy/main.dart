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
                _showImage("https://dummyimage.com/400x300/ff0000/000000.png&text=Test");
            })

        ..addRoute(name: 'Kitten', path: new ReactPattern('/kitten'),
            enter: (final RouteEnterEvent event) {
                _log(event.route.title);
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                _showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG-20150820-WA0000.jpg");
            })

        ..addRoute(name: 'Specific cat', path: new ReactPattern(r'/cats/([\w%]+)'),
            enter: (final RouteEnterEvent event) {
                _log("${event.route.title}: ${event.params.join(",")}");
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                if(event.params.first.toLowerCase() == "grumpy cat") {
                    _showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG_20140811_032111.jpg");
                } else {
                    _showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG_20151224_182316.jpg");
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