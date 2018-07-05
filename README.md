# Material4Dart router

m4d_router is a client routing library for Dart. It helps make building
single-page web apps and using `HttpServer` easier.

<p align="center">
    <img src="https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/m4d_router.gif" alt="Preview" />
</p>

## Installation

Add this package to your pubspec.yaml file:

    dependencies:
      m4d_router: any

Then, run `pub get` to download and link in the package.

## Example

Live: [m4d_router.example.mikemitterer.at](http://m4d_router.example.mikemitterer.at/)  
Source on [GitHub](https://github.com/MikeMitterer/m4d_router/tree/route_version/example/browser)

```dart
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

        ..addRoute(name: 'Specific cat', path: new ReactPattern(r'/cats/(\w+)'),
            enter: (final RouteEnterEvent event) {
                _log("${event.route.title}: ${event.params.join(",")}");
                _logger.info("Path: ${event.path} Params: ${event.params.join(",")}");
                if(event.params.first.toLowerCase() == "grumpy") {
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
```

### UrlPattern

Route is built around `UrlPattern` a class that matches, parses and produces
URLs. A `UrlPattern` is similar to a regex, but constrained so that it is
_reversible_, given a `UrlPattern` and a set of arguments you can produce the
URL that when parsed returns those same arguments. This is important for keeping
the URL space for your app flexible so that you can change a URL for a resource
in one place and keep your app working.

Route lets you use the same URL patterns for client-side and server-side
routing. Just define a library containing all your URLs.

As an example, consider a blog with a home page and an article page. The article
URL has the form /article/1234. We want to show articles without reloading the
page.

## Routing

On the browser, there is a `Router` class that associates `UrlPattern`s
to handlers. Given a URL, the router finds a pattern that matches, and invokes
its handler. The handlers
are then responsible for rendering the appropriate changes to the page.
