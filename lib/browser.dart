// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library m4d_router.browser;

import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:validate/validate.dart';

import 'package:m4d_router/exceptions.dart';
import 'package:m4d_router/url_pattern.dart';
import 'package:m4d_router/route.dart';

export 'package:m4d_router/url_pattern.dart';
export 'package:m4d_router/route.dart';

typedef Handler(final String path);

typedef void EventHandler(final Event e);

final _logger = new Logger('m4d_router.browser');

void _defaultEnterCallback(final RouteEnterEvent event,
    [ void onError(final Exception exception)]) {
    
    _logger.fine(
        "Default-Callback for ${event.route.title}. "
        "(Path: ${event.path} Params: ${event.params.join(",")})"
    );
}

/// Stores a set of [UrlPattern] to [Handler] associations and provides methods
/// for calling a handler for a URL path, listening to [Window] history events,
/// and creating HTML event handlers that navigate to a URL.
class Router {
    final _logger = new Logger('m4d_router.browser.router');

    final HashMap<UrlPattern, Route> _handlers;
    final bool useFragment;

    bool _listen = false;

    StreamController<RouteEnterEvent> _onEnter;
    StreamController<RouteErrorEvent> _onError;

    /// Collects all the registered Events - helpful for downgrading
    /// Sample:
    ///     eventStreams.add(input.onFocus.listen( _onFocus));
    final List<StreamSubscription> _eventStreams = new List<StreamSubscription>();


    /// [useFragment] determines whether this Router uses pure paths with
    /// [History.pushState] or paths + fragments and [Location.assign]. The default
    /// value is null which then determines the behavior based on
    /// [History.supportsState].
    Router({final bool useFragment: true})
        : _handlers = new HashMap<UrlPattern, Route>(),
            useFragment = (useFragment == null) ? !History.supportsState : useFragment;

    /// Registers a function that will be invoked when the router handles a URL
    /// that matches [pattern].
    ///
    /// [name] must be unique
    void addRoute({final String name, final path,
        final RouteEnterCallback enter: _defaultEnterCallback }) {

        Validate.notBlank(name);
        Validate.notNull(path);
        Validate.notNull(enter);

        // Name must be unique
        final patternInList = _findByName(name);

        if(patternInList != null) {
            throw new ArgumentError(
                "$name must be unique in pattern-list but was "
                "already defined for ${patternInList.pattern}");
        }

        final Route route = (path is UrlPattern)
            ? new Route(name, path, enter)
            : new Route(name, new UrlPattern(path.toString()), enter);

        _logger.finest('addHandler ${route.title} -> ${route.urlPattern.pattern}');
        _handlers[route.urlPattern] = route;
    }

    /// Listens for window history events and invokes the router. On older
    /// browsers the hashChange event is used instead.
    void listen({final bool ignoreClick: false}) {
        _logger.finest('listen ignoreClick=$ignoreClick useFragment=$useFragment');
        if (_listen) {
            throw new StateError('listen should be called once.');
        }

        _listen = true;
        if (useFragment) {
            _eventStreams.add(
                window.onHashChange.listen((_) {
                final path = '${window.location.pathname}${window.location.hash}';
                _logger.finest('onHashChange handle($path)');
                return _handle(path);
            }));
            _handle('${window.location.pathname}${window.location.hash}');
        }
        else {
            _eventStreams.add(
                window.onPopState.listen((_) {
                final path = '${window.location.pathname}${window.location.hash}';
                _logger.finest('onPopState handle($path)');
                _handle(path);
            }));
        }

        if (!ignoreClick) {
            _eventStreams.add(
                window.onClick.listen((final MouseEvent event) {
                if (event.target is AnchorElement) {
                    final AnchorElement anchor = event.target;
                    if (anchor.host == window.location.host) {
                        event.preventDefault();

                        final fragment = (anchor.hash == '') ? '' : '${anchor.hash}';

                        // TODO: Maybe pass title (anchor.title) as optional param
                        gotoPath("${anchor.pathname}$fragment");
                    }
                }
            }));
        }
    }

    /// Searches a route by its [name]
    void go(final String name, { final List<String> params = const <String>[] }) {
        Validate.notBlank(name);
        final pattern = _findByName(name);

        if(pattern == null) {
            throw new ArgumentError('No route defined for "$name"');
        }

        gotoUrl(pattern, params);
    }

