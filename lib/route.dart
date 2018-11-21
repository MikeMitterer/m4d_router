/*
 * Copyright (c) 2018, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library route.client;

import 'package:m4d_router/url_pattern.dart';

typedef void RouteEnterCallback(final RouteEnterEvent event,
    [ void onError(final Exception exception)]
    );

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
    String toString() => "RouteEnterEvent(title: '${route.title}', pattern: '${route.urlPattern.pattern}')";
}

/// Event on error
class RouteErrorEvent extends RouteEvent {
    final Exception exception;

    RouteErrorEvent(this.exception, final String path)
        : super(path);

    @override
    String toString() => "Path: ${path} -> ${exception.toString()}";
}

class Route {
    final String title;
    final UrlPattern urlPattern;

    /// Callback
    final RouteEnterCallback onEnter;

    Route(this.title, this.urlPattern, this.onEnter);
}