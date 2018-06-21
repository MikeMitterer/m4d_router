library route.client;

import 'dart:async';

import 'package:route/url_pattern.dart';

//typedef void RoutePreEnterEventHandler(RoutePreEnterEvent event);
//typedef void RouteEnterEventHandler(RouteEnterEvent event);
//typedef void RoutePreLeaveEventHandler(RoutePreLeaveEvent event);
//typedef void RouteLeaveEventHandler(RouteLeaveEvent event);

typedef void RouteEnterEventHandler(final RouteEvent event);

/**
 * Route enter or leave event.
 */
class RouteEvent {
    final Route route;

    RouteEvent(this.route);

    @override
    String toString() => "Title: ${route.title} -> ${route.urlPattern.pattern}";
}

class Route {
    final String title;
    final UrlPattern urlPattern;

    final RouteEnterEventHandler onEnter;

    Route(this.title, this.urlPattern, this.onEnter);
}