    /// Navigates the browser to the path produced by [urlPattern] with [params] by calling
    /// [History.pushState], then invokes the handler associated with [urlPattern].
    ///
    /// On older browsers [Location.assign] is used instead with the fragment
    /// version of the UrlPattern.
    void gotoUrl(final UrlPattern urlPattern, final List<String> params) {
        final route = _handlers.containsKey(urlPattern) ? _handlers[urlPattern]
            : throw new ArgumentError('Unknown URL pattern: $urlPattern');

        final fixedPath = urlPattern.expand(params, useFragment: useFragment);

        _go(fixedPath, route.title);
        _fire(new RouteEnterEvent(_handlers[urlPattern], fixedPath,  params));
    }

    /// Goes to specific path
    ///
    /// [testing] is quite a hack and is used only for unit-test
    /// Without this flag the browser hangs in unit-tests
    void gotoPath(final String path, { final bool testing: false }) {
        final urlPattern = _getUrl(path);
        final route = urlPattern != null ? _handlers[urlPattern]
            : throw new ArgumentError('No URL pattern found for : $path');

        _go(path, route.title);

        // If useFragment, onHashChange will call handle for us.
        if (!_listen || !useFragment || testing) {
            final List<String> params = urlPattern.parse(path)
                .map((final String param) => Uri.decodeFull(param)).toList();

            final fixedPath = urlPattern.expand(params, useFragment: useFragment);

            _fire(new RouteEnterEvent(_handlers[urlPattern], fixedPath,  params));
        }
    }

    Stream<RouteEnterEvent> get onEnter {
        if (_onEnter == null) {
            _onEnter = new StreamController<RouteEnterEvent>.broadcast(onCancel: () => _onEnter = null);
        }
        return _onEnter.stream;
    }

    Stream<RouteErrorEvent> get onError {
        if (_onError == null) {
            _onError = new StreamController<RouteErrorEvent>.broadcast(onCancel: () => _onError = null);
        }
        return _onError.stream;
    }

    /// Cancels all the registered streams
    ///
    /// It should not be necessary to use this function in your program.
    /// It's used for testing.
    ///
    ///     final router  = new Router();
    ///
    ///     group('browser', () {
    ///         setUp(() {
    ///             router.downgrade();
    ///         });
    ///
    ///     test('go should route to cats', () {
    ///
    ///         ...
    ///         // Your test
    ///     });
    ///
    void downgrade() {
        _onEnter?.onCancel();
        _onError?.onCancel();
        _eventStreams.forEach((final StreamSubscription stream) => stream?.cancel());
        _eventStreams.clear();
        _listen = false;
        _handlers.clear();
    }

    // - private -------------------------------------------------------------------------------------

    ///  Finds a matching [UrlPattern] added with [addRoute], parses the path
    ///  and invokes the associated callback.
    ///
    ///  This method does not perform any navigation, [go] should be used for that.
    ///  This method is used to invoke a handler after some other code navigates the
    ///  window, such as [listen].
    ///
    ///  If the UrlPattern contains a fragment (#), the handler is always called
    ///  with the path version of the URL by converting the # to a /.
    void _handle(final String path) {
        final url = _getUrl(path);
        if (url != null) {
            final List<String> params = url.parse(path)
                .map((final String param) => Uri.decodeFull(param)).toList();

            final fixedPath = url.expand(params, useFragment: useFragment);

            _fire(new RouteEnterEvent(_handlers[url], fixedPath,  params));
        }
    }

    UrlPattern _getUrl(final String path) {
        var matches = _handlers.keys.where((final UrlPattern pattern) => pattern.matches(path));
        if (matches.isEmpty) {

            final exception = new RouteNotFoundException("No handler found for $path");
            if(true == _onError?.hasListener) {
                _fire(new RouteErrorEvent(exception, path));
                return null;
            } else {
                throw exception;
            }
        }
        return matches.first;
    }

    void _go(final String path, String title) {
        title = (title == null) ? '' : title;
        if (useFragment) {
            window.location.assign(path);
            (window.document as HtmlDocument).title = title;
        }
        else {
            window.history.pushState(null, title, path);
        }
    }

    /// Searches for [UrlPattern] by [name]
    UrlPattern _findByName(final String name) {
        return _handlers.keys.firstWhere((final UrlPattern pattern)
        => _handlers[pattern].title == name,orElse: () => null);
    }

    void _fire(final RouteEvent event) {
        // _logger.info("onChange: ${_onChange}, hasListeners: ${_onChange ?.hasListener}");
        // print(event);

        if(event is RouteErrorEvent) {
            if (true == _onError?.hasListener) {
                _onError.add(event);
            }
        }
        else if(event is RouteEnterEvent) {
            if (true == _onEnter?.hasListener) {
                _onEnter.add(event);
            }

            // Call callback defined with route
            event.route.onEnter(event, (final Exception exception) {
                _onError?.add(RouteErrorEvent(exception, event.path));
            });
        }
        else {
            throw ArgumentError("Undefined RouteEvent! ($event)");
        }
    }
}
