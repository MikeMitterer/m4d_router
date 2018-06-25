library route.client;

import 'package:route/url_pattern.dart';

typedef void RouteEnterCallback(final RouteEnterEvent event);

/// Route enter event.
abstract class RouteEvent {
    final String path;

    RouteEvent(this.path);

    @override
    String toString() => "RouteEvent(${path})";
}

class RouteEnterEvent extends RouteEvent {
    final Route route;
    final List<String> params;

    RouteEnterEvent(this.route,final String path, this.params) : super(path);

    @override
    String toString() => "Title: ${route.title} -> ${route.urlPattern.pattern}";
}

/// Event on error
class RouteErrorEvent extends RouteEvent {
    final Error error;

    RouteErrorEvent(this.error, final String path)
        : super(path);

    @override
    String toString() => "Path: ${path} -> ${error.toString()}";
}

class Route {
    final String title;
    final UrlPattern urlPattern;

    /// Callback
    final RouteEnterCallback onEnter;

    Route(this.title, this.urlPattern, this.onEnter);
